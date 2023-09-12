					.INCLUDE <m128def.inc>
`					
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
					OUT Out_Port,R16			

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
					
					RJMP normal_off

hold:				SBIS In_Port1, 1  			
					RJMP start
					RJMP hold

start:				SET							
					RETI

shut_down:			LDI R16, shutdown
					OUT Out_Port,R16			
					LDI R16, 0x00
					OUT EIMSK, R16				

loop_shutdown : 	RJMP loop_shutdown			
					RETI

