-- luacheck: ignore 112 113

vim.g.terminal_ansi_colors = nil -- Disable Neovim's automatic handling of ANSI color codes within the terminal.
vim.opt.termguicolors = true -- ターミナル環境用に256色を使えるようにする
-- if vim.opt.term == 'screen-256color' then
-- if vim.fn.getenv("TERM") == "screen-256color" then
--   -- 背景の塗り潰しは行わない(Not Work)
--   vim.opt.t_ut = ''
-- end

-- 全角スペースを分かりやすく表示する
-- vim.api.nvim_set_hl(0, 'ZenkakuSpace', {cterm = 'underline', ctermfg = 'lightmagenta', guibg = 'lightmagenta'})
-- vim.regex_pattern["ZenkakuSpace"] = "/　/"
vim.api.nvim_create_augroup("extra-whitespace", {})
aug({
  events = { "VimEnter", "WinEnter" },
  group = "extra-whitespace",
  cb = [[call matchadd('ExtraWhitespace', '[\u00A0\u2000-\u200B\u3000]')]],
})
aug({
  events = { "ColorScheme" },
  group = "extra-whitespace",
  cb = [[highlight default ExtraWhitespace ctermbg=darkmagenta guibg=darkmagenta]],
})

-- シンタックスハイライトを有効にする
vim.cmd("syntax enable")
-- デフォルトのシンタックスハイライトをshにする
au({
  events = { "BufNewFile", "BufRead" },
  cb = function()
    local syntax = vim.bo[0].syntax
    if syntax ~= "" and syntax ~= "conf" then
      return
    end
    vim.cmd("set syntax=sh")
  end,
})
au({
  events = "FileType",
  pat = { "vue" },
  cb = "syntax sync fromstart",
})

-- TAB文字/行末の半角スペースを表示する
vim.opt.list = true
-- tab: タブの表示. 2文字指定
-- trail: 行末に続くスペース
-- eol: 改行記号
-- extends: ウィンドウの幅が狭くて右に省略された文字がある場合に表示
-- precedes: extends と同じで左に省略された文字がある場合に表示
-- nbsp: 不可視のスペースを表す表示。ただし、この記号の通りに表示されるのは、ノーブレークスペースに限られており、
--    ほかの不可視スペース (​、﻿など)には効果なし
vim.opt.listchars = { tab = "▸ ", trail = "_", extends = " " }

vim.opt.number = true -- 行番号を表示する
vim.opt.relativenumber = true -- 相対行番号を表示する
vim.opt.ruler = true -- ルーラを表示
vim.opt.colorcolumn = "80,120" -- 80,120 に縦 Line
vim.opt.signcolumn = "yes" -- サイン列を常時表示 (gutter の出し入れ再描画漏れ防止)
vim.opt.updatetime = 100 -- CursorHold 発火を高速化 (gitgutter の編集後更新を即時化)

-- カーソル行・列を一定時間入力なし時、ウィンドウ移動直後に表示
local cursorline_lock = 0
local function auto_cursorline(args)
  local event = args.event
  if event == "WinEnter" then
    vim.opt_local.cursorline = true
    vim.opt_local.cursorcolumn = true
    cursorline_lock = 2
  elseif event == "WinLeave" then
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
  elseif event == "CursorMoved" then
    if cursorline_lock then
      if cursorline_lock > 1 then
        cursorline_lock = 1
      else
        vim.opt_local.cursorline = false
        vim.opt_local.cursorcolumn = false
        cursorline_lock = 0
      end
    end
  elseif event == "CursorHold" then
    vim.opt_local.cursorline = true
    vim.opt_local.cursorcolumn = true
    cursorline_lock = 1
  end
end
local aug_ac = "vimrc-auto-cursorline"
vim.api.nvim_create_augroup(aug_ac, {})
local function auto_cursor_callback(event)
  return function()
    auto_cursorline({ event = event })
  end
end
aug({
  events = { "CursorMoved", "CursorMovedI" },
  group = aug_ac,
  cb = auto_cursor_callback("CursorMoved"),
})
aug({
  events = { "CursorHold", "CursorMovedI" },
  group = aug_ac,
  cb = auto_cursor_callback("CursorHold"),
})
aug({
  events = { "WinEnter" },
  group = aug_ac,
  cb = auto_cursor_callback("WinEnter"),
})
aug({
  events = { "WinLeave" },
  group = aug_ac,
  cb = auto_cursor_callback("WinLeave"),
})

-- ステータスラインの表示変更
vim.opt.laststatus = 2 -- Always display the statusline in all windows
vim.opt.showtabline = 2 -- Always display the tabline, even if there is only one tab
vim.opt.showmode = false -- Hide the default mode text (e.g. -- INSERT --)
vim.opt.cmdheight = 2 -- コマンドラインの高さ
vim.opt.pumheight = 10 -- 補完メニューの高さ
vim.opt.display = "lastline" -- 長い行も表示

-- viminfo、バックアップ、スワップ
vim.opt.viminfo:append("n~/.vim/_nviminfo") -- ~/.vim/_viminfo を viminfo ファイルとして指定
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath("data") .. "/backup"
vim.opt.swapfile = true
vim.opt.directory = vim.fn.stdpath("data") .. "/backup"
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true

-- スワップファイルがある場合は常に Read-Only で開く設定
aumg({
  events = "SwapExists",
  group = "swapchoice-readonly",
  cb = function()
    vim.v.swapchoice = "o"
  end,
})

-- ファイルオープン時に元の位置を開く設定
aumg({
  events = "BufRead",
  group = "restore-rownum",
  cb = function()
    local line = vim.fn.line
    -- '\": 最後に編集していた行番号を表す
    if line("'\"") > 0 and line("'\"") <= line("$") then
      vim.cmd('normal g`"')
    end
  end,
})

vim.opt.matchtime = 1 -- カーソルの移動速度を 0.1 秒に設定する
vim.opt.ttyfast = true -- ターミナル接続を高速化する
vim.opt.scrolloff = 5 -- スクロールした際に余白を 5 行分残す
vim.opt.showmatch = true -- 閉じ括弧が入力されたときに対応する括弧を表示する
vim.opt.tabpagemax = 99 -- タブページの最大数を 99 に設定する
vim.opt.wildmenu = true -- コマンド補完機能を有効にする
vim.opt.wildmode = "longest:full,full" -- コマンド補完機能を zsh ライクにする
vim.opt.ignorecase = true -- 大文字と小文字を区別しない(wildmenuにも影響する)
vim.opt.smartcase = true -- 検索時に大文字を含んでいたら大文字と小文字を区別する(wildmenuにも影響する)

-- https://stackoverflow.com/questions/6726783/changing-default-position-of-quickfix-window-in-vim
vim.opt.splitright = true -- For quickfix
vim.opt.diffopt:append("vertical") -- デフォルトのdiffspritは縦分割指定
vim.opt.mouse = "a" -- ターミナル時でもマウスを使えるようにする
-- vim.opt.guioptions:append("a")
vim.opt.vb = false -- ビープ音OFF
vim.opt.eb = false -- エラーベルOFF
vim.opt.virtualedit = "block" -- 矩形選択で行末より後ろもカーソルを置ける
vim.opt.backspace = "indent,eol,start" -- Backspace を有効にする
vim.opt.helpheight = 99999 -- help の高さを 99999 に設定する
vim.opt.helplang = "ja,en" -- help の言語を日本語と英語にする
vim.opt.incsearch = true -- インクリメンタルサーチを有効にする
vim.opt.hlsearch = true -- 検索結果のハイライト表示を有効にする

-- UTF-8 をデフォルトの文字コードセットに設定する
--  encoding(enc)
--    vimの内部で使用されるエンコーディングを指定する。
--    編集するファイル内の全ての文字を表せるエンコーディングを指定するべき。
vim.opt.encoding = "utf-8"
--  fileencoding(fenc)
--    そのバッファのファイルのエンコーディングを指定する。
--    バッファにローカルなオプション。これに encoding と異なる値が設定されていた場合、
--    ファイルの読み書き時に文字コードの変換が行なわれる。
--    fencが空の場合、encodingと同じ値が指定されているものとみなされる。(つまり、変換は行なわれない。)
vim.opt.fileencoding = "utf-8"
--  fileencodings(fencs)
--    既存のファイルを編集する際に想定すべき文字コードのリストをカンマ区切りで列挙したものを指定する。
--    編集するファイルを読み込む際には、「指定された文字コード」→「encodingの文字コード」の変換が試行され、
--    最初にエラー無く変換できたものがそのバッファの fenc に設定される。
--    fencsに列挙された全ての文字コードでエラーが出た場合、fencは空に設定され、その結果、
--    文字コードの変換は行われないことになる。fencsにencodingと同じ文字コードを途中に含めると、
--    その文字コードを試行した時点で、「 encoding と同じ」→「文字コード変換の必要無し」→「常に変換成功」→「fencに採用」となる。
-- set fileencodings=ucs-bom,iso-2022-jp-3,iso-2022-jp,eucjp-ms,euc-jisx0213,euc-jp,cp932,sjis,utf-8
-- © Only File Not working see [.vimrc | 暇人専用](http://himajin-senyo.com/conf/vimrc/)
-- set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
-- [Vim – 文字コードを自動認識して判定/判別する方法 | Howpon[ハウポン]](https://howpon.com/20630)
-- set fileencodings=iso-2022-jp,ucs-bom,utf-8,euc-jp,cp932,sjis,default,latin1
-- [Vimの文字コードの認識の仕組みと、文字化けを減らすための設定 - Qiita](https://qiita.com/aikige/items/12ffa2574199cc740a44)
vim.opt.fileencodings = "ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin"

vim.opt.fileformats = "unix,dos,mac" -- 新規、読み込み時の改行設定(複数で自動判定)
vim.opt.ambiwidth = "double" -- Unicodeで行末が変になる問題を解決
-- -- 旧 .vimrc では double(Unicodeで行末が変になる問題対策)だったが、
-- -- nvim 起動ロゴ等の曖昧幅グリフが double で崩れるため single へ変更
-- vim.opt.ambiwidth = "single"

-- バッファ自動再読込
-- 元のファイルの変更を Vim が検知し、かつバッファが変更されていなかった場合に自動再読込
vim.opt.autoread = true
-- 以下タイミングで、checktime を実行
aumg({
  events = { "WinEnter", "FocusGained", "BufEnter" },
  group = "auto_checktime",
  cb = "checktime",
})

-- インデント設定
vim.opt.cindent = true -- C言語スタイルのインデントを使用
vim.opt.autoindent = true -- オートインデント
vim.opt.smartindent = true -- 賢いインデント
-- tw  = textwidth
-- ft  = filetype
-- 既定は 2 スペース (100_base.vim と同値)。リスト外の FT (markdown/json 等) もこれに従う
vim.opt.tabstop = 2 -- ts  = tabstop     ファイル中の<TAB>を見た目x文字に展開する(既に存在する<TAB>の見た目の設定)
vim.opt.softtabstop = 2 -- sts = softtabstop TABキーを押した際に挿入される空白の量を設定
vim.opt.shiftwidth = 2 -- sw  = shiftwidth  インデントやシフトオペレータで挿入/削除されるインデントの幅を設定
vim.opt.expandtab = true -- expandtab         <TAB>を空白スペース文字に置き換える
-- 特定 FT のみインデントを 4 にする (100_base.vim の FileType 設定と同値)
au({
  events = "FileType",
  pat = { "python", "java", "go", "make", "Dockerfile", "lua" },
  cb = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
-- go はタブを空白に変換しない (100_base.vim と同値)
au({
  events = "FileType",
  pat = { "go" },
  cb = function()
    vim.opt_local.expandtab = false
  end,
})
-- 改行時にコメントを続けるか等の自動整形オプション
-- ex) formatoptions-=c
--     - jcroql (in java,vim)
--     - tqj (in python)
-- c: (textwidth の値を超える)長いコメント行を入力した場合に自動で改行
-- t: (textwidth の値を超える)長いテキスト行を入力した場合に自動で改行
-- l: インサートモード時(textwidth の値を超える)長い行入力中に改行しない
-- r: Enter 入力時にコメントリーダーを挿入する。
-- o: o あるいは O で行を挿入した場合にコメントリーダーを挿入する。
-- j: 結合時にコメントリーダーを削除する
-- q: gq コマンドで選択部分をコメント整形する。
-- set formatoptions-=c
-- " setglobal formatoptions+=mb
vim.opt.formatoptions = "jcroql"

-- 挿入モードからノーマルモードに戻る時にペーストモードを自動で解除
au({
  events = "InsertLeave",
  cb = function()
    vim.opt.paste = false
  end,
})

-- ファイルタイプ別の設定
au_ft_map("*.js", "javascript")
au_ft_map("*.ejs", "html")
-- au_ft_map('*.vue', 'html')
au_ft_map("*.py", "python")
au_ft_map("*.rb", "ruby")
au_ft_map("*.erb", "ruby")
au_ft_map("Gemfile", "ruby")
au_ft_map("*.coffee", "coffee")
au_ft_map("*.ts", "typescript")
au_ft_map("*.md", "markdown")
au_ft_map("*.jade", "markdown")
au_ft_map("*.gyp", "json")
au_ft_map("*.cson", "json")
au_ft_map("*.yml", "yaml")
au_ft_map("*.yaml", "yaml")
au_ft_map("Jenkinsfile", "groovy")

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
au({
  events = "FileType",
  pat = { "json", "jsonc", "markdown" },
  cb = function()
    vim.opt.conceallevel = 0
  end,
})

-- 起動時引数で渡したバッファ (startup buffer, 例: `nvim foo.md`) は、lazy が rtp へ
-- ~/.vim を載せ切る前に ftplugin パスが走るため、~/.vim/ftplugin/markdown.vim
-- (キーマップ等) や ~/.vim/after/ftplugin/markdown.lua (treesitter 停止) が適用されず、
-- vim-markdown syntax も読まれない (nvim 標準 markdown syntax/treesitter のままになる)。
-- VimEnter 時点では rtp が揃っているので、開いている markdown バッファの filetype を
-- 再適用して post-startup (`:edit`) と同じ ftplugin/syntax 経路に乗せ直す。
aumg({
  events = "VimEnter",
  group = "markdown-startup-refire",
  cb = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
        vim.bo[buf].filetype = "markdown"
      end
    end
    -- vim-markdown の fenced code 言語別ハイライト (s:MarkdownHighlightSources) は
    -- ftplugin の BufWinEnter autocmd 契機の force refresh でしか走らない。上の filetype
    -- 再適用は ftplugin を読み直すだけで BufWinEnter を再発火しないため、startup buffer の
    -- ```go ``` 等が `mkdCode` 止まり (言語別 syntax が当たらない) になる。表示中の markdown
    -- ウィンドウで BufWinEnter を明示発火し、正しいバッファコンテキストで refresh を走らせる。
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "markdown" then
        vim.fn.win_execute(win, "doautocmd <nomodeline> BufWinEnter")
      end
    end
    -- 起動引数の markdown は read 系イベント (BufRead) が発火せず、shada のカーソル位置が
    -- バッファへ読み込まれない (restore-rownum が動かず常に 1 行目になる)。shada を読み直して
    -- '" マークを回収し、未復元 (カーソルが 1 行目) の markdown ウィンドウで前回位置へ戻す。
    local md_wins = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if
        vim.bo[buf].filetype == "markdown"
        and vim.bo[buf].buftype == ""
        and vim.api.nvim_win_get_cursor(win)[1] == 1
      then
        table.insert(md_wins, win)
      end
    end
    if #md_wins > 0 then
      vim.cmd("rshada!")
      for _, win in ipairs(md_wins) do
        vim.fn.win_execute(win, 'normal! g`"')
      end
    end
  end,
})

if vim.fn.exists("##TermOpen") then
  -- tig から開く vim? にTermOpenイベントがないため
  -- エラーが発生するので有効な場合のみ
  local aug_term = "vimrc-terminal"
  vim.api.nvim_create_augroup(aug_term, { clear = true })
  -- terminal開始時にインサートモードを開始する
  aug({
    events = "TermOpen",
    group = aug_term,
    pattern = "term://*",
    cb = "startinsert",
  })
  -- terminal JOBの終了ステータスが成功であれば、バッファを閉じる
  aug({
    events = "TermClose",
    group = aug_term,
    cb = function(event)
      if not event.status then
        vim.api.nvim_command("bdelete! " .. vim.fn.expand("<abuf>"))
      end
    end,
  })
end

-- Enable Java Highlight
-- @see https://nanasi.jp/articles/vim/java_vim.html
vim.g.java_highlight_all = true -- 標準クラス名のハイライト
vim.g.java_highlight_debug = true -- デバッグ文のハイライト
-- C++ キーワードのハイライト
-- auto delete enum extern friend inline redeclared register signed sizeof
-- struct template typedef union unsigned operator
vim.g.java_allow_cpp_keywords = true
vim.g.java_space_errors = true -- 余分な空白に対して警告
vim.g.java_highlight_functions = true -- メソッドの宣言文と、ブレースのハイライト

vim.opt.clipboard = is_linux and "unnamedplus" or "unnamed" -- クリップボードを有効にする

local winclip = "/mnt/c/Windows/System32/clip.exe"
local function set_yank_post_for_win()
  if vim.fn.getenv("DISPLAY") == ":0" then
    -- DISPLAY :0 => wslg is running
    -- define only wsl(no define in wslg)
    return
  end
  local function yank_post_for_win()
    vim.fn.system(winclip, vim.fn.getreg("0"))
  end
  aumg({
    events = { "TextYankPost" },
    group = "my-yank-post",
    cb = yank_post_for_win,
  })
end

-- リモート接続時のクリップボードフォワード設定
-- OSC52 対応端末なら OSC52、未対応なら clipper(bin/clip) にフォールバック
local function set_yank_post_in_remote()
  -- if vim.fn.getenv("IS_VAGRANT") == "1" or vim.fn.getenv("IS_ORB") == "1" then
  if vim.fn.getenv("IS_VAGRANT") == "1" then
    return
  end
  local remote_state = getenv("REMOTEHOST", "") .. getenv("SSH_CONNECTION", "")
  if remote_state == "" then
    return
  end
  local clip = getenv("HOME", "") .. "/.dot/bin/clip"
  local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")
  local function yank_post_via_clipper()
    local cliptmp = vim.fn.getenv("HOME") .. "/.vim/.clip.tmp"
    local clip_content = vim.fn.split(vim.fn.getreg("0"), "\n")
    vim.fn.writefile(clip_content, cliptmp)
    vim.fn.system("cat <" .. cliptmp .. "| " .. clip)
  end
  local function yank_post_in_remote()
    -- g:termfeatures.osc52 は TUI が起動時に非同期で検出するため yank 時に判定する
    if (vim.g.termfeatures or {}).osc52 then
      osc52_copy(vim.split(vim.fn.getreg("0"), "\n", { plain = true }))
      return
    end
    if vim.fn.executable(clip) == 1 then
      yank_post_via_clipper()
    end
  end
  aumg({
    events = { "TextYankPost" },
    group = "my-yank-post",
    cb = yank_post_in_remote,
  })
end
if vim.fn.executable(winclip) == 1 then
  set_yank_post_for_win()
else
  set_yank_post_in_remote()
end

local function get_local_rc_path()
  return vim.fn.getenv("HOME") .. "/.ldot/vim/additional" .. vim.fn.getcwd() .. "/local.vimrc"
end
local function load_local_rc()
  local rc = get_local_rc_path()
  if vim.fn.filereadable(rc) == 0 then
    return
  end
  vim.cmd("source " .. rc)
end
aumg({
  events = { "BufNewFile", "BufReadPost" },
  group = "local-rc",
  cb = load_local_rc,
})

local function openLocalRc()
  local rc = get_local_rc_path()
  if vim.fn.filereadable(rc) == 0 then
    return
  end
  vim.cmd("tabe " .. rc)
end
vim.api.nvim_create_user_command("OpenLocalRc", openLocalRc, {})

-- "==============================================================================
-- " SQL auto uppercase
local function sql_abbr_buf_map()
  vim.cmd("iabbrev <buffer> select SELECT")
  vim.cmd("iabbrev <buffer> update UPDATE")
  vim.cmd("iabbrev <buffer> delete DELETE")
  vim.cmd("iabbrev <buffer> from FROM")
  vim.cmd("iabbrev <buffer> where WHERE")
  vim.cmd("iabbrev <buffer> order ORDER")
  vim.cmd("iabbrev <buffer> by BY")
  vim.cmd("iabbrev <buffer> join JOIN")
  vim.cmd("iabbrev <buffer> on ON")
  vim.cmd("iabbrev <buffer> set SET")
end
aumg({
  events = "FileType",
  group = "sql-auto-uppercase",
  pat = "sql",
  cb = sql_abbr_buf_map,
})
