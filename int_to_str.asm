org 0x7c00
jmp 0x0000:_main

; Converts int to string and vice-versa storing 
; values in 16 bits registers.
;
; Assembly is the best-worst love of all time.
; Made by Jose Gerson Fialho Neto - jgfn1@github.com
;

integer dw 0
ten db 10

;--------------------------main--------------------------; 
_main:

jmp end
;--------------------------main_end----------------------; 

; Function which converts a string to an integer.
; To use it, put the string pointer in the si reg and
; then get the result in the "integer" variable.
; Make sure AX and BX does not contain any important data.
; 
; for(si=0; string[i] != '\0'; ++si)
; {
; 	integer *= 10;
; 	integer += string[si] - 48;
; }
string_to_int:

	.loop:
		
		mov ax, word[integer]
		mov ax, [si] 			;equivalent to the first part of lodsb
		cmp ax, 0 				;if string[si] == 0
		je .endfunc 			; jump to endfunc

		mov ax, word[ten] 		;multiplies the integer by 10
		mul word[integer]
		mov word[integer], ax
		
		mov bx, [si]
		add word[integer], bx	;integer + si (ASCII)
		sub word [integer], 48	;integer - 48 (integer)

		inc si 					;second part of lodsb

	jmp .loop

.endfunc:
ret

; To use this function, put the value you wanna print in the
; reg ax and be sure that there's no important data in the regs
; dx and cl.
int_to_string:					;prints the integer in ax

	xor dx, dx
	xor cl, cl
	
	.sts:						;let the fun begin (sts = send to stack)
			div byte[ten]		;divides ax by cl(10), saves the quocient in al and the remainder in ah
			mov dl, ah			;sends the remainder to dl
			mov ah, 0			;ah = 0
			push dx				;sends dx to the stack
			inc cl				;increments cl
			cmp al, 0			;compares the quocient(al) with 0
	jne .sts					;if it's not 0, sends the next char to the stack

	.print:						;else
			pop ax				;pops to ax
			add al, 48			;transforms the int into char
			call print_char		;prints char which's in al
			dec cl				;decrements cl
			cmp cl, 0			;compares cl with 0
	jne .print					;if the counter != 0, prints the next char

ret								;else, returns

end:
jmp $
times 510 - ($ - $$) db 0
dw 0xaa55