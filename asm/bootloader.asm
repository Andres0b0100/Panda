; Fill 510 Bytes With 0's
	times 0x200-0x2 db 0x0
; Put The Signature At The End Of The Sector
	dw 0xAA55