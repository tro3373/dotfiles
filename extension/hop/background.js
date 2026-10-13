import { loadActions, saveActions, upsert } from './actions.js';
import { parseSteps } from './steps.js';
import { runSteps } from './runner.js';

const RECORDING = 'recording';
const PAGE_SCRIPTS = ['pagekit.js'];

/**
 * @typedef {{ tabId: number, draft: import('./actions.js').Action, lines: string[], crossedPage: boolean }} Recording
 * 録画中の状態。service worker は止まることがあるので storage.session に置く。
 */
const getRecording = async () => (await chrome.storage.session.get(RECORDING))[RECORDING];
const setRecording = (rec) => chrome.storage.session.set({ [RECORDING]: rec });

const handlers = {
  // popup は返事を受けたら閉じる。実行の完了は待たせない。
  run: ({ action, tabId }) => {
    run(action, tabId).catch((e) => console.error(`[${action.name}]`, e));
  },
  'record-start': ({ tabId, draft }) => startRecording(tabId, draft),
  'record-step': async ({ line }) => {
    const rec = await getRecording();
    rec.lines.push(line);
    await setRecording(rec);
    return { count: rec.lines.length };
  },
  'record-status': async () => {
    const rec = await getRecording();
    return { count: rec.lines.length, crossedPage: rec.crossedPage };
  },
  'record-stop': ({ save }) => stopRecording(save),
};

chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  const handler = handlers[msg.type];
  if (!handler) return;
  Promise.resolve(handler(msg)).then(sendResponse, (e) => {
    console.error(msg.type, e);
    sendResponse({ error: e.message });
  });
  return true;
});

/**
 * アクションの URL を開き、自動実行があれば読み込み完了後に注入する。
 * @param {import('./actions.js').Action} action
 * @param {number} currentTabId target が current のときに遷移させるタブ
 */
async function run(action, currentTabId) {
  const steps = parseSteps(action.steps);
  const tab = action.target === 'current'
    ? await chrome.tabs.update(currentTabId, { url: action.url })
    : await chrome.tabs.create({ url: action.url });
  if (steps.length === 0) return;

  await waitForLoad(tab.id);
  await chrome.scripting.executeScript({ target: { tabId: tab.id }, files: PAGE_SCRIPTS });
  await chrome.scripting.executeScript({ target: { tabId: tab.id }, func: runSteps, args: [steps, action.name] });
}

/** タブの遷移先の読み込み完了を待つ。速いページは listener を付ける前に終わるので、付けた後に今の状態も見る。 */
function waitForLoad(tabId) {
  return new Promise((resolve) => {
    const done = () => {
      chrome.tabs.onUpdated.removeListener(listener);
      resolve();
    };
    const listener = (id, info) => {
      if (id !== tabId || info.status !== 'complete') return;
      done();
    };
    chrome.tabs.onUpdated.addListener(listener);
    chrome.tabs.get(tabId).then((tab) => {
      if (tab.status !== 'complete' || tab.pendingUrl) return;
      done();
    });
  });
}

/** 再生と同じ条件にするため、アクションの URL を開き直してから録画を始める。注入は onUpdated が行う。 */
async function startRecording(tabId, draft) {
  await setRecording({ tabId, draft, lines: [], crossedPage: false });
  await chrome.action.setBadgeBackgroundColor({ color: '#ea4335' });
  await chrome.action.setBadgeText({ text: 'REC' });
  await chrome.tabs.update(tabId, { url: draft.url });
}

/** 録画した手順を draft の自動実行の末尾に足して保存し、次に popup を開いたときその編集画面を出す。 */
async function stopRecording(save) {
  const rec = await getRecording();
  await chrome.storage.session.remove(RECORDING);
  await chrome.action.setBadgeText({ text: '' });
  if (!save) return;

  const steps = [rec.draft.steps.trimEnd(), ...rec.lines].filter(Boolean).join('\n');
  await saveActions(upsert(await loadActions(), { ...rec.draft, steps }));
  await chrome.storage.session.set({ reopen: rec.draft.id });
}

chrome.tabs.onUpdated.addListener(async (tabId, info) => {
  if (info.status !== 'complete') return;
  const rec = await getRecording();
  if (rec?.tabId !== tabId) return;
  if (rec.lines.length > 0) await setRecording({ ...rec, crossedPage: true });
  await chrome.scripting.executeScript({ target: { tabId }, files: [...PAGE_SCRIPTS, 'recorder.js'] });
});

chrome.tabs.onRemoved.addListener(async (tabId) => {
  const rec = await getRecording();
  if (rec?.tabId !== tabId) return;
  await stopRecording(false);
});
