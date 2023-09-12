					.INCLUDE <m128def.inc>
					.EQU in_port1 = PIND
					.EQU in_port2 = PINE
					.EQU out_port = PORTA
					.EQU TANKFUL = 2				
					.EQU TEMPOK = 1					
					.EQU TANKMT = 0 					
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

					.ORG 0x0046

main:				LDI R16, low(RAMEND)
					OUT SPL, R16				
					LDI R16, high(RAMEND)
					OUT SPH, R16
					LDI R16, 0xFF
					OUT DDRA, R16				
					LDI R16, 0x00
					OUT DDRD, R16				
					OUT DDRE, R16
					LDI R16, 0xFF
					OUT PORTD, R16				
					OUT PORTE, R16
					LDI R16, 0b00000111
					OUT EIMSK, R16				
					LDI R16, 0b00101010
					STS EICRA, R16				
					SEI 						
					CLT							

				
normal_off:			LDI R16, off
					OUT out_port,R16			

check_start:		BRBC 6, check_start			
isi_tanki :			LDI R16, proses_isi
					OUT out_port, R16			

check_tankful:		SBIS in_port2, TANKFUL		
					RJMP check_tankful			

panastanki:			LDI R16, proses_panas	
					OUT out_port, R16			

check_tempok: 		SBIC in_port2,TEMPOK		
					RJMP check_tempok			

proseskosong:		LDI R16, proses_kosong
					OUT out_port, R16			

check_tankmt:		SBIC in_port2, TANKMT
					RJMP check_tankmt			
					
					RJMP normal_off

start:				SET							
					RETI

hold:				SBIS in_port1, 1  			
					RJMP start
					RJMP hold


shut_down:			LDI R16, shutdown
					OUT out_port,R16			
					LDI R16, 0x00
					OUT EIMSK, R16				

loop_shutdown : 	RJMP loop_shutdown			
					RETI


hapus:				SBIS PORTD, 1
					LDI counter, 0
					RETI 