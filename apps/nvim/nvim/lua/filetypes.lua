-- luacheck: ignore 112 113
-- 拡張子 => filetype の上書き (nvim 組み込み判定より優先される)。
--
-- 依存ゼロの純設定に保つ (test/test-nvim-gs-filetype が --clean な nvim へ
-- dofile して単体検証するため)。

vim.filetype.add({
  extension = {
    -- 組み込みは .gs を GrADS スクリプト (grads) と判定するが、扱うのは
    -- GAS (Google Apps Script) = JavaScript のみ。ts_ls / treesitter を
    -- 効かせるため javascript に固定する。
    gs = "javascript",

    -- 旧 base.lua の au_ft_map から移行した上書き。組み込み検出と結果が
    -- 異なる (or 組み込みが未検出の) ものだけ残す。組み込みと同じ .js/.py/
    -- .ts/.md/.yml/.yaml/.rb/Gemfile/Jenkinsfile は組み込みに委譲し書かない。
    ejs = "html", -- 組み込み: 未検出
    erb = "ruby", -- 組み込み: eruby (埋め込みでなく素の ruby 扱いにする)
    coffee = "coffee", -- 組み込み: 未検出
    gyp = "json", -- 組み込み: gyp
    cson = "json", -- 組み込み: 未検出
    -- .jade は旧 au_ft_map で markdown 指定だったが、vim-pug の ftdetect が
    -- 常に pug で上書きしており実効しない死に設定だった。vim-pug に委譲する。
    -- vue = "html", -- 旧 config で無効化済み (組み込み vue に委譲)
  },
})
