// ページに注入する部品。chrome.scripting.executeScript({ files }) で classic script として入れ、
// globalThis.hopPage から使う。再生 (runner) と録画 (recorder) が同じ探し方をしないと、
// 録画した selector が再生で別の要素に当たる。
globalThis.hopPage = (() => {
  const TEXT_PREFIX = 'text:';
  const MAX_TEXT_LENGTH = 40;
  const ACTIONABLE = 'a, button, input, select, textarea, label, '
    + '[role=button], [role=link], [role=menuitem], [role=option], [role=tab], [role=checkbox], [role=switch]';

  /** 数字や : を含む id は自動採番 (mat-input-3, :r1:) とみなす。再訪で変わるので selector に使わない。 */
  const isStableId = (id) => /^[A-Za-z][\w-]*$/.test(id) && !/\d/.test(id);

  // DSL は 1 行 1 コマンドで、type は " | " で値と分けるので、改行と | を含む値は使えない。
  const usable = (v) => typeof v === 'string' && v !== '' && !/[\n|]/.test(v);
  const attr = (tag, name, value) => `${tag}[${name}="${value.replace(/["\\]/g, '\\$&')}"]`;

  /**
   * 要素の属性から selector の候補を、壊れにくい順に返す。一意かどうかは見ない。
   * @param {{ tag: string, id?: string, testId?: string, name?: string, ariaLabel?: string,
   *   placeholder?: string, texts?: string[] }} info texts は外側の要素の文字列から順に
   * @returns {string[]}
   */
  function candidates(info) {
    return [
      usable(info.id) && isStableId(info.id) && `#${info.id}`,
      usable(info.testId) && attr('', 'data-testid', info.testId),
      usable(info.name) && attr(info.tag, 'name', info.name),
      usable(info.ariaLabel) && attr(info.tag, 'aria-label', info.ariaLabel),
      usable(info.placeholder) && attr(info.tag, 'placeholder', info.placeholder),
      ...(info.texts ?? []).map((t) => usable(t) && t.length <= MAX_TEXT_LENGTH && `${TEXT_PREFIX}${t}`),
    ].filter(Boolean);
  }

  /** Step を DSL の 1 行にする。steps.js の parseSteps の逆。 */
  function stepLine(step) {
    switch (step.op) {
      case 'click':
        return `click ${step.selector}`;
      case 'type':
        return `type ${step.selector} | ${step.value}`;
      case 'press':
        return `press ${step.key}`;
    }
  }

  const visible = (el) => el.getClientRects().length > 0;

  /** CSS selector か text:<部分一致> で要素を 1 つ探す。text: は一致する最も内側の見えている要素。 */
  function query(selector) {
    if (!selector.startsWith(TEXT_PREFIX)) return document.querySelector(selector);
    const text = selector.slice(TEXT_PREFIX.length);
    const contains = (el) => el.textContent.includes(text);
    return [...document.querySelectorAll('body *')]
      .find((el) => contains(el) && visible(el) && ![...el.children].some(contains)) ?? null;
  }

  /** selector で探したとき、el (またはその中身) に当たるか。 */
  function pointsTo(selector, el) {
    try {
      if (selector.startsWith(TEXT_PREFIX)) return el.contains(query(selector));
      const all = document.querySelectorAll(selector);
      return all.length === 1 && all[0] === el;
    } catch {
      return false;
    }
  }

  function cssPath(el) {
    const parts = [];
    for (let node = el; node && node !== document.body; node = node.parentElement) {
      if (node.id && isStableId(node.id)) return [`#${node.id}`, ...parts].join(' > ');
      const tag = node.localName;
      const nth = [...node.parentElement.children].filter((s) => s.localName === tag).indexOf(node) + 1;
      parts.unshift(`${tag}:nth-of-type(${nth})`);
    }
    return ['body', ...parts].join(' > ');
  }

  const ownText = (el) => (el.matches('input, select, textarea') ? '' : el.textContent.trim());

  /**
   * 操作された要素から、記録する要素とその selector を決める。
   * アイコン内の span などを押しても、外側のボタンを記録する。
   * @param {Element} target イベントの target
   * @returns {{ el: Element, selector: string }}
   */
  function selectorFor(target) {
    const el = target.closest(ACTIONABLE) ?? target;
    const found = candidates({
      tag: el.localName,
      id: el.id,
      testId: el.getAttribute('data-testid') ?? undefined,
      name: el.getAttribute('name') ?? undefined,
      ariaLabel: el.getAttribute('aria-label') ?? undefined,
      placeholder: el.getAttribute('placeholder') ?? undefined,
      texts: [ownText(el), ownText(target)],
    }).find((s) => pointsTo(s, el));
    return { el, selector: found ?? cssPath(el) };
  }

  return { candidates, stepLine, query, selectorFor };
})();
