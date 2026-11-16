import { loadPrompts, savePrompts, newId } from './store.js';

const $ = (id) => document.getElementById(id);
let prompts = [];
let editingId = null;

async function persist() {
  try {
    await savePrompts(prompts);
    $('msg').textContent = '';
  } catch (e) {
    $('msg').textContent = `保存失敗（同期容量の上限かも）: ${e.message}`;
  }
  render();
}

function render() {
  const list = $('list');
  list.replaceChildren();
  prompts.forEach((p, i) => {
    const li = document.createElement('li');
    const title = document.createElement('span');
    title.className = 'title';
    title.textContent = p.title;
    title.title = p.body;
    title.onclick = async () => {
      await navigator.clipboard.writeText(p.body);
      li.classList.add('copied');
      setTimeout(() => window.close(), 400);
    };
    li.append(title);
    const btn = (label, fn, tip) => {
      const b = document.createElement('button');
      b.textContent = label;
      b.title = tip;
      b.onclick = fn;
      li.append(b);
    };
    btn('↑', () => move(i, -1), '優先度を上げる');
    btn('↓', () => move(i, 1), '優先度を下げる');
    btn('編', () => openForm(p), '編集');
    btn('×', () => { if (confirm(`「${p.title}」を削除？`)) { prompts.splice(i, 1); persist(); } }, '削除');
    list.append(li);
  });
}

function move(i, d) {
  const j = i + d;
  if (j < 0 || j >= prompts.length) return;
  [prompts[i], prompts[j]] = [prompts[j], prompts[i]];
  persist();
}

function openForm(p) {
  editingId = p?.id ?? null;
  $('ftitle').value = p?.title ?? '';
  $('fbody').value = p?.body ?? '';
  $('form').classList.add('open');
  $('ftitle').focus();
}

$('add').onclick = () => openForm(null);
$('cancel').onclick = () => $('form').classList.remove('open');
$('form').onsubmit = (e) => {
  e.preventDefault();
  const data = { title: $('ftitle').value.trim(), body: $('fbody').value };
  if (editingId) Object.assign(prompts.find((p) => p.id === editingId), data);
  else prompts.push({ id: newId(), ...data });
  $('form').classList.remove('open');
  persist();
};

$('export').onclick = () => {
  const blob = new Blob([JSON.stringify(prompts, null, 2)], { type: 'application/json' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'prompt-clip.json';
  a.click();
};
$('import').onclick = () => $('file').click();
$('file').onchange = async (e) => {
  const file = e.target.files[0];
  if (!file) return;
  try {
    const items = JSON.parse(await file.text());
    if (!Array.isArray(items)) throw new Error('配列ではありません');
    prompts = items.map((p) => ({ id: p.id ?? newId(), title: String(p.title ?? ''), body: String(p.body ?? '') }));
    persist();
  } catch (err) {
    $('msg').textContent = `読み込み失敗: ${err.message}`;
  }
};

loadPrompts().then((p) => { prompts = p; render(); });
