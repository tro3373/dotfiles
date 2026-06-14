# nvim 設定移行メモ (init.vim → lua)

- 対象: `apps/nvim/nvim/` 配下
- コミット: `feat(nvim): migrate config from init.vim to lazy.nvim/lua`
- 検証基準: `nvim --headless +q` がエラー/警告0 (達成済み)

## 1. 何が変わったか

- エントリ
  - 旧: `~/.config/nvim/init.vim` → `~/.vimrc` → `~/.vim/conf.d/*.vim` を全 source
  - 新: `~/.config/nvim/init.lua` → lua ネイティブ構成 + 一部 vimscript を source 再利用
- プラグイン管理
  - 旧: vim-plug (`~/.vim/plugged`)
  - 新: lazy.nvim (`~/.local/share/nvim/lazy`)
- モード切替
  - `bin/nvim_switch` で vim モード(init.vim) ⇔ lua モード(init.lua) を双方向トグル
  - モード状態は `~/.config/nvim` のローカル symlink。リポジトリ非コミット

## 2. 仕組み (ハイブリッド SSoT)

- 方針: 全 vimscript を lua へ書き直さない。動く vimscript は source して二重管理を避ける
- lua ネイティブ化した領域
  - プラグイン管理 (lazy.nvim)
  - LSP (nvim-lspconfig + mason-lspconfig の automatic_enable)
  - 補完 (nvim-cmp + LuaSnip)
  - statusline (lualine)
  - オプション/autocmd (`lua/base.lua`)
- vimscript を source 再利用する領域
  - bespoke utility コマンド: `~/.vim/conf.d/102_funcs.vim` (109コマンド・80関数)
  - 汎用キーマップ: `~/.vim/conf.d/101_mapping.vim`
  - 追加ハイライト: `~/.vim/conf.d/999_custom.vim`
  - 残す vim プラグインの個別設定 (`204_*`, `222_fzf.vim` 等)

### 2.1 ファイル構成

- `init.lua` … エントリ。`global → compat → base → pm → source(101/102/999)` の順
- `lua/global.lua` … ヘルパ関数 (`map`/`au`/`aug`/`aumg`/`dd`) + プラットフォーム判定 `_G.is_*`
- `lua/compat.lua` … vimscript 互換 shim
- `lua/base.lua` … オプション・autocmd (旧 `100_base.vim` の lua 版)
- `lua/pm.lua` … lazy.nvim ブートストラップ + spec 読み込み
- `lua/plugins/*.lua` … lazy プラグイン spec (ui/editor/finder/lsp/treesitter/lang/ai)
- `lua/util/debug.lua` … `dd()` デバッガ

### 2.2 自前 function/コマンドを参照する仕組み

- 全ての自前コマンド (`:Clip`, `:SaveTemp`, `:Translate` 等) と関数 (`GetGitRoot()` 等) は `102_funcs.vim` 内に定義
- `init.lua` 末尾で `_G.src("102_funcs.vim")` 等を実行 → 起動時に source → nvim ネイティブで全コマンド利用可能
- `_G.src(name)` … `compat.lua` 定義。`source ~/.vim/conf.d/<name>` するだけのヘルパ
- `102_funcs` 内の `g:is_wsl` / `g:winclip` 等の参照は全て関数内 (実行時) のため source 時にエラーは出ない
  - これら `g:` 変数は `compat.lua` が `_G.is_*` から派生して定義

### 2.3 残す vim プラグイン設定の再利用 (g:plug shim)

- 各 `conf.d/*.vim` 設定は先頭に `if !g:plug.is_installed("name") | finish | endif` の自己ゲートを持つ
- `compat.lua` が `g:plug.is_installed()` shim を定義
  - lazy の spec に `name` が存在すれば 1 (インストール済み) を返す
- lazy spec 側で残すプラグインの `config = function() _G.src("NNN_xxx.vim") end` とする
  - プラグインがロードされた後に既存設定を source → 設定を一切書き直さず再利用
- プラグイン名と guard 文字列を一致させるため一部 spec に `name` を明示
  - 例: `catgoose/nvim-colorizer.lua` に `name = "nvim-colorizer.lua"`

### 2.4 起動時バグの根治 (global.lua の autocmd ヘルパ)

- 旧 `global.lua` の `au/aug/aumg` は引数キー `groups`(複数) を渡すが `_create_au` は `group`(単数) を読むキー不一致バグがあった
- 結果 `aumg` が **イベント名 (FileType / BufRead 等) で augroup を生成**していた
- これが後続 source 時の `autocmd FileType ...` / `autocmd BufRead *` の event 名を shadow し `E216` / `E1155` を発生
- 修正: キーを `group` に統一し、`make_group` 時のみ augroup 生成
- 調査の罠: `nvim --headless -es` はエラーを握り潰す → 検証時は `-es` を外す必要があった

## 3. プラグイン変更一覧

### 3.1 廃止 (nvim ネイティブ/モダンへ置換)

| 廃止 | 置換先 | 理由 |
|---|---|---|
| vim-plug | lazy.nvim | nvim 標準のモダンプラグインマネージャ |
| lightline.vim (+ lightline-ale/-lsp) | lualine.nvim | nvim ネイティブ statusline |
| vim-lsp (+ vim-lsp-settings/-icons) | nvim-lspconfig | nvim 標準 LSP |
| asyncomplete.vim (+ 各 source/async.vim) | nvim-cmp | nvim ネイティブ補完 |
| neosnippet (+ snippets/vsnip) | LuaSnip + friendly-snippets | nvim ネイティブスニペット |
| unite.vim + neomru + unite-outline/-colorscheme | fzf へ集約 | レガシー (開発停止) |
| ctrlp.vim (+ funky/commandline/extensions) | fzf へ集約 | レガシー |
| vimproc.vim | (不要) | unite の依存 |
| taglist.vim | (未置換) | レガシー |
| norcalli/nvim-colorizer.lua | catgoose/nvim-colorizer.lua | 本家 unmaintained (deprecation) |
| syntastic | (ALE が担当) | 旧 passive 設定で実質未使用 |

### 3.2 新規導入

| 追加 | 役割 |
|---|---|
| lazy.nvim | プラグインマネージャ |
| lualine.nvim | statusline |
| nvim-lspconfig | LSP クライアント設定 (lsp/<name>.lua プリセット) |
| mason.nvim | LSP サーバのインストール管理 |
| mason-lspconfig.nvim | mason 導入済みサーバを自動 enable (vim-lsp-settings 相当) |
| kakehashi (+ kakehashi.nvim) | Tree-sitter ベース汎用 LS。md コードブロックを他 LS へブリッジ |
| nvim-cmp (+ cmp-nvim-lsp/buffer/path/cmp_luasnip) | 補完エンジン |
| LuaSnip + friendly-snippets | スニペット |
| catgoose/nvim-colorizer.lua | カラーコード着色 (fork) |
| claude-code.nvim | Claude Code 連携 (vim ではコメントアウトだったものを有効化) |

### 3.3 維持 (既存 vim プラグイン + 設定を source 再利用)

- 外観: Apprentice, nvim-web-devicons, vim-indent-guides, vim-gitgutter, nvim-blame-line, vim-fugitive, goyo, smear-cursor, fidget
- 編集: vim-surround, vim-repeat, vim-commentary, vim-smartinput(+context_filetype), vim-smartinput-endwise, vim-submode, accelerated-jk, vim-expand-region, clever-f, jumpcursor, vim-quickhl, Align, vim-easy-align, vim-quickrun(+shabadou), vim-ambicmd, open-browser, sudo.vim
- 検索/ファイラ/git: fzf + fzf.vim, vaffle, tig-explorer
- 解析: ALE (lint/fix), nvim-treesitter, hurl.nvim(+nui+plenary)
- 言語: Dockerfile.vim, vim-toml, vim-vue, typescript-vim, vim-dbml, vim-pug, kotlin-vim, dart-vim-plugin, vim-sqlfmt, vim-terraform, vim-yapf, vim-markdown, sqls.vim, sonictemplate-vim, markdown-preview.nvim(fork), live-server.nvim
- AI: copilot.vim, CopilotChat.nvim, denops.vim + denops-translate.vim

## 4. 既知の懸念・動作しないもの・未対応

### 4.1 LSP サーバの導入と自動有効化 (mason-lspconfig)

- enable 方式: mason-lspconfig の `automatic_enable` (デフォルト true)
  - mason 導入済みサーバを `vim.lsp.enable()` で自動有効化 (vim-lsp-settings 相当)
  - 旧構成の `executable()` ガード + 手動 enable ループは廃止
- 設定の分担
  - cmd / filetypes / root_markers: nvim-lspconfig の `lsp/<name>.lua` プリセット
  - サーバ固有 settings: `lsp.lua` の `vim.lsp.config(name, {settings=...})` (lua_ls/pylsp/yamlls)
  - `setup({automatic_enable=true})` は settings 登録後に呼ぶ (順序依存)
- 導入手順: `:Mason` または `:LspInstall <server>`
  - 例: `:MasonInstall lua-language-server python-lsp-server yaml-language-server`
  - 導入後 nvim 再起動 → 対象ファイルを開けば自動 attach
- 注意点
  - 自動 enable 対象は **mason 管理下のみ**。system 導入のみのサーバは mason へ寄せる
  - pylsp の `pylsp_mypy` / `flake8` プラグインは mason 同梱外
    - `python-lsp-server` の venv に別途 pip 導入が必要 (`:PylspInstall` 等)

### 4.2 廃止プラグインに紐づくキーマップが死んでいる

| キー | 旧動作 | 状態 | 代替候補 |
|---|---|---|---|
| `<Space>p` (Leader+p) | `:CtrlPMRU` 最近使ったファイル | **無効** (CtrlP 廃止) | fzf `:History` 等を再割当 |
| `sf` / `sb` / `sB` / `sm` / `sa` / `sr` | Unite 各種一覧 | **無効** (Unite 廃止) | fzf へ寄せる |

- これらは未割当 (何も起きない)。fzf ベースの再割当を別途検討

### 4.3 statusline / tabline の見た目が変わった

- statusline: 旧 lightline (theme `seoul256`) → 新 lualine (theme `auto`)
  - 配色・セグメント構成が別物。意図的な置換
- tabline: 旧 lightline がタブ行も描画 → 新は nvim デフォルトの tabline
  - `showtabline=2` は維持しているが装飾なし
  - 対応案: lualine の tabline 機能を有効化すれば近い見た目に戻せる

### 4.4 lazy 遅延ロードとキーマップの齟齬

- 旧 vim-plug は全プラグインを起動時に一括ロード → 全キーマップが即時有効
- 新 lazy は `ft` / `cmd` / `event` で遅延ロード
- source した vimscript 内のキーマップが、未ロードのプラグインコマンドを叩くと一時的に効かない場合がある
  - 例: `<Space>s` (MarkdownPreview) は markdown バッファを開くまでプラグイン未ロード
- 起動エラーにはならないが、初回操作のタイミングで体感差が出る

### 4.5 実機でのみ確認できる挙動 (起動エラーは0)

- `<CR>`: nvim-cmp の確定と vim-smartinput-endwise の括弧/end 補完の優先順位
- `<Leader>tr` 等の翻訳: denops の非同期起動の初回待ち
- これらは起動時でなくキー実行時の挙動のため headless 検証の範囲外

### 4.6 100_base.vim から未移植の軽微機能

- `base.lua` は `100_base.vim` のオプション・主要 autocmd を移植済みだが、以下は未移植
  - `DisableLintInThisRepository` コマンド
  - `HighlightMixedIndent` (make の混在インデント警告)
  - `RemoveAutoCommentAfterURL`, `highlight_notes` augroup
- 必要なら個別に lua 移植 or 該当部のみ source

### 4.7 kakehashi (md コードブロックの LSP ブリッジ)

- 役割: md の ```lang コードブロックを各言語の LS へブリッジ
  - md 内の Lua/Python/Go 等で hover / definition / 補完が効く
  - host のハイライトは nvim-treesitter に任せ、attach は markdown に限定
- 構成 (`lsp.lua`)
  - バイナリ: `apps/kakehashi` で GitHub Releases から導入 (`bin/setup kakehashi`)
  - `vim.lsp.config("kakehashi", {...})` + `vim.lsp.enable` (VeryLazy ロード)
    - `ft=`/`event=` 遅延は `nvim file.md` 起動引数で発火しないため VeryLazy
  - `inherit_nvim_lsp_config` で enable 済み LS 設定を継承しブリッジ先に流用
  - bridge 対象言語は静的列挙 (サーバ無しでも無害、転送先は inherit が動的解決)
  - `:KakehashiConceal` / `:KakehashiContext` で extra 機能トグル
- vim との非対称
  - vim 側は vim-lsp-settings の `settings/kakehashi.vim` が全 LS を自動検出しブリッジ構築
  - nvim 側は mason で enable したサーバのみが対象 (gopls 等は `:Mason` 導入が必要)
- 前提: 初回に C コンパイラ + ネットワークで tree-sitter parser を自動コンパイル
- 未検証: 実機での attach / bridge 補完は要確認 (headless 起動エラーは0)

## 5. 検証状況

- `nvim --headless +q`: 実 config・各ファイルタイプ(md/lua/tf/yaml/sql/py)・挿入モードでエラー/警告0
- 導入プラグイン数: 70 (依存含む)
- `bin/nvim_switch`: vim ⇔ lua 双方向トグル動作確認済み

## 6. モード切替手順

- lua モードへ: `bin/nvim_switch` (init.lua が無い状態で実行)
- vim モードへ戻す: `bin/nvim_switch` (init.lua が有る状態で実行)
- 現在のモード確認: `ls -la ~/.config/nvim/` で `init.lua`(lua) か `init.vim`(vim) か
