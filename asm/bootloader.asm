first:
	mov ax, 0x7C0
		mov ds,ax
		mov es,ax

	mov ah, 0x2
	mov al, 0x3
	mov bx, second
	mov ch, 0x0
	mov cl, 0x2
	mov dh, 0x0
	int 0x13
		
; Request The Data		
	mov si, .msg
	call procedures.puts
; Get The Number
	xor cx,cx
	call procedures.getn
; Store The Number
	mov [data], cx
; Get The String Until A New Line
	mov bh, 0xD
	mov di, data+0x2
	call procedures.gets
	
	jmp second
	
.msg db "Enter A Number And A String.",0xD,0x0

	times 0x200-0x2-($-first) db 0x0
	dw 0xAA55
	
second: 
; Print The First Message
	mov si, .msg1
	call procedures.puts
; Print The Number
	mov ax, [data]
	call procedures.putn
; Print The Second Message
	mov si, .msg2
	call procedures.puts
; Print The String
	mov si, data+0x2
	call procedures.puts
	
	jmp $
	
.msg1 db "You Entered The Number ",0x0
.msg2 db " And The String: ",0x0

	times 0x200-($-second) db 0x0
	
procedures:
.ret:
; Return
	ret
.cls:
; Function #2: Set Cursor Position
	mov ah, 0x2
; First Video Page
	mov bh, 0x0
; First Cell
	xor dx,dx
; BIOS Video Interrupt
	int 0x10
; Function #9: Print Character And Color
	mov ah, 0x9
; Fill The Whole Screen
	mov cx, 0x1000
; BIOS Video Interrupt
	int 0x10
; Return
	ret
.putc:
; Function #14: Teletype Character
	mov ah, 0xE
; First Video Page
	mov bh, 0x0
; BIOS Video Interrupt
	int 0x10
; Return If It's Not A Carriage Return
	cmp al, 0xD
	jne .ret
; Print A New Line
	mov al, 0xA
	jmp .putc
.puts:
; Load A Character
	lodsb
; Return If It's 0
	test al,al
	jz .ret
; Print The Character
	call .putc
; Next Character
	jmp .puts
.putn:
; Null
	xor dx,dx
; Get The 5th Digit
	mov cx, 0d10000
	div cx
; Make It A Character
	add al, '0'
; Print The Digit
	call .putc
; Do The Same With The Remainder
	mov ax,dx
	xor dx,dx
; 4th Digit
	mov cx, 0d1000
	div cx
	add al, '0'
	call .putc
	mov ax,dx
	xor dx,dx
; 3rd Digit
	mov cx, 0d100
	div cx
	add al, '0'
	call .putc
	mov ax,dx
	xor dx,dx
; 2nd Digit
	mov cx, 0d10
	div cx
	add al, '0'
	call .putc
; 1st Digit
	mov ax,dx
	add al, '0'
	call .putc
; Return
	ret
.getc:
; Function #0: Wait And Read Key
	mov ah, 0x0
; BIOS Keyboard Interrupt
	int 0x16
; Save AX And Print The Character
	push ax
		call .putc
	pop ax
; Return
	ret
.gets:
; Make The Character 0
	mov byte [es:di], 0x0
; Save BX And Get A Character
	push bx
		call .getc
	pop bx
; Return If It's BH
	cmp al,bh
	je .ret
; Store The Character
	stosb
; Next Character
	jmp .gets
.getn:
; Get A Character
	call .getc
; Return If It's Not A Digit
	cmp al, '0'
	jl .ret
	cmp al, '9'
	jg .ret
; Make It A Number
	sub al, '0'
; Shift One Space Left
	imul cx, 0d10
; Append The Digit
	xor ah,ah
	add cx,ax
; Next Digit
	jmp .getn

data:
	times 0x200-($-data) db 0x0