import { loadPrompts } from './store.js';

// service worker からは直接クリップボードに書けないので offscreen document 経由でコピーする
async function copyViaOffscreen(text) {
  if (!(await chrome.offscreen.hasDocument())) {
    await chrome.offscreen.createDocument({
      url: 'offscreen.html',
      reasons: ['CLIPBOARD'],
      justification: 'プロンプトをクリップボードにコピーする',
    });
  }
  await chrome.runtime.sendMessage({ type: 'copy', text });
}

async function flashBadge(text, color) {
  await chrome.action.setBadgeBackgroundColor({ color });
  await chrome.action.setBadgeText({ text });
  setTimeout(() => chrome.action.setBadgeText({ text: '' }), 1500);
}

chrome.commands.onCommand.addListener(async (command) => {
  if (command !== 'copy-top') return;
  const [top] = await loadPrompts();
  if (!top) return flashBadge('0', '#d33');
  await copyViaOffscreen(top.body);
  await flashBadge('✓', '#2a2');
});
