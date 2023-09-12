				.INCLUDE "m128def.inc"	; atau <m128def.inc>
				.DEF counter = R18 		; definisikan kata counter sebagai R18
				.DEF bindata = R20		; R20 = data biner
				.DEF bcddata = R21		; R21 = data bcd
				.DEF puluhan = R22		; R22 = angka desimal puluhan
				.ORG 0x0000
				RJMP main

				.ORG 0x0002
				RJMP tambah

				.ORG 0x0004
				RJMP kurang

				.ORG 0x0046
main: 			LDI R16, low(RAMEND)	; inisialisasi Stack Pointer
				OUT SPL, R16
				LDI R16, high(RAMEND)
				OUT SPH, R16
				LDI R16, 0x00
				OUT DDRD, R16			; set PORTD sebagai input
				LDI R16, 0xFF
				OUT PORTD, R16			; aktifkan pull-up di PORTD
				OUT DDRE, R16			; definisikan PORTE = output
				STS DDRF, R16			; sama dengan OUT, STS digunakan karena instruksi out di PORTF sudah habis
				LDI R16, 0x03
				OUT EIMSK, R16			; enable INT1 dan INT0
				LDI R16, 0x0A
				STS EICRA, R16			; INT0 & INT1 aktif karena falling-edge (lihat buku ATM128)
				SEI 					; set enable interupt (kunci master mengaktifkan global interupt), kebalikannya CLI
				LDI counter, 0			; muati counter dengan 0
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
				RETI					; return from interrupt

bin2bcd:		LDI puluhan, 0			; inisialisasi puluhan = 0
ulang:			CPI bindata, 10			; bandingkan angka biner dengan 10
				BRMI selesai			; Branch if minus (loncat ke selesai jika nilai negatif)
				INC puluhan				; puluhan = puluhan + 1
				SUBI bindata, 10		; substract immediate (kurangi angka biner dengan 10)
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

display:		PUSH bcddata			; simpan bcddata ke stack
				ANDI bcddata, 0x0F		; tutupi (mask) bit yang tidak diperlukan
				RCALL bcd27segment		; konversi ke 7 segment
				;bcddata = 0011 0111
				;0F      = 0000 1111
				;ANDI    = 0000 0111
				STS PORTF, R0			; tampilkan ke PORTF
				POP bcddata				; ambil bcddata dari stack
				SWAP bcddata			; tukar tempat 4 bit data
				;0011 0111 di SWAP 0111 0011
				;0F                0000 1111
				;ANDI              0000 0011
				ANDI bcddata, 0x0F		; tutupi (mask) bit yang tidak diperlukan
				RCALL bcd27segment		; konversikan ke 7 segment
				OUT PORTE, R0			; tampilkan ke PORTE
				RET

bcd27segment: 	LDI ZH, high(Table<<1)	; ambil alamat tertinggi dari Table
				LDI ZL, low(Table<<1)	; ambil alamat terendah dari Table
				ADD ZL, bcddata			; alamat Table ditambah dengan bcddata
				LPM R0, Z				; load from program memory (ambil dari Table yang ditunjuk oleh Z dan disimpan di register R0)
				RET 

Table:			.DB 0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90,0xFF,0xFF,0xFF,0xFF
