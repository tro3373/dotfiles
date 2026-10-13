/**
 * @typedef {{ op: 'sleep', ms: number, line: number }
 *   | { op: 'wait' | 'click', selector: string, line: number }
 *   | { op: 'type', selector: string, value: string, line: number }
 *   | { op: 'press', key: string, line: number }} Step
 */

/** 自動実行欄の書式見本。popup の placeholder に使う。 */
export const STEPS_HELP = `# 1 行 1 コマンド。selector は CSS か text:表示文字列
wait 1000
wait text:フィルタ
click text:フィルタ
type input[type=text] | status
press Enter`;

/**
 * 自動実行の DSL を Step 列に変換する。空行と # で始まる行は無視する。
 * - wait <ms> / wait <selector> : 待機 / 要素が現れるまで待つ
 * - click <selector>
 * - type <selector> | <value>    : input/textarea に値を入れる
 * - press <key>                  : 直前に click / type した要素 (無ければフォーカス中の要素) に KeyboardEvent を送る
 * @param {string} src
 * @returns {Step[]}
 * @throws {Error} 不正な行があれば、行番号付きのメッセージで投げる
 */
export function parseSteps(src) {
  return src
    .split('\n')
    .map((raw, i) => ({ text: raw.trim(), line: i + 1 }))
    .filter(({ text }) => text !== '' && !text.startsWith('#'))
    .map(parseLine);
}

function parseLine({ text, line }) {
  const [, cmd, arg] = text.match(/^(\S+)\s*(.*)$/);
  const fail = (msg) => new Error(`${line} 行目: ${msg}`);
  if (arg === '') throw fail(`${cmd} に引数がありません`);

  switch (cmd) {
    case 'wait':
      return /^\d+$/.test(arg) ? { op: 'sleep', ms: Number(arg), line } : { op: 'wait', selector: arg, line };
    case 'click':
      return { op: 'click', selector: arg, line };
    case 'type': {
      const m = arg.match(/^(.*?)\s+\|\s?(.*)$/);
      if (!m) throw fail('type は "type <selector> | <value>" の形式です');
      return { op: 'type', selector: m[1], value: m[2], line };
    }
    case 'press':
      return { op: 'press', key: arg, line };
    default:
      throw fail(`不明なコマンド: ${cmd}`);
  }
}
