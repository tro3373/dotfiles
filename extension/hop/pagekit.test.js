import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseSteps } from './steps.js';
import './pagekit.js';

const { candidates, stepLine } = globalThis.hopPage;

test('候補は id => data-testid => name => aria-label => placeholder => 文字列 の順', () => {
  assert.deepEqual(
    candidates({
      tag: 'input', id: 'search', testId: 't', name: 'q', ariaLabel: 'Search', placeholder: 'Find', texts: ['Go'],
    }),
    ['#search', '[data-testid="t"]', 'input[name="q"]', 'input[aria-label="Search"]', 'input[placeholder="Find"]', 'text:Go'],
  );
});

for (const id of ['mat-input-3', ':r1:', 'ember123', '1abc']) {
  test(`自動採番らしい id は使わない: ${id}`, () => {
    assert.deepEqual(candidates({ tag: 'input', id }), []);
  });
}

test('改行・| を含む値、長すぎる文字列は使わない', () => {
  assert.deepEqual(
    candidates({ tag: 'button', ariaLabel: 'a | b', texts: ['line1\nline2', 'x'.repeat(41), 'Filter'] }),
    ['text:Filter'],
  );
});

test('属性値の " と \\ はエスケープする', () => {
  assert.deepEqual(candidates({ tag: 'a', ariaLabel: 'say "hi" \\o/' }), ['a[aria-label="say \\"hi\\" \\\\o/"]']);
});

test('stepLine の出力は parseSteps で元に戻る', () => {
  const steps = [
    { op: 'click', selector: 'text:Add filter' },
    { op: 'type', selector: 'input[aria-label="Value"]', value: 'active user' },
    { op: 'press', key: 'Enter' },
  ];
  const parsed = parseSteps(steps.map(stepLine).join('\n')).map(({ line, ...s }) => s);
  assert.deepEqual(parsed, steps);
});
