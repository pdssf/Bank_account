org 0x7e00
jmp 0x0000:start


STRUC register
    .name resb 21
    .CPF resb 6                        ;CPF is the Brazillian equivalent to the American Social Security Number
    .agency resb 6
    .account resb 6
    .validity resb 1
    .size:
ENDSTRUC

SEGMENT .data                                   

;Variable declaration field
string db 'original:',  0; variavel com 50 espaços de memoria
menu_str db '                        Choose your option:', 10, 13,10, 13,10,13,'1 - Register New Account', '         2 - Query Account', '         3 - Edit Account', 10, 13,10, 13,10,13, '4 - Delete Account', '               5 - List Agencies', '         6 - List Accounts', 10, 13,10, 13,0
cpf_str db 10, 13,'CPF:  ',0
agency_str db 10, 13, 'Agency:  ',0
account_str db 10, 13, 'Account:  ',0
check db 'Debug:', 0
name_str db 10,13,'Name:  ',0
array_size db 10

client: ISTRUC register                ;declarando variavel do tipo register
    AT register.name, DB 'Paulo',0             
    AT register.CPF, DB 0              ;CPF is the Brazillian equivalent to the American Social Security Number
    AT register.agency, DB 0
    AT register.account, DB 0
    AT register.validity, DB 0
IEND

SEGMENT .bss

client_array: resb 10*register.size ;reserves space for 10 structures
client_size:	EQU ($ - client_array) / register.size

SEGMENT .text

start:

   xor ax,ax
   mov ds,ax
    	
	;mode 12h (video)
   mov ah, 0x0
   mov al,12h
   int 10h
   
   ;fundo azul
   mov ah, 0xb
   mov bh, 0
   mov bl, 1
   int 10h
	

	menu:
	mov si, menu_str
	call print_string
	
    mov ah, 0
    int 16h
    sub al, '0'
    
    cmp al, 1                           ;1 - Register New Account
    jne not_1
    	call register_account
    jmp menu
    
    not_1:	
    cmp al, 2                           ;2 - Query Account
        
    cmp al, 3                           ;3 - Edit Account
    
    cmp al, 4                           ;4 - Delete Account
    
    cmp al, 5                           ;5 - List Agencies
    jne not_5
    	call list_agencies
    jmp menu
    not_5:
    
    cmp al, 6                           ;6 - List Accounts
    jne not_6
    	call list_accounts
    jmp menu
    not_6:
jmp menu

;======================================= Registers a new account:
register_account:

	;checks validity
	mov si, client_array
	mov al, [si+register.validity]
	add al, 48
	call print_char
	call print_enter
	
	;prints "Name:\n"
	push si
	mov si, name_str		            
	call print_string
	pop si
	
	call searches      			   ;searchs for an empty slot in the structure
	;cmp si, vec_size				   ;compares si with vec_size
	;je .returns					   ;returns in case there's no such slot
	
	lea di, [si+register.name]		;points di to the position in wich the name will be written
	call read_string				   ;reads the name and saves in .name of the current position
   
   push si
   lea si, [si+register.name]
   call print_string
   call print_enter
   pop si
   
	mov al, [si+register.validity]
	add al, 48
	call print_char
	call print_enter
	
   ;prints "cpf:"
   push si
   mov si, cpf_str           			
   call print_string
   pop si

   lea di, [si+register.CPF] ;points di to the position to write CPF
   call read_string            ;reads the CPF and stores in .name of the current position
	
	push si
   lea si, [si+register.CPF]
   call print_string
   call print_enter
   pop si
   
   ;prints "Agency:"
   push si
   mov si, agency_str                   
   call print_string
   pop si

   lea di, [si+register.agency]	;points di to the position to write agency
	call read_string				   ;reads the agency and saves in .name of the current position

	push si
   lea si, [si+register.agency]
   call print_string
   call print_enter
   pop si
   
   push si
   mov si, account_str                   
   call print_string	
   pop si

   lea di, [si+register.account]	;points di to the position to write account
	call read_string				   ;reads the account and saves in .name of the current position
	
	push si
   lea si, [si+register.account]
   call print_string
   call print_enter
   pop si
   
	mov si, client_array
	mov al, [si+register.validity]
	add al, 48
	call print_char
ret
 
;=======================================/*buscando uma conta:*/:
find_account:
    lea si, [client_array]             ;vai para a primeira posição do vetor de contas

    push si
    push ax
    push bp
    push cx 	                       ;salva o valor original dos registradores a serem usados pelo call

    mov bp, sp 	                       ;copia sp em bp para ficar mais facil de trabalhar
    add bp, 10                         ;adicionando 10 a dp é possivel ter acesso
    				                   ;ao endereço dos parametros a serem usados pelo call
    mov ax, [bp] 			           ;carrega o numero a ser buscado (x)
    mov si, [bp + 2] 	               ;carrega o endereço onde deve ser iniciado a busca (assume-se que v[0])

    mov cx, [array_size] 			   ;tamanho do vetor pra ser usado na pilha

    compara: 
        cmp ax, [si + register.account];x == v[i]?
        je salvaEndereco               ;se sim, sai do loop

        add si, [register.size]          ;se não, i++
        loop compara

    mov si, [si + register.account] 
    call print_string 	               ;caso a conta buscada não exista, informa ao usuario e
    mov word[bp + 2], -1 	           ;salva -1 na posição da pilha onde originalmente estava v[0]
    jmp fimBusca

    salvaEndereco:
        mov [bp + 2], si               ;salva v[i] na posição da pilha onde antes existia v[0]

    fimBusca:
        pop cx ;
        pop bp
        pop ax
        pop si                         ;restaura os valores originais dos registradores usados no call
        ret 2                          ;retorna incrementando sp em 2 para sobrescrever o local onde estava o parametro x
ret
;========================================deletando uma conta:

    deleta:
    ;push si 
    ;push ax
    ;push bp                           ;salva o valor original dos registradores a serem usados pelo call
    ;mov bp, sp                        ;copia sp em bp para ficar mais facil de trabalhar
    ;add bp, 8 	                       ;adicionando 8 a dp é possivel ter acesso ao endereco
    				                   ;dos parametros a serem usados pelo call
    ;mov ax, [bp]                      ;carrega o numero da conta a ser deletado
    ;mov si, [bp + 2]                  ;carrega o endereco da posicao inicial do vetor de clientes

    ;push si 
    ;push ax                           ;salva o numero da conta e o endereco de v[0] pra ser usado no procedimento busca
    ;call busca

    ;pop si
    ;cmp si, -1 
    ;jne fimDeleta                     ;se busca retornar -1, ou seja, a conta não existe pula pro final

    ;mov word[si + register.validity], 0 ;caso contrario sobrescreve o bit validade 
    								   ;"apagando" a conta

    ;fimDeleta:
        ;pop bp ;
        ;pop ax
        ;pop si                        ;restaura os valores originais do registrador
        ;ret 4                         ;retorna sobrescrevendo os paramentros contidos na pilha

;========================================listar agencias:
    list_agencies:
    
    lea di, [client_array]	;move primeira conta para si: deslocando o tamanho ate agencia
    mov cx, 10				;move para cx o numero de elementos no vetor

    ag_busca:
        lea bx, [di + register.validity]     ;carrega o bit de validade em bx
        cmp byte[bx],0		;verifica se esta livre
        je notbusca        ;caso não seja uma posicao valida

        mov si,[di + register.agency]        ;movo o numero da agencia para si
				mov dx, 6        
        xchg dx,cx
        ag_prt:
       		  lodsb          
            mov ah, 0xe    
            mov bl, 2      
            int 10h                    
       loop ag_prt
       
        xchg cx,dx
        
    notbusca:					;caso nao precise printar
    
        add di, word[register.size];avança para a proxima(si+28)
        loop ag_busca
    
    ret
;========================================listar contas:

list_accounts:
    lea di, [client_array]	;move primeira conta para dx: 
                                            ;deslocando o tamanho ate conta
    mov cx, 10		;move para cx o numero de elementos no vetor

    account_show:
        lea bx, [di + register.validity]
        cmp byte[bx],0
        je not_acc         ;caso não seja uma posicao valida
        mov si,[di + register.account]	;posicao do valor da conta
        xchg bx,cx
        mov cx, 6
        acc_prt:

        lodsb          
            mov ah, 0xe    
            mov bl, 2      
            int 10h        
            loop acc_prt
        xchg cx,bx
        
    not_acc:
        add di, word[register.size]	;avança para a proxima(si+28)
    loop account_show
ret    
;========================================:
read_string:	
	mov ah, 0 	;
	int 16h 		;  /*AL <- caracter*/				
	;stosb 		;	/* tirar de AL->DI*/	
	mov [di], al
	inc di
	cmp al, 13	;
	je .read

	call print_char ; /*exibe o que esta sendo escrito na leitura*/

	jmp read_string
	.read:
	call print_enter
ret	
;========================================:
print_string:
	;lodsb          ;Carrega um byte de DS:SI em AL e depois incrementa SI 	
	mov al, byte[si]
	inc si	
	cmp al,0       ;0 é o código do \0
	je .printed

	call print_char

	jmp print_string
	.printed:
ret

miscmp:
	;/*compara 2 strings em ES:DI e DS:SI não esquecer de setar cx com o tamanho das strings*/
	repe cmpsb			;/*repete enquanto cx!=0 e ZF==1*/
	;/*retorna, e deve ser verificado o conteudo de CX*/
ret

;========================================:
searches: ; /*essa funcao procura uma posicao vazia para fazer operacoes (ex:register conta)*/
	lea si, [client_array]	;recebe a posicao inicial do array struc
    												;deslocando o tamanho ate validade
   mov cx, array_size								;move para cx o numero de elementos no vetor
   .search_account:
   	lea bx, [si+register.validity]		;coloca o que esta armazenado em si+.validade
   																		; em bx para comparar
   	cmp word[bx], 1						;caso a posicao esteja ocupada, avanca para prox posicao
   	je .invalida        					;caso não seja uma posicao valida
   	mov byte[si + register.validity], 1     ;movo o numero da conta para ax
   	ret  										;retorna apos preencher a posicao valida
   .invalida:
   	add si, word[register.size]					;avança para a proxima(si+40)
   loop .search_account						;se sair desse loop, nao encontrou espaco
ret
;========================================:
print_char:
	mov ah, 0xe  ;code of the instruction to print a char which is in al
   mov bl, 0xf
	int 10h   
ret
;========================================:
print_enter:	
	mov al, 13	;chama um enter para descer a tela
	call print_char
   mov al, 10
   call print_char
ret

end:
jmp $
times 510-($-$$) db 0		; preenche o resto do setor com zeros 
dw 0xaa55					; coloca a assinatura de boot no final
							; do setor (x86 : little endian)
