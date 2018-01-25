first:
	mov ax, 0x7C0
		mov ds,ax
		mov es,ax
		
	mov si, .msg
	call puts

; Function #2: Read Disk	
	mov ah, 0x2
; Sectors To Read
	mov al, 0x1
; The Second Stage Offset
	mov bx, second
; Cylinder Number
	mov ch, 0x0
; Sector Number
	mov cl, 0x2
; Head Number
	mov dh, 0x0
; BIOS Disk Interrupt
	int 0x13
	
; Jump To The Second Stage
	jmp second

.msg db "First Stage.",0xD,0xA,0x0

puts:
	lodsb
	test al,al
	jz .end
	mov ah, 0xE
	mov bh, 0x0
	int 0x10
	jmp puts
.end:
	ret

	times 0x200-0x2-($-first) db 0x0
	dw 0xAA55
	
second: 
	mov si, .msg
	call puts
	
	jmp $
	
.msg db "Second Stage.",0x0
; Fill Another Sector
	times 0x200-($-second) db 0x0