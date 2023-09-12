				.INCLUDE "m128def.inc"	; atau <m128def.inc>
				.DEF counter = R18 		; definisikan kata counter sebagai R18
				.DEF bindata = R20		; R20 = data biner
				.DEF bcddata = R21		; R21 = data bcd
				.DEF puluhan = R22		; R22 = angka desimal puluhan

				.EQU nilaiT1= 19531			; nilai maksimum Timer1 = 5.000.000/256 = 19531 (10MHz)
				.EQU set_run_T1= 0B00001100 ; isi TCCR1B prescaler 256
											; TCCR1B harus diisi dengan 0B00000100 untuk membagi clock dengan 64, LED menyala 0.5 detik
											; nyalakan mode CTC (WGM12)

				.ORG 0x0000
				RJMP main				

				.ORG 0x0002
				RJMP tambah				; alamat INT0

				.ORG 0x0004
				RJMP kurang				; alamat INT1

				.ORG 0x0046
main: 			
				LDI R16, low(RAMEND)
				OUT SPL, R16
				LDI R16, high(RAMEND)
				OUT SPH, R16
				LDI R16, 0x00
				OUT DDRD, R16			; set PORTD sebagai input
				LDI R16, 0xFF
				OUT PORTD, R16			; aktifkan pull-up di PORTD
				OUT DDRE, R16			; definisikan PORTE = output
				STS DDRF, R16			; sama dengan OUT, STS digunakan karena instruksi out di PORTF sudah habis
				OUT DDRB, R16			; definisikan PORTD = output

				LDI R16, 0x03			; 0000 0011
				OUT EIMSK, R16			; enable INT1 dan INT0
				LDI R16, 0x0A			; 0000 1010
				STS EICRA, R16			; INT0 & INT1 aktif karena falling-edge (lihat buku ATM128)

				LDI R16, 0x40
				OUT TCCR1A, R16			; TCCR1A diisi dengan toogle (nyala-mati) (01) untuk Timer1 untuk Channel A sehingga 0x40
				LDI R16, low(nilaiT1)
				OUT OCR1AL, R16 		; OCR1A Low (bit terendah) 
				LDI R16, high(nilaiT1)
				OUT OCR1AH, R16 		; OCR1A High (bit tertinggi) 
				LDI R16, 0x01
				OUT TIMSK, R16			; TIMSK 0x01 untuk OCIE1A
				LDI R16, set_run_T1
				OUT TCCR1B, R16 		; Mengaktifkan prescaller
				SEI 					; set enable interupt (kunci master mengaktifkan global interupt), kebalikannya CLI

				LDI counter, 0x00		; muati counter dengan 0
				MOV bindata, counter	; copykan counter ke binddata
				RCALL bin2bcd			; panggil program konversi biner ke bcd
				RCALL display			; tampilkan ke 7 segment display

loop: 			RJMP loop 				; selalu looping

tambah:			INC counter 			; counter = counter + 1
				MOV bindata, counter	; copykan counter ke binddata
				RCALL bin2bcd
				RCALL display
				RETI					; return from interupt

kurang:			DEC counter 			; counter = counter - 1
				MOV bindata, counter	; copykan counter ke binddata
				RCALL bin2bcd
				RCALL display
				RETI					; return from

bin2bcd:		LDI puluhan, 0			; inisialisasi puluhan = 0
ulang:			
				CPI bindata, 10			; bandingkan angka biner dengan 10
				BRMI selesai			; Branch if minus (loncat ke selesai jika nilai negatif)
				INC puluhan				; puluhan = puluhan + 1
				SUBI bindata, 10		; substract immediate (kurangi angka biner dengan 10)
				LDI R16, set_run_T1
				OUT TCCR1B, R16
				RJMP ulang				

				; puluhan = 0000 0011 = 3 desimal
				; bindata = 0000 0111 = 7 desimal
				; bcd 	  = 0011 0111 = 37 desimal

selesai:		SWAP puluhan 			; tukar tempat antara empat bit pertama dengan empat bit kedua 	
				; puluhan =  00000011 = 3 desimal  di SWAP 0011 0000
				; bindata = 0000 0111 = 7 desimal		   0000 0111
				; bcd 	  = 0011 0111 = 37 desimal di OR   0011 0111 
				OR puluhan, bindata 	; gabung puluhan dan satuan
				MOV bcddata, puluhan 	; pindahkan angka puluhan ke bcddata
				RET

display:		OUT PORTE, bcddata
				CPI counter, 10
				BRMI kurangdari10		; jika counter < 10, pindah ke kurangdari10
				RET

kurangdari10:	LDI R16, 0x00
				OUT TCCR1B, R16			; set prescaler = 256, run
				RET
