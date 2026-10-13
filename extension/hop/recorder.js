// 録画用。pagekit.js の後に classic script として注入する。
// ページを読み込み直すたびに background が注入し直すので、同じ文書への 2 回目の注入は何もしない。
(() => {
  if (globalThis.hopRecorderActive) return;
  globalThis.hopRecorderActive = true;

  const { selectorFor, stepLine } = globalThis.hopPage;
  const NON_TEXT_TYPES = new Set(['checkbox', 'radio', 'button', 'submit', 'reset', 'file', 'image', 'range', 'color']);
  const RECORDED_KEYS = new Set(['Enter', 'Escape']);
  const isTextField = (el) => el instanceof HTMLTextAreaElement
    || (el instanceof HTMLInputElement && !NON_TEXT_TYPES.has(el.type));

  const send = (msg) => chrome.runtime.sendMessage(msg);

  // Trusted Types を強制するページ (Google 系のコンソール) では innerHTML が使えないので、要素を組み立てる。
  const h = (tag, props, ...children) => {
    const el = Object.assign(document.createElement(tag), props);
    el.append(...children);
    return el;
  };
  const style = h('style', {}, `
    .bar { display:flex; align-items:center; gap:8px; padding:8px 10px; border-radius:10px;
      background:#202124; color:#e8eaed; font:13px/1.4 system-ui,sans-serif; box-shadow:0 4px 16px rgba(0,0,0,.35) }
    .dot { width:10px; height:10px; border-radius:50%; background:#ea4335; animation:blink 1s infinite }
    @keyframes blink { 50% { opacity:.3 } }
    button { font:inherit; padding:3px 10px; border-radius:6px; border:1px solid #5f6368; background:none; color:inherit; cursor:pointer }
    button.save { background:#8ab4f8; border-color:#8ab4f8; color:#202124 }
    .warn { max-width:320px; margin-top:6px; padding:6px 10px; border-radius:8px; background:#fbbc04; color:#202124;
      font:12px/1.4 system-ui,sans-serif }`);
  const label = h('span', {}, 'Hop 録画中 0 手');
  const saveButton = h('button', { className: 'save' }, '保存');
  const cancelButton = h('button', {}, '取消');
  const warn = h('div', { className: 'warn', hidden: true },
    'ページが読み込み直されました。再生は 1 ページの中でしか続かないので、ここより前の手順は別のアクションに分けてください。');
  const host = h('div');
  host.style.cssText = 'position:fixed;top:12px;right:12px;z-index:2147483647';
  host.attachShadow({ mode: 'closed' })
    .append(style, h('div', { className: 'bar' }, h('span', { className: 'dot' }), label, saveButton, cancelButton), warn);
  const setCount = (count) => (label.textContent = `Hop 録画中 ${count} 手`);

  // 文字入力は 1 打鍵ごとに記録せず、次の操作の直前に最終値を 1 手として記録する。
  let pending = null;
  let queue = Promise.resolve();
  const record = (step) => {
    queue = queue.then(async () => setCount((await send({ type: 'record-step', line: stepLine(step) })).count));
    return queue;
  };
  const flush = () => {
    if (!pending) return;
    record({ op: 'type', selector: pending.selector, value: pending.value });
    pending = null;
  };

  const fromBar = (e) => e.composedPath().includes(host);
  const handlers = {
    click: (e) => {
      if (!e.isTrusted || fromBar(e)) return;
      const { el, selector } = selectorFor(e.target);
      if (isTextField(el) || el instanceof HTMLSelectElement) return;
      flush();
      record({ op: 'click', selector });
    },
    input: (e) => {
      if (!e.isTrusted || !isTextField(e.target)) return;
      if (pending?.el !== e.target) flush();
      pending = { el: e.target, selector: selectorFor(e.target).selector, value: e.target.value };
    },
    change: (e) => {
      if (!e.isTrusted || !(e.target instanceof HTMLSelectElement)) return;
      flush();
      record({ op: 'type', selector: selectorFor(e.target).selector, value: e.target.value });
    },
    keydown: (e) => {
      if (!e.isTrusted || fromBar(e) || !RECORDED_KEYS.has(e.key)) return;
      flush();
      record({ op: 'press', key: e.key });
    },
  };
  for (const [type, fn] of Object.entries(handlers)) window.addEventListener(type, fn, true);

  const stop = async (save) => {
    flush();
    await queue;
    for (const [type, fn] of Object.entries(handlers)) window.removeEventListener(type, fn, true);
    await send({ type: 'record-stop', save });
    globalThis.hopRecorderActive = false;
    host.remove();
  };
  saveButton.addEventListener('click', () => stop(true));
  cancelButton.addEventListener('click', () => stop(false));

  document.documentElement.append(host);
  send({ type: 'record-status' }).then(({ count, crossedPage }) => {
    setCount(count);
    warn.hidden = !crossedPage;
  });
})();
