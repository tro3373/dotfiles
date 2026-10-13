import { parseSteps } from './steps.js';

/**
 * @typedef {{ id: string, name: string, group: string, url: string, target: 'new' | 'current', steps: string }} Action
 */

export const TARGETS = ['new', 'current'];

/** @returns {Promise<Action[]>} */
export const loadActions = async () => (await chrome.storage.local.get('actions')).actions ?? [];

/** @param {Action[]} actions */
export const saveActions = (actions) => chrome.storage.local.set({ actions });

/** id が一致すれば置き換え、無ければ先頭に足す。 */
export function upsert(actions, action) {
  const exists = actions.some((a) => a.id === action.id);
  return exists ? actions.map((a) => (a.id === action.id ? action : a)) : [action, ...actions];
}

/**
 * 一覧の表示単位に分ける。グループは actions 内の初出順に並べ、グループ無し ('') は末尾に置く。
 * 検索中は畳みを無視して一致したものを全部出す。一致が 0 件のグループは出さない。
 * @param {Action[]} actions
 * @param {string} query グループ名・名前・URL への部分一致 (大文字小文字は区別しない)
 * @param {string[]} collapsed 畳んでいるグループ名
 * @returns {{ name: string, collapsed: boolean, items: Action[] }[]}
 */
export function groupActions(actions, query, collapsed) {
  const q = query.trim().toLowerCase();
  const hit = (a) => `${a.group} ${a.name} ${a.url}`.toLowerCase().includes(q);
  const names = [...new Set(actions.map((a) => a.group))].sort((x, y) => (x === '') - (y === ''));
  return names
    .map((name) => ({
      name,
      collapsed: q === '' && collapsed.includes(name),
      items: actions.filter((a) => a.group === name && hit(a)),
    }))
    .filter((section) => section.items.length > 0);
}

/**
 * JSON 一括編集の内容を検証し、保存する形に揃える。id が無ければ振る。
 * @throws {Error} 何件目のどの項目が不正かをメッセージに含める
 */
export function normalize(raw) {
  if (!Array.isArray(raw)) throw new Error('配列で書いてください');
  return raw.map((a, i) => {
    const fail = (msg) => new Error(`${i + 1} 件目: ${msg}`);
    if (typeof a?.name !== 'string' || a.name === '') throw fail('name が必要です');
    if (!URL.canParse(a.url)) throw fail('url が不正です');
    const group = a.group ?? '';
    if (typeof group !== 'string') throw fail('group は文字列です');
    const target = a.target ?? 'new';
    if (!TARGETS.includes(target)) throw fail(`target は ${TARGETS.join(' / ')} のどれかです`);
    const steps = a.steps ?? '';
    if (typeof steps !== 'string') throw fail('steps は文字列です');
    try {
      parseSteps(steps);
    } catch (e) {
      throw fail(e.message);
    }
    return { id: a.id ?? crypto.randomUUID(), name: a.name, group, url: a.url, target, steps };
  });
}
