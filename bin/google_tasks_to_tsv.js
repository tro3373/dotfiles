#!/usr/bin/env node

// biome-ignore lint/correctness/noNodejsModules: ignore
// biome-ignore lint/style/useNodejsImportProtocol: ignore
const fs = require('fs');
// import { fs } from 'node:fs/promises';
// import fs from 'fs-custom';

const tasksJson = `${process.cwd()}/Tasks.json`;
const stockAllTitles = (items) => {
  const map = {};
  items.map((t) => {
    map[t.id] = t.title;
    t.items.map((i) => {
      map[i.id] = i.title;
    });
  });
  return map;
};
const escapeString = (str) => {
  if (!str) {
    return '';
  }
  return str.replace(/"/g, '""');
};
const linksToText = (links) => {
  if (!links) {
    return '';
  }
  return links
    .map((l) => {
      if (l.desc === l.link) {
        return l.link;
      }
      return `${escapeString(l.desc)} ${l.link}`;
    })
    .join('\n');
};
// ここでヘッダーを出力
const cols = ['created', 'tabTitle', 'parentTitle', 'title', 'notes', 'links'];
const outputHeader = () => {
  console.info(cols.join('\t'));
};
const outputRows = (rows) => {
  rows.map((r) => console.info(cols.map((c) => `"${r[c]}"`).join('\t')));
};
// tabTitle:asc, parentTitle:asc, created:desc
const sorter = (a, b) => {
  if (a.tabTitle !== b.tabTitle) {
    return a.tabTitle.localeCompare(b.tabTitle);
  }
  if (a.parentTitle !== b.parentTitle) {
    return a.parentTitle.localeCompare(b.parentTitle);
  }
  if (!b.created) {
    return -1;
  }
  return b.created.localeCompare(a.created);
};
const main = () => {
  if (!fs.existsSync(tasksJson)) {
    console.error(`File not found: ${tasksJson}`);
    return;
  }
  const data = require(tasksJson);
  const titles = stockAllTitles(data.items);
  outputHeader();
  const rows = [];
  data.items.map((tab) => {
    if (tab.status === 'completed') {
      return; // 完了済みはスキップ
    }
    tab.items
      .filter((i) => i.status !== 'completed')
      .filter((i) => i.title || i.links) // タイトルかリンクがあるもののみ抽出
      .map((i) => {
        const parentId = i.parent;
        const parentTitle = parentId ? titles[parentId] : '';
        // NOTE: outputHeader()と同じ順番で出力
        rows.push({
          created: i.created,
          tabTitle: tab.title,
          parentTitle: parentTitle,
          title: escapeString(i.title),
          notes: escapeString(i.notes || ''),
          links: linksToText(i.links),
        });
        // console.info(
        //   `${i.created}\t"${tab.title}"\t"${parentTitle}"\t"${escapeString(i.title)}"\t"${escapeString(i.notes || '')}"\t"${linksToText(i.links)}"`,
        // );
      });
  });
  rows.sort(sorter);
  outputRows(rows);
  console.error('==>done');
};
main();
