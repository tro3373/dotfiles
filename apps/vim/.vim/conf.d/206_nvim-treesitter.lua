-- luacheck: globals vim
-- treesitter ハイライト対応ファイルタイプのホワイトリスト
-- 他ファイルは従来の vim syntax / colorscheme (Apprentice) を維持する
--
-- markdown を treesitter 化するのは lua 版 nvim のみ。
-- 旧 vim モード (init.vim / nvim_switch) では _G.src が未定義なので、
-- markdown は従来どおり vim-markdown に任せ、ここでは何も足さない。
local lua_mode = _G.src ~= nil

local ts_highlight_filetypes = { hurl = true, dockerfile = true }
local ts_indent_filetypes = { hurl = true }
local ensure = { 'hurl', 'dockerfile' }
if lua_mode then
  ts_highlight_filetypes.markdown = true
  ts_highlight_filetypes.markdown_inline = true
  ensure = { 'hurl', 'markdown', 'markdown_inline' }
end

-- Dockerfile.vim プラグインが filetype を大文字 'Dockerfile' にするため、
-- treesitter の parser 'dockerfile'(小文字) と紐付ける
vim.treesitter.language.register('dockerfile', 'Dockerfile')

---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup({
  ensure_installed = ensure,
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, _)
      return not ts_highlight_filetypes[lang]
    end,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = function(lang, _)
      return not ts_indent_filetypes[lang]
    end,
  },
})

-- markdown の見出し/リスト記号/リンク色を treesitter の @markup group へ適用 (lua 版のみ)
-- 色値の SSOT は 010_md_palette.vim (旧 vim の vim-markdown syntax group と共有)
if lua_mode then
  _G.src("010_md_palette.vim")

  -- markdown(ブロック)クエリをカスタム:
  --   1) コードフェンス ``` の conceal/conceal_lines を解除 => ``` 行を残す (旧 vim 同様)
  --      ※ インライン ** や ` の conceal は markdown_inline 側なので影響しない
  --   2) 引用マーカー > を @markup.quote 扱いにして quote 色(灰)へ寄せる
  local qfiles = vim.api.nvim_get_runtime_file("queries/markdown/highlights.scm", true)
  if qfiles[1] then
    local fd = io.open(qfiles[1], "r")
    if fd then
      local q = fd:read("*a")
      fd:close()
      q = q:gsub('%s*%(#set! conceal ""%)', '')
      q = q:gsub('%s*%(#set! conceal_lines ""%)', '')
      q = q .. '\n((block_quote_marker) @markup.quote (#set! priority 105))\n'
      pcall(vim.treesitter.query.set, "markdown", "highlights", q)
    end
  end

  local function apply_markdown_hl()
    local p = vim.g.md_palette
    if not p or not p.marker then
      return
    end
    vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = p.h1.gui, ctermfg = p.h1.cterm })
    vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = p.h2.gui, ctermfg = p.h2.cterm })
    vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = p.h3.gui, ctermfg = p.h3.cterm })
    -- リンク本文(可視テキスト) は link 色、括弧 [] () と URL は marker(青)
    vim.api.nvim_set_hl(0, "@markup.link.label", { fg = p.link.gui, ctermfg = p.link.cterm })
    vim.api.nvim_set_hl(0, "@markup.link", { fg = p.marker.gui, ctermfg = p.marker.cterm })
    -- リスト記号 (- * + 1.) と タスクチェックボックス ([x] [ ]) は marker(青)
    vim.api.nvim_set_hl(0, "@markup.list.markdown", { fg = p.marker.gui, ctermfg = p.marker.cterm })
    vim.api.nvim_set_hl(0, "@markup.list.checked.markdown", { fg = p.marker.gui, ctermfg = p.marker.cterm })
    vim.api.nvim_set_hl(0, "@markup.list.unchecked.markdown", { fg = p.marker.gui, ctermfg = p.marker.cterm })
    -- コードフェンス本文は色を付けず Normal(白) に戻す
    vim.api.nvim_set_hl(0, "@markup.raw.block.markdown", {})
    -- 引用 (> とその本文) はコメント色(灰) に合わせる
    vim.api.nvim_set_hl(0, "@markup.quote.markdown", { link = "Comment" })
  end
  apply_markdown_hl()
  -- colorscheme 適用後と markdown バッファ進入時に必ず再適用 (起動順に依存しない)
  vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_markdown_hl })
  vim.api.nvim_create_autocmd("FileType", { pattern = "markdown", callback = apply_markdown_hl })
end
