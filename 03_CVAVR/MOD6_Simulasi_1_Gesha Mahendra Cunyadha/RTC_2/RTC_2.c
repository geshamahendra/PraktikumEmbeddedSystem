/*******************************************************
This program was created by the
CodeWizardAVR V3.12 Advanced
Automatic Program Generator
� Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : 
Version : 
Date    : 11/9/2021
Author  : 
Company : 
Comments: 


Chip type               : ATmega128
Program type            : Application
AVR Core Clock frequency: 10.000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 1024
*******************************************************/

#include <mega128.h>
#include <delay.h>

// I2C Bus functions
#include <i2c.h>

// PCF8583 Real Time Clock functions
#include <pcf8583.h>

// Alphanumeric LCD functions
#include <alcd.h>

// Declare your global variables here
unsigned char hdetik, detik, menit, jam, hari, bulan, setjam, setmenit;
unsigned int tahun;
unsigned int i = 1;
char text1[16], text2[16];

// External Interrupt 0 service routine
interrupt [EXT_INT0] void ext_int0_isr(void)
{
// Place your code here
PORTB.0 = 0;
setjam = 0;
setmenit = 0;
}

// Standard Input/Output functions
#include <stdio.h>
#include <stdlib.h>

void main(void)
{
// Declare your local variables here

// Input/Output Ports initialization

// Port B initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRB=(1<<DDB7) | (1<<DDB6) | (1<<DDB5) | (1<<DDB4) | (1<<DDB3) | (1<<DDB2) | (1<<DDB1) | (1<<DDB0);
// State: Bit7=0 Bit6=0 Bit5=0 Bit4=0 Bit3=0 Bit2=0 Bit1=0 Bit0=0 
PORTB=(0<<PORTB7) | (0<<PORTB6) | (0<<PORTB5) | (0<<PORTB4) | (0<<PORTB3) | (0<<PORTB2) | (0<<PORTB1) | (0<<PORTB0);

// USART0 initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART0 Receiver: On
// USART0 Transmitter: On
// USART0 Mode: Asynchronous
// USART0 Baud Rate: 9600
UCSR0A=(0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (0<<U2X0) | (0<<MPCM0);
UCSR0B=(0<<RXCIE0) | (0<<TXCIE0) | (0<<UDRIE0) | (1<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
UCSR0C=(0<<UMSEL0) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0);
UBRR0H=0x00;
UBRR0L=0x40;

// External Interrupt(s) initialization
// INT0: On
// INT0 Mode: Falling Edge
// INT1: Off
// INT2: Off
// INT3: Off
// INT4: Off
// INT5: Off
// INT6: Off
// INT7: Off
EICRA=(0<<ISC31) | (0<<ISC30) | (0<<ISC21) | (0<<ISC20) | (0<<ISC11) | (0<<ISC10) | (1<<ISC01) | (0<<ISC00);
EICRB=(0<<ISC71) | (0<<ISC70) | (0<<ISC61) | (0<<ISC60) | (0<<ISC51) | (0<<ISC50) | (0<<ISC41) | (0<<ISC40);
EIMSK=(0<<INT7) | (0<<INT6) | (0<<INT5) | (0<<INT4) | (0<<INT3) | (0<<INT2) | (0<<INT1) | (1<<INT0);
EIFR=(0<<INTF7) | (0<<INTF6) | (0<<INTF5) | (0<<INTF4) | (0<<INTF3) | (0<<INTF2) | (0<<INTF1) | (1<<INTF0);

// Bit-Banged I2C Bus initialization
// I2C Port: PORTA
// I2C SDA bit: 1
// I2C SCL bit: 0
// Bit Rate: 100 kHz
// Note: I2C settings are specified in the
// Project|Configure|C Compiler|Libraries|I2C menu.
i2c_init();

// PCF8583 Real Time Clock initialization
rtc_init(0,0);

// Alphanumeric LCD initialization
// Connections are specified in the
// Project|Configure|C Compiler|Libraries|Alphanumeric LCD menu:
// RS - PORTC Bit 0
// RD - PORTC Bit 2
// EN - PORTC Bit 1
// D4 - PORTC Bit 4
// D5 - PORTC Bit 5
// D6 - PORTC Bit 6
// D7 - PORTC Bit 7
// Characters/line: 8
lcd_init(16);

// Global enable interrupts
#asm("sei")
printf("Set The Minute for The Alarm \r");
scanf("%d" , &setmenit);
delay_ms(100);
printf("Set The Hour for The Alarm \r");
scanf("%d", &setjam);
delay_ms(100);
printf("You will awake at %02d:%02d\r", setjam, setmenit);

while (1)
      {
      // Place your code here
      lcd_clear();
      sprintf(text1,"Tanggal");
      lcd_gotoxy(0,0);
      lcd_puts(text1);
      
      rtc_get_date(0, &hari, &bulan, &tahun);
      tahun = rtc_read(0,5);
      tahun = ((tahun & 0xC0)>>6);
      sprintf(text2,"%02d:%2d:%4d",hari, bulan, abs(tahun)+2020);
      lcd_gotoxy(0,1);
      lcd_puts(text2);
      delay_ms(1000);

      lcd_clear();
      sprintf(text1,"Waktu");
      lcd_gotoxy(0,0);
      lcd_puts(text1); 

      while(i<6){      
        rtc_get_time(0, &jam, &menit, &detik, &hdetik);
        sprintf(text2,"%02d:%02d:%02d",jam, menit, detik);
        lcd_gotoxy(0,1);
        lcd_puts(text2);
        delay_ms(5000);
        i=i+1;
      }
      i=1;

      while ((jam == setjam) & (menit == setmenit)){
        if ((jam == setjam) & (menit == setmenit)){
            lcd_clear();
            sprintf(text1,"WAKE UP");
            lcd_gotoxy(0,0);
            lcd_puts(text1);
            PORTB.0 = 1;
            }
        }    
      }
}
