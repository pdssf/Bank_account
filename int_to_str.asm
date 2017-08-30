; Converts int to string and vice-versa storing 
; values in 16 bits registers.
;
; Assembly is the best-worst love of all time.
; Made by Jose Gerson Fialho Neto - jgfn1@github.com
;
org 0x7c00
jmp 0x0000:_main

integer db 0

;--------------------------main--------------------------; 
_main:

jmp end
;--------------------------main_end----------------------; 

; Function which converts a string to an integer.
; To use it, put the string pointer in the si reg and
; then get the result in the "integer" variable.
; 
; for(si=0; string[i] != '\0'; ++si)
; {
; 	integer *= 10;
; 	integer += string[si] - 48;
; }
string_to_int:

	.loop:
		
		mov al, byte[integer]
		mov al, [si] 			;equivalent to the first part of lodsb
		cmp al, 0 				;if string[si] == 0
		je .endfunc 			; jump to endfunc

		mov al, byte[ten] 		;multiplies the integer by 10
		mul byte[integer]
		mov byte[integer], al
		
		mov bl, [si]
		add byte[integer], bl	;integer + si (ASCII)
		sub byte [integer], 48	;integer - 48 (integer)

		inc si 					;second part of lodsb

	jmp .loop

.endfunc:
ret

; To use this function, put the value you wanna print in the
; reg ax and be sure that there's no important data in the regs
; dx and cl.
int_to_string:
	xor dx, dx
	xor cl, cl
	.sts:			;começa conversão (sts = send to stack)
			div byte[ten]		;divide ax por cl(10) salva quociente em al e resto em ah
			mov dl, ah		;manda ah pra dl
			mov ah, 0		;zera ah
			push dx			;manda dx pra pilha
			inc cl			;incrementa cl
			cmp al, 0		;compara o quociente(al) com 0
			jne .sts		;se não for 0 manda próximo caractere para pilha

	.print:						;caso contrário
			pop ax			;pop na pilha pra ax
			add al, 48		;transforma numero em char
			call print_char	;imprime char em al
			dec cl			;decrementa cl
			cmp cl, 0		;compara cl com 0
			jne .print		;se o contador não for 0, imprima o próximo char

ret				;caso contrario, retorne

end:
jmp $
times 510 - ($ - $$) db 0
dw 0xaa55