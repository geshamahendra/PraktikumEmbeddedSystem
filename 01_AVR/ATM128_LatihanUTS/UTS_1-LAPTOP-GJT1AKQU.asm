                    .INCLUDE "m128def.inc"
                    
                    ; PINS ;
                    .EQU IN_PIN1 = PIND 
                    .EQU IN_PIN2 = PINE
                    .EQU OUT_PORT = PORTA
                    
                    ; INPUTS ;
                    .EQU SHUTDOWN = 0				; sensor SHUTCDOWN di PIND0
				    .EQU START = 1					; sensor START di PIN D1
				    .EQU HOLD = 2					; sensor HOLD di PIN D2
				    .EQU ADD = 3					; sensor ADDD di PIN D3
				    .EQU CANCEL	= 4					; sensor CANCEL di PIN D4
				    .EQU TEMPOK = 0					; sensor TEMPOK di PIN 0
				    .EQU TANKMT = 1					; sensor TANKMT di PIN E1
				    .EQU TANKFULL = 2				; sensor TANKFULL di PIN E2
                    
                    ; OUTPUTS ;
                    .EQU INFLOW1 = 0                ; sensor INFLOW1 di PIN A0 
                    .EQU INFLOW2 = 1                ; sensor INFLOW2 di PIN A0
                    .EQU OUTLOW = 2                 ; sensor OUTLOW di PIN A2
                    .EQU HTRON = 3                  ; sensor HTRON di PIN A3
                    .EQU STIRON = 4                 ; sensor STIRON di PIN A4
                    .EQU ALARM = 5                  ; sensor ALARAM di PIN A5
                    .EQU BUZZER = 6                 ; sensor BUZZER di PIN A6
                    
                    /*
                    nanti final diapus aja gan...
                    IO descriptions
                    ' = active low

                    output
                    PA6=BUZZER
                    PA5=ALARM; PA4'=STIRON; PA3=HTRON
                    PA2=OUTFLOW; PA1=INFLOW2; PA0=INFLOW1

                    input
                    PE2=TANKFUL; PE1=TEMPOK; PE0=TANKMT 

                    PD5'=CANCEL; PD4'=ADD
                    PD3'=HOLD; PD1'=START; PD0'=SHUTDOWN
                    */

                    ; Output aktuator
                    .EQU off = 0B00010000           ; PA6=Buzzer, PA5=Alarm, PA4=STIRON, PA3=HTRON, PA2=OUTFLOW, PA1=INFLOW2, PA0=INFLOW1
                    .EQU shutdown = 0B01110000      ; semua aktuator mati, kecuali ALARM dan BUZZER ON
                    .EQU proses_isi = 0B00010011    ; INFLOW1 dan INFLOW2 ON
                    .EQU proses_panas = 0B00001000  ; STIRON ON dan HTRON ON
                    .EQU proses_kosong = 0B00010100 ; OUTFLOW ON

                    .ORG 0x0000                     ; RESET ALL
                    RJMP init

                    .ORG 0x0002
                    RJMP shut_down                  ; Tidak boleh sama dengan kata shutdown sebelumnya

                    .ORG 0x0004
                    RJMP start

                    .ORG 0x0006
                    RJMP cancel

                    .ORG 0x0008
                    RJMP hold

                    .ORG 0x0046
                    RJMP check_start

; FUNGSI INISIALISASI I/O, DLL ;
init:               ; inisialisi stack pointer
                    ; low
                    LDI R16, low(RAMEND)
                    OUT SPL, R16                    ; inisialisasi stack pointer
                    ; high
                    LDI R16, high(RAMEND)
                    OUT SPH, R16
                    
                    ; pins
                    ; output
                    LDI R16, 0xFF
                    OUT DDRA, R16                   ; set PORTA = output
                    ; input
                    LDI R16, 0x00
                    OUT DDRD, R16                   ; set PORTD = input
                    OUT DDRE, R16                   ; set PORTE = input

                    ; pull-up di PORTD dan PORTE
                    LDI R16, 0xFF
                    OUT PORTD, R16                  ; aktifkan pull-up di PORTD
                    OUT PORTE, R16                  ; aktifkan pull-up di PORTE
                    
                    ; interrupt 
                    LDI R16, 0B00000111             
                    OUT EIMSK, R16                  ; set INT0, INT1, INT2
                    LDI R16, 0B00101010             
                    STS EICRA, R16                  ; semua interrupt aktif falling-edge
                    SEI                             ; set enable interrupt (set global interrupt)
                    CLT                             ; set bit T di SREG (Status Register)
; FUNGSI MAIN ;

normal_off:         LDI R16, off
			        OUT OUT_PORT, R16               ; semua aktuator mati
check_start:        BRBC 6, check_start             ; tunggu sampai bit T (SREG.6) = 1

isi_tanki:          LDI R16, proses_isi             
                    OUT OUT_PORT, R16                   ; jalankan proses_isi

check_tankful:      SBIC IN_PIN2, TANKFUL
                    RJMP check_tankful              ; tunggu sampai TANKFUL = 0

panastanki:         LDI R16, proses_panas
                    OUT OUT_PORT, R16

check_tempok:       SBIC IN_PORT2, TEMPOK
                    RJMP check_tempok               ; tunggu sampai TEMPOK = 1

proseskosong:       LDI R16, proses_kosong
                    OUT OUT_PORT, R16                   ; jalankan proses_kosong

check_tankmt:       SBIC IN_PIN2, TANKMT
                    RJMP check_tankmt               ; tunggu sampai TANKMT = 0
		            RJMP check_start                ; loop ke kondisi awal program utama (check_start)


; FUNGSI INTERRUPT ;
shut_down:          LDI R16, shutdown
					OUT OUT_PORT, R16 				    ; jalankan proses shutdown
					LDI R16, 0x00
					OUT EIMSK, R16					; disable semua INT

loop_shutdown:		RJMP loop_shutdown				; loop terus menerus
					RETI

start:              SET                             ; set bit T = 1
                    RETI

cancel:             CLT                             ; clear bit T
                    RETI

/*
hold:               PUSH R16					    ; simpan R16 ke stack
                    LDI R16, off                    ; matikan semuanya
                    OUT PORTA, R16
                    SBIC PIND, 1        		    ; Skip if  PIND.0 Clear
                    POP R16
                    OUT PORTA, R16
                    BRBC 6, check_start             ; tunggu sampai bit T (SREG.6) = 1
                    
                    
                    OUT PORTA, R16				    ; tampilkan di PORTEA
                    POP R16						    ; Ambil kembali R16 dari stack
                    CLC
                    
                    ROL R16						    ; rotate left with carry
                    BREQ loop					    ; Branch to loop if carry to zero
                    RJMP lanjut					    ; loncat ke lanjut 
*/



/*
kodingan rizky
                    .INCLUDE "m128def.inc"
                    
                    ; PINS ;
                    .EQU IN_PIN1 = PIND 
                    .EQU IN_PIN2 = PINE
                    .EQU OUT_PORT = PORTA
                    
                    ; INPUTS ;
                    .EQU SHUTDOWN = 0				; sensor SHUTCDOWN di PIND0
				    .EQU START = 1					; sensor START di PIN D1
				    .EQU HOLD = 2					; sensor HOLD di PIN D2
				    .EQU ADD_S = 3					; sensor ADD di PIN D3
				    .EQU CANCEL	= 4					; sensor CANCEL di PIN D4
				    .EQU TEMPOK = 0					; sensor TEMPOK di PIN 0
				    .EQU TANKMT = 1					; sensor TANKMT di PIN E1
				    .EQU TANKFULL = 2				; sensor TANKFULL di PIN E2
                    
                    ; OUTPUTS ;
                    .EQU INFLOW1 = 0                ; sensor INFLOW1 di PIN A0 
                    .EQU INFLOW2 = 1                ; sensor INFLOW2 di PIN A0
                    .EQU OUTLOW = 2                 ; sensor OUTLOW di PIN A2
                    .EQU HTRON = 3                  ; sensor HTRON di PIN A3
                    .EQU STIRON = 4                 ; sensor STIRON di PIN A4
                    .EQU ALARM = 5                  ; sensor ALARAM di PIN A5
                    .EQU BUZZER = 6                 ; sensor BUZZER di PIN A6
                    
                    /*
                    IO descriptions
                    ' = active low

                    output
                    PA6=BUZZER
                    PA5=ALARM; PA4'=STIRON; PA3=HTRON
                    PA2=OUTFLOW; PA1=INFLOW2; PA0=INFLOW1

                    input
                    PE2=TANKFUL; PE1=TEMPOK; PE0=TANKMT 

                    PD5'=CANCEL; PD4'=ADD
                    PD3'=HOLD; PD1'=START; PD0'=SHUTDOWN
                    */

                    ; Output aktuator
                    .EQU off = 0B00010000           
                    .EQU shutdown_cond = 0B01110000 ; semua aktuator mati, kecuali ALARM dan BUZZER ON
                    .EQU proses_isi = 0B00010011    ; INFLOW1 dan INFLOW2 ON
                    .EQU proses_panas = 0B00001000  ; STIRON ON dan HTRON ON
                    .EQU proses_kosong = 0B00010100 ; OUTFLOW ON

                    .ORG 0x0000                     ; RESET ALL
                    RJMP init

                    .ORG 0x0002
                    RJMP shut_down                  ; Tidak boleh sama dengan kata shutdown sebelumnya

                    .ORG 0x0004
                    RJMP start_int

                    .ORG 0x0006
                    RJMP cancel_int

                    .ORG 0x0008
                    RJMP hold

                    .ORG 0x0046
                    RJMP check_start

; FUNGSI INISIALISASI I/O, DLL ;
init:               ; inisialisi stack pointer
                    ; low
                    LDI R16, low(RAMEND)
                    OUT SPL, R16                    ; inisialisasi stack pointer
                    ; high
                    LDI R16, high(RAMEND)
                    OUT SPH, R16
                    
                    ; pins
                    ; output
                    LDI R16, 0xFF
                    OUT DDRA, R16                   ; set PORTA = output
                    ; input
                    LDI R16, 0x00
                    OUT DDRD, R16                   ; set PORTD = input
                    OUT DDRE, R16                   ; set PORTE = input

                    ; pull-up di PORTD dan PORTE
                    LDI R16, 0xFF
                    OUT PORTD, R16                  ; aktifkan pull-up di PORTD
                    OUT PORTE, R16                  ; aktifkan pull-up di PORTE
                    
                    ; interrupt 
                    LDI R16, 0B00000111             
                    OUT EIMSK, R16                  ; set INT0, INT1, INT2
                    LDI R16, 0B00101010             
                    STS EICRA, R16                  ; semua interrupt aktif falling-edge
                    SEI                             ; set enable interrupt (set global interrupt)
                    CLT                             ; set bit T di SREG (Status Register)

; FUNGSI MAIN ;
check_start:        LDI R16, off
					OUT OUT_PORT, R16
					BRBC 1, check_start             ; tunggu sampai bit T (SREG.6) = 1

isi_tanki:          LDI R16, proses_isi             
                    OUT OUT_PORT, R16                   ; jalankan proses_isi

check_tankful:      SBIC IN_PIN2, TANKFULL
                    RJMP check_tankful              ; tunggu sampai TANKFUL = 0

panastanki:         LDI R16, proses_panas
                    OUT OUT_PORT, R16

check_tempok:       SBIC IN_PIN2, TEMPOK
                    RJMP check_tempok               ; tunggu sampai TEMPOK = 1

proseskosong:       LDI R16, proses_kosong
                    OUT OUT_PORT, R16                   ; jalankan proses_kosong

check_tankmt:       SBIC IN_PIN2, TANKMT
                    RJMP check_tankmt               ; tunggu sampai TANKMT = 0
		            RJMP check_start                ; loop ke kondisi awal program utama (check_start)


; FUNGSI INTERRUPT ;
shut_down:          LDI R16, shutdown_cond
					OUT OUT_PORT, R16 				    ; jalankan proses shutdown
					LDI R16, 0x00
					OUT EIMSK, R16					; disable semua INT

loop_shutdown:		RJMP loop_shutdown				; loop terus menerus
					RETI

start_int:          SET                             ; set bit T = 1
                    RETI

cancel_int:         CLT                             ; clear bit T
                    RETI

/*
hold:               PUSH R16					    ; simpan R16 ke stack
                    LDI R16, off                    ; matikan semuanya
                    OUT PORTA, R16
                    SBIC PIND, 1        		    ; Skip if  PIND.0 Clear
                    POP R16
                    OUT PORTA, R16
                    BRBC 6, check_start             ; tunggu sampai bit T (SREG.6) = 1
                    
                    
                    OUT PORTA, R16				    ; tampilkan di PORTEA
                    POP R16						    ; Ambil kembali R16 dari stack
                    CLC
                    
                    ROL R16						    ; rotate left with carry
                    BREQ loop					    ; Branch to loop if carry to zero
                    RJMP lanjut					    ; loncat ke lanjut 
*/










/*
				.include <m128def.inc>
				.EQU SHUTDOWN = 0				; sensor SHUTCDOWN di PIND0
				.EQU START = 1					; sensor START di PIND1
				.EQU HOLD = 2					; sensor HOLD di PIND2
				.EQU ADDD = 3					; sensor ADDD di PIND3
				.EQU CANCEL	= 4					; sensor CANCEL di PIND4
				.EQU TEMPOK = 0					; sensor TEMPOK di PINE0
				.EQU TANKMT = 1					; sensor TANKMT di PINE1
				.EQU TANKFULL = 2				; sensor TANKFULL di PINE2
; Output ;
; PINA -> INFLOW1 = 0; INFLOW2 = 1; OUTFLOW = 2; HTRON = 3; STIRON = 4; ALARM = 5; BUZZER = 6				
				
				.EQU awal = 0B00010000 			; 
				.EQU isi_larutan = 0B00010011	; INFLOW1 on
				.EQU panas_aduk = 0B00110010	; MXRON & HTRON on
				.EQU kosong_tanki = 0B00111100	; OUTFLOW ON
				.EQU emergency = 0B00111001		; ALARM on
				.DEF start_reg1 = R20
				.DEF start_reg2 = R21

				.ORG 0x0000
				RJMP main						; relative jump ke label main

				.ORG 0x0002						; alamat dr service routine INT0
				RJMP shutdown					; relative jump ke interrupt shutdown

				.ORG 0x0004						; alamat dr service routine INT1
				RJMP start						; relative jump ke interrupt start

				.ORG 0x0006						; alamat dr service routine INT1
				RJMP hold						; relative jump ke interrupt start
	
				.ORG 0x0046
												; semua output off

main:			LDI R16,low(RAMEND)				; ambil alamat low byte dari memory terakhir
			   	OUT SPL, R16					; simpan ke Stack Pointer Low
			   	LDI R16,high(RAMEND)			; ambil alamat high byte dari memory terakhir
		   		OUT SPH,R16						; simpan ke Stack Pointer High
				LDI R16, 0x00
				OUT DDRD, R16					; definisikan PIN D
				OUT DDRE, R16					; definisikan PIN E
				LDI R16, 0xFF
				OUT PORTD, R16					; aktifkan pull up di PortD
				OUT PORTE, R16					; aktifkan pull up di PortE
				OUT DDRA, R16					; definisikan PORT A
				LDI R16, 0B00101010
				STS EICRA, R16					; aktif sense falling edge untuk INT0 & INT1
				LDI R16, 0B00000111
				STS EIMSK, R16					; enable INT0 & INT1 & INT2
				SEI								; set enable interrupt
init:			LDI start_reg1, 0x00
				LDI start_reg2, 0x01
				LDI R16, awal 
				OUT PINA, R16

stage1:			CPI start_reg1, start_reg2		;
				BRNE stage1
				LDI R17, isi_larutan
				OUT PINA, R17
				SBIC PIND, TANKFULL
				RJMP stage2
				RJMP stage1

stage2:			CPI start_reg1, start_reg

start:          LDI start_reg1,1
                RET
hold:           LDI start_reg1, 0
				LDI R16, awal 
				OUT PINA, R16
                CPI start_reg1,start_reg2
                BRNE hold
                RET
*/