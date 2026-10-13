/**
 * ページ内で Step 列を順に実行する。
 * chrome.scripting.executeScript の func として直列化して注入するため、
 * この関数の外側の識別子を参照してはならない。先に pagekit.js を同じタブへ注入しておくこと。
 * 失敗したらページ右下にトーストを出して止まる。
 * @param {import('./steps.js').Step[]} steps
 * @param {string} name トーストに出すアクション名
 * @returns {Promise<{ ok: true } | { ok: false, error: string }>}
 */
export async function runSteps(steps, name) {
  const TIMEOUT_MS = 10000;
  const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
  const { query } = globalThis.hopPage;

  const waitFor = async (selector) => {
    const deadline = Date.now() + TIMEOUT_MS;
    while (Date.now() < deadline) {
      const el = query(selector);
      if (el) return el;
      await sleep(100);
    }
    throw new Error(`要素が見つかりません: ${selector}`);
  };

  // フレームワークは value の setter を差し替えて変更を検知するので、素の setter を呼んでからイベントを送る。
  const setValue = (el, value) => {
    const proto = [HTMLTextAreaElement, HTMLSelectElement, HTMLInputElement].find((c) => el instanceof c)?.prototype;
    if (!proto) throw new Error(`入力欄ではありません: <${el.localName}>`);
    Object.getOwnPropertyDescriptor(proto, 'value').set.call(el, value);
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  };

  // press の送り先。ウィンドウにフォーカスが無いと focus() が効かず activeElement が body のままになるので、
  // 直前に click / type した要素を覚えておく。
  let last = null;
  const exec = async (step) => {
    switch (step.op) {
      case 'sleep':
        return sleep(step.ms);
      case 'wait':
        return waitFor(step.selector);
      case 'click': {
        last = await waitFor(step.selector);
        last.scrollIntoView({ block: 'center' });
        return last.click();
      }
      case 'type': {
        last = await waitFor(step.selector);
        last.focus();
        return setValue(last, step.value);
      }
      case 'press': {
        const el = last ?? document.activeElement ?? document.body;
        for (const type of ['keydown', 'keypress', 'keyup']) {
          el.dispatchEvent(new KeyboardEvent(type, { key: step.key, bubbles: true, cancelable: true }));
        }
      }
    }
  };

  const toast = (message) => {
    const el = document.createElement('div');
    el.textContent = message;
    el.style.cssText = 'position:fixed;right:16px;bottom:16px;z-index:2147483647;max-width:420px;padding:10px 14px;'
      + 'background:#b3261e;color:#fff;font:13px/1.5 system-ui,sans-serif;border-radius:8px;box-shadow:0 4px 16px rgba(0,0,0,.3)';
    document.body.append(el);
    setTimeout(() => el.remove(), 8000);
  };

  for (const step of steps) {
    try {
      await exec(step);
    } catch (e) {
      const error = `[${name}] ${step.line} 行目: ${e.message}`;
      toast(error);
      return { ok: false, error };
    }
  }
  return { ok: true };
}
