0x7C00
jmp 0xstart

STRUC cliente
.nome resb 21
.CPF resw 1
.agencia resw 1
.conta resw 1
.validade resb 1
ENDSTRUC

aCliente: times 10*cliente_size db 0
aSize: db 28
