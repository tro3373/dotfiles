import { groupActions, loadActions, normalize, saveActions, upsert } from './actions.js';
import { parseSteps, STEPS_HELP } from './steps.js';

const $ = (selector) => document.querySelector(selector);
const views = { list: $('#list-view'), edit: $('#edit-view'), json: $('#json-view') };
const field = (view, name) => views[view].elements.namedItem(name);
const EDIT_FIELDS = ['name', 'group', 'url', 'target', 'steps'];
const UNGROUPED_LABEL = 'その他';

/** @type {import('./actions.js').Action[]} */
let actions = [];
/** @type {string[]} */
let collapsed = [];
/** キーボードで選べる (畳まれていない) 項目。selected はこの添字。 */
let visible = [];
let selected = 0;
let editingId = null;

const persist = (next) => {
  actions = next;
  return saveActions(actions);
};

function show(name) {
  for (const [key, el] of Object.entries(views)) el.hidden = key !== name;
}

function faviconUrl(pageUrl) {
  const url = new URL(chrome.runtime.getURL('/_favicon/'));
  url.searchParams.set('pageUrl', pageUrl);
  url.searchParams.set('size', '32');
  return url.href;
}

function renderList() {
  const sections = groupActions(actions, $('#search').value, collapsed);
  // グループが 1 つも無ければ見出しは邪魔なだけなので出さない。
  const showHeaders = sections.some((s) => s.name !== '');
  visible = sections.filter((s) => !s.collapsed).flatMap((s) => s.items);
  selected = Math.min(selected, Math.max(visible.length - 1, 0));

  $('#items').replaceChildren(...sections.flatMap((section) => [
    ...(showHeaders ? [renderSection(section)] : []),
    ...(section.collapsed ? [] : section.items.map(renderItem)),
  ]));
  $('#items .selected')?.scrollIntoView({ block: 'nearest' });
  $('#empty').hidden = actions.length > 0;
}

function renderSection(section) {
  const li = $('#section').content.firstElementChild.cloneNode(true);
  li.querySelector('.caret').textContent = section.collapsed ? '▶' : '▼';
  li.querySelector('.group-name').textContent = section.name || UNGROUPED_LABEL;
  li.querySelector('.count').textContent = section.collapsed ? `(${section.items.length})` : '';
  li.addEventListener('click', () => toggleSection(section.name));
  return li;
}

function renderItem(action) {
  const li = $('#item').content.firstElementChild.cloneNode(true);
  li.classList.toggle('selected', visible[selected] === action);
  li.querySelector('img').src = faviconUrl(action.url);
  li.querySelector('.name').textContent = action.name;
  li.querySelector('.host').textContent = new URL(action.url).host;
  li.querySelector('.tag').hidden = action.steps.trim() === '';
  li.addEventListener('click', () => run(action));
  li.querySelector('.edit').addEventListener('click', (e) => {
    e.stopPropagation();
    openEdit(action);
  });
  return li;
}

async function toggleSection(name) {
  collapsed = collapsed.includes(name) ? collapsed.filter((n) => n !== name) : [...collapsed, name];
  await chrome.storage.local.set({ collapsed });
  renderList();
}

function backToList() {
  show('list');
  renderList();
  $('#search').focus();
}

const activeTab = async () => (await chrome.tabs.query({ active: true, currentWindow: true }))[0];

async function run(action) {
  await chrome.runtime.sendMessage({ type: 'run', action, tabId: (await activeTab()).id });
  window.close();
}

function openEdit(action) {
  editingId = action.id ?? null;
  for (const name of EDIT_FIELDS) field('edit', name).value = action[name];
  $('#groups').replaceChildren(
    ...[...new Set(actions.map((a) => a.group))].filter(Boolean).map((g) => Object.assign(document.createElement('option'), { value: g })),
  );
  $('#edit-error').textContent = '';
  $('#delete').hidden = editingId === null;
  $('#delete').textContent = '削除';
  show('edit');
  field('edit', 'name').focus();
}

/** 編集画面の入力からアクションを作る。自動実行の書式が不正ならエラーを表示して null を返す。 */
function actionFromForm() {
  const data = Object.fromEntries(new FormData(views.edit));
  try {
    parseSteps(data.steps);
  } catch (err) {
    $('#edit-error').textContent = err.message;
    return null;
  }
  return { id: editingId ?? crypto.randomUUID(), ...data, group: data.group.trim() };
}

$('#search').addEventListener('input', () => {
  selected = 0;
  renderList();
});

$('#search').addEventListener('keydown', (e) => {
  const n = visible.length;
  if (n === 0) return;
  switch (e.key) {
    case 'ArrowDown':
    case 'ArrowUp':
      e.preventDefault();
      selected = (selected + (e.key === 'ArrowDown' ? 1 : -1) + n) % n;
      return renderList();
    case 'Enter':
      return run(visible[selected]);
  }
});

$('#add').addEventListener('click', async () => {
  const tab = await activeTab();
  openEdit({ name: tab.title, group: '', url: tab.url, target: 'new', steps: '' });
});

$('#delete').addEventListener('click', async (e) => {
  if (e.target.textContent === '削除') {
    e.target.textContent = 'もう一度押すと削除';
    return;
  }
  await persist(actions.filter((a) => a.id !== editingId));
  backToList();
});

$('#record').addEventListener('click', async () => {
  if (!views.edit.reportValidity()) return;
  const draft = actionFromForm();
  if (!draft) return;
  await chrome.runtime.sendMessage({ type: 'record-start', tabId: (await activeTab()).id, draft });
  window.close();
});

views.edit.addEventListener('submit', async (e) => {
  e.preventDefault();
  const action = actionFromForm();
  if (!action) return;
  await persist(upsert(actions, action));
  backToList();
});

$('#json').addEventListener('click', () => {
  field('json', 'json').value = JSON.stringify(actions, null, 2);
  $('#json-error').textContent = '';
  $('#copy').textContent = 'コピー';
  show('json');
});

$('#copy').addEventListener('click', async (e) => {
  await navigator.clipboard.writeText(field('json', 'json').value);
  e.target.textContent = 'コピーしました';
});

views.json.addEventListener('submit', async (e) => {
  e.preventDefault();
  try {
    await persist(normalize(JSON.parse(field('json', 'json').value)));
  } catch (err) {
    $('#json-error').textContent = err.message;
    return;
  }
  backToList();
});

for (const button of document.querySelectorAll('.cancel')) button.addEventListener('click', backToList);

field('edit', 'steps').placeholder = STEPS_HELP;
actions = await loadActions();
collapsed = (await chrome.storage.local.get('collapsed')).collapsed ?? [];

// 録画を保存した直後は、その結果を確かめられるよう編集画面から始める。
const { reopen } = await chrome.storage.session.get('reopen');
await chrome.storage.session.remove('reopen');
const recorded = actions.find((a) => a.id === reopen);
recorded ? openEdit(recorded) : backToList();
