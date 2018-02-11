	#include config.inc
UDATA
delay_1 res 1
delay_2 res 1
CODE
    org 0x0
    goto main
    org 0x08
    goto t1int
    org 0x18
    goto t1int
    org 0xaa

t1int:
    banksel PIR4
    bcf PIR4, TMR1IF
    banksel 0
    movlw 0x1
    xorwf LATB, f
    movlw 0xA0
    movwf TMR1H
    clrf TMR1L
    retfie 1
    
main
    movlb 0
    call setup_timer
    bcf TRISB,0
    call enable_interrupts
loop

    goto loop

setup_timer
    movlw b'00110010'
    movwf T1CON
    movlw b'00'                 ; Do not gate the timer
    movwf T1GCON
    movlw b'00001'
    movwf T1CLK                 ;Select Fosc/4 as the clock
    bsf T1CON, 0
    return
enable_interrupts:
    banksel PIE4
    bsf PIE4, TMR1IE
    bsf PIR4, TMR1IF
    banksel 0
    bsf INTCON0, GIE
    
    return

    end

