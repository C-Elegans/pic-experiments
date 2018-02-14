	#include config.inc
    UDATA
delay_1 res 1
delay_2 res 1
    CODE

    org 0x0
    goto main
    org 0x24
    dw (0xc0)>>2
    org 0x48
    dw (0xb0)>>2

    org 0xb0

t1int:                          ;Timer 1 interrupt
    banksel PIR4
    bcf PIR4, TMR1IF            ;Clear the timer interrupt flag
    
    banksel 0
    movlw 0x1                   
    ;; xorwf LATB, f               ;Toggle RB0

    movlw 0xA0
    movwf TMR1H                 ;Write 0xA0:0x00 to Timer 1
    clrf TMR1L

    retfie 1                    ; Return from interrupt, restore context
    org 0xc0
smtint:
    banksel PIR1
    bcf PIR1, SMT1PRAIF
    retfie 1
main
    movlb 0
    bcf TRISB, 0
    bsf TRISC, 2
    banksel ANSELC
    clrf ANSELC
    banksel 0
    call setup_timer
    call enable_interrupts
    call setup_SMT
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
    bsf PIE1, SMT1PRAIE
    bcf PIR1, SMT1PRAIF
                                ; (for debugging)
    banksel 0
    bsf INTCON0, GIE            ; Globally enable interrupts
    
    return
setup_SMT:
    banksel SMT1CON0
    movlw b'10000001'           ; SMT all signals rising edge, 1:4 prescale
    movwf SMT1CON0
    movlw b'01000011'           ; GO off, repeat aquisition, High-Low measure
    movwf SMT1CON1
    clrf SMT1CLK                ; Select Fosc as clock
    clrf SMT1SIG
    clrf SMT1WIN
    bsf SMT1CON1, SMT1GO

    ;; Setup PPS
    bcf INTCON0, GIE            ;Disable interrupts
    banksel PPSLOCK
    movlw 0x55
    movwf PPSLOCK
    movlw 0xAA
    movwf PPSLOCK
    bcf PPSLOCK, 0
    movlw 0x12                  ; PORTC, pin 2
    movwf SMT1SIGPPS
    banksel 0
    bsf INTCON0, GIE
    return

    end

