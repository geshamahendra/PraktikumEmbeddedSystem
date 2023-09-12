;
; ATM128_AksesIO.asm
;
; Created: 9/8/2021 16:37:30
; Author : Gesha
;
; Catatan = 
;1.		0x00 => 0x menandakan kode hexadecimal.
;	   		    ambil dua digit paling belakang, masing2 dikali 16 lalu dijumlahkan untuk mendapatkan desimalnya.
;				untuk mendapatkan binernya, pecah dua digit belakang secara biner (2^n).
;2.		Pin register (RXX) memiliki rentang antara 16-31 yang dapat dimasukkan memori perintah yang independen.
;3.		Sistematika penulisan => Instruksi alamat, sumber

;Identitas Pembuka
.INCLUDE <m128def.inc>		; (Directive) memasukkan library yang akan digunakan
.ORG 0x0000					; origin alamat awal dari program (start)
RJMP main					; relative jump ke kabel main (langsung melewati keseluruhan proses yang tidak perlu dan langsung menuju fungsi main)

;Deklarasi yang menyatakan keadaan awal
	  .ORG 0x0046           ; masukkan origin program ke 0x0046 {0x0000 terdapat definisi tersendiri(alokasi tersendiri)}
main: LDI R16, 0x00			; muati R16 dengan 0x00 (LDI hanya ada 16-31)
      OUT DDRB, R16			; definisikan PORTB = input (pin B akan digunakan sebagai memori)
	  ;Pada saat ini di R16 dan DDRB telah disimpan memori logika low
      LDI R16, 0xFF			; masukkan kondisi maximum (255) pada R16
      OUT PORTB, R16		; aktifkan pull-up di PORTB (memasukkan kondisi maksimum dan mengingat untuk kondisi PORTB yang disimpan dalam memori logika high)
	  ;LDI R16, 0xFF		; (tidak perlu ditulis karena sudah ditulis diatas) 
      OUT DDRE, R16			; definisikan PORTE = output

;Fungsi yang akan dikerjakan 
baca_input:  IN R17, PINB		; baca data PINB, simpan di R17     (a)
			 COM R17			; Komplemen (invers) R17			(b)
			 OUT PORTE, R17		; PORTE sebagai output dari R17		(c) 
			 RJMP baca_input	; jump ke label baca_input [fungsi ini berperan seperti "while loop" tanpa keadaan akhir (dijalankan terus-menerus) dan kembali ke fungsi (a)]
