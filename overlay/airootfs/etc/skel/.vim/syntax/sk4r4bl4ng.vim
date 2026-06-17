if exists("b:current_syntax")
  finish
endif

" Keywords
syn keyword skrlangKeyword NOP JMP LABEL JMPIF YIELD ECHO
syn keyword skrlangOperator SHELL PS BOF CD SHELLCODE EXIT SLEEP
syn keyword skrlangComp SHELLCOMP BOFCOMP CSCOMP

" Comments
syn match skrlangComment ";.*"

" Strings
syn region skrlangString start=/"/ skip=/\\"/ end=/"/

" Numbers
syn match skrlangNumber "\v<\d+>"

" Operators

" Link your custom groups to standard highlight groups
hi def link skrlangKeyword Keyword
hi def link skrlangComment Comment
hi def link skrlangString String
hi def link skrlangNumber Number
hi def link skrlangComp Float
hi def link skrlangOperator Operator

let b:current_syntax = "sk4r4bl4ng"

