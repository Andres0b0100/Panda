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

.cls:	
; Null
	mov al, 0x0
; Foreground Cyan
	mov bl, 0xB
; Clear the Screen
	call procedures.cls
.operation:
; Function #3: Get Cursor Position
	mov ah, 0x3
; First Video Page
	mov bh, 0x0
; BIOS Video Interrupt
	int 0x10
; Clear The Screen If It's At The Last Row
	cmp dh, 0x18
	jge .cls
; Get An Operand
	xor cx,cx
	call procedures.getn
; Save The Operand
	push cx
.switch:
; Jump To The Corresponding Procedure
		cmp al,'+'
		je second.add
		cmp al,'-'
		je second.sub
		cmp al,'*'
		je second.mul
		cmp al,'/'
		je second.div
		cmp al,'%'
		je second.mod
		cmp al,'&'
		je second.and
		cmp al,'|'
		je second.or
		cmp al,'^'
		je second.xor
		cmp al,'<'
		je second.shl
		cmp al,'>'
		je second.shr
		cmp al,'!'
		je second.not
		cmp al,'~'
		je second.neg
; Throw An Error If It's An Invalid Operator
		jmp second.error

	times 0x200-0x2-($-first) db 0x0
	dw 0xAA55
	
second: 
.add:
; Get The Second operand
		xor cx,cx
		call procedures.getn
	pop ax
; Sum
	add ax,cx
	push ax
; End
		jmp .end
.sub:
; Get The Second Operand
		xor cx,cx
		call procedures.getn
	pop ax
; Substract
	sub ax,cx
	push ax
; End
		jmp .end
.mul:
; Get The Second operand
		xor cx,cx
		call procedures.getn
	pop ax
; Multiplicate
	mul cx
	push ax
; End
		jmp .end
.div:
; Get The Second operand
		xor cx,cx
		call procedures.getn
; Catch Zero Division Error
		test cx,cx
		jz .error
	pop ax
; Divide
	xor dx,dx
	div cx
; Return The Quotient
	push ax
; End
		jmp .end
.mod:
; Get The Second operand
		xor cx,cx
		call procedures.getn
; Catch Zero Division Error
		test cx,cx
		jz .error
	pop ax
; Divide
	xor dx,dx
	div cx
; Return The Remainder
	push dx
; End
		jmp .end
.and:
; Get The Second operand
		xor cx,cx
		call procedures.getn
	pop ax
; Bitwise AND
	and ax,cx
	push ax
; End
		jmp .end
.or:
; Get The Second operand
		xor cx,cx
		call procedures.getn
	pop ax
; Bitwise OR
	or ax,cx
	push ax
; End
		jmp .end
.xor:
; Get The Second operand
		xor cx,cx
		call procedures.getn
	pop ax
; Bitwise XOR
	xor ax,cx
	push ax
; End
		jmp .end
.shl:
; Get The Second operand
		xor cx,cx
		call procedures.getn
	pop ax
; Bit Left Shift
	shl ax,cl
	push ax
; End
		jmp .end
.shr:
; Get The Second operand
		xor cx,cx
		call procedures.getn
	pop ax
; Bit Right Shift 
	shr ax,cl
	push ax
; End
		jmp .end
.not:
; It's An Unary Operation
	pop ax
; Bitwise NOT
	not ax
	push ax
; Write An Empty Character
		mov al, 0x0
		call procedures.putc
; End
		jmp .end
.neg:
; It's An Unary Operation
	pop ax
; Negate The Number
	neg ax
	push ax
; Write An Empty Character
		mov al, 0x0
		call procedures.putc
; End
		jmp .end
		
.error:
; Print The Error Message
	pop ax
	mov si, .msg
	call procedures.puts
; Next Operation
	jmp first.operation
	
.end:
; Backspace
		mov al, 0x8
		call procedures.putc
; Equal Sign
		mov al, '='
		call procedures.putc
; Get And Print The Result
	pop ax
	call procedures.putn
; Print A New Line
	mov al, 0xD
	call procedures.putc
; Next Operation	
	jmp first.operation

.msg db " {[(<Error>)]} ",0xD,0x0
	
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