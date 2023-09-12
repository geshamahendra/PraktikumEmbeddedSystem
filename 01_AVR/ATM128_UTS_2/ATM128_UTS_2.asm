					.INCLUDE <m128def.inc>
					.DEF counter = R18 		; definisikan kata counter sebagai R18
					.DEF bindata = R20		; R20 = data biner
					.DEF bcddata = R21		; R21 = data bcd
					.DEF puluhan = R22		; R22 = angka desimal puluhan

					; Definisi Input
					.EQU In_Port1 = PIND
					.EQU In_Port2 = PINE
					.EQU Out_Port = PORTA
					.EQU TANKFUL = 2				
					.EQU TEMPOK = 1					
					.EQU TANKMT = 0
					
					; Definisi Aktuator					
					.EQU off = 0b00010000			
					.EQU shutdown = 0b01110000		
					.EQU proses_isi = 0b00010011	
					.EQU proses_panas = 0b00001000	
					.EQU proses_kosong = 0b00010100

					.ORG 0x0000
					RJMP main

					.ORG 0x0002
					RJMP shut_down

					.ORG 0x0004
					RJMP start

					.ORG 0x0006
					RJMP hold

					.ORG 0x0008
					RJMP tambah

					.ORG 0x0046
main:				LDI R16, low(RAMEND)
					OUT SPL, R16				
					LDI R16, high(RAMEND)
					OUT SPH, R16
					LDI R16, 0xFF
					OUT DDRA, R16
					OUT DDRB, R16
					OUT DDRC, R16				
					LDI R16, 0x00
					OUT DDRD, R16				
					OUT DDRE, R16
					LDI R16, 0xFF
					OUT PORTD, R16				
					OUT PORTE, R16
					LDI R16, 0b00001111
					OUT EIMSK, R16				
					LDI R16, 0b10101010
					STS EICRA, R16				
					SEI 

					LDI counter, 0					; set nilai awal counter = 0
					MOV bindata, counter			; copy isi counter ke bindata
					CALL bin2bcd					; panggil program bin2bcd
					CALL display					; panggil program display						
					CLT	
											
				
normal_off:			LDI R16, off				
					OUT Out_Port,R16
					RCALL hapus
					RJMP normal_off
								
check_start:		BRBC 6, check_start
					
isi_tanki :			LDI R16, proses_isi
					OUT Out_Port, R16			

check_tankful:		SBIS In_Port2, TANKFUL		
					RJMP check_tankful			

panastanki:			LDI R16, proses_panas	
					OUT Out_Port, R16			

check_tempok: 		SBIC In_Port2,TEMPOK		
					RJMP check_tempok			

proseskosong:		LDI R16, proses_kosong
					OUT Out_Port, R16			

check_tankmt:		SBIC In_Port2, TANKMT
					RJMP check_tankmt			
					DEC counter
					RJMP normal_off

hold:				SBIS In_Port1, 1  			
					RJMP start
					RJMP hold

start:				SET
					RJMP isi_tanki							

shut_down:			LDI R16, shutdown
					OUT Out_Port,R16			
					LDI R16, 0x00
					OUT EIMSK, R16				

loop_shutdown : 	RJMP loop_shutdown			
					RETI

tambah:				INC counter 			; counter = counter + 1
					MOV bindata, counter	; copykan counter ke binddata
					RCALL bin2bcd
					RCALL display
					RETI					; return from interupt

hapus:				SBIS PIND, 4
					LDI counter, 0
					MOV bindata, counter			; copy isi counter ke bindata
					CALL bin2bcd					; panggil program bin2bcd
					CALL display					; panggil program display
					RETI

bin2bcd:			LDI puluhan, 0			; inisialisasi puluhan = 0
ulang:				CPI bindata, 10			; bandingkan angka biner dengan 10
					BRMI selesai			; Branch if minus (loncat ke selesai jika nilai negatif)
					INC puluhan				; puluhan = puluhan + 1
					SUBI bindata, 10		; substract immediate (kurangi angka biner dengan 10)
					RJMP ulang				

					; puluhan = 0000 0011 = 3 desimal
					; bindata = 0000 0111 = 7 desimal
					; bcd 	  = 0011 0111 = 37 desimal

selesai:			SWAP puluhan 			; tukar tempat antara empat bit pertama dengan empat bit kedua 	
					; puluhan =  00000011 = 3 desimal  di SWAP 0011 0000
					; bindata = 0000 0111 = 7 desimal		   0000 0111
					; bcd 	  = 0011 0111 = 37 desimal di OR   0011 0111 
					OR puluhan, bindata 	; gabung puluhan dan satuan
					MOV bcddata, puluhan 	; pindahkan angka puluhan ke bcddata
					RET

display:			PUSH bcddata			; simpan bcddata ke stack
					ANDI bcddata, 0x0F		; tutupi (mask) bit yang tidak diperlukan
					RCALL bcd27segment		; konversi ke 7 segment
					;bcddata = 0011 0111
					;0F      = 0000 1111
					;ANDI    = 0000 0111
					OUT PORTB, R0			; tampilkan ke PORTF
					POP bcddata				; ambil bcddata dari stack
					SWAP bcddata			; tukar tempat 4 bit data
					;0011 0111 di SWAP 0111 0011
					;0F                0000 1111
					;ANDI              0000 0011
					ANDI bcddata, 0x0F		; tutupi (mask) bit yang tidak diperlukan
					RCALL bcd27segment		; konversikan ke 7 segment
					OUT PORTC, R0			; tampilkan ke PORTE
					RET

bcd27segment: 		LDI ZH, high(Table<<1)	; ambil alamat tertinggi dari Table
					LDI ZL, low(Table<<1)	; ambil alamat terendah dari Table
					ADD ZL, bcddata			; alamat Table ditambah dengan bcddata
					LPM R0, Z				; load from program memory (ambil dari Table yang ditunjuk oleh Z dan disimpan di register R0)
					RET 

Table:				.DB 0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90,0xFF,0xFF,0xFF,0xFF


