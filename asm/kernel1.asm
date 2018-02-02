kernel: 	
; Kernel Segment
	mov ax, 0x8C0
		mov ds,ax
; Function #3: Get Cursor Info
	mov ah, 0x3
; First Video Page
	mov bh, 0x0
; BIOS Video Interrupt
	int 0x10
; Null
	mov al, 0x0
; Green On White
	mov bl, 0xF2
; Clear The Screen
	call .cls
; Print The Message
	mov si, .msg
	call .puts
; Infinite Loop
	jmp 0x1000:0x0
	
.ret:
; Return
	ret
.cls:
; Function #2: Set Cursor Position
	mov ah, 0x2
; First Video Page
	mov bh, 0x0
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
	
.msg db "Hello From First Kernel.",0xD,0x0

	times 0x200-0x14-($-kernel) db 0x0
; System Name, Size And Signature
	db "FirstKernelTest ",0x0,0x1,0xBB,0x46