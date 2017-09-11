org 0x7c00
jmp 0x0000:start

start:
	xor ax, ax
	mov ds, ax

	;Reseta o disco
	inicio:

            mov ah, 0		;
            int 13H  		;
            jc inicio     		;verifica o CF. Se 0, foi lido com sucesso. Se 1, le novamente
        
            mov cx, 0x7E0 		;endereço de bank.asm
            mov es, cx    		; salva em es
            mov bx, 0 		; bx tem que estar com zero pois eh o offset de memoria
            
	;Le no disco
        read_disk:

            mov ah, 2           ;ler disco
            mov al, 2           ;numero de setrores
            mov ch, 0           ;numero do cilindro (??)
            mov cl, 2           ;numero do setor
            mov dh, 0           ;numero da cabeça
            mov dl, 0           ;numero do disco
            int 13H  
        jc read_disk
        
	jmp 0x7E00  ;pula para essa memoria

times 510-($-$$) db 0		; preenche o resto do setor com zeros 
dw 0xaa55					; coloca a assinatura de boot no final        
							
