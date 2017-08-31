0x7C00
jmp start

STRUC cliente
.nome resb 21
.CPF resw 1
.agencia resw 1
.conta resw 1
.validade resb 1
ENDSTRUC

aCliente: times 10*cliente_size db 0
aSize: dw 10
sSize: dw 28

start:
	lea si, [aCliente]

busca:
	push si ;
	push ax
	push bp
	push cx ;salva o valor original dos registradores a serem usados pelo call
	mov bp, sp ;copia sp em bp para ficar mais facil de trabalhar
	add bp, 10 ;adicionando 10 a dp é possivel ter acesso ao endereço dos parametros a serem usados pelo call
	mov ax, [bp] ;carrega o numero a ser buscado (x)
	mov si, [bp + 2] ;carrega o endereço onde deve ser iniciado a busca (assume-se que v[0])

	mov cx, [aSize] ;tamanho do vetor pra ser usado na pilha
	compara:
		cmp ax, [si + cliente.conta] ;x == v[i]?
		je salvaEndereco ;se sim, sai do loop

		add si, [sSize] ;se não, i++
		loop compara

	mov si, string 
	call print_string ;caso a conta buscada não exista, informa ao usuario e
	mov [bp + 2], -1 ;salva -1 na posição da pilha onde originalmente estava v[0]
	jmp fimBusca

	salvaEndereco:
		mov [bp + 2], si ;salva v[i] na posição da pilha onde antes existia v[0]

	fimBusca:
		pop cx ;
		pop bp
		pop ax
		pop si ;restaura os valores originais dos registradores usados no call
		ret 2 ;retorna incrementando sp em 2 para sobrescrever o local onde estava o parametro x

deleta:
	push si ;
	push ax
	push bp ;salva o valor original dos registradores a serem usados pelo call
	mov bp, sp ;copia sp em bp para ficar mais facil de trabalhar
	add bp, 8 ;adicionando 8 a dp é possivel ter acesso ao endereço dos parametros a serem usados pelo call
	mov ax, [bp] ;carrega o numero da conta a ser deletado
	mov si, [bp + 2] ;carrega o endereço da posição inicial do vetor de clientes

	push si ;
	push ax ;salva o numero da conta e o endereço de v[0] pra ser usado no procedimento busca
	call busca

	pop si
	cmp si, -1 
	jne fimDeleta ;se busca retornar -1, ou seja, a conta não existe pula pro final

	mov word[si + cliente.validade], 0 ;caso contrario sobrescreve o bit validade "apagando" a conta

	fimDeleta:
		pop bp ;
		pop ax
		pop si ;restaura os valores originais do registrador
		ret 4 ;retorna sobrescrevendo os paramentros contidos na pilha


end:
times 510 - ($ - $$) db 0
dw 0xAA55


