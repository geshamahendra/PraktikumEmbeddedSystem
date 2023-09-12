				.INCLUDE"m128def.inc"
				.EQU nilaiT1= 31250			; nilai maksimum Timer1 = 31250 x 64 = 2.000.000 (10MHz)
				.EQU set_run_T1= 0B00000011 ; isi TCCR1B prescaler 64 (batasannya 2^16 = 65535)
											; TCCR1B harus diisi dengan 0x03 (011) untuk membagi clock dengan 64, LED menyala 1/5 detik
				.DEF counter = R20			; melihat berapa kali counter berkdeip							
				.ORG 0x00
				RJMP main

				.ORG 0x0002					; lokasi (alamat) INT0
				RJMP On_Off_T1

				.ORG 0x0018					; lokasi (alamat) dari Timer1 OCM
				RJMP On_Off_LED

				.ORG 0x0046
main:			LDI R16, low(RAMEND)
				OUT SPL, R16
				LDI R16, high(RAMEND)
				OUT SPH, R16
				LDI R16, 0xFF
				OUT DDRA, R16			; definisikan PORTA sebagai Output
				OUT DDRB, R16			; definisikan PORTB sebagai Output
				LDI R16, 0x00
				OUT DDRD, R16			; definisikan PORTD sebagai Input
				LDI R16, 0xFF
				OUT PORTD, R16			; kirim 0xFF ke PORTD
				LDI R16, 0x01
				OUT EIMSK, R16			; enable INT1 dan INT0
				LDI R16, 0x02
				STS EICRA, R16			; INT0 & INT1 aktif karena falling-edge (lihat buku ATM128)
				SEI						; set global interrupt
				LDI R16, 0x40
				OUT TCCR1A, R16			; set pin OC1A toogle (nyala-mati) (01) sehingga 0x40
				LDI R16, 0x10
				OUT TIMSK, R16			; set int Timer1 jika TCNT1 = OCR1A
				LDI R16, low(nilaiT1)
				OUT OCR1AL, R16 		; set nilai OCR1A Low (bit terendah)
				LDI R16, high(nilaiT1)
				OUT OCR1AH, R16 		; set nilai OCR1A High (bit tertinggi) 
				LDI R16, set_run_T1
				OUT TCCR1B, R16 		; Mengaktifkan prescaller = 64 dan run Timer1
				LDI R16, 0B01010101
				OUT PORTA, R16			; Nyalakan PORTA
				LDI counter, 0			; mula-mula counter 0

loop:			RJMP loop

On_Off_T1:		LDI R16, set_run_T1
				IN R17, TCCR1B
				EOR R16, R17			; EXOR R16 dengan R17
				OUT TCCR1B, R16
				RETI

On_Off_LED:		CPI counter, 1
				BRNE tambah
				IN R16, PORTA			; ambil kondisi akhir PORTA
				COM R16					; complement (balik) isi dari R16
				OUT PORTA, R16			; kirim ke PORTA lagi
				LDI counter, 0			; nol kan kembali nilai counter
				RJMP balik

tambah:			INC counter

balik:			RETI
										
										

