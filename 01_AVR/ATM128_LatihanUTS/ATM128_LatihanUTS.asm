; Nama 	= Fadinda Shafira
; NPM	= 1806136422
; UTS SISTEM TERTANAM
; Soal No. 1
				.include <m128def.inc>
				.EQU LVL1OK = 4					; sensor LVL1OK di PIND4
				.EQU LVL2OK = 5					; sensor LVL2OK di PIND5
				.EQU TEMPOK = 6					; sensor TEMPOK di PIND6
				.EQU TANKMT = 7					; sensor TANKMT di PIND7
				.EQU awal = 0B00111000			; PB5=INFLOW1; PB4=INFLOW2; PB3=MXRON; 
												; PB2=OUTFLOW; PB1= HTRON; PB0=ALARM
												; semua output off

:DEFINITIONS
				.EQU isi_larutan1 = 0B00011000	; INFLOW1 on
				.EQU isi_larutan2 = 0B00101000	; INFLOW2 on
				.EQU panas_aduk = 0B00110010	; MXRON & HTRON on
				.EQU kosong_tanki = 0B00111100	; OUTFLOW ON
				.EQU emergency = 0B00111001		; ALARM on
				.DEF start_reg1 = R20
				.DEF start_reg2 = R21	
				.DEF counter = R22
				.DEF bindata = R23
				.DEF tenth = R24
				.DEF bcddata = R25

				.ORG 0x0000
				RJMP main						; relative jump ke label main

				.ORG 0x0002						; alamat dr service routine INT0
				RJMP shutdown					; relative jump ke interrupt shutdown

				.ORG 0x0004						; alamat dr service routine INT1
				RJMP start						; relative jump ke interrupt start
	
				.ORG 0x0046

; MAIN FUNCTIONS ;
main:			LDI R16,low(RAMEND)				; ambil alamat low byte dari memory terakhir
			   	OUT SPL, R16					; simpan ke Stack Pointer Low
			   	LDI R16,high(RAMEND)			; ambil alamat high byte dari memory terakhir
		   		OUT SPH,R16						; simpan ke Stack Pointer High
				LDI R16, 0x00
				OUT DDRD, R16					; definisikan PortD = input
				LDI R16, 0xFF
				OUT PORTD, R16					; aktifkan pull up di PortD
				OUT DDRB, R16					; definisikan PortB = output
				OUT DDRE, R16					; definisikan PortE = output
				STS DDRF, R16					; definisikan PortF = output
				LDI R16, 0B00001010
				STS EICRA, R16					; aktif sense falling edge untuk INT0 & INT1
				LDI R16, 0B00000011
				OUT EIMSK, R16					; enable INT0 & INT1
				SEI								; set enable interrupt
				LDI counter, 0					; set nilai awal counter = 0
				MOV bindata, counter			; copy isi counter ke bindata
				CALL bin2bcd					; panggil program bin2bcd
				CALL display					; panggil program display
				LDI start_reg1, 0x00
				LDI start_reg2, 0x01

;PROCESS
state_awal:		LDI R16, awal
				OUT PortB, R16					; mengirimkan state awal ke PortB
cek_start:		CP start_reg1, start_reg2 		; cek apakah start_reg1 == start_reg2
				BRNE cek_start					; branch (to cek_start) if not equal

isikan_tanki_1:	LDI R16, isi_larutan1
				OUT PortB, R16					; mengirimkan state isikan_tanki_1 ke PortB
hold_1:			CP start_reg1, start_reg2		; cek apakah start_reg1 == start_reg2
				BRNE hold_1						; branch (to hold_1) if not equal
cek_lvl_1:		SBIS PIND, LVL1OK				; Skip if LVL1OK is Set
				RJMP cek_lvl_1

isikan_tanki_2:	LDI R16, isi_larutan2			
				OUT PortB, R16					; mengirimkan state isikan_tanki_2 ke PortB
hold_2:			CP start_reg1, start_reg2		; cek apakah start_reg1 == start_reg2
				BRNE hold_2						; branch (to hold_2) if not equal
cek_lvl_2:		SBIS PIND, LVL2OK				; Skip if LVL2OK is Set
				RJMP cek_lvl_2
				
heating_mixing:	LDI R16, panas_aduk
				OUT PortB, R16					; mengirimkan state heating_mixing ke PortB
hold_3:			CP start_reg1, start_reg2		; cek apakah start_reg1 == start_reg2
				BRNE hold_3						; branch (to hold_3) if not equal
cek_tempok:		SBIC PIND, TEMPOK 				; Skip if TEMPOK is Set
				RJMP cek_tempok
				
kosongkan:		LDI R16, kosong_tanki
				OUT PortB, R16					; mengirimkan state kosongkan ke PortB
hold_4:			CP start_reg1, start_reg2		; cek apakah start_reg1 == start_reg2
				BRNE hold_4						; branch (to hold_4) if not equal
cek_tankmt:		SBIC PIND, TANKMT				; Skip if TANKMT is Set 
				RJMP cek_tankmt
				INC counter
				MOV bindata, counter
				RCALL bin2bcd
				RCALL display

				; DELAY
				rcall DELAY

				RJMP state_awal


; START/STOP FUNCTIONS ;				
start:			EOR start_reg1, start_reg2		; menerapkan eksklusif or kepada start_reg1 dan start_reg2
				RETI							; return interrupt start
				
shutdown:		LDI R16, 0x00
				OUT EIMSK, R16					; nonaktifkan INT0 dan INT1 pada dua digit terakhir
				LDI R16, emergency
				OUT PORTB, R16					; mengirimkan state shutdown ke PortB
loop_shutdown:	RJMP loop_shutdown				; relative jump ke label loop_shutdown
				RETI							; return interrupt shutdown
				
bin2bcd:		LDI tenth, 0					; tenth = 0	
ulang:			CPI bindata,10					; compare bindata dg 10
				BRMI selesai					; branch to label selesai if minus
				INC tenth						; increment ==> tenth = tenth + 1
				SUBI bindata, 10				; substract ==> bindata = bindata - 10
				RJMP ulang
selesai:		SWAP tenth						; 4 bit data bawah tukar tempat 4 bit data atau
				OR bindata, tenth				; gabungkan puluhan & satuan
				MOV bcddata, bindata			; (move) ==> copy isi bindata ke bcddata
				RET								; return
display:		PUSH bcddata 					; simpan bcddata ke Stack
				ANDI bcddata, 0x0F				; tutupi 4 bit data teratas
				RCALL konversi					; jalankan program konversi
				STS PORTF, R0					; tampilkan ke PortF
				POP bcddata						; ambil kembali isi bcddata 
				SWAP bcddata					; tukar tempat antar 4 bit
				ANDI bcddata, 0x0F				; tutupi 4 bit data teratas
				RCALL konversi					; panggil program konversi
				OUT PORTE, R0					; tampilkan ke PortE
				RET

			.ORG 0X900

; DELAY FUNCTIONS ;
DELAY: 		LDI R18,10				 			; delay 250 ms

OUTER_LOOP: LDI R28, LOW(3037)
 			LDI R29, HIGH(3037)

DELAY_LOOP: ADIW R28,1
 			BRNE DELAY_LOOP
 			DEC R18
 			BRNE OUTER_LOOP

 			RET

konversi:		LDI ZH, high(Tabel<<1)			; ambil alamat tertinggi dari Tabel
				LDI ZL, low(Tabel<<1)			; ambil alamat terbawah dari Tabel
				ADD ZL, bcddata					; alamat Tabel = Tabel + bcddata
				LPM R0, Z						; load from program memory
				RET								; ambil data dari Tabel sesuai urutan
												; yang ditunjuk oleh Z
Tabel:	.DB 0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF

			
