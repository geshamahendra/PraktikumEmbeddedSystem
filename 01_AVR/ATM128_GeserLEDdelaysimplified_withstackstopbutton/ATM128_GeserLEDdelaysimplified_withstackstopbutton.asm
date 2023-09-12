
			.INCLUDE<m128def.inc>
			.ORG 0x0000
			RJMP main

			.ORG 0x0046
main:		LDI R16, low(RAMEND)		; isi R16 dengan alamat low dari RAMEND
			OUT SPL, R16				; simpan di SPL 
			LDI R16, high(RAMEND)		; isi R16 dengan alamat high dari RAMEND
			OUT SPH, R16				; simpan di SPL
			LDI R16, 0x00				; 
			OUT DDRD, R16				; definisikan PORTD sebagai input
			LDI R16, 0xFF				; 
			OUT PORTD, R16				; aktifkan pull-up di PORTD
			OUT DDRE, R16				; definisikan PORTE sebagai output

loop:		LDI R16, 0B00000001			;

lanjut:		PUSH R16					; simpan R16 ke stack
			COM R16						; complement	
			OUT PORTE, R16				; tampilkan di PORTE
			RCALL delay					; panggil delay
			POP R16						; Ambil kembali R16 dari stack
			CLC
			SBIC PIND, 0        		; Skip if  PIND.0 Clear
			ROL R16						; rotate left with carry
			BREQ loop					; Branch to loop if carry to zero
			RJMP lanjut					; loncat ke lanjut

delay: 									; the subroutine: 
			LDI R18, 18 				; load r18 with 8 

outer_loop: 							; outer loop label 
			LDI R24, low(3037) 
			LDI R25, high(3037) 		; load registers r24:r25 with 3037, our new 
										; init value 
delay_loop: 
			ADIW R24, 1 				; the loop label , "add immediate to word" 
										; r24:r25 are incremented 
			BRNE delay_loop 			; if no overflow ("branch if not equal"), go 
										; back to "delay_loop" 
 			DEC R18 					; decrement r16 
			BRNE outer_loop 			; and loop if outer loop not finished 
			RET 						; return from subroutine
