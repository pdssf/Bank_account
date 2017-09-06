org 0x7C00
jmp 0x0000:start

STRUC register
    .name resb 21
    .CPF resb 6        ;CPF is the Brazillian equivalent to the American Social Security Number
    .agency resb 6
    .account resb 6
    .validity resb 1
		.size:
ENDSTRUC

SEGMENT .data									;declarando variavel do tipo register
client: ISTRUC register
    AT register.name, DB 0 ;bank.asm:15: error: non-constant argument supplied to TIMES    https://forum.nasm.us/index.php?topic=748.0

    AT register.CPF, DB 0        ;CPF is the Brazillian equivalent to the American Social Security Number
    AT register.agency, DB 0
    AT register.account, DB 0
    AT register.validity, DB 0
IEND

;string declaration field
option db "Name:", 10,13,0
menu_str db 'Choose your option', 10, 13,'1 - Register New Account', 10, 13, '2 - Query Account', 10, 13, '3 - Edit Account', 10, 13, '4 - Delete Account', 10, 13, '5 - List Agencies', 10, 13, '6 - List Accounts', 10, 13,0
array_size: dw 10

SEGMENT .bss

client_array: resb 10*register.size ;reserves space for 10 structures
client_size:	EQU ($ - client_array) / register.size

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
    	call create
    cmp al, 2                           ;2 - find Account
    
    cmp al, 3                           ;3 - Edit Account
    
    cmp al, 4                           ;4 - Delete Account
    
    cmp al, 5                           ;5 - List Agencies
    	call list_agencies
    cmp al, 6                           ;6 - List Accounts
    	call list_accounts
jmp menu

;======================================= Registers a new account:
create:
	mov di, option 			           ;/*Name: ...*/ 
	call print_string			       ;prints "Name:"
	call searches      			       ;searchs for an empty slot in the structure
	;cmp si, vec_size				   ;compares si with vec_size
	;je .returns					   ;returns in case there's no such slot
	mov di, [si+register.name]			       ;points di to the position in wich the name will be written
	call read_string				   ;reads the name and saves in .name of the current position
	mov di, [si+register.CPF]				   ;points di to the position in which the CPF will be written
	call read_string				   ;reads the CPF and stores in .name of the current position
	mov di, [si+register.agency]		       ;points di to the position in which the agency will be written
	call read_string				   ;reads the agency and saves in .name of the current position
	mov di, [si+register.account]			       ;points di to the position in which the account will be written
	call read_string				   ;reads the account and saves in .name of the current position
	
	;.returns
ret

;=======================================/*buscando uma conta:*/:
find_account:
    ;lea si, [client_array]                 ;vai para a primeira posição do vetor de contas

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
        cmp ax, [si + register.account] ;x == v[i]?
        je salvaEndereco ;se sim, sai do loop

        add si, [client_size] ;se não, i++
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
ret
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

    mov word[si + register.validity], 0 ;caso contrario sobrescreve o bit validade 
    												;"apagando" a conta

    fimDeleta:
        pop bp ;
        pop ax
        pop si ;restaura os valores originais do registrador
        ret 4 ;retorna sobrescrevendo os paramentros contidos na pilha

;========================================listar agencias:
    list_agencies:
    
    lea dx, [client_array]	;move primeira conta para si: deslocando o tamanho
    													; ate agencia
    mov cx, word[array_size]				;move para cx o numero de elementos no vetor

    ag_busca:
        lea bx, [dx+register.validity]     ;carrega o bit de validade em bx
        cmp word[bx],0		;verifica se esta livre
        je notprint        ;caso não seja uma posicao valida
        lea si,[dx+ register.agency] ;SI now point to the agency number
    back:
        call print_string	;chama o procedimendo para imprimir numero
    notprint:					;caso nao precise printar
        add dx, word[client_size];avança para a proxima(si+28)
        loop ag_busca
    ret
  
;========================================listar contas:
list_accounts:
    lea dx, [client_array]	;move primeira conta para dx: 
    												;deslocando o tamanho ate conta
    mov cx, word[array_size]								;move para cx o numero de elementos no vetor

    accountshow:
        lea bx, [dx+register.validity]
        cmp word[bx],0
        je not_acc         ;caso não seja uma posicao valida
        lea si,[dx+register.account]
        call print_number   ;chamo o procedimendo para imprimir
    not_acc:
        add dx, word[client_size]	;avança para a proxima(si+28)
    loop accountshow
ret    
;========================================:
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
;========================================:
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
;========================================:
cmp_str:
	
ret
;========================================:
searches: ; /*essa funcao procura uma posicao vazia para fazer operacoes (ex:register conta)*/
	lea si, [client_array+register.validity]	;seleciona o bit de validade da struc 
    												;deslocando o tamanho ate validade
   mov cx, array_size								;move para cx o numero de elementos no vetor
   .search_account:
   	lea bx, [si+register.validity]		;coloca o que esta armazenado em si+.validade
   												; em bx para comparar
   	cmp word[bx], 1						;caso a posicao esteja ocupada, avanca para prox posicao
   	je .invalida        					;caso não seja uma posicao valida
   	mov [si+register.validity], 1     ;movo o numero da conta para ax
   	ret  										;retorna apos preencher a posicao valida
   .invalida:
   	add si, word[client_size]					;avança para a proxima(si+28)
   loop .search_account						;se sair desse loop, nao encontrou espaco   
ret
;========================================:
end:
times 510 - ($ - $$) db 0
dw 0xAA55
