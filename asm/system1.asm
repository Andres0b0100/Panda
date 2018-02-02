system: 	
; System Segment
	mov ax, 0x1000
		mov ds,ax
; Print The Message
	mov si, .msg
	call .puts
; Infinite Loop
	jmp $
	
.ret:
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
	
.msg db "Hello From First System.",0xD,0x0

	times 0x200-0x14-($-system) db 0x0
; System Name, Size And Signature
	db "FirstSystemTest ",0x0,0x1,0x33,0x57