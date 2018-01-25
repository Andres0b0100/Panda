; The Boot Loader Segment
	mov ax, 0x7C0
		mov ds,ax
		
; Message To Print
	mov si, msg
; Call The Procedure
	call puts

; Loop Infinitely
	jmp $

msg db "Hello World!",0x0

puts:
; Load A Character
	lodsb
; Return If It's 0
	test al,al
	jz .end
; Function #14: Teletype Character
	mov ah, 0xE
; First Video Page
	mov bh, 0x0
; BIOS Video Interrupt
	int 0x10
; Next Character
	jmp puts
.end:
; Exit From The Function
	ret

; Fill The Rest Of The Sector
	times 0x200-0x2-($-$$) db 0x0
	dw 0xAA55