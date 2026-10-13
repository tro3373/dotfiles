import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseSteps, STEPS_HELP } from './steps.js';

test('各コマンドを Step に変換し、空行とコメントは無視する', () => {
  const src = `
# comment
wait 500
wait div.list > span
click text:絞り込み
type input[name="q"] | a | b
type #q |
press Enter`;
  assert.deepEqual(parseSteps(src), [
    { op: 'sleep', ms: 500, line: 3 },
    { op: 'wait', selector: 'div.list > span', line: 4 },
    { op: 'click', selector: 'text:絞り込み', line: 5 },
    { op: 'type', selector: 'input[name="q"]', value: 'a | b', line: 6 },
    { op: 'type', selector: '#q', value: '', line: 7 },
    { op: 'press', key: 'Enter', line: 8 },
  ]);
});

test('書式見本はそのまま解析できる', () => {
  assert.equal(parseSteps(STEPS_HELP).length, 5);
});

for (const [src, msg] of [
  ['click', /1 行目: click に引数がありません/],
  ['\nfoo x', /2 行目: 不明なコマンド: foo/],
  ['type #q', /1 行目: type は/],
]) {
  test(`不正な行は行番号付きで失敗する: ${JSON.stringify(src)}`, () => {
    assert.throws(() => parseSteps(src), msg);
  });
}
