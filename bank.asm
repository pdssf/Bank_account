org 0x7C00
jmp 0x0000:start

STRUC client
    .name resb 21
    .CPF resb 6        ;CPF is the Brazillian equivalent to the American Social Security Number
    .agency resb 6
    .account resb 6
    .validity resb 1
ENDSTRUC

SEGMENT .data
cliente: ISTRUC client
    AT client.name, DB 0
    AT client.CPF, DB 0        ;CPF is the Brazillian equivalent to the American Social Security Number
    AT client.agency, DB 0
    AT client.account, DB 0
    AT client.validity, DB 0
IEND

;string declaration field

SEGMENT .bss

option db "Name:", 10,13,0

menu_str db 'Choose your option', 10, 13,'1 - Register New Account', 10, 13, '2 - Query Account', 10, 13, '3 - Edit Account', 10, 13, '4 - Delete Account', 10, 13, '5 - List Agencies', 10, 13, '6 - List Accounts', 10, 13,0

cliente_array: resb 10*client.size ;reserves space for 10 structures
array_size: dw 10
cliente_size: dw 40 ;unecessary if client.size works out

;ag_num times 10 db 0 				   ;saves the No. of an agency

SEGMENT .text
start:
    xor ax,ax
    mov ds,ax
    
	 mov ah, 0 						   ;enters the video mode
	 mov al, 12h
	 int 10h
	
menu:
    mov si, menu_str
    print_menu:
    	lodsb                          ;loads a byte from DS:SI into AL and then increments SI
    	mov ah, 0xe                    ;code of the instruction to print a char which is in al
    	mov bl,0xf
    	mov bh,0
		int 10h                        ;video interruption 
		
     	cmp  al, 0                     ;checks if it didn't reach the end of the string
		je done_menu
    jmp print_menu
done_menu:

    mov ah, 0
    int 16h
    sub al, '0'
    
    cmp al, 1                           ;1 - Register New Account
    	call register
    cmp al, 2                           ;2 - Query Account
    
    cmp al, 3                           ;3 - Edit Account
    
    cmp al, 4                           ;4 - Delete Account
    
    cmp al, 5                           ;5 - List Agencies
    	call listar_agencias
    cmp al, 6                           ;6 - List Accounts
    	call listar_contas
jmp menu_str

;======================================= Registers a new account:
register:
	mov di, option 			           ;/*Name: ...*/ 
	call print_string:			       ;prints "Name:"
	call searchs:      			       ;searchs for an empty slot in the structure
	;cmp si, vec_size				   ;compares si with vec_size
	;je .returns					   ;returns in case there's no such slot
	mov di, [si+.nome]			       ;points di to the position in wich the name will be written
	call read_string:				   ;reads the name and saves in .name of the current position
	mov di, [si+.CPF]				   ;points di to the position in which the CPF will be written
	call read_string:				   ;reads the CPF and stores in .name of the current position
	mov di, [si+.agencia]		       ;points di to the position in which the agency will be written
	call read_string:				   ;reads the agency and saves in .name of the current position
	mov di, [si+.conta]			       ;points di to the position in which the account will be written
	call read_string:				   ;reads the account and saves in .name of the current position
	
	;.returns
ret

;=======================================/*buscando uma conta:*/

    lea si, [client_array]                 ;vai para a primeira posição do vetor de contas
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

    mov cx, [array_size] 											;tamanho do vetor pra ser usado na pilha

    compara:
        cmp ax, [si + cliente.conta] ;x == v[i]?
        je salvaEndereco ;se sim, sai do loop

        add si, [cliente_size] ;se não, i++
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
    
    lea si, [client_array+ cliente.agencia]	;move primeira conta para si: deslocando o tamanho
    													; ate agencia
    mov cx, array_size				;move para cx o numero de elementos no vetor

    ag_busca:
        lea bx, [si+4]     ;carrega o bit de validade em bx
        cmp word[bx],0		;verifica se esta livre
        je notprint        ;caso não seja uma posicao valida

        mov ax,[si]        ;movo o numero da agencia para ax
        mov bx, ag_num		;
        call agfetch
    back:
        call print_number	;chama o procedimendo para imprimir numero
    notprint:					;caso nao precise printar

        add si, word[cliente_size];avança para a proxima(si+28)
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
    lea si, [client_array+cliente.conta]	;move primeira conta para si: 
    												;deslocando o tamanho ate conta
    mov cx, array_size								;move para cx o numero de elementos no vetor

    accountshow:
        lea bx, [si+2]
        cmp word[bx],0
        je semconta         ;caso não seja uma posicao valida
        mov ax,[si]         ;movo o numero da conta para ax
        call print_number   ;chamo o procedimendo para imprimir
    semconta:
        add si, word[cliente_size]								           ;avança para a proxima(si+28)
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
procura: ; /*essa funcao procura uma posicao vazia para fazer operacoes (ex:register conta)*/
	lea si, [client_array+cliente.validade]	;seleciona o bit de validade da struc 
    												;deslocando o tamanho ate validade
   mov cx, array_size								;move para cx o numero de elementos no vetor
   .search_account:
   	lea bx, [si+cliente.validade]		;coloca o que esta armazenado em si+.validade
   												; em bx para comparar
   	cmp word[bx], 1						;caso a posicao esteja ocupada, avanca para prox posicao
   	je .invalida        					;caso não seja uma posicao valida
   	mov [si+cliente.validade], 1     ;movo o numero da conta para ax
   	ret  										;retorna apos preencher a posicao valida
   .invalida:
   	add si, word[cliente_size]					;avança para a proxima(si+28)
   loop .search_account						;se sair desse loop, nao encontrou espaco   
ret
;========================================    
end:
times 510 - ($ - $$) db 0
dw 0xAA55


