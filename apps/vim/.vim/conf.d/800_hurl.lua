-- luacheck: globals vim
require('hurl').setup({
  debug = false,
  mode = 'split',            -- 'split' | 'popup'
  show_notification = false,
  auto_close = true,

  -- Split options
  split_position = 'right',
  split_size = '50%',

  -- Popup options
  popup_position = '50%',
  popup_size = { width = 80, height = 40 },

  env_file = { 'vars.env' },

  formatters = {
    json = { 'jq' },
    html = { 'prettier', '--parser', 'html' },
    xml  = { 'tidy', '-xml', '-i', '-q' },
  },

  mappings = {
    close = 'q',
    next_panel = '<C-n>',
    prev_panel = '<C-p>',
  },
})
