import { test } from 'node:test';
import assert from 'node:assert/strict';
import { groupActions, normalize, upsert } from './actions.js';

const a = (id, group, name = id) => ({ id, name, group, url: `https://${id}.example/`, target: 'new', steps: '' });
const shape = (sections) => sections.map((s) => [s.name, s.collapsed, s.items.map((i) => i.id)]);

test('グループは初出順、グループ無しは末尾', () => {
  const actions = [a('1', ''), a('2', 'fs'), a('3', 'mon'), a('4', 'fs')];
  assert.deepEqual(shape(groupActions(actions, '', [])), [
    ['fs', false, ['2', '4']],
    ['mon', false, ['3']],
    ['', false, ['1']],
  ]);
});

test('畳んだグループは collapsed、検索中は畳みを無視し一致 0 件のグループを消す', () => {
  const actions = [a('1', 'fs', 'users'), a('2', 'fs', 'orders'), a('3', 'mon', 'grafana')];
  assert.deepEqual(shape(groupActions(actions, '', ['fs'])), [['fs', true, ['1', '2']], ['mon', false, ['3']]]);
  assert.deepEqual(shape(groupActions(actions, 'USER', ['fs'])), [['fs', false, ['1']]]);
});

test('検索はグループ名にも当たる', () => {
  assert.deepEqual(shape(groupActions([a('1', 'Firestore'), a('2', 'mon')], 'fire', [])), [['Firestore', false, ['1']]]);
});

test('upsert は同じ id を置き換え、新規は先頭に足す', () => {
  const list = [a('1', ''), a('2', '')];
  assert.deepEqual(upsert(list, a('2', 'x')).map((i) => [i.id, i.group]), [['1', ''], ['2', 'x']]);
  assert.deepEqual(upsert(list, a('3', '')).map((i) => i.id), ['3', '1', '2']);
});

test('normalize は省略項目を既定値で埋める', () => {
  const [got] = normalize([{ name: 'n', url: 'https://x.example/' }]);
  assert.equal(typeof got.id, 'string');
  assert.deepEqual({ ...got, id: '' }, { id: '', name: 'n', group: '', url: 'https://x.example/', target: 'new', steps: '' });
});

for (const [raw, msg] of [
  [{}, /配列/],
  [[{ url: 'https://x/' }], /1 件目: name/],
  [[{ name: 'n', url: 'nope' }], /url/],
  [[{ name: 'n', url: 'https://x/', target: 'side' }], /target/],
  [[{ name: 'n', url: 'https://x/', steps: 'foo x' }], /1 件目: 1 行目: 不明なコマンド/],
]) {
  test(`normalize は不正を弾く: ${msg}`, () => assert.throws(() => normalize(raw), msg));
}
