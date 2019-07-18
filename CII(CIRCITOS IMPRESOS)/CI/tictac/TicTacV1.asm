 ;********************************
;	INIT
;********************************
	processor pic16f627a
	#include <p16f627a.inc>
	__config b'0010000100110000' ;intocc 4mc
	ERRORLEVEL 1	
	org	0x00
	goto MAIN

;TIC-TAC-TOE  V1.0
;october 2017
;Marcelo Requena (Simpletronic)


;******************
;	init
;******************

#define	BANK_1	bsf STATUS,5
#define	BANK_0	bcf STATUS,5

		cblock	0x20

tim0		;0x20		
tim1
flags			
data_A		
data_B		
temp		
temp2
temp3
temp4
intdel_1	
intdel_2	
loop			
loop2
PA_temp			
PB_temp		
kloop		
PORTA_save	
PORTB_save	;0x30
biptim0		
biptim1		
retim0		
slptim		;0x34
		endc

;	0x40  data ram (9 bytes)
;	0x41
;	0x42
;	0x43
;	0x44
;	0x45
;	0x46
;	0x47
;	0x48

;flags,0	
;flags,1	present color
;flags,2	end of game
;flags,3	start	color
;flags,4	restart
;flags,5	sleep timeout
;================================
MAIN
;================================
	bcf		INTCON,7 ;disable GIE 
	movlw	B'00000111' ; enable portA i/o
	movwf	CMCON
	movlw	b'00110001'
	movwf	T1CON	;timer1 init
	bcf		PIR1,0	;clr TMR1 overflow flag

	clrf	PORTA
	clrf	PORTB
	clrf	data_A
	clrf	data_B

;-------------------------------------------
rin	; splash intro / entry point after wake
;-------------------------------------------
	movlw	.40		
	movwf	slptim	; load sleep timer
spla1
	call	sub_table1
	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;1

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;2

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;3

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;4 red

;-------------------------------
	call	sub_table2

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;5

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;6 

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;7

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;8 

;-----------------------------------
	call	sub_table3

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;9

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;10 

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;7

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;8 

;------------------------------------------  
rin2	;rotate / entry point after restart
;------------------------------------------
	movlw	.40		
	movwf	slptim		; load sleep timer

	btfsc	flags,3		;start color
	goto	$+4			
	bsf		flags,3
	bsf		flags,1		;next color
	goto	$+3	
	bcf		flags,3
	bcf		flags,1

	bcf		flags,2		;end of game
	bcf		flags,4		;clear reset flag
	bcf		flags,5		;clear sleep flag
	call	sub_clear	;clear display ram 9bytes 

	movlw	.2
	movwf	temp4		;loop x2
spla2
	call	sub_table4

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;9

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;10 

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;11

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;12 

;--------------------------  rotate2
	call	sub_table5

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;9

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;10 

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;11

	call	sub_shift

	movlw	.10
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2			;12 

	decfsz	temp4
	goto	spla2

;--------------------------- show starting color
	btfsc	flags,1			;( 0=red 1=blue)
	goto	$+3				;1 blue
	call	sub_table6		;0 red
	goto	$+2
	call	sub_table7		;1 blu

;------------------ iter1 / all ON selected color
	movlw	.20	
	movwf	temp3
	call 	sub_beep
	call	sub_display
	decfsz	temp3
	goto	$-2				

	movlw	.255
	movwf	tim0
	movlw	.100
	movwf	tim1
	call	sub_delay

;------------------ iter2
	movlw	.20	
	movwf	temp3
	call 	sub_beep
	call	sub_display
	decfsz	temp3
	goto	$-2				

	movlw	.255
	movwf	tim0
	movlw	.100
	movwf	tim1
	call	sub_delay

;------------------ iter3
	movlw	.20	
	movwf	temp3
	call 	sub_beep
	call	sub_display
	decfsz	temp3
	goto	$-2				

	call	sub_clear		;clear RAM display data
;-----------------------------------------
;	end of splash intro - prog loop start
;-----------------------------------------		

pin
	call	sub_countdown 
	btfsc	flags,5		;sleep timeout?	
	goto	sleep_in	
	call	sub_keys	;read keys
	call	sub_set		;place in ram
	call	sub_display	;show current state
	call	sub_test	;check for win string
	call	sub_reset	;test rb4 2 seconds & set reset flag

	btfsc	flags,4		;restart ?
	goto	rin2		;go to restart

	btfss	flags,2		;win?, end of game	
	goto	pin			;continue loop


;------------------------------------------win loop	
	movlw	.2
	movwf	loop2
w0
	movlw	.20	
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2				

	movlw	.255
	movwf	tim0
	movlw	.180
	movwf	tim1
	call	sub_delay
	call	sub_beep
	decfsz	loop2
	goto	w0

w1
	movlw	.1
	movwf	retim0	;reset timer

	movlw	.20	
	movwf	temp3
	call	sub_display
	decfsz	temp3
	goto	$-2				

	movlw	.255
	movwf	tim0
	movlw	.255
	movwf	tim1
	call	sub_delay

	call	sub_reset
	btfsc	flags,4			;reset?
	goto	rin2			;go to reset
	call	sub_countdown	;	
	btfsc	flags,5			;sleep timeout?	
	goto	sleep_in
	goto	w1

;--------------------------------------------------------
sleep_in	; sleep seq start zzzz

	BANK_1
	bcf		OPTION_REG,7	;enable B pullups	
	movlw	b'00010000'		;B4 to in	
	movwf	TRISB
	movlw	b'00000000'
	movwf	TRISA			;portA all out
	BANK_0

	movlw	b'00010000'		;all portB out to 0
	movwf	PORTB

	movlw	b'00000000'
	movwf	PORTA

	bsf		INTCON,3	; enable PB int
	bcf		INTCON,0	; flag
	nop
	nop

	sleep

	nop		;wake
	nop
	nop

	BANK_1
	bsf		OPTION_REG,7	;disable B pullups	
	BANK_0

	call	sub_beep
	goto	rin	


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; 					subroutines
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



;************
sub_countdown
;************
;decrement sleep counter & set flags,5
	btfss	PIR1,0
	return
	bcf		PIR1,0
	decfsz	slptim
	return
	bsf		flags,5	;set sleep flag
	return

;**********
sub_table1
;**********
;led startup splash
;****************
;	b0	b1  b2  *
;				*
;	b3	b4	b5	*
;				*
;	b6	b7	a0	*
;****************
;	b0					xxxx xxrb
;	b1
;	b2
;	b3
;	b4
;	b5
;	b6
;	b7
;	a0
;****************
	movlw	b'10000001'
	movwf	0x40
	movlw	b'00000001'
	movwf	0x41
	movlw	b'00000001'
	movwf	0x42
	movlw	b'10000100'
	movwf	0x43
	movlw	b'00000100'
	movwf	0x44
	movlw	b'00000100'	
	movwf	0x45
	movlw	b'10010000'
	movwf	0x46
	movlw	b'00010000'
	movwf	0x47
	movlw	b'00010000'	
	movwf	0x48

	return

;**********
sub_table2
;**********    
	movlw	b'00000000'	;B0
	movwf	0x40
	movlw	b'00000010'	;B1
	movwf	0x41
	movlw	b'00001000'	;B2
	movwf	0x42
	movlw	b'01000000'	;B3
	movwf	0x43
	movlw	b'01000010'	;B4
	movwf	0x44
	movlw	b'01001000'	;B5
	movwf	0x45
	movlw	b'00010000'	;B6
	movwf	0x46
	movlw	b'00010010'	;B7
	movwf	0x47
	movlw	b'00011000'	;A0
	movwf	0x48

	return

;**********
sub_table3
;**********
	movlw	b'10000001'	;B0
	movwf	0x40
	movlw	b'00100001'	;B1
	movwf	0x41
	movlw	b'00001001'	;B2
	movwf	0x42
	movlw	b'10000000'	;B3
	movwf	0x43
	movlw	b'00100000'	;B4
	movwf	0x44
	movlw	b'00001000'	;B5
	movwf	0x45
	movlw	b'10000000'	;B6
	movwf	0x46
	movlw	b'00100000'	;B7
	movwf	0x47
	movlw	b'00001000'	;A0
	movwf	0x48

	return

;**********
sub_table4	;rotation1
;**********
	movlw	b'01000000'	;B0
	movwf	0x40
	movlw	b'00000010'	;B1
	movwf	0x41
	movlw	b'00001000'	;B2
	movwf	0x42
	movlw	b'00010000'	;B3
	movwf	0x43
	movlw	b'00000000'	;B4
	movwf	0x44
	movlw	b'00100000'	;B5
	movwf	0x45
	movlw	b'00000100'	;B6
	movwf	0x46
	movlw	b'00000001'	;B7
	movwf	0x47
	movlw	b'10000000'	;A0
	movwf	0x48

	return


;**********
sub_table5	;rotation2
;**********
	movlw	b'10000000'	;B0
	movwf	0x40
	movlw	b'00000001'	;B1
	movwf	0x41
	movlw	b'00000100'	;B2
	movwf	0x42
	movlw	b'00100000'	;B3
	movwf	0x43
	movlw	b'00000000'	;B4
	movwf	0x44
	movlw	b'00010000'	;B5
	movwf	0x45
	movlw	b'00001000'	;B6
	movwf	0x46
	movlw	b'00000010'	;B7
	movwf	0x47
	movlw	b'01000000'	;A0
	movwf	0x48

	return

;**********
sub_table6		;start player (allred)
;**********
	movlw	b'00000010'	;B0
	movwf	0x40
	movlw	b'00000010'	;B1
	movwf	0x41
	movlw	b'00000010'	;B2
	movwf	0x42
	movlw	b'00000010'	;B3
	movwf	0x43
	movlw	b'00000010'	;B4
	movwf	0x44
	movlw	b'00000010'	;B5
	movwf	0x45
	movlw	b'00000010'	;B6
	movwf	0x46
	movlw	b'00000010'	;B7
	movwf	0x47
	movlw	b'00000010'	;A0
	movwf	0x48

	return

;**********
sub_table7		;start player (allblu)
;**********
	movlw	b'00000001'	;B0
	movwf	0x40
	movlw	b'00000001'	;B1
	movwf	0x41
	movlw	b'00000001'	;B2
	movwf	0x42
	movlw	b'00000001'	;B3
	movwf	0x43
	movlw	b'00000001'	;B4
	movwf	0x44
	movlw	b'00000001'	;B5
	movwf	0x45
	movlw	b'00000001'	;B6
	movwf	0x46
	movlw	b'00000001'	;B7
	movwf	0x47
	movlw	b'00000001'	;A0
	movwf	0x48

	return

;*************
sub_shift		;shift data table 
;*************
	movlw	.9
	movwf	loop
	movlw	0x40
	movwf	FSR
	rrf		INDF
	rrf		INDF
	incf	FSR
	decfsz	loop
	goto	$-4
	return	

;***********
sub_display
;***********
;action: read ram table 0x40-0x48 & display red-blu
;used: data_B , data_A , temp ,loop,FSR
;PORTA, PORTB

	BANK_1
	movlw	b'00000000'
	movwf	TRISB		;all B to out
	movlw	b'00110000'	; all out A xept A4 in (no k)
	movwf	TRISA
	BANK_0

; 1)bluB 0000000X
	clrf	data_B
	movlw	.8
	movwf	loop
	movlw	0x40
	movwf	FSR	;point to data block
loopinBlu	
	movfw	INDF
	andlw	b'00000001'
	movwf	temp
	rrf		temp,1
	rrf		data_B
	incf	FSR
	decfsz	loop
	goto	loopinBlu

	movfw	data_B
	movwf	PORTB
;bluA,0
	movfw	PORTA
	andlw	b'11111110' ;clear bit 0 to w 
	movwf	temp
	movfw	INDF
	andlw	b'00000001'	;keep only bit0
	iorwf	temp,1
	bsf		temp,2	;on blu
	movfw	temp
	movwf	PORTA

	movlw	b'00001000'		;delay
	movwf	intdel_1
	clrf	intdel_2
	decfsz	intdel_2
	goto	$-1
	decfsz	intdel_1
	goto	$-3	

;blu leds off
	movfw	PORTA
	movwf	temp
	bcf		temp,2	;off leds blu
	movfw	temp
	movwf	PORTA	

; 2)redB 0000000X
	clrf	data_B
	movlw	.8
	movwf	loop
	movlw	0x40
	movwf	FSR	;point to data block
loopinRed	
	movfw	INDF
	andlw	b'00000010' ;keep only bit 1
	movwf	temp
	rrf		temp,1
	rrf		temp,1
	rrf		data_B
	incf	FSR
	decfsz	loop
	goto	loopinRed

	movfw	data_B
	movwf	PORTB
;redA,0
	movfw	INDF
	movwf	data_A
	rrf		data_A,0 ;bit1 to bit0 to w
	andlw	b'00000001'	;keep bit 0
	movwf	data_A

	movfw	PORTA
	andlw	b'11111110' ;clear bit 0 to w 
	iorwf	data_A,1
	bsf		data_A,3 ;on red
	movfw	data_A
	movwf	PORTA

	movlw	b'00001000'		;delay
	movwf	intdel_1
	clrf	intdel_2
	decfsz	intdel_2
	goto	$-1
	decfsz	intdel_1
	goto	$-3	
;red leds off
	movfw	PORTA
	movwf	temp
	bcf		temp,3	;off leds red
	movfw	temp
	movwf	PORTA	

	return

;***********
sub_reset	
;***********
;action: detect B4 2 sec press, set flags,4, reset game

	BANK_1
	bcf		OPTION_REG,7	;enable B pullups
	movlw	b'11111111'		;set PORTB all input
	movwf	TRISB
	movlw	b'01101111'		;a4 to out	
	movwf	TRISA
	BANK_0
	movlw	b'00000000'
	movwf	PORTA
	movfw	PORTB
	movwf	PORTB_save
	btfsc	PORTB_save,4
	goto	nk				;1=no key
	goto	yk	
nk
	movlw	.100		;reset timers
	movwf	retim0		
	return	
yk
	decfsz	retim0
	return
	bsf		flags,4		;set reset flag
	call	sub_beep
	return	

;***********
sub_keys
;***********
;action: read keys A&B, set INDF,7 (temp bit)
;used: PA_temp, PB_temp, kloop, FSR, INDF
;common to red & blu
;bits 0&1 not changed

	BANK_1
	bcf		OPTION_REG,7	;enable B pullups		
	movlw	b'11111111'		;set PORTB all input
	movwf	TRISB
	movlw	b'00100001' 	;set PORTA,0 to input
	movwf	TRISA
	BANK_0

	movfw	PORTA		;set A pullup
	movwf	PA_temp
	bsf		PA_temp,6
	bcf		PA_temp,4	;enab k
	movfw	PA_temp
	movwf	PORTA

	movfw	PORTB
	movwf	PB_temp		;store data in PB_temp
	movfw	PORTA
	movwf	PA_temp		;store data in PA_temp

	comf	PB_temp	;invert data
	comf	PA_temp,0
	andlw	b'00000001' ;clear all xpt bit 0
	movwf	PA_temp

;encode to data block in RAM
	movlw	.8
	movwf	kloop
	movlw	0x40
	movwf	FSR	;init data block
klopin
	rlf		INDF
	rrf		PB_temp		;LSBit to C
	rrf		INDF		;C to INDF,7
	incf	FSR
	decfsz	kloop	
	goto	klopin	
	rlf		INDF
	rrf		PA_temp
	rrf		INDF

	BANK_1
	bsf		OPTION_REG,7	;clear B pullups
	BANK_0

	movfw	PORTA	;clear A pullup
	movwf	PA_temp
	bcf		PA_temp,6
	movfw	PA_temp
	movwf	PORTA

	return

;*************
sub_set
;*************
;action: set temp bit 7 to bit (0,1) if empty
;used: kloop, FSR, INDF 
;flags,1 xxxx.xxNx 0=red 1=blu

	movlw	0x40
	movwf	FSR		;point to ram 
	movlw	.9
	movwf	kloop
slopin
	btfsc	INDF,7
	goto	S1		;set	
S2	incf	FSR		;clear
	decfsz	kloop
	goto	slopin	;kloop not 0
xt	return			;kloop=0

S1	movfw	INDF	
	xorlw	b'10000000'	;cell empy or full ?
	btfss	STATUS,Z
	goto	S2	;z=0 , not equal, occupied
	nop			;z=1 , xor=0 ,equal, empty
	btfsc	flags,1  ;red or blue?
	goto   $+3				 ;1=blu
	bsf		INDF,1	 ;0=red cell
	goto	S3
	bsf		INDF,0		;blu cell					
S3	call	sub_beep
	btfsc	flags,1		;invert color flag				
	goto	$+3			;flag=1
	bsf		flags,1		;flag=0	
	goto	xt			;return
	bcf		flags,1
	goto	xt	

;**********
sub_beep
;**********
;used: biptim0, biptim1, PORTA, PORTA_save, slptim 
;reloads sleep timer

	movlw	.255		
	movwf	biptim0		
	movlw	.100		
	movwf	biptim1		

	movfw	PORTA
	movwf	PORTA_save
	bsf		PORTA_save,7	;beep on
	movfw	PORTA_save
	movwf	PORTA
	decfsz  biptim0
	goto	$-1
	decfsz	biptim1 
	goto	$-3
	bcf		PORTA_save,7
	movfw	PORTA_save
	movwf	PORTA	

	movlw	.40		;refresh sleep 	
	movwf	slptim

	return


;*************
sub_test	;check for win
;*************
;find win strings:
;012	345		678	
;036	147		258
;048	246

;012---------------	 blue (indf,7)    #1
	bcf		STATUS,C
	clrf	temp

	rrf		0x40,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x41,0
	rlf		temp
	rrf		0x42,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x40
	movwf	0x41
	movwf	0x42
	bsf		flags,2		; flags,2 = end of game
	return

;012---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x40,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x41,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x42,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x40
	movwf	0x41
	movwf	0x42
	bsf		flags,2		; flags,2 = end of game
	return

;345---------------	 blue (indf,7)	#2
	bcf		STATUS,C
	clrf	temp

	rrf		0x43,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x44,0
	rlf		temp
	rrf		0x45,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x43
	movwf	0x44
	movwf	0x45
	bsf		flags,2		; flags,2 = end of game
	return

;345---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x43,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x44,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x45,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x43
	movwf	0x44
	movwf	0x45
	bsf		flags,2		; flags,2 = end of game
	return

;678---------------	 blue (indf,7)		#3
	bcf		STATUS,C
	clrf	temp

	rrf		0x46,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x47,0
	rlf		temp
	rrf		0x48,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x46
	movwf	0x47
	movwf	0x48
	bsf		flags,2		; flags,2 = end of game
	return

;678---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x46,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x47,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x48,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x46
	movwf	0x47
	movwf	0x48
	bsf		flags,2		; flags,2 = end of game
	return

;036---------------	 blue (indf,7)	#4
	bcf		STATUS,C
	clrf	temp

	rrf		0x40,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x43,0
	rlf		temp
	rrf		0x46,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x40
	movwf	0x43
	movwf	0x46
	bsf		flags,2		; flags,2 = end of game
	return

;036---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x40,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x43,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x46,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x40
	movwf	0x43
	movwf	0x46
	bsf		flags,2		; flags,2 = end of game
	return

;147---------------	 blue (indf,7)	#5
	bcf		STATUS,C
	clrf	temp

	rrf		0x41,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x44,0
	rlf		temp
	rrf		0x47,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x41
	movwf	0x44
	movwf	0x47
	bsf		flags,2		; flags,2 = end of game
	return

;147---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x41,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x44,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x47,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x41
	movwf	0x44
	movwf	0x47
	bsf		flags,2		; flags,2 = end of game
	return

;258---------------	 blue (indf,7)	#6
	bcf		STATUS,C
	clrf	temp

	rrf		0x42,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x45,0
	rlf		temp
	rrf		0x48,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x42
	movwf	0x45
	movwf	0x48
	bsf		flags,2		; flags,2 = end of game
	return

;258---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x42,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x45,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x48,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x42
	movwf	0x45
	movwf	0x48
	bsf		flags,2		; flags,2 = end of game
	return

;048---------------	 blue (indf,7)	#7
	bcf		STATUS,C
	clrf	temp

	rrf		0x40,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x44,0
	rlf		temp
	rrf		0x48,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x40
	movwf	0x44
	movwf	0x48
	bsf		flags,2		; flags,2 = end of game
	return

;048---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x40,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x44,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x48,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x40
	movwf	0x44
	movwf	0x48
	bsf		flags,2		; flags,2 = end of game
	return

;246---------------	 blue (indf,7)	#8
	bcf		STATUS,C
	clrf	temp

	rrf		0x42,0	;bit0 > c
	rlf		temp	;c > temp,0
	rrf		0x44,0
	rlf		temp
	rrf		0x46,0
	rlf		temp,0	;result in w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+8			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000001'
	movwf	0x42
	movwf	0x44
	movwf	0x46
	bsf		flags,2		; flags,2 = end of game
	return

;246---------------	 red	(indf,6)
	bcf		STATUS,C
	clrf	temp
	clrf	temp2

	rrf		0x42,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0

	rrf		0x44,0
	movwf	temp2
	rrf		temp2
	rlf		temp	;c > temp,0
	
	rrf		0x46,0
	movwf	temp2
	rrf		temp2
	rlf		temp,0	;c > temp > w

	xorlw	b'00000111'
	btfsc	STATUS,Z
	goto	$+2			;equal	Z=1 (result=0)winner
	goto	$+7			;not=   Z=0	 continue
	call	sub_clear	;erase all + display data
	movlw	b'00000010'
	movwf	0x42
	movwf	0x44
	movwf	0x46
	bsf		flags,2		; flags,2 = end of game
	return

;**********
sub_clear
;**********
;clear display & k ram 9bytes 
	movlw	.9	   
	movwf	temp3
	movlw	0x40
	movwf	FSR
	clrf	INDF
	incf	FSR
	decfsz	temp3
	goto	$-3
	return
		
;*********
sub_delay
;*********
;	used:	tim0, tim1, (must be set in call)
;
	decfsz	tim0
	goto	$-1
	decfsz	tim1
	goto	$-3
	return	



	END	

