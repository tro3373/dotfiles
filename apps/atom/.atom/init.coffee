# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# An example hack to log to the console when each text editor is saved.
#
# atom.workspace.observeTextEditors (editor) ->
#   editor.onDidSave ->
#     console.log "Saved! #{editor.getPath()}"

# TODO
# npm install iconv-lite
# npm install jschardet
#
# fs = require('fs')
#
# atom.workspace.observeTextEditors (editor) ->
#   try
#     filePath = editor.getPath()
#   catch error
#     return
#   return unless fs.existsSync(filePath)
#
#   jschardet = require 'jschardet'
#   iconv = require 'iconv-lite'
#   fs.readFile filePath, (error, buffer) =>
#     return if error?
#     {encoding} = jschardet.detect(buffer) ? {}
#     encoding = 'utf8' if encoding is 'ascii' or encoding is 'windows-1252'
#     return unless iconv.encodingExists(encoding)
#
#     encoding = encoding.toLowerCase().replace(/[^0-9a-z]|:\d{4}$/g, '')
#     editor.setEncoding(encoding)
#   return
