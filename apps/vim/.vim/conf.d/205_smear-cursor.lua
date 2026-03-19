require("smear_cursor").setup({
  cursor_color = "#d3cdc3", -- カーソルの色（16進数またはハイライトグループ名）
  smear_between_buffers = true, -- バッファ切り替え時にスライム効果を出すか
  smear_between_neighbor_lines = true, -- 隣接する行への移動時に効果を出すか
  smear_insert_mode = true, -- インサートモードでも有効にするか
  scroll_buffer_space = true, -- スクロール時にバッファのスペースもスライム効果を出すか
  -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
  -- Smears and particles will look a lot less blocky.
  legacy_computing_symbols_support = false, -- レガシーコンピューティングシンボルのサポート（ブロックUnicodeシンボルを使用するか）

  -- Faster smear  -- Default[Ranges]
  stiffness = 0.8, -- 0.6[0, 1]
  trailing_stiffness = 0.6, -- 0.45[0, 1]
  stiffness_insert_mode = 0.7, -- 0.5[0, 1]
  trailing_stiffness_insert_mode = 0.7, -- 0.5[0, 1]
  damping = 0.95, -- 0.85[0, 1]
  damping_insert_mode = 0.95, -- 0.9[0, 1]
  distance_stop_animating = 0.5, -- 0.1[0,]
})
