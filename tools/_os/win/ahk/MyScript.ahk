; alt-ime-ahk を読み込む
; #Include alt-ime-ahk.ahk

; !r::Send,#r
; !l::Send,#l
; !d::Send,#d
; !e::Send,#e


; LAlt up::Send,{vk1Dsc07B}
; RAlt up::Send,{vk1Csc079}

; !h::left    ;Win+Hに←キーを割り当て
; !j::down    ;Win+Jに↓キーを割り当て
; !k::up      ;Win+Kに↑キーを割り当て
; !l::right   ;Win+Lに→キーを割り当て

; #IfWinActive ahk_class Vim
; LAlt::
;     Return
; RAlt up::
;     Return
; #IfWinActive
