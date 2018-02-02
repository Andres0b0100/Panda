boot:
; boot Loader Segment
	mov ax, 0x7C0
		mov ds,ax
		mov es,ax
		mov fs,ax

; Function #2: Read Disk
	mov ah, 0x2
; Read 7 Sectors
	mov al, 0x7
; Offset
	mov bx, loader
; Cylinder
	mov ch, 0x0
; Sector
	mov cl, 0x2
; Head
	mov dh, 0x0
; BIOS Disk Interrupt
	int 0x13

; Save The Disk	
	mov [data.disk],dl

; Check If Data Is Set	
	mov ax, [data.kernel]
	test ax,ax
	jz .start
	mov ax, [data.system]
	test ax,ax
	jz .start
; Function #2: Get Keyboard Flags
	mov ah, 0x2
; BIOS Keyboard Interrupt
	int 0x16
; Load If CTRL Isn't Pressed
	test al, 0x4
	jz loader
	
.start:
; Null
	mov al, 0x0
; Cyan Text
	mov bl, 0xB
; Fill The Screen
	call procedures.cls
; Print The Commands
	mov si, .commands
	call procedures.puts
.switch:
; Get The Command
	xor cx,cx
	call procedures.getn
; Go To The Procedure
	cmp cx, 0x0
	je .lo
	cmp cx, 0x1
	je .fk
	cmp cx, 0x2
	je .sk
	cmp cx, 0x3
	je .fs
	cmp cx, 0x4
	je .ss
	cmp cx, 0x5
	je .sl
; Default
	jmp .start
.fk:
; Kernel Segment
	mov bx, 0x8C0
		mov ds,bx
		mov es,bx
; Null
	xor bp,bp
; Function #8: Get Disk Info
	mov ah, 0x8
; Disk
	mov dl, [fs:data.disk]
; BIOS Disk Interrupt
	int 0x13
.fkl:
; Function #2: Read Disk
	mov ah, 0x2
; Read One Sector
	mov al, 0x1
; Null
	xor bx,bx
	xor ch,ch
	xor dh,dh
; Disk
	mov dl, [fs:data]
; BIOS Disk Interrupt
	int 0x13
; The Last Word Of The Sector
	mov ax, [0x200-0x2]
; Check If It's A Kernel
	cmp ax, 0x46BB
	je .fka
.fkd:
; Next Sector
	dec cl
	jnz .fkl
.fke:
; Boot Sector
	mov bx, 0x7C0
		mov ds,bx
		mov es,bx
; Next Command
	jmp .switch
.fka:
; Size
	mov al, [0x200-0x3]
	mov [fs:data.kbuffer+bp],al
	inc bp
; Sector
	mov [fs:data.kbuffer+bp],cl
	inc bp
; Print The Number And Name
	push cx
		mov ax,bp
		shr ax, 0x1
		call procedures.putn
		mov al, '>'
		call procedures.putc
		mov si, 0x200-0x14
		call procedures.puts
		mov al, 0xD
		call procedures.putc
	pop cx
; Next
	jmp .fkd
	
.sk:
; Null
	xor cx,cx
; Get The Number
	call procedures.getn
; Duplicate The Number
	mov bp,cx
	dec bp
	shl bp, 0x1
; Get The Data
	mov ax, [fs:data.kbuffer+bp]
; Select It
	mov [fs:data.kernel],ax
; Next Command
	jmp .switch

.fs:
; Kernel Segment
	mov bx, 0x8C0
		mov ds,bx
		mov es,bx
; Null
	xor bp,bp
; Function #8: Get Disk Info
	mov ah, 0x8
; Disk
	mov dl, [fs:data.disk]
; BIOS Disk Interrupt
	int 0x13
.fsl:
; Function #2: Read Disk
	mov ah, 0x2
; Read One Sector
	mov al, 0x1
; Null
	xor bx,bx
	xor ch,ch
	xor dh,dh
; Disk
	mov dl, [fs:data]
; BIOS Disk Interrupt
	int 0x13
; The Last Word Of The Sector
	mov ax, [0x200-0x2]
; Check If It's A Kernel
	cmp ax, 0x5733
	je .fsa
.fsd:
; Next Sector
	dec cl
	jnz .fsl
.fse:
; Boot Sector
	mov bx, 0x7C0
		mov ds,bx
		mov es,bx
; Next Command
	jmp .switch
.fsa:
; Size
	mov al, [0x200-0x3]
	mov [fs:data.sbuffer+bp],al
	inc bp
; Sector
	mov [fs:data.sbuffer+bp],cl
	inc bp
; Print The Number And Name
	push cx
		mov ax,bp
		shr ax, 0x1
		call procedures.putn
		mov al, '>'
		call procedures.putc
		mov si, 0x200-0x14
		call procedures.puts
		mov al, 0xD
		call procedures.putc
	pop cx
; Next
	jmp .fsd
	
.ss:
; Null
	xor cx,cx
; Get The Number
	call procedures.getn
; Duplicate The Number
	mov bp,cx
	dec bp
	shl bp, 0x1
; Get The Data
	mov ax, [fs:data.sbuffer+bp]
; Select It
	mov [fs:data.system],ax
; Next Command
	jmp .switch

.sl:
; Function #3: Write Disk
	mov ah, 0x3
; Write Four Sectors
	mov al, 0x4
; Save Data
	mov bx, data
; Cylinder
	mov ch, 0x0
; Sector
	mov cl, 0x4
; Head
	mov dh, 0x0
; Disk
	mov dl, [fs:data]
; BIOS Disk Interrupt
	int 0x13
.lo:
; Load The Operating System
	jmp loader	
	
.commands db "1) Find Kernels 2) Select Kernel",0xD,"3) Find Systems 4) Select System",0xD,"0) Load Once 5) Save And Load",0xD,0x0

	times 0x200-0x2-($-boot) db 0x0
	dw 0xAA55
	
loader: 
; Selected Info
	mov ax, [fs:data.kernel]
; Kernel Size
	mov cl,ah
; Function #2: Read Disk
	mov ah, 0x2
; Kernel Segment
	mov bx, 0x8C0
		mov es,bx
; Null
	xor bx,bx
	xor ch,ch
	xor dh,dh
; Disk
	mov dl, [fs:data.disk]
; BIOS Disk Interrupt
	int 0x13
	
; Selected Info
	mov ax, [fs:data.system]
; System Size
	mov cl,ah
; Function #2: Read Disk
	mov ah, 0x2
; System Segment
	mov bx, 0x1000
		mov es,bx
; Null
	xor bx,bx
	xor ch,ch
	xor dh,dh
; Disk
	mov dl, [fs:data.disk]
; BIOS Disk Interrupt
	int 0x13
	
	jmp 0x8C0:0x0
	
	times 0x200-($-loader) db 0x0
	
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
	
	times 0x200-($-procedures) db 0x0

data:
; Disk Number
.disk 	db 0x0
; Video Mode
.video 	db 0x0
; Kernel Data
.kernel dw 0x0
; System Data
.system dw 0x0
	times 0x200-($-data) db 0x0
; Kernel Buffer
.kbuffer times 0x200 db 0x0
; System Buffer
.sbuffer times 0x200 db 0x0
; Free Buffer
.fbuffer times 0x400 db 0x0