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
full_str db 'Nao ha mais espaco. Delete uma conta antes de cadastrar outra.', 10, 13, 0
array_size db 10
input_string times 6 db 0
searching db 'Searching...', 10, 13, 0

client: ISTRUC register                ;declaring struc register variable type
    AT register.name, DB 0             
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
	
	;/*Reads input char*/
	call read_char	
    
	cmp al, '1'					;1 - Register New Account
	jne not_1
		call register_account
		jmp menu    
	not_1:	
	cmp al, '2'					;2 - Find account
	jne not_2
		call find_account
		jmp menu
   not_2:
   cmp al, '3'					;3 - Edit Account
   jne not_3
   	call edit_account
   	jmp menu
	not_3:    
   cmp al, '4'					;4 - Delete Account
   jne not_4
      call delete_account
      jmp menu
   not_4: 
   cmp al, '5'					;5 - List Agencies
   jne not_5
   	call list_agencies
   	jmp menu
   not_5:    
   cmp al, 6               ;6 - List Accounts
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
	
	call searches_validity      ;searchs for an empty slot in the structure
	;cmp si, array_size	 ;compares si with vec_size
	cmp dx, 1
	je menu		 ;returns in case there's no such slot
	
	;prints "Name:"
	push si
	mov si, name_str		            
	call print_string
	pop si
	
	;reads the name
	lea di, [si+register.name]		;points di to the position in wich the name will be written
	call read_string				   ;reads the name and saves in .name of the current position
   
   ;prints the name
   push si
   lea si, [si+register.name]
   call print_string
   call print_enter
   pop si
	
   ;prints "cpf:"
   push si
   mov si, cpf_str           			
   call print_string
   pop si

	;reads the CPF
   lea di, [si+register.CPF] ;points di to the position to write CPF
   call read_string            ;reads the CPF and stores in .name of the current position
	
	;prints the CPF
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

	;reads the agency
   lea di, [si+register.agency]	;points di to the position to write agency
	call read_string				   ;reads the agency and saves in .name of the current position

	;prints the agency
	push si
   lea si, [si+register.agency]
   call print_string
   call print_enter
   pop si
   
   ;prints "Account:"
   push si
   mov si, account_str                   
   call print_string	
   pop si

	;reads the account
   lea di, [si+register.account]	;points di to the position to write account
	call read_string				   ;reads the account and saves in .name of the current position
	
	;prints the account
	push si
   lea si, [si+register.account]
   call print_string
   call print_enter
   pop si
   
   ;prints validity number
	mov si, client_array
	mov al, [si+register.validity]
	add al, 48
	call print_char
ret
 
;=======================================/*buscando uma conta:*/:
find_account:
	call searches_string   ;call query procedure
	cmp si, 0              ;if procedure return si = 0 there's no account with that number
	je .notFound           ;so jump to .notFound label

	mov bl, 2                 
   mov cx, si
        
	lea si, [name_str]
	call print_string
	xchg cx, si
	add si, register.name
	call print_string      ;Print the name
	mov ah, 0xe
	mov al, 0xa
	int 10h
	mov al, 0xd
	int 10h

	lea si, [cpf_str]
	call print_string
	xchg cx, si
	add si, register.CPF
	call print_string          ;CPF
	mov ah, 0xe
	mov al, 0xa
	int 10h
	mov al, 0xd
	int 10h

	lea si, [agency_str]
	call print_string
	xchg cx, si
	add si, register.agency
	call print_string          ;and agency of the account 
	mov ah, 0xe
	mov al, 0xa
	int 10h
	mov al, 0xd
	int 10h
ret

.notFound:               ;print account not found and return
	lea si, [error_str]
	call print_string
ret
;========================================deletando uma conta:
delete_account:
    call busca
    cmp si, 0
    je .naoEncontrada

    mov byte[si + register.validity], 0
    ret

    .naoEncontrada:
        lea si, [error_str]
        call print_string
ret
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
;========================================:
miscmp:
	;/*compara 2 strings em ES:DI e DS:SI não esquecer de setar cx com o tamanho das strings*/
	repe cmpsb			;/*repete enquanto cx!=0 e ZF==1*/
	;/*retorna, e deve ser verificado o conteudo de CX*/
ret
;========================================:
searches_validity: ; /*essa funcao procura uma posicao vazia para fazer operacoes (ex:register conta)*/
	lea si, [client_array]					;recebe a posicao inicial do array struc
	mov dx, 0
   mov cx, 10									;move para cx o numero de elementos no vetor
   .search_account:
   	lea bx, [si+register.validity]	;coloca o que esta armazenado em si+.validade
   												; em bx para comparar
   	cmp word[bx], 1						;caso a posicao esteja ocupada, avanca para prox posicao
   	je .invalida        					;caso não seja uma posicao valida
   	mov byte[si+register.validity],1 ;movo o numero da conta para ax
   	ret  										;retorna apos preencher a posicao valida
   .invalida:
   	add si, word[register.size]		;avança para a proxima(si+40)
   	
   loop .search_account						;se sair desse loop, nao encontrou espaco
   mov si, full_str
   call print_string
   mov dx, 1
ret
;========================================:
searches_string:
    lea si, searching
    call print_string

    lea di, [input_string]              
    call read_string                     ;get the account with the user
    mov byte[di+1], 0

    lea si, [client_array + register.account]
    mov di, [input_string]

    mov cx, [array_size]
    .compara:                         ;while(cmp_str!=1 && CX>=0)
        push si
        push di
        call cmp_str                  ;call procedure to compare the strings 

        pop ax
        cmp ax, 1                     ;if they are equal it'll return 1
        je .encontrada                ;so get out the loop

        add si, word[client_size]             ;else, do i = i + sSize and keep the loop
        loop .compara                 

        mov si, 0
        ret

    .encontrada:
        sub si, [register.account]                ;si = si - cliente.conta to get the adress of aCliente[i]
        ret
;========================================:
cmp_str:
    push si                        ;save registers on the stack
    push di
    push cx
    push bp

    mov bp, sp
    add bp, 10

    mov di, [bp]                   ;get the strings to compare from the stack
    mov si, [bp + 2]

    mov cx, 6
    repe cmpsb                     ;compare them
    jz .ret_e                      

    mov word[bp +2], 0                ;if(string1 != string2) return 0
    jmp .end

    .ret_e:
        mov word[bp + 2], 1           ;else return 1

    .end:
        pop bp
        pop cx
        pop di
        pop si                    ;unstack the registers

ret 2                     ;return
;========================================
print_char:
	mov ah, 0xe  ;code of the instruction to print a char which is in al
   mov bl, 0xf
	int 10h   
ret
;========================================:
read_char:	
	mov ah, 0
   int 16h
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
