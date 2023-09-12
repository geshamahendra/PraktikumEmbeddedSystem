/*******************************************************
This program was created by the
CodeWizardAVR V3.12 Advanced
Automatic Program Generator
� Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
http://www.hpinfotech.com

Project : 
Version : 
Date    : 10/24/2021
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
#include <stdio.h>
#include <delay.h>
#include <math.h>
#include <stdlib.h>

// Alphanumeric LCD functions
#include <alcd.h>

// Declare your global variables here
float data_adc0, data_adc1;
float tegangan0, tegangan1;
float selisih;
char LCDBuffer[16];
int led = 0b00000000;

// Voltage Reference: AVCC pin
#define ADC_VREF_TYPE ((0<<REFS1) | (1<<REFS0) | (0<<ADLAR))

// Read the AD conversion result
unsigned int read_adc(unsigned char adc_input)
{
ADMUX=adc_input | ADC_VREF_TYPE;
// Delay needed for the stabilization of the ADC input voltage
delay_ms(1);
// Start the AD conversion
ADCSRA|=(1<<ADSC);
// Wait for the AD conversion to complete
while ((ADCSRA & (1<<ADIF))==0);
ADCSRA|=(1<<ADIF);
return ADCW;
}

void main(void)
{
// Declare your local variables here

// Input/Output Ports initialization

// Port B initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRB=(1<<DDB7) | (1<<DDB6) | (1<<DDB5) | (1<<DDB4) | (1<<DDB3) | (1<<DDB2) | (1<<DDB1) | (1<<DDB0);
// State: Bit7=0 Bit6=0 Bit5=0 Bit4=0 Bit3=0 Bit2=0 Bit1=0 Bit0=0 
PORTB=(0<<PORTB7) | (0<<PORTB6) | (0<<PORTB5) | (0<<PORTB4) | (0<<PORTB3) | (0<<PORTB2) | (0<<PORTB1) | (0<<PORTB0);

// Port C initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRC=(1<<DDC7) | (1<<DDC6) | (1<<DDC5) | (1<<DDC4) | (1<<DDC3) | (1<<DDC2) | (1<<DDC1) | (1<<DDC0);
// State: Bit7=0 Bit6=0 Bit5=0 Bit4=0 Bit3=0 Bit2=0 Bit1=0 Bit0=0 
PORTC=(0<<PORTC7) | (0<<PORTC6) | (0<<PORTC5) | (0<<PORTC4) | (0<<PORTC3) | (0<<PORTC2) | (0<<PORTC1) | (0<<PORTC0);

// ADC initialization
// ADC Clock frequency: 625.000 kHz
// ADC Voltage Reference: AVCC pin
ADMUX=ADC_VREF_TYPE;
ADCSRA=(1<<ADEN) | (0<<ADSC) | (0<<ADFR) | (0<<ADIF) | (0<<ADIE) | (1<<ADPS2) | (0<<ADPS1) | (0<<ADPS0);
SFIOR=(0<<ACME);

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
// Characters/line: 16
lcd_init(16);

while (1)
      {
      // Place your code here
      lcd_clear();
      data_adc0 = read_adc(0);
      tegangan0 = data_adc0*4/1023;
      data_adc1 = read_adc(1);
      tegangan1 = data_adc1*4/1023;
      
      lcd_gotoxy(0,0);
      sprintf(LCDBuffer,"%1.2f V -- %1.2f V", tegangan0, tegangan1);
      lcd_puts(LCDBuffer);
      
      selisih = fabs(tegangan0-tegangan1);
      
      lcd_gotoxy(0,1);
      sprintf(LCDBuffer,"Selisih = %1.2f V", selisih);
      lcd_puts(LCDBuffer);
      delay_ms(100);
      
      PORTB = led;
      if (selisih == 0){
          led = 0b00000000;      
        } else if (selisih < 1){
          led = 0b11000000; 
        } else if (selisih < 2){
          led = 0b11110000;
        } else if (selisih < 3){
          led = 0b11111100;
        } else if (selisih < 4){
          led = 0b11111111;
        } else {
          if (led == 0B10101010)
        { led = 0B01010101; 
        } else {
          led = 0B10101010;
          };
        };
      delay_ms(100);
      }
}     
