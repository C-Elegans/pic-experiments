	#include config.inc
    UDATA
delay_1 res 1
delay_2 res 1
tabletmp res 1
digit1 res 1
digit2 res 1
digit3 res 1
digit4 res 1
dcnt res 1
dtmp res 1

    CODE

    org 0x0
    goto main
    
    org 0x48
    dw (0xb0)>>2
    org 0x4c
    dw (0xd0)>>2
    org 0xb0

t1int:                          ;Timer 1 interrupt
    banksel PIR4
    bcf PIR4, TMR1IF            ;Clear the timer interrupt flag
    
    banksel 0
    movlw 0x1                   
    addwf digit1, w
    daw
    andlw 0xF
    movwf digit1
    

    retfie 1                    ; Return from interrupt, restore context
    org 0xd0
t2int:
    banksel PIR4
    bcf PIR4, TMR2IF
    banksel dcnt
    movf dcnt, W
    addlw 0x1
    andlw 0x3
    movwf dcnt
    lfsr FSR0, digit1
    movf PLUSW0, W
    call digitlut
    movwf PORTC
    setf LATB
    movf dcnt, W
    movwf dtmp
    incf dtmp
    clrf WREG
    bsf STATUS, C
t2l: 
    rlcf WREG
    decfsz dtmp
    goto t2l
    comf WREG
    andwf LATB
    retfie 1

main
    movlb 0
    setf PORTB
    movlw b'11100000'
    movwf TRISB
    clrf TRISC
    setf PORTC
    banksel ANSELC
    clrf ANSELC
    banksel 0
    call setup_timer
    call enable_interrupts
    banksel 0
    movlw 4
    movwf digit2
    movlw 2
    movwf digit3
    movlw 9
    movwf digit4
loop:
    
    goto loop

setup_timer
    movlw b'00010010'           ; 1:2 prescaler, read as 16 bit
    movwf T1CON
    movlw b'00'                 ; Do not gate the timer
    movwf T1GCON
    movlw b'00001'
    movwf T1CLK                 ; Select Fosc/4 as the clock
    bsf T1CON, TMR1ON           ; Enable the timer

    movlw b'0001'
    movwf T2CLK
    clrf T2RST
    setf T2PR
    movlw b'00010000'
    movwf T2CON
    clrf T2HLT
    bsf T2CON, T2ON
    return

enable_interrupts:
    banksel PIE4
    bsf PIE4, TMR1IE            ; Enable TMR1 interrupt
    bsf PIR4, TMR1IF            ; Set TMR1 interrupt flag
    bsf PIE4, TMR2IF
                                ; (for debugging)
    banksel 0
    bsf INTCON0, GIE            ; Globally enable interrupts
    
    return
;setup_SMT:
;    banksel SMT1CON0
;    movlw b'10000001'           ; SMT all signals rising edge, 1:4 prescale
;    movwf SMT1CON0
;    movlw b'01000011'           ; GO off, repeat aquisition, High-Low measure
;    movwf SMT1CON1
;    clrf SMT1CLK                ; Select Fosc as clock
;    clrf SMT1SIG
;    clrf SMT1WIN
;    bsf SMT1CON1, SMT1GO
;
;    ;; Setup PPS
;    bcf INTCON0, GIE            ;Disable interrupts
;    banksel PPSLOCK
;    movlw 0x55
;    movwf PPSLOCK
;    movlw 0xAA
;    movwf PPSLOCK
;    bcf PPSLOCK, 0
;    movlw 0x12                  ; PORTC, pin 2
;    movwf SMT1SIGPPS
;    banksel 0
;    bsf INTCON0, GIE
;    return


digitlut:
    movwf tabletmp
    movlw HIGH tab
    movwf PCLATH
    movf tabletmp, W
    rlncf WREG
    addwf PCL, f
    
    ;    GABFE0DC
tab:
    dt b'11011110'
    dt b'10000010'
    dt b'01010111'
    dt b'11000111'
    dt b'10001011'
    dt b'11001101'
    dt b'11011101'
    dt b'10000110'
    dt b'11011111'
    dt b'11001111'
    
    
    end

