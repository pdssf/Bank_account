0x7C00
jmp start

STRUC cliente
    .nome resb 21
    .CPF resb 6
    .agencia resb 6
    .conta resb 6
    .validade resb 1
ENDSTRUC

;campo de declaracao de string

opcao db "Nome:"10,13,0

Menu db 'escolha sua opcao', 10, 13,'1-casdastrar nova conta', 10, 13, '2-buscar conta', 10, 13, '3-editar conta', 10, 13, '4-deletar conta', 10, 13, '5-listar agencias', 10, 13, '6-listar contas', 10, 13,0


aCliente: 10*cliente_size db 0
aSize: dw 10
sSize: dw 40

;ag_num times 10 db 0 					;guarda o num de uma agencia

start:
    xor ax,ax
    mov ds,ax
    
	 mov ah, 0 						;inicia o modo de video
	 mov al, 12h
	 int 10h
	
menu:
    mov si, Menu
    print_menu:
    	lodsb                          ;Carrega um byte de DS:SI em AL e depois incrementa SI
    	mov ah, 0xe                    ;Código da instrução de imprimir um caractere que está em al
    	mov bl,0xf
    	mov bh,0
		int 10h        ;Interrupção de vídeo. 
		
     	cmp  al, 0                     ;0 é o código do \0
		je done_menu
    jmp print_menu
done_menu:

    mov ah, 0
    int 16h
    sub al, '0'
    
    cmp al, 1 ;/*1-cadastrar nova conta*/
    	call cadastra
    cmp al, 2 ;/*2-buscar conta*/
    
    cmp al, 3 ;/*3-editar conta*/
    
    cmp al, 4 ;/*4-deletar conta*/
    
    cmp al, 5 ;/*5-listar agencias*/
    	call listar_agencias
    cmp al, 6 ;/*6-listar contas*/
    	call listar_contas
jmp Menu
;=======================================/*Cadastra uma nova conta:*/
cadastra:
	mov DI, opcao 			;/*Nome: ...*/ 
	call print_string:			;printa "Nome:"
	call procura:      			;procura um espaco vazio da estrutura
	;cmp si, tam_vet				;compara si com o tam do vetor
	;je .retorna					;caso nao encontre espaco valido
	mov DI, [si+.nome]			;coloca em DI a posicao onde vai escrever o nome
	call read_string:				;le o nome e salva em .nome da pos atual
	mov DI, [si+.CPF]				;coloca em DI a posicao onde vai escrever o CPF
	call read_string:				;le o CPF e salva em .nome da pos atual
	mov DI, [si+.agencia]		;coloca em DI a posicao onde vai escrever a agencia
	call read_string:				;le a agencia e salva em .nome da pos atual
	mov DI, [si+.conta]			;coloca em DI a posicao onde vai escrever a conta
	call read_string:				;le a conta e salva em .nome da pos atual
	
	.retorna
ret

;========================================/*buscando uma conta:*/

    lea si, [aCliente]                 ;vai para a primeira posição do vetor de contas
    busca:

    push si
    push ax
    push bp
    push cx 	;salva o valor original dos registradores a serem usados pelo call

    mov bp, sp 	;copia sp em bp para ficar mais facil de trabalhar
    add bp, 10 ;adicionando 10 a dp é possivel ter acesso
    				;ao endereço dos parametros a serem usados pelo call
    mov ax, [bp] 			;carrega o numero a ser buscado (x)
    mov si, [bp + 2] 	;carrega o endereço onde deve ser iniciado a busca (assume-se que v[0])

    mov cx, [aSize] 											;tamanho do vetor pra ser usado na pilha

    compara:
        cmp ax, [si + cliente.conta] ;x == v[i]?
        je salvaEndereco ;se sim, sai do loop

        add si, [sSize] ;se não, i++
        loop compara

    mov si, string 
    call print_string 	;caso a conta buscada não exista, informa ao usuario e
    mov [bp + 2], -1 	;salva -1 na posição da pilha onde originalmente estava v[0]
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
    add bp, 8 	;adicionando 8 a dp é possivel ter acesso ao endereco
    				; dos parametros a serem usados pelo call
    mov ax, [bp] ;carrega o numero da conta a ser deletado
    mov si, [bp + 2] ;carrega o endereco da posicao inicial do vetor de clientes

    push si ;
    push ax ;salva o numero da conta e o endereco de v[0] pra ser usado no procedimento busca
    call busca

    pop si
    cmp si, -1 
    jne fimDeleta ;se busca retornar -1, ou seja, a conta não existe pula pro final

    mov word[si + cliente.validade], 0 ;caso contrario sobrescreve o bit validade 
    												;"apagando" a conta

    fimDeleta:
        pop bp ;
        pop ax
        pop si ;restaura os valores originais do registrador
        ret 4 ;retorna sobrescrevendo os paramentros contidos na pilha

;========================================listar agencias:
    listar_agencias:
    
    lea si, [aCliente+ cliente.agencia]	;move primeira conta para si: deslocando o tamanho
    													; ate agencia
    mov cx, aSize				;move para cx o numero de elementos no vetor

    ag_busca:
        lea bx, [si+4]     ;carrega o bit de validade em bx
        cmp world[bx],0		;verifica se esta livre
        je notprint        ;caso não seja uma posicao valida

        mov ax,[si]        ;movo o numero da agencia para ax
        mov bx, ag_num		;
        call agfetch
    back:
        call print_number	;chama o procedimendo para imprimir numero
    notprint:					;caso nao precise printar

        add si, word[sSize];avança para a proxima(si+28)
        loop ag_busca
        jmp menu
    agfetch:            ;compara ax com as contas existentes em ag_num
        cmp ax, word[bx]
        je notprint
        
        add bx,4
        cmp word[bx],0
        jne agfetch
        
        mov [bx],ax
    jmp back
    
;========================================listar contas
listar_contas:
    lea si, [aCliente+cliente.conta]	;move primeira conta para si: 
    												;deslocando o tamanho ate conta
    mov cx, aSize								;move para cx o numero de elementos no vetor

    accountshow:
        lea bx, [si+2]
        cmp word[bx],0
        je semconta         ;caso não seja uma posicao valida
        mov ax,[si]         ;movo o numero da conta para ax
        call print_number   ;chamo o procedimendo para imprimir
    semconta:
        add si, word[sSize]								           ;avança para a proxima(si+28)
    loop accountshow
ret    
;========================================
read_string:	
	mov ah, 0 	;
	int 16h 		;  /*AL <- caracter*/				
	stosb 		;	/* tirar de AL->DI*/	
	cmp al, 13	;
	je .read:

	mov ah, 0xe ; /*exibe o que esta sendo escrito na leitura*/
	mov bl, 2
	int 10h

	jmp read_string
	.read:
ret	
;========================================
print_string:
	lodsb          ;Carrega um byte de DS:SI em AL e depois incrementa SI 		
	cmp al,0       ;0 é o código do \0
	je .printed

	mov ah, 0xe    ;Código da instrução de imprimir um caractere que está em al
	mov bl, 2      ;Cor do caractere em modos de vídeo gráficos (verde)
	int 10h        ;Interrupção de vídeo. 

	jmp print_string
	.printed:
ret
;========================================
cmp_str:
	
ret
;========================================
procura: ; /*essa funcao procura uma posicao vazia para fazer operacoes (ex:cadastrar conta)*/
	lea si, [aCliente+cliente.validade]	;seleciona o bit de validade da struc 
    												;deslocando o tamanho ate validade
   mov cx, aSize								;move para cx o numero de elementos no vetor
   .search_account:
   	lea bx, [si+cliente.validade]		;coloca o que esta armazenado em si+.validade
   												; em bx para comparar
   	cmp word[bx], 1						;caso a posicao esteja ocupada, avanca para prox posicao
   	je .invalida        					;caso não seja uma posicao valida
   	mov [si+cliente.validade], 1     ;movo o numero da conta para ax
   	ret  										;retorna apos preencher a posicao valida
   .invalida:
   	add si, word[sSize]					;avança para a proxima(si+28)
   loop .search_account						;se sair desse loop, nao encontrou espaco   
ret
;========================================    
end:
times 510 - ($ - $$) db 0
dw 0xAA55


