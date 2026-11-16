// chrome.storage.sync に保存する（Googleアカウントで端末間同期される）
// sync は1項目8KB・合計100KBの制限があるので、プロンプトは1件1キーで持つ
// 並び順 = 優先度。先頭が優先度1位

const ORDER_KEY = 'order';
const key = (id) => `p:${id}`;

export async function loadPrompts() {
  const all = await chrome.storage.sync.get(null);
  const order = all[ORDER_KEY] ?? [];
  return order.map((id) => all[key(id)]).filter(Boolean);
}

export async function savePrompts(prompts) {
  const before = await chrome.storage.sync.get(null);
  const next = { [ORDER_KEY]: prompts.map((p) => p.id) };
  for (const p of prompts) next[key(p.id)] = p;
  await chrome.storage.sync.set(next);
  const stale = Object.keys(before).filter((k) => k.startsWith('p:') && !(k in next));
  if (stale.length) await chrome.storage.sync.remove(stale);
}

export const newId = () => Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
