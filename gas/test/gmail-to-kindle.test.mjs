// gas/gmail-to-kindle.gs のユニットテスト。
// .gs を vm コンテキストへロードし、GAS サービス (GmailApp / PropertiesService /
// Utilities / Session) をフェイクに差し替えて振る舞いを検証する。
//
//   node --test gas/test/
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { createContext, runInContext } from 'node:vm';

const here = dirname(fileURLToPath(import.meta.url));
const source = readFileSync(join(here, '..', 'gmail-to-kindle.gs'), 'utf8');

const DAY_MS = 24 * 60 * 60 * 1000;
const KINDLE_EMAIL = 'me@kindle.com';
const SENDER = 'news@example.com';

// 指定した属性を持つ GmailMessage フェイク。
function fakeMessage({
  id = 'msg1',
  from = `Example News <${SENDER}>`,
  subject = 'Weekly News',
  body = '<p>hello</p>',
  plainBody = 'hello',
  ageMs = 0,
  fails = false,
} = {}) {
  return {
    fails,
    getId: () => id,
    getFrom: () => from,
    getSubject: () => subject,
    getBody: () => body,
    getPlainBody: () => plainBody,
    getDate: () => new Date(Date.now() - ageMs),
  };
}

// messages を持つ GmailThread フェイク。付与されたラベルは labels に残る。
function fakeThread(messages) {
  const labels = [];
  return {
    labels,
    getMessages: () => messages,
    addLabel: (label) => labels.push(label.getName()),
  };
}

// .gs を隔離コンテキストで評価し、公開関数とフェイクの記録を返す。
function load({ properties = { KINDLE_EMAIL, SENDERS: SENDER }, threads = [] } = {}) {
  const searched = [];
  const sent = [];
  const created = [];
  const triggers = { deleted: [], created: [] };

  const sandbox = {
    console: { log() {}, warn() {}, error() {} },
    PropertiesService: {
      getScriptProperties: () => ({
        getProperty: (key) => properties[key] ?? null,
      }),
    },
    GmailApp: {
      search: (query, start, max) => {
        searched.push({ query, start, max });
        return threads;
      },
      getUserLabelByName: (name) => (created.includes(name) ? { getName: () => name } : null),
      createLabel: (name) => {
        created.push(name);
        return { getName: () => name };
      },
      sendEmail: (to, subject, body, options) => {
        // 送信対象メッセージが fails なら例外を投げる (blob 経由で判定)。
        const blob = options.attachments[0];
        if (blob.fails) {
          throw new Error('send failed');
        }
        sent.push({ to, subject, body, options, blob });
      },
    },
    Utilities: {
      newBlob: (_data, contentType, name) => ({
        contentType,
        name,
        content: '',
        charset: '',
        fails: false,
        setDataFromString(content, charset) {
          this.content = content;
          this.charset = charset;
          return this;
        },
      }),
      formatDate: (date, _tz, _format) => `formatted:${date.toISOString()}`,
    },
    Session: { getScriptTimeZone: () => 'Asia/Tokyo' },
    ScriptApp: {
      getProjectTriggers: () => [
        { getHandlerFunction: () => 'main' },
        { getHandlerFunction: () => 'otherJob' },
      ],
      deleteTrigger: (trigger) => triggers.deleted.push(trigger.getHandlerFunction()),
      newTrigger: (handler) => {
        const spec = { handler, minutes: 0 };
        const builder = {
          timeBased: () => builder,
          everyMinutes: (minutes) => {
            spec.minutes = minutes;
            return builder;
          },
          create: () => triggers.created.push(spec),
        };
        return builder;
      },
    },
  };

  createContext(sandbox);
  runInContext(source, sandbox);
  return {
    gs: sandbox,
    config: runInContext('CONFIG', sandbox),
    searched,
    sent,
    created,
    triggers,
  };
}

// sendEmail 失敗を再現するため、fails 付きメッセージの blob へフラグを伝播させる。
// Utilities.newBlob は件名しか受け取らないので、件名で失敗対象を見分ける。
function loadWithFailingSubject(failingSubject, opts) {
  const loaded = load(opts);
  const newBlob = loaded.gs.Utilities.newBlob;
  loaded.gs.Utilities.newBlob = (data, contentType, name) => {
    const blob = newBlob(data, contentType, name);
    blob.fails = name.startsWith(failingSubject);
    return blob;
  };
  return loaded;
}

test('KINDLE_EMAIL 未設定なら main は明示エラーで停止する', () => {
  const { gs } = load({ properties: { SENDERS: SENDER } });
  assert.throws(() => gs.main(), /KINDLE_EMAIL/);
});

test('SENDERS 未設定なら main は明示エラーで停止する', () => {
  const { gs } = load({ properties: { KINDLE_EMAIL } });
  assert.throws(() => gs.main(), /SENDERS/);
});

test('検索クエリは送信元 OR 条件・期間・処理済みラベル除外を含む', () => {
  const { gs, config } = load();
  const query = gs.buildSearchQuery_(['a@example.com', 'b@example.com']);

  assert.match(query, /from:\("a@example\.com" OR "b@example\.com"\)/);
  assert.match(query, new RegExp(`newer_than:${config.SEARCH_WINDOW_DAYS}d`));
  assert.match(query, new RegExp(`-label:"${config.PROCESSED_LABEL}"`));
});

test('main は処理済みラベルを除外したクエリで検索する', () => {
  const { gs, searched, config } = load();

  gs.main();

  assert.equal(searched.length, 1);
  assert.ok(searched[0].query.includes(`-label:"${config.PROCESSED_LABEL}"`));
  assert.equal(searched[0].max, config.MAX_THREADS);
});

test('対象送信元でないメッセージは送信しない', () => {
  const thread = fakeThread([fakeMessage({ from: 'spam@other.com', subject: 'Spam' })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.deepEqual(sent, []);
  assert.deepEqual(thread.labels, []);
});

test('表示名に対象アドレスを詐称したメールは送信しない', () => {
  const thread = fakeThread([fakeMessage({ from: `"${SENDER}" <evil@attacker.com>` })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.deepEqual(sent, []);
});

test('対象アドレスを接頭辞に持つ別ドメインのメールは送信しない', () => {
  const thread = fakeThread([fakeMessage({ from: `Newsletter <${SENDER}.evil.jp>` })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.deepEqual(sent, []);
});

test('アドレスのみの From ヘッダも対象送信元として扱う', () => {
  const thread = fakeThread([fakeMessage({ from: SENDER })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.equal(sent.length, 1);
});

test('検索ウィンドウより古いメッセージは送信しない', () => {
  const thread = fakeThread([fakeMessage({ subject: 'Old', ageMs: 3 * DAY_MS })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.deepEqual(sent, []);
});

test('全メッセージ送信成功したスレッドに処理済みラベルを付与する', () => {
  const thread = fakeThread([fakeMessage({ subject: 'A' }), fakeMessage({ subject: 'B' })]);
  const { gs, sent, config } = load({ threads: [thread] });

  gs.main();

  assert.deepEqual(
    sent.map((mail) => mail.subject),
    ['A', 'B'],
  );
  assert.deepEqual(thread.labels, [config.PROCESSED_LABEL]);
});

test('送信失敗したスレッドはラベル未付与 (次回実行で再送)', () => {
  const thread = fakeThread([fakeMessage({ subject: 'Boom' })]);
  const { gs, sent } = loadWithFailingSubject('Boom', { threads: [thread] });

  gs.main();

  assert.deepEqual(sent, []);
  assert.deepEqual(thread.labels, []);
});

test('プレーンテキスト本文は段落・改行を HTML へ変換する', () => {
  const thread = fakeThread([
    fakeMessage({ body: '', plainBody: 'first line\nsecond line\n\nnext paragraph' }),
  ]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  const html = sent[0].blob.content;
  assert.match(html, /<p>first line<br>second line<\/p>/);
  assert.match(html, /<p>next paragraph<\/p>/);
});

test('HTML 本文はそのまま埋め込む', () => {
  const body = '<div><h1>Headline</h1><p>body text</p></div>';
  const thread = fakeThread([fakeMessage({ body })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.ok(sent[0].blob.content.includes(body));
});

test('件名・送信元の HTML 特殊文字をエスケープする', () => {
  const thread = fakeThread([
    fakeMessage({ subject: '<script> & "quoted"', from: `News & Co <${SENDER}>` }),
  ]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  const html = sent[0].blob.content;
  assert.match(html, /<title>&lt;script&gt; &amp; &quot;quoted&quot;<\/title>/);
  assert.ok(html.includes(`News &amp; Co &lt;${SENDER}&gt;`));
  assert.ok(!html.includes('<script>'));
});

test('添付ファイル名は不正文字を除去し .html を付与する', () => {
  const thread = fakeThread([fakeMessage({ subject: 'a/b:c*d?"e<f>g|h' })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.equal(sent[0].blob.name, 'a b c d e f g h.html');
});

test('空件名は既定の件名になる', () => {
  const thread = fakeThread([fakeMessage({ subject: '' })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.equal(sent[0].subject, '(no subject)');
  assert.equal(sent[0].blob.name, '(no subject).html');
});

test('不正文字だけの件名は既定のファイル名になる', () => {
  const thread = fakeThread([fakeMessage({ subject: '///' })]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.equal(sent[0].blob.name, 'newsletter.html');
});

test('添付は text/html + UTF-8 で Kindle アドレス宛へ送信する', () => {
  const thread = fakeThread([fakeMessage()]);
  const { gs, sent } = load({ threads: [thread] });

  gs.main();

  assert.equal(sent[0].to, KINDLE_EMAIL);
  assert.equal(sent[0].blob.contentType, 'text/html');
  assert.equal(sent[0].blob.charset, 'UTF-8');
  assert.match(sent[0].blob.content, /^<!DOCTYPE html>/);
});

test('testSendLatest は処理済みラベルを除外せず、最初の対象スレッドだけ送る', () => {
  const skipped = fakeThread([fakeMessage({ from: 'spam@other.com' })]);
  const target = fakeThread([fakeMessage({ subject: 'A' })]);
  const rest = fakeThread([fakeMessage({ subject: 'B' })]);
  const { gs, sent, searched, config } = load({ threads: [skipped, target, rest] });

  gs.testSendLatest();

  assert.ok(!searched[0].query.includes('-label:'));
  assert.deepEqual(
    sent.map((mail) => mail.subject),
    ['A'],
  );
  assert.deepEqual(target.labels, [config.PROCESSED_LABEL]);
  assert.deepEqual(rest.labels, []);
});

test('setupTrigger は既存の main トリガのみ消して 1 本作り直す', () => {
  const { gs, triggers, config } = load();

  gs.setupTrigger();

  assert.deepEqual(triggers.deleted, ['main']);
  assert.deepEqual(triggers.created, [
    { handler: 'main', minutes: config.TRIGGER_INTERVAL_MINUTES },
  ]);
});
