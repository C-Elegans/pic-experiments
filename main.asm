	#include config.inc
    UDATA
delay_1 res 1
delay_2 res 1
    CODE

    org 0x0
    goto main
    org 0x48
    dw (0xb0)>>2

    org 0xb0

t1int:                          ;Timer 1 interrupt
    banksel PIR4
    bcf PIR4, TMR1IF            ;Clear the timer interrupt flag
    
    banksel 0
    movlw 0x1                   
    xorwf LATB, f               ;Toggle RB0

    movlw 0xA0
    movwf TMR1H                 ;Write 0xA0:0x00 to Timer 1
    clrf TMR1L

    retfie 1                    ; Return from interrupt, restore context
    
main
    movlb 0
    bcf TRISB,0
    call setup_timer
    call enable_interrupts
loop
    goto loop

setup_timer
    movlw b'00010010'           ; 1:2 prescaler, read as 16 bit
    movwf T1CON
    movlw b'00'                 ; Do not gate the timer
    movwf T1GCON
    movlw b'00001'
    movwf T1CLK                 ; Select Fosc/4 as the clock
    bsf T1CON, TMR1ON           ; Enable the timer
    return

enable_interrupts:
    banksel PIE4
    bsf PIE4, TMR1IE            ; Enable TMR1 interrupt
    bsf PIR4, TMR1IF            ; Set TMR1 interrupt flag
                                ; (for debugging)
    banksel 0
    bsf INTCON0, GIE            ; Globally enable interrupts
    
    return

    end

