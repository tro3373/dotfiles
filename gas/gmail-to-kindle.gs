/**
 * Gmail => Kindle newsletter forwarder (Google Apps Script).
 *
 * Setup:
 *   1. Script Properties (Project Settings > Script Properties):
 *        KINDLE_EMAIL = your-address@kindle.com
 *        SENDERS      = news@a.example,news@b.example
 *                       (comma separated, full addresses, matched exactly)
 *   2. Add this Gmail address to Amazon's
 *      "Approved Personal Document E-mail List".
 *   3. Run setupTrigger() once to create the recurring trigger.
 *   4. testSendLatest() sends the most recent matching newsletter right now.
 *
 * A thread is labeled PROCESSED_LABEL once sent, and the search query excludes
 * that label, so nothing is sent twice. GmailApp labels threads, not messages:
 * a sender that keeps replying into one thread is only forwarded once.
 */
const CONFIG = {
  SEARCH_WINDOW_DAYS: 2,
  TRIGGER_INTERVAL_MINUTES: 15,
  PROCESSED_LABEL: 'kindle-sent',
  MAX_THREADS: 50,
};

// Main job - runs on the time-based trigger.
function main() {
  const settings = loadSettings_();
  const label = getOrCreateLabel_(CONFIG.PROCESSED_LABEL);
  const query = buildSearchQuery_(settings.senders);
  const threads = GmailApp.search(query, 0, CONFIG.MAX_THREADS);

  threads.forEach((thread) => processThread_(thread, settings, label));
}

// Send every unsent message of the thread, then label the thread.
// Returns the number of messages sent.
function processThread_(thread, settings, label) {
  let sent = 0;
  let failed = 0;

  targetMessages_(thread, settings.senders).forEach((message) => {
    try {
      sendToKindle_(message, settings.kindleEmail);
      sent += 1;
      console.log(`Sent to Kindle: ${message.getSubject()}`);
    } catch (e) {
      failed += 1;
      console.error(`Failed: ${message.getSubject()} - ${e}`);
    }
  });

  // Label only on a clean sweep, so a failed message is retried next run.
  if (sent > 0 && failed === 0) {
    thread.addLabel(label);
  }
  return sent;
}

// Read the per-account settings. Missing values are a setup mistake, not a
// runtime condition, so fail loudly instead of silently sending nowhere.
function loadSettings_() {
  const props = PropertiesService.getScriptProperties();
  const kindleEmail = (props.getProperty('KINDLE_EMAIL') || '').trim();
  const senders = (props.getProperty('SENDERS') || '')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s !== '');

  if (!kindleEmail) {
    throw new Error('Script property KINDLE_EMAIL is not set.');
  }
  if (senders.length === 0) {
    throw new Error('Script property SENDERS is not set.');
  }
  return { kindleEmail, senders };
}

// GmailApp.search matches threads, so a matched thread can also carry messages
// from other senders and messages older than the search window.
function targetMessages_(thread, senders) {
  const cutoff = Date.now() - CONFIG.SEARCH_WINDOW_DAYS * 24 * 60 * 60 * 1000;
  return thread
    .getMessages()
    .filter(
      (message) =>
        isTargetSender_(message.getFrom(), senders) && message.getDate().getTime() >= cutoff,
    );
}

// Send one email to Kindle as an .html attachment.
function sendToKindle_(message, kindleEmail) {
  const subject = message.getSubject() || '(no subject)';
  const html = buildDocumentHtml_(message, subject);
  const filename = `${sanitizeFilename_(subject)}.html`;
  const blob = Utilities.newBlob('', 'text/html', filename).setDataFromString(html, 'UTF-8');

  GmailApp.sendEmail(kindleEmail, subject, 'newsletter-to-kindle', {
    attachments: [blob],
    name: 'Newsletter to Kindle',
  });
}

// Plain-text newsletters need their line breaks converted,
// otherwise Kindle collapses them into one giant paragraph.
function buildDocumentHtml_(message, subject) {
  let body = message.getBody();
  if (!body || !looksLikeHtml_(body)) {
    body = plainTextToHtml_(message.getPlainBody() || '');
  }

  const from = escapeHtml_(message.getFrom());
  const date = Utilities.formatDate(
    message.getDate(),
    Session.getScriptTimeZone(),
    'yyyy-MM-dd HH:mm',
  );

  return [
    '<!DOCTYPE html><html lang="ja">',
    `<head><meta charset="UTF-8"><title>${escapeHtml_(subject)}</title></head>`,
    '<body>',
    `<p style="color:#666;font-size:0.85em;">${from}<br>${date}</p><hr>`,
    body,
    '</body></html>',
  ].join('');
}

function looksLikeHtml_(body) {
  return /<\s*(html|body|div|p|br|table|tr|td|img|span|a|blockquote|h[1-6])[\s>/]/i.test(body);
}

function plainTextToHtml_(text) {
  return escapeHtml_(text)
    .split(/\r?\n\s*\r?\n+/)
    .map((paragraph) => `<p>${paragraph.replace(/\r?\n/g, '<br>')}</p>`)
    .join('\n');
}

// Sender query without the processed-label exclusion.
function buildSenderQuery_(senders) {
  const fromClause = senders.map((sender) => `"${sender}"`).join(' OR ');
  return `from:(${fromClause}) newer_than:${CONFIG.SEARCH_WINDOW_DAYS}d`;
}

function buildSearchQuery_(senders) {
  return `${buildSenderQuery_(senders)} -label:"${CONFIG.PROCESSED_LABEL}"`;
}

// Gmail's from: operator also matches display names, so re-check the header
// ourselves. Compare the address only: a display name of "news@example.com"
// on a mail from evil@attacker.com must not pass.
function isTargetSender_(fromHeader, senders) {
  const address = senderAddress_(fromHeader);
  return senders.some((sender) => sender.toLowerCase() === address);
}

// "News <news@example.com>" => "news@example.com"
function senderAddress_(fromHeader) {
  const angled = fromHeader.match(/<([^>]*)>\s*$/);
  return (angled ? angled[1] : fromHeader).trim().toLowerCase();
}

function getOrCreateLabel_(name) {
  return GmailApp.getUserLabelByName(name) || GmailApp.createLabel(name);
}

function sanitizeFilename_(name) {
  return name.replace(/[\\/:*?"<>|\r\n]+/g, ' ').trim().slice(0, 80) || 'newsletter';
}

function escapeHtml_(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// Run once: creates the recurring trigger.
function setupTrigger() {
  ScriptApp.getProjectTriggers().forEach((trigger) => {
    if (trigger.getHandlerFunction() === 'main') {
      ScriptApp.deleteTrigger(trigger);
    }
  });
  ScriptApp.newTrigger('main')
    .timeBased()
    .everyMinutes(CONFIG.TRIGGER_INTERVAL_MINUTES)
    .create();
  console.log(`Trigger set: every ${CONFIG.TRIGGER_INTERVAL_MINUTES} minutes.`);
}

// Test: sends your most recent matching newsletter right now.
// Ignores the processed label so an already-sent newsletter can be re-sent.
function testSendLatest() {
  const settings = loadSettings_();
  const label = getOrCreateLabel_(CONFIG.PROCESSED_LABEL);
  const query = buildSenderQuery_(settings.senders);
  const threads = GmailApp.search(query, 0, CONFIG.MAX_THREADS);

  for (const thread of threads) {
    if (processThread_(thread, settings, label) > 0) {
      return;
    }
  }
  console.warn('No matching email found.');
}
