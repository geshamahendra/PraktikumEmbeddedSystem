                    .INCLUDE "m128def.inc"
                    .EQU In_Port = PIND
                    .EQU Out_Port = PORTB
                    ;
                    .EQU TANKFULL = 5               ; sensor TANKFULL di PIN D5 
                    .EQU TEMPOK = 6                 ; sensor TEMPOK di PIN D6
                    .EQU TANKMT = 4                 ; sensor TANKMT di PIN D4
                    ; Output aktuator
                    .EQU off = 0B00001000           ; PB4 = Alarm, nPB3=STIRON, PB2=HTRON, PB1=OUTFLOW, PB0=INFLOW
                    .EQU shutdown = 0B00011000      ; semua aktuator mati kecuali alarm ON
                    .EQU proses_isi = 0B00001001    ; INFLOW ON
                    .EQU proses_panas = 0B00000100  ; STIRON ON, HTRON ON
                    .EQU proses_kosong = 0B00001010 ; 

                    .ORG 0x0000
                    RJMP main

                    .ORG 0x0002
                    RJMP shut_down                  ; tidak boleh sama dengan kata shutdown sebelumnya

                    .ORG 0x00004
                    RJMP start

                    .ORG 0x0006
                    RJMP stop

                    .ORG 0x0046
main:               LDI R16, low(RAMEND)
                    OUT SPL, R16                    ; inisialisasi stack pointer
                    LDI R16, high(RAMEND)
                    OUT SPH, R16
                    LDI R16, 0xFF
                    OUT DDRB, R16                   ; set PORTB = output
                    LDI R16, 0x00
                    OUT DDRD, R16                   ; set PORTD = input
                    LDI R16, 0xFF
                    OUT PORTD, R16                  ; aktifkan pull-up di PORTD
                    LDI R16, 0B00001111             
                    OUT EIMSK, R16                  ; set INT0, INT1, INT2
                    LDI R16, 0B00101010             
                    STS EICRA, R16                  ; semua interrupt aktif falling-edge
                    SEI                             ; set enable interrupt (set global interrupt)
                    CLT                             ; set bit T di SREG (Status Register)

normal_off:         LDI R16, off
			        OUT Out_Port, R16               ; semua aktuator mati
					        
check_start:        BRBC 6, check_start             ; tunggu sampai bit T (SREG.6) = 1

isi_tanki:          LDI R16, proses_isi             
                    OUT Out_Port, R16               ; jalankan proses_isi

check_tankful:      SBIC In_Port, TANKFULL
                    RJMP check_tankful               ; tunggu sampai TANKFUL = 0

panastanki:         LDI R16, proses_panas
                    OUT Out_Port, R16

check_tempok:       SBIS In_Port, TEMPOK
                    RJMP check_tempok                ; tunggu sampai TEMPOK = 1

proseskosong:       LDI R16, proses_kosong
                    OUT Out_Port, R16               ; jalankan proses_kosong

check_tankmt:       SBIC In_Port, TANKMT
                    RJMP check_tankmt               ; tunggu sampai TANKMT = 0
					RJMP normal_off



shut_down:          LDI R16, shutdown
					OUT Out_Port, R16 				; jalankan proses shutdown
					LDI R16, 0x00
					OUT EIMSK, R16					; disable semua INT

loop_shutdown:		RJMP loop_shutdown				; loop terus menerus
					RETI

start:              SET                             ; set bit T = 1
                    RETI

stop:               CLT                             ; clear bit T
                    RETI



