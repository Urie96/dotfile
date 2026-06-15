if exists('b:current_syntax')
  finish
endif

syntax include @RpcJson syntax/json.vim
unlet b:current_syntax

syntax match rpcSeparator /^\s*###\s*$/
syntax match rpcComment /^\s*#\%([^#].*\)\?$/ containedin=ALLBUT,rpcBody
syntax match rpcMetaKey /^\s*\zs[A-Za-z_][A-Za-z0-9_]*\ze\s*:/ containedin=ALLBUT,rpcBody
syntax match rpcMetaColon /:/ containedin=ALLBUT,rpcBody
syntax match rpcMetaValue /:\s*\zs.*$/ containedin=ALLBUT,rpcBody
syntax region rpcBody start=/^\s*$/ end=/^\s*###\s*$/me=s-1 keepend contains=@RpcJson

highlight default link rpcSeparator Delimiter
highlight default link rpcComment Comment
highlight default link rpcMetaKey Identifier
highlight default link rpcMetaColon Delimiter
highlight default link rpcMetaValue String

let b:current_syntax = 'rpc'
