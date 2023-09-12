		.include <m128def.inc>
		.EQU timer_value = 19531; 2 detik ==> 20M/1024
		.EQU offset_value = 979	; 0,1 detik ==> 1M/1024
		.ORG 0x0000
		RJMP main

		.ORG 0x0002				; alamat awal INT0
		RJMP tambah				; relative jump ke label tambah
		
		.ORG 0x0004				; alamat awal INT1
		RJMP kurang				; relative jump ke label kurang
		
		.ORG 0x0046
main:	LDI R16,low(RAMEND)		; ambil alamat low byte dari memory terakhir
		OUT SPL, R16			; simpan ke Stack Pointer Low
		LDI R16,high(RAMEND)	; ambil alamat high byte dari memory terakhir
		OUT SPH,R16				; simpan ke Stack Pointer High
		LDI R16, 0xFF
		OUT DDRB, R16			; definisikan PortB = output
		LDI R16, 0x00
		OUT DDRD, R16			; definisikan PortD = input
		LDI R16, 0xFF			
		OUT PORTD, R16			; aktifkan pull up di PortD
		LDI R18, low(timer_value)
		OUT OCR1AL, R18			; Output Compare Register (target T1)
		LDI R19, high(timer_value)
		OUT OCR1AH, R19		; Output Compare Register (target T1)
		LDI R16, 0x40
		OUT TCCR1A, R16			; set T1 CTC OCM1A Toggle
		LDI R16, 0x0D
		OUT TCCR1B, R16			; set prescaler=1024, run
		LDI R16, 0B00000011
		OUT EIMSK, R16			; aktifkan INT0 & INT1
		LDI R16, 0B00001010
		STS EICRA, R16			; aktif falling edge
		SEI 					; set enable interrupt (set master global interrupt)

loop:	RJMP loop

tambah: LDI R26, low(offset_value)
		LDI R27, high(offset_value)
		ADD R18, R26
		OUT OCR1AL, R18
		ADD R19, R27
		OUT OCR1AH, R19
		RETI					; return interrupt tambah
		
kurang: SUBI R18, low(offset_value)
		OUT OCR1AL, R18
		SUBI R19, high(offset_value)
		OUT OCR1AH, R19
		RETI					; return interrupt kurang
		