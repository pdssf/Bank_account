0x7C00
jmp start

STRUC cliente
    .nome resb 21
    .CPF resw 1
    .agencia resw 1
    .conta resw 1
    .validade resb 1
ENDSTRUC

;campo de declaracao de string

concluido db "feito!"10,13,0

Menu db 'escolha sua opcao', 10, 13,'1-casdastrar nova conta', 10, 13, '2-buscar conta', 10, 13, '3-editar conta', 10, 13, '4-deletar conta', 10, 13, '5-listar agencias', 10, 13, '6-listar contas', 10, 13,0


aCliente: times 10*cliente_size db 0
aSize: dw 10
sSize: dw 28

ag_num times aSize dw 0 					;guarda o num de uma agencia

start:
    xor ax,ax
    mov ds,ax
    
	mov ah, 0 						;inicia o modo de video
	mov al, 12h
	int 10h
	
menu:
    mov si, Menu
    printm:
    	lodsb                          ;Carrega um byte de DS:SI em AL e depois incrementa SI
    	mov ah, 0xe                     ;Código da instrução de imprimir um caractere que está em al
    	mov bl,0xf
    	mov bh,0
		int 10h        ;Interrupção de vídeo. 
		
        cmp  al, 0                     ;0 é o código do \0
		je donem
    jmp printm
donem:

    mov ah, 0
    int 16h
    sub al, '0'
    
    cmp al, 1
    
    cmp al, 2
    
    cmp al, 3
    
    cmp al, 4
    
    cmp al, 5
        jmp listar_agencias
    cmp al, 6
        jmp listar_contas
jmp Menu
;========================================buscando uma conta:

    lea si, [aCliente]                 ;vai para a primeira posição do vetor de contas
    busca:

    push si 
    push ax
    push bp
    push cx 													;salva o valor original dos registradores a serem usados pelo call

    mov bp, sp 													;copia sp em bp para ficar mais facil de trabalhar
    add bp, 10 													;adicionando 10 a dp é possivel ter acesso ao endereço dos parametros a serem usados pelo call
    mov ax, [bp] 												;carrega o numero a ser buscado (x)
    mov si, [bp + 2] 											;carrega o endereço onde deve ser iniciado a busca (assume-se que v[0])

    mov cx, [aSize] 											;tamanho do vetor pra ser usado na pilha

    compara:
        cmp ax, [si + cliente.conta] ;x == v[i]?
        je salvaEndereco ;se sim, sai do loop

        add si, [sSize] ;se não, i++
        loop compara

    mov si, string 
    call print_string 											;caso a conta buscada não exista, informa ao usuario e
    mov [bp + 2], -1 											;salva -1 na posição da pilha onde originalmente estava v[0]
    jmp fimBusca

    salvaEndereco:
        mov [bp + 2], si ;salva v[i] na posição da pilha onde antes existia v[0]

    fimBusca:
        pop cx ;
        pop bp
        pop ax
        pop si ;restaura os valores originais dos registradores usados no call
        ret 2 ;retorna incrementando sp em 2 para sobrescrever o local onde estava o parametro x

;========================================deletando uma conta:

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

;========================================listar agencias:
    listar_agencias:
    
    lea si, [aCliente+ cliente.agencia]						;move primeira conta para si: deslocando o tamanho ate agencia
    mov cx, aSize											            ;move para cx o numero de elementos no vetor

    ag_busca:
        lea bx, [si+4]
        cmp world[bx],0
        je notprint         ;caso não seja uma posicao valida

        mov ax,[si]         ;movo o numero da agencia para ax
        mov bx, ag_num
        call agfetch
    back:
        call print_number									             ;chama o procedimendo para imprimir numero
        notprint:											                 ;caso nao precise printar

        add si, world[sSize]								           ;avança para a proxima(si+28)
        loop ag_busca
        jmp menu
    agfetch:            ;compara ax com as contas existentes em ag_num
        cmp ax, world[bx]
        je notprint
        
        add bx,4
        cmp world[bx],0
        jne agfetch
        
        mov [bx],ax
    jmp back
    
;========================================listar contas
    listar_contas:
    lea si, [aCliente+ cliente.conta]						;move primeira conta para si: deslocando o tamanho ate conta
    mov cx, aSize											            ;move para cx o numero de elementos no vetor

    accountshow:
        lea bx, [si+2]
        cmp world[bx],0
        je semconta         ;caso não seja uma posicao valida
        mov ax,[si]         ;movo o numero da conta para ax
        call print_number   ;chamo o procedimendo para imprimir
    semconta:
        add si, world[sSize]								           ;avança para a proxima(si+28)
    loop accountshow
    jmp menu
    
end:
times 510 - ($ - $$) db 0
dw 0xAA55


