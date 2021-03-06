;Description:
; Full duplex DMX PC Interface Code
;
; Speed: 12Mhz
; Input:  DMX 512 Signal (250000 Baud)
; Output: DMX 512 Signal (250000 Baud)
; Also Connection to PC over USB
;
; Target: ATmega8515
;
; Pin Definitions:
; Port A,0-7	-> Memory Adress/Data Port
; Port B,0		-> DMX Transceiver Driver Power On/Off (0 -> On)
; Port B,1-7	-> NC
; Port C,0-7	-> Memory Adress Port
; Port D,0 (RxD)-> 75176,Y (DMX Receive)
; Port D,1 (TxD)-> 75176,Y (DMX Transmit)
; Port D,2		-> USBN9604, INT
; Port D,3		-> Device USB Power Detection
; Port D,4		-> Device EXT Power Detection
; Port D,5		-> USB Active LED
; Port D,6		-> /WR
; Port D,7		-> /RD
;
; Memory (Intern 60h - 25Fh):
; 60h - 61h		-> DMX Receive Memory Pointer
; 62h - 63h		-> DMX Send Memory Pointer
;
; USBN (Extern 1000h - 103Fh)
;
; Memory (Extern 2000h - 3FFFh):
; 2000h - 21FFh	-> DMX In Memory (512 Bytes)
; 2200h - 23FFh	-> PC Data In Memory (512 Bytes)
; 2400h - 24FFh	-> Status Memory (256 Bytes)
; 2500h - 25FFh	-> Config Memory (256 Bytes)
; 2600h - 27FFh	-> DMX In Backup Memory (512 Bytes)
; 2800h - 29FFh	-> DMX Change Memory (512 Bytes)
; 2A00h - 2BFFh	-> DMX Out Memory (512 Bytes)


;Includes:
.include "m8515def.inc"


;Equals:
;Pins:
.equ			DMX_DRIVER				=0
.equ			USBN_INT				=2
.equ			USB_POWER				=3
.equ			EXT_POWER				=4
.equ			LED						=5

;Memory Locations for DMX Transceiver:
.equ			DMXRMPL					=0x0060			;DMX Receiver Memory Pointer L
.equ			DMXRMPH					=0x0061			;DMX Receiver Memory Pointer H
.equ			DMXTMPL					=0x0062			;DMX Transmitter Memory Pointer L
.equ			DMXTMPH					=0x0063			;DMX Transmitter Memory Pointer H
.equ			DMXRINDCOUNT			=0x0068			;DMX Receiver Indicator Count (Shows if an incoming DMX Signal is present)
.equ			TIMER0_H				=0x0069

.equ			DMXTADV_CTRL			=0x0070			;Bit 4: Break Delay Run, Bit 5: Mark Delay Run, Bit 6: Interbyte Delay Run, Bit 7: Interframe Delay Run
.equ			DMXTADV_BRK				=0x0071
.equ			DMXTADV_MARK			=0x0072
.equ			DMXTADV_START			=0x0073
.equ			DMXTADV_BYTE			=0x0074
.equ			DMXTADV_CNT_L			=0x0075
.equ			DMXTADV_CNT_H			=0x0076
.equ			DMXTADV_FRM				=0x0077
.equ			DMXTADV_BRK_H			=0x0078
.equ			DMXTADV_MARK_H			=0x0079
.equ			DMXTADV_BYTE_H			=0x007A
.equ			DMXTADV_FRM_H			=0x007B

.equ			DMXTADV_CTRL_LOAD		=0x0080			;Bit 0: Enable Interbyte Delay, Bit 1: Enable Interframe Delay
.equ			DMXTADV_BRK_LOAD		=0x0081			;CK/64
.equ			DMXTADV_MARK_LOAD		=0x0082			;CK/8
.equ			DMXTADV_START_LOAD		=0x0083			;Transmitt Startbyte
.equ			DMXTADV_BYTE_LOAD		=0x0084			;CK/8
.equ			DMXTADV_CNT_L_LOAD		=0x0085
.equ			DMXTADV_CNT_H_LOAD		=0x0086
.equ			DMXTADV_FRM_LOAD		=0x0087			;CK/256
.equ			DMXTADV_BRK_H_LOAD		=0x0088
.equ			DMXTADV_MARK_H_LOAD		=0x0089
.equ			DMXTADV_BYTE_H_LOAD		=0x008A
.equ			DMXTADV_FRM_H_LOAD		=0x008B

.equ			EEPROM_ADDR				=0x0090
.equ			EEPROM_DATA				=0x0091

;Memory Locations for USB Transceiver:
.equ			USB_SETUP_0				=0x0100			;Actual EP 0 USB Setup Packet Byte 0
.equ			USB_SETUP_1				=0x0101			;Actual EP 0 USB Setup Packet Byte 1
.equ			USB_SETUP_2				=0x0102			;Actual EP 0 USB Setup Packet Byte 2
.equ			USB_SETUP_3				=0x0103			;Actual EP 0 USB Setup Packet Byte 3
.equ			USB_SETUP_4				=0x0104			;Actual EP 0 USB Setup Packet Byte 4
.equ			USB_SETUP_5				=0x0105			;Actual EP 0 USB Setup Packet Byte 5
.equ			USB_SETUP_6				=0x0106			;Actual EP 0 USB Setup Packet Byte 6
.equ			USB_SETUP_7				=0x0107			;Actual EP 0 USB Setup Packet Byte 7
.equ			USB_CONFIG				=0x0108			;USB Config Register (Contains the actual USB Configuration (0 = unconfigured or 1 = configured))

;Memory Locations for Device Power Logic:
.equ			DEV_STATUS_BAC			=0x0109
.equ			DMX_USBLED_STAT			=0x010A			;Contains the Status of DMX TX/RX/EN and USB_LED (Bit 0: DMX_TX_ON; Bit 1: DMX_TX_OFF; Bit 2: DMX_RX_ON; Bit 3: DMX_RX_OFF; Bit 4: DMX_EN_ON; Bit 5: DMX_EN_OFF; Bit 6: USB_LED_ON; Bit 7: USB_LED_OFF)

;I/O Locations for USBN9604:
.equ			MCNTRL					=0x1000
.equ			CCONF					=0x1001
.equ			RID						=0x1003
.equ			FAR						=0x1004
.equ			NFSR					=0x1005
.equ			MAEV					=0x1006
.equ			MAMSK					=0x1007
.equ			ALTEV					=0x1008
.equ			ALTMSK					=0x1009
.equ			TXEV					=0x100A
.equ			TXMSK					=0x100B
.equ			RXEV					=0x100C
.equ			RXMSK					=0x100D
.equ			NAKEV					=0x100E
.equ			NAKMSK					=0x100F
.equ			FWEV					=0x1010
.equ			FWMSK					=0x1011
.equ			FNH						=0x1012
.equ			FNL						=0x1013
.equ			DMACNTRL				=0x1014
.equ			DMAEV					=0x1015
.equ			DMAMSK					=0x1016
.equ			MIR						=0x1017
.equ			DMACNT					=0x1018
.equ			DMAERR					=0x1019
.equ			WKUP					=0x101B
.equ			EPC0					=0x1020
.equ			TXD0					=0x1021
.equ			TXS0					=0x1022
.equ			TXC0					=0x1023
.equ			RXD0					=0x1025
.equ			RXS0					=0x1026
.equ			RXC0					=0x1027
.equ			EPC1					=0x1028
.equ			TXD1					=0x1029
.equ			TXS1					=0x102A
.equ			TXC1					=0x102B
.equ			EPC2					=0x102C
.equ			RXD1					=0x102D
.equ			RXS1					=0x102E
.equ			RXC1					=0x102F
.equ			EPC3					=0x1030
.equ			TXD2					=0x1031
.equ			TXS2					=0x1032
.equ			TXC2					=0x1033
.equ			EPC4					=0x1034
.equ			RXD2					=0x1035
.equ			RXS2					=0x1036
.equ			RXC2					=0x1037
.equ			EPC5					=0x1038
.equ			TXD3					=0x1039
.equ			TXS3					=0x103A
.equ			TXC3					=0x103B
.equ			EPC6					=0x103C
.equ			RXD3					=0x103D
.equ			RXS3					=0x103E
.equ			RXC3					=0x103F


;Register Definitions:

.def			LPM_LOAD				=r0				;LPM Load Register (Get Descriptor Functions -> Programm Memory Access)
.def			USB_ACT_DESC_POS_L		=r1
.def			USB_ACT_DESC_POS_H		=r2
.def			USB_DESC_ENDPOINT_L		=r3
.def			USB_DESC_ENDPOINT_H		=r4
.def			USB_ACT_DESC_PACKE_L	=r5
.def			USB_ACT_DESC_PACKE_H	=r6
.def			USB_SET_REP_MEM_POS_L	=r7
.def			USB_SET_REP_MEM_POS_H	=r8
.def			SREG_BACK				=r9				;Backup Register for STATUS Register in Interrupts
.def			DELAY_R					=r10			;DELAY Register
.def			INT_TEMP				=r11			;USB Interrupt Temp Register
.def			DESC_SIZE				=r12			;USB Descriptor Size Register
.def			INT_DELAY				=r13
.def			TEMP_2					=r14			;Additional Temp Register
.def			LAST_DEV_CONFIG			=r15			;Last Device Configuration
.def			TEMP					=r16			;Temp Register
.def			LOAD					=r17			;Load Register
.def			USB_INIT_LOAD			=r18			;USB Interrupt Load Register
.def			DESC_ACT_POS			=r19			;USB Actual Descriptor Position Register
.def			DEV_CONFIG				=r20			;Device Config Register (Contains the actual Device Configuration)
.def			USB_STATUS				=r21			;USB Status Register (Bit 0: Get Descriptor Mode; Bit 1: Get Report Mode; Bit 2: Set Report Mode; Bit 3: TX0 DATA PID TOGGLE BIT; Bit 4: RX0 DATA PID TOGGLE BIT; Bit 5: TX1 active; Bit 6: TX1 DATA PID TOGGLE BIT)
.def			DEV_STATUS				=r22			;Device Status (Bit 0: USB Active; Bit 1: USB Bus powered; Bit 2: Self powered; Bit 3: USB Suspend indicator Bit; Bit 4: USB Bus powered Backup; Bit 5: Self powered Backup; Bit 6: USB Suspend indicator Bit Backup)
.def			BYTE_TREAT_POS			=r23			;DMX In -> PC In Compare Block Position Register(00h - 15h: Actual Block, 16h: Update DMX In Backup Mem)
.def			DMX_STATE				=r24			;DMX Status Register (Bit 0: Wait for Break; Bit 1: There was a Break in the last Frame; Bit 2: Send Break)
.def			DMX_BYTE				=r25			;DMX Byte Register (Only used in DMX Transceiver Interrupt Service Routines)
.def			INT_LOAD				=r25			;General Interrupt Load Register (Not used in UART RX Interrupt Service Routine)

; 				r26,r27					->				16 Bit X Register: Memory Access for Main Routines
; 				r28,r29					-> 				16 Bit Y Register: Memory Access for Main Routines
; 				r30,r31					->				16 Bit Z Register: Temporary DMX Transceiver Memory Position and temporary Memory Access for USB Interrupt Routines



;Programm Code:
.org $0000



;Interrupts:
				rjmp	RESET
				rjmp	INT0_USBN
				reti
				reti
				reti
				reti
				rjmp	TIMER1_OVER
				rjmp	TIMER0_OVER
				reti
				rjmp	RX_INT
				rjmp	TX_EMPTY
				rjmp	TX_COMPLETE
				reti
				reti
				reti
				reti
				reti



;Delays:
DELAY:			clr		DELAY_R
DELAY_JUMP:		dec		DELAY_R
				brbc	1,DELAY_JUMP
				clr		DELAY_R
DELAY_JUMP1:	dec		DELAY_R
				dec		DELAY_R
				dec		DELAY_R
				dec		DELAY_R
				brbc	1,DELAY_JUMP1
				ret


INT0_DELAY_97u:	clr		INT_DELAY
INT0_DELAY_JUMP:dec		INT_DELAY
				brbc	1,INT0_DELAY_JUMP
				clr		INT_DELAY
INT0_DELAY_JUM1:dec		INT_DELAY
				dec		INT_DELAY
				dec		INT_DELAY
				dec		INT_DELAY
				brbc	1,INT0_DELAY_JUM1
				ret


;--------------- Begin DMX 512 Receive and Transmitt Routines -------------------

;UART Receive Complete Interrupt
RX_INT:			;DMX Receive Interrupt Service Routine
				in		SREG_BACK,SREG			;Save SREG
				lds		ZH,DMXRMPH				;Load Memory Pointer from internal SRAM
				lds		ZL,DMXRMPL
				;Check if last Transmission was a Break
				sbic	UCSRB,1					;Is Break?
				rjmp	NO_BREAK				;No!
				in		DMX_BYTE,UDR			;GET DMX_BYTE
				ldi		ZH,0x20					;DMX Memory Start (High Byte)
				ldi		ZL,0x00					;DMX Memory Start (Low Byte)
				cbr		DMX_STATE,1				;Clr Wait_for_next_Break
				sbr		DMX_STATE,2				;Set Break_was_in_last_Frame
				rjmp	ENDE_RX_INT				;Exit_Interruptroutine
NO_BREAK:		in		DMX_BYTE,UDR			;GET DMX_BYTE
				;Check if Data can be received at the Moment or if we are waiting for the next Frame
				;Check (if we receive Data) if the last Transmission was a Startbyte
				sbrc	DMX_STATE,0				;Is Wait_for_next_Break set?
				rjmp	ENDE_RX_INT				;Yes!
				sbrs	DMX_STATE,1				;No!  -> Was there a Break in the last Frame?
				rjmp	DATA_BYTE_REC			;No!  -> goto DATA_BYTE_REC
				cpi		DMX_BYTE,0				;Yes! -> Is DMX_BYTE = 0?
				brne	SET_WB_U_EXIT			;No!  -> Set Wait_for_next_Break_and_Exit
				cbr		DMX_STATE,2				;Yes  -> Clear Break_was_in_last_Frame
				ldi		DMX_BYTE,0xFF			;Reset DMX Indicator
				sts		DMXRINDCOUNT,DMX_BYTE
				rjmp	ENDE_RX_INT				;and Exit Interruptroutine
DATA_BYTE_REC:	;Receive Bytes until "CHANNELS_TO_RECV" is reached
				st		Z+,DMX_BYTE
				cpi		ZH,0x22					;512 + DMX Receive Memory Start (High Byte)
				brlo	ENDE_RX_INT				;goto ENDE_RX_INT
SET_WB_U_EXIT:	sbr		DMX_STATE,1				;Set WAIT_FOR_NEXT_BREAK Bit and Exit
ENDE_RX_INT:	sts		DMXRMPH,ZH				;Save Memory Pointer to internal SRAM
				sts		DMXRMPL,ZL
				out		SREG,SREG_BACK
				reti

;TX Helper Functions
TX_ADV_UPDATE_I:lds		DMX_BYTE,DMXTADV_CTRL_LOAD ;Copy using Interrupt Register
				andi	DMX_BYTE,0x03
				sts		DMXTADV_CTRL,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_START_LOAD
				sts		DMXTADV_START,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_CNT_L_LOAD
				sts		DMXTADV_CNT_L,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_CNT_H_LOAD
				subi	DMX_BYTE,0xD6				;add 0x2A to high Byte because DMX Out Buffer starts at 0x2A00
				sts		DMXTADV_CNT_H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BRK_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_BRK,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BRK_H_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_BRK_H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_MARK_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_MARK,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_MARK_H_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_MARK_H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BYTE_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_BYTE,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BYTE_H_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_BYTE_H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_FRM_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_FRM,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_FRM_H_LOAD
				com		DMX_BYTE					;Invert because we are using an Up-Timer
				sts		DMXTADV_FRM_H,DMX_BYTE
				ret

TX_ADV_UPDATE:	lds		LOAD,DMXTADV_CTRL_LOAD ;Copy using Main Register
				andi	LOAD,0x03
				sts		DMXTADV_CTRL,LOAD
				lds		LOAD,DMXTADV_START_LOAD
				sts		DMXTADV_START,LOAD
				lds		LOAD,DMXTADV_CNT_L_LOAD
				sts		DMXTADV_CNT_L,LOAD
				lds		LOAD,DMXTADV_CNT_H_LOAD
				subi	LOAD,0xD6				;add 0x2A to high Byte because DMX Out Buffer starts at 0x2A00
				sts		DMXTADV_CNT_H,LOAD
				lds		LOAD,DMXTADV_BRK_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_BRK,LOAD
				lds		LOAD,DMXTADV_BRK_H_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_BRK_H,LOAD
				lds		LOAD,DMXTADV_MARK_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_MARK,LOAD
				lds		LOAD,DMXTADV_MARK_H_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_MARK_H,LOAD
				lds		LOAD,DMXTADV_BYTE_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_BYTE,LOAD
				lds		LOAD,DMXTADV_BYTE_H_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_BYTE_H,LOAD
				lds		LOAD,DMXTADV_FRM_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_FRM,LOAD
				lds		LOAD,DMXTADV_FRM_H_LOAD
				com		LOAD					;Invert because we are using an Up-Timer
				sts		DMXTADV_FRM_H,LOAD
				ret

;UART Send Empty Interrupt
TX_EMPTY:		;DMX Sender Empty Interrupt Service Routine
				in		SREG_BACK,SREG			;Save SREG
				lds		ZH,DMXTMPH				;Load Memory Pointer from internal SRAM
				lds		ZL,DMXTMPL
				lds		DMX_BYTE,DMXTADV_CNT_L	;Check if end of TX DMX Buffer is reached
				cp		ZL,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_CNT_H
				cpc		ZH,DMX_BYTE
				brsh	TX_EMPTY_D_C			;All Data has been sent
				ld		DMX_BYTE,Z+				;Load Byte from Memory
				out		UDR,DMX_BYTE			;Send Byte to UART
				rjmp	ENDE_TX_EMPTY
TX_EMPTY_D_C:	cbi		UCSRB,5					;Disable TX Empty Interrupt
				sbr		DMX_STATE,0x04			;Set send Break
ENDE_TX_EMPTY:	sts		DMXTMPH,ZH				;Save Memory Pointer to internal SRAM
				sts		DMXTMPL,ZL
				out		SREG,SREG_BACK
				reti

;UART Send Complete Interrupt
TX_COMPLETE:	;DMX Sender Complete Interrupt Service Routine
				in		SREG_BACK,SREG			;Yes, Save SREG
TX_COMPLETE_NS:	lds		DMX_BYTE,DMXTADV_CTRL
				sbrs	DMX_BYTE,0				;Interbyte Delay?
				rjmp	TX_COMPLETE_BRK
TX_COMPLETE_IB:	lds		DMX_BYTE,DMXTADV_CTRL	;Interbyte Delay, Set Interbyte Delay Run Bit
				sbr		DMX_BYTE,0x40
				sts		DMXTADV_CTRL,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BYTE_H	;Load Timer with DMXTADV_BYTE
				out		TCNT1H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BYTE
				out		TCNT1L,DMX_BYTE
				ldi		DMX_BYTE,0x02
				out		TCCR1B,DMX_BYTE			;Start Timer with CK/8 (= 1,5 MHz)
				out		SREG,SREG_BACK
				reti
TX_COMPLETE_BRK:sbrs	DMX_STATE,2				;Send break?
				reti							;No -> Exit
				lds		DMX_BYTE, DMXTADV_CTRL
				sbrc	DMX_BYTE, 1
				rjmp	TX_COMPLETE_IF
				rjmp	TX_COMPLETE_B
TX_COMPLETE_IF:	lds		DMX_BYTE,DMXTADV_CTRL	;Interframe Delay enabled, Set Interframe Delay Run Bit
				sbr		DMX_BYTE,0x80
				sts		DMXTADV_CTRL,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_FRM_H	;Load Timer with DMXTADV_FRM
				out		TCNT1H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_FRM
				out		TCNT1L,DMX_BYTE
				ldi		DMX_BYTE,0x04
				out		TCCR1B,DMX_BYTE			;Start Timer with CK/256 (= 46,875 KHz)
				cbr		DMX_STATE,0x04			;Clear send Break
				out		SREG,SREG_BACK
				reti
TX_COMPLETE_B:	cbi		UCSRB,3					;Next Break, Disable Transmitter
				rcall	TX_ADV_UPDATE_I			;Copy DMX_ADV Values here
				lds		DMX_BYTE,DMXTADV_CTRL	;Set Break Delay Run Bit
				sbr		DMX_BYTE,0x10
				sts		DMXTADV_CTRL,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BRK_H	;Load Timer with DMXTADV_BRK
				out		TCNT1H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BRK
				out		TCNT1L,DMX_BYTE
				ldi		DMX_BYTE,0x03
				out		TCCR1B,DMX_BYTE			;Start Timer with CK/64 (= 187,5 KHz)
				cbr		DMX_STATE,0x04			;Clear send Break
				out		SREG,SREG_BACK
				reti

;Timer 0 Overrun Interrupt
TIMER1_OVER:	;DMX Sender Timer Interrupt Service Routine
				in		SREG_BACK,SREG			;Save SREG
				ldi		DMX_BYTE,0x00
				out		TCCR1B,DMX_BYTE			;Stop Timer
				in		DMX_BYTE,TIFR			;Clear Overflow Flag
				sbr		DMX_BYTE,0x80
				out		TIFR,DMX_BYTE
				lds		DMX_BYTE, DMXTADV_CTRL	;Get Timer Reason
				sbrc	DMX_BYTE, 4
				rjmp	TIMER1_OV_BRK
				sbrc	DMX_BYTE, 5
				rjmp	TIMER1_OV_MRK
				sbrc	DMX_BYTE, 6
				rjmp	TIMER1_OV_IB
				rjmp	TIMER1_OV_IF
TIMER1_OV_BRK:	sbi		UCSRB,3					;Break Delay Done, Start Transmitter
				lds		DMX_BYTE,DMXTADV_CTRL	;Clear Break Delay Run Bit and set Mark Delay Run Bit
				cbr		DMX_BYTE,0x10
				sbr		DMX_BYTE,0x20
				sts		DMXTADV_CTRL,DMX_BYTE
				ldi		ZH,0x2A					;Set Transmitter Start Memory Position
				ldi		ZL,0x00
				sts		DMXTMPH,ZH				;Save Memory Pointer to internal SRAM
				sts		DMXTMPL,ZL
				lds		DMX_BYTE,DMXTADV_MARK_H	;Load Timer with DMXTADV_MARK
				out		TCNT1H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_MARK
				out		TCNT1L,DMX_BYTE
				ldi		DMX_BYTE,0x02
				out		TCCR1B,DMX_BYTE			;Start Timer with CK/8 (= 1,5 MHz)
				out		SREG,SREG_BACK
				reti
TIMER1_OV_MRK:	lds		DMX_BYTE, DMXTADV_CTRL	;Mark Delay Done
				cbr		DMX_BYTE,0x20			;Clear Mark Delay Run Bit
				sts		DMXTADV_CTRL,DMX_BYTE
				sbrs	DMX_BYTE,0				;Interbyte Delay? -> Don't activate TX Empty IRQ
				sbi		UCSRB,5					;Enable TX Empty Interrupt
				cbr		DMX_STATE,0x04			;Clear send Break
				lds		DMX_BYTE, DMXTADV_START	;Send Startbyte
				out		UDR,DMX_BYTE
				out		SREG,SREG_BACK
				reti
TIMER1_OV_IB:	lds		ZH,DMXTMPH				;Interbyte Delay Done, Load Memory Pointer from internal SRAM
				lds		ZL,DMXTMPL
				lds		DMX_BYTE, DMXTADV_CNT_L	;Check if end of TX DMX Buffer is reached
				cp		ZL,DMX_BYTE
				lds		DMX_BYTE, DMXTADV_CNT_H
				cpc		ZH,DMX_BYTE
				brsh	TIMER1_OV_IB_DC			;All Data has been sent
				ld		DMX_BYTE,Z+				;Load Byte from Memory
				out		UDR,DMX_BYTE			;Send Byte to UART
				sts		DMXTMPH,ZH				;Save Memory Pointer to internal SRAM
				sts		DMXTMPL,ZL
				out		SREG,SREG_BACK
				reti
TIMER1_OV_IB_DC:sts		DMXTMPH,ZH				;Save Memory Pointer to internal SRAM
				sts		DMXTMPL,ZL
				sbr		DMX_STATE,0x04			;Set send Break
				lds		DMX_BYTE,DMXTADV_CTRL	;Clear Interbyte Delay Run and Interbyte Delay Bit
				cbr		DMX_BYTE,0x41
				sts		DMXTADV_CTRL,DMX_BYTE
				sbr		DMX_STATE,0x04			;Set send Break
				rjmp	TX_COMPLETE_NS
TIMER1_OV_IF:	cbi		UCSRB,3					;Interframe Delay Done, Next Break, Disable Transmitter
				rcall	TX_ADV_UPDATE_I			;Copy DMX_ADV Values here
				lds		DMX_BYTE,DMXTADV_CTRL	;Set Break Delay Run Bit
				sbr		DMX_BYTE,0x10
				sts		DMXTADV_CTRL,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BRK_H	;Load Timer with DMXTADV_BRK
				out		TCNT1H,DMX_BYTE
				lds		DMX_BYTE,DMXTADV_BRK
				out		TCNT1L,DMX_BYTE
				ldi		DMX_BYTE,0x03
				out		TCCR1B,DMX_BYTE			;Start Timer with CK/64 (= 187,5 KHz)
				out		SREG,SREG_BACK
				reti

;DMX RX/TX/EN Start/Stop Routines
DMX_START_RX:	lds		TEMP,DMX_USBLED_STAT
				sbrc	TEMP,1
				rjmp	DMX_START_RX_E
				sbr		TEMP,0x02
				clr		DMX_STATE
				sts		DMXRINDCOUNT,DMX_STATE	;Clear DMX Indicator Register
				ldi		DMX_STATE,0x01			;Init DMX Status Register
				sbi		UCSRB,4					;Enable RX-UART
				sbi		UCSRB,7					;Enable RX Interrupt
DMX_START_RX_E:	sts		DMX_USBLED_STAT,TEMP
				ret

DMX_STOP_RX:	lds		TEMP,DMX_USBLED_STAT
				sbrs	TEMP,1
				rjmp	DMX_STOP_RX_E
				cbr		TEMP,0x02
				cbi		UCSRB,7					;Disable RX Interrupt
				cbi		UCSRB,4					;Disable RX-UART
				clr		DMX_STATE
				sts		DMXRINDCOUNT,DMX_STATE	;Clear DMX Indicator Register
DMX_STOP_RX_E:	sts		DMX_USBLED_STAT,TEMP
				ret

DMX_START_TX:	lds		TEMP,DMX_USBLED_STAT
				sbrc	TEMP,0
				rjmp	DMX_START_TX_E
				sbr		TEMP,0x01
				ldi		LOAD,0x60				;Clear Interrupt Flag when set
				out		UCSRA,LOAD
				rcall	TX_ADV_UPDATE			;Copy DMX_ADV Values here
				lds		LOAD,DMXTADV_CTRL		;Set Break Delay Run Bit
				sbr		LOAD,0x10
				sts		DMXTADV_CTRL,LOAD
				lds		LOAD,DMXTADV_BRK_H		;Load Timer with DMXTADV_BRK
				out		TCNT1H,LOAD
				lds		LOAD,DMXTADV_BRK
				out		TCNT1L,LOAD
				ldi		LOAD,0x03
				out		TCCR1B,LOAD				;Start Timer with CK/64 (= 187,5 KHz)
				sbi		UCSRB,6					;Enable TX Complete Interrupt
DMX_START_TX_E:	sts		DMX_USBLED_STAT,TEMP
				ret

DMX_STOP_TX:	lds		TEMP,DMX_USBLED_STAT
				sbrs	TEMP,0
				rjmp	DMX_STOP_TX_E
				cbr		TEMP,0x01
				ldi		LOAD,0x00
				out		TCCR1B,LOAD				;Stop Timer
				cbi		UCSRB,6					;Disable TX Complete Interrupt
				cbi		UCSRB,5					;Disable TX Empty Interrupt
				cbi		UCSRB,3					;Disable Transmitter
DMX_STOP_TX_E:	sts		DMX_USBLED_STAT,TEMP
				ret

DMX_START_EN:	lds		TEMP,DMX_USBLED_STAT
				sbrc	TEMP,2
				rjmp	DMX_START_EN_E
				sbr		TEMP,0x04
				cbi		PORTB,DMX_DRIVER
DMX_START_EN_E:	sts		DMX_USBLED_STAT,TEMP
				ret

DMX_STOP_EN:	lds		TEMP,DMX_USBLED_STAT
				sbrs	TEMP,2
				rjmp	DMX_STOP_EN_E
				cbr		TEMP,0x04
				sbi		PORTB,DMX_DRIVER
DMX_STOP_EN_E:	sts		DMX_USBLED_STAT,TEMP
				ret

;--------------- End DMX 512 Receive and Transmitt Routines ---------------------



;--------------- Begin USB Communication Routines -------------------------------

;Timer 1 Overrun Interrupt (USB Active LED)
TIMER0_OVER:	in		SREG_BACK,SREG			;Save SREG
				lds		INT_LOAD,TIMER0_H
				dec		INT_LOAD
				breq	TIMER0O_B
				sts		TIMER0_H,INT_LOAD
				out		SREG,SREG_BACK
				reti
TIMER0O_B:		sbrs	DEV_STATUS,0
				rjmp	TIMER0O_NUSBA
				sbis	PORTD,LED
				rjmp	TIMER0O_S
				rjmp	TIMER0O_C
TIMER0O_S:		sbi		PORTD,LED
				rjmp	TIMER0O_CA
TIMER0O_C:		cbi		PORTD,LED
TIMER0O_CA:		cbr		DEV_STATUS,0x01
				rjmp	TIMER0O_EXIT
TIMER0O_NUSBA:	sbi		PORTD,LED
TIMER0O_EXIT:	ldi		INT_LOAD,0x02
				sts		TIMER0_H,INT_LOAD
				out		SREG,SREG_BACK
				reti

;--------------- Begin USBN Main Interrupt Routine ------------------------------

INT0_USBN:		in		SREG_BACK,SREG
				sbr		DEV_STATUS,0x01			;Set USB Active Bit (for active Indicator LED)
				lds		INT_TEMP,MAEV			;Get Main Event Register
				sbrc	INT_TEMP,4				;NAK Event?
				rjmp	INT0_USB_NAK			;Yes, jump to NAK Event Service Routine
				sbrc	INT_TEMP,6				;RX Event?
				rjmp	INT0_USB_RX				;Yes, jump to RX Event Service Routine
				sbrc	INT_TEMP,2				;TX Event?
				rjmp	INT0_USB_TX				;Yes, jump to TX Event Service Routine
				sbrc	INT_TEMP,1				;Alternate Event?	
				rjmp	INT0_USB_ALT			;Yes, jump to Alternate Event Service Routine
				rjmp	INT0_USBN_MEXIT

;--------------- Begin USB NAK Event --------------------------------------------

INT0_USB_NAK:	lds		INT_TEMP,NAKEV			;Get NAK Event Register
				sbrc	INT_TEMP,4				;NAK Out 0?
				rjmp	INT0_USB_NAK_0
				sbrc	INT_TEMP,5				;NAK Out 1?
				rjmp	INT0_USB_NAK_1
				rjmp	INT0_USBN_MEXIT			;No, Exit Interrupt Service Routine
INT0_USB_NAK_0:	cbr		USB_STATUS,0x03			;Clear Get Descritor Mode and Get Report Mode
				ldi		INT_LOAD,0x08			;Flush and disable Transmitter
				sts		TXC0,INT_LOAD
				ldi		INT_LOAD,0x08			;Flush and disable RX0
				sts		RXC0,INT_LOAD
				ldi		INT_LOAD,0x01			;Enable Receiver
				sts		RXC0,INT_LOAD
				rjmp	INT0_USBN_MEXIT
INT0_USB_NAK_1:	ldi		INT_LOAD,0x08			;Flush Receiver
				sts		RXC1,INT_LOAD
				ldi		INT_LOAD,0x01			;Enable Receiver
				sts		RXC1,INT_LOAD
				rjmp	INT0_USBN_MEXIT

;--------------- End USB NAK Event ----------------------------------------------


;--------------- Begin USB ALT Event --------------------------------------------

INT0_USB_ALT:	lds		INT_TEMP,ALTEV			;Get Alternate Event Register
				sbrc	INT_TEMP,4				;SD3 Event?
				rjmp	INT0_USB_SD3			;Yes, jump to SD3 Event Service Routine
				sbrc	INT_TEMP,7				;RESUME Event?
				rjmp	INT0_USB_RESUME			;Yes, jump to RESUME Event Service Routine
				sbrc	INT_TEMP,6				;RESET Event?
				rjmp	INT0_USB_RESET			;Yes, jump to RESET Event Service Routine
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine
				;------- Begin USB Service Reset (no full USBN Reset) ----
INT0_USB_RESET:	ldi		INT_LOAD,0x00			;Go to Reset State (Yes, USB Reset Routine)
				sts		NFSR,INT_LOAD
				clr		USB_STATUS				;Reset USB Operation Registers
				sts		USB_CONFIG,INT_LOAD
				rcall	INT0_DELAY_97u			;Delay ca. 200 us
				rcall	INT0_DELAY_97u
				ldi		INT_LOAD,0x80			;Set Function Adress to 0 and Enable FAR
				sts		FAR,INT_LOAD
				ldi		INT_LOAD,0x00			;Enable Endpoint 0 Only
				sts		EPC0,INT_LOAD
				sts		EPC1,INT_LOAD
				sts		EPC2,INT_LOAD
				ldi		INT_LOAD,0x08			;Flush TX0 FIFO and disable Transmitter
				sts		TXC0,INT_LOAD
				ldi		INT_LOAD,0x08			;Flush RX0 FIFO and disable Receiver
				sts		RXC0,INT_LOAD
				ldi		INT_LOAD,0x50			;Mask RESUME Bit and unmask SD3 Bit during normal Operation
				sts		ALTMSK,INT_LOAD	
				ldi		INT_LOAD,0x02			;Go to Operational State
				sts		NFSR,INT_LOAD
				ldi		INT_LOAD,0x01			;Enable Receiver
				sts		RXC0,INT_LOAD
				cbr		DEV_STATUS,0x08			;Clear Suspend Bit
				;------- End USB Service Reset ---------------------------
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine
INT0_USB_SD3:	ldi		INT_LOAD,0xC0			;Mask SD3 Bit and unmask RESUME Bit during Suspend
				sts		ALTMSK,INT_LOAD
				ldi		INT_LOAD,0x03			;Force Suspend State
				sts		NFSR,INT_LOAD
				sbr		DEV_STATUS,0x08			;Set Suspend Bit
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine
INT0_USB_RESUME:ldi		INT_LOAD,0x02			;Force Operational State
				sts		NFSR,INT_LOAD
				ldi		INT_LOAD,0x50			;Mask RESUME Bit and unmask SD3 Bit during normal Operation
				sts		ALTMSK,INT_LOAD
				cbr		DEV_STATUS,0x08			;Clear Suspend Bit
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine

;--------------- End USB ALT Event ----------------------------------------------


;--------------- Begin USB TX Event ---------------------------------------------

INT0_USB_TX:	lds		INT_TEMP,TXEV			;Get Transmit Event Register
				sbrc	INT_TEMP,1				;TX FIFO 1?
				rjmp	INT0_TX1				;Yes; TX FIFO 1 Code
				sbrc	INT_TEMP,0				;TX FIFO 0?
				rjmp	INT0_TX0				;Yes; TX FIFO 0 Code
				rjmp	INT0_USBN_MEXIT			;No, Exit Interrupt Service Routine

;--------------- Begin USB TX0 Event --------------------------------------------

INT0_TX0:		lds		INT_LOAD,TXS0			;Get Transmitter 0 Status Register
				;???????????
				sbrs	INT_LOAD,6				;Test if ACK_STAT Bit is set
				rjmp	INT0_USBN_MEXIT			;No, exit TX0
				;???????????
				;----- Flush and Disable Transmitter -----
				ldi		INT_LOAD,0x08			;Flush transmitter and disable
				sts		TXC0,INT_LOAD
				;----- Check if a multipacked Mode is active -----
				sbrc	USB_STATUS,0			;Is Get Descriptor Mode active?
				rjmp	INT0_GET_DESC_M			;Yes, jump to Get Descriptor Mode TX Service
				sbrc	USB_STATUS,1			;Is Get Report Mode active?
				rjmp	INT0_GET_REPO_M			;Yes, jump to Get Report Mode TX Service
				;----- If no multipacked Mode is active, the Receiver can be reenabled -----
				ldi		INT_LOAD,0x01			;No, Enable Receiver
				sts		RXC0,INT_LOAD
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine
INT0_GET_DESC_M:;----- Get Descriptor Mode TX Service -----
				rcall	INT0_LOAD_DEC_P			;Load new Data to TX 0 Fifo
				rjmp	INT0_TX0_EN_PID			;Enable TX0 Transmitter with correct Data PID
INT0_GET_REPO_M:;----- Get Report Mode TX Service -----

				; Get Report Mode Code...

				;----- Enable Transmitter with correct Data PID and toggle it -----
INT0_TX0_EN_PID:sbrs	USB_STATUS,3			;Test witch PID to use
				rjmp	INT0_TX0_PID_0
INT0_TX0_PID_1:	ldi		INT_LOAD,0x05			;DATA 1 PID (Load Transmit Register with 05h and Clear TX0 PID Toggle Bit)
				cbr		USB_STATUS,0x08
				rjmp	INT0_TX0_EN
INT0_TX0_PID_0:	ldi		INT_LOAD,0x01			;DATA 0 PID (Load Transmit Register with 01h and Set TX0 PID Toggle Bit)
				sbr		USB_STATUS,0x08
INT0_TX0_EN:	sts		TXC0,INT_LOAD
				rjmp	INT0_USBN_MEXIT			;Exit TX0

;--------------- End USB TX0 Event ----------------------------------------------

;--------------- Begin USB TX1 Event --------------------------------------------

INT0_TX1:		lds		INT_LOAD,TXS1			;TX1 Code; Get Transmitter 1 Status Register
				sbrs	INT_LOAD,6				;Test if ACK_STAT Bit is set
				rjmp	INT0_TX1_RETRAN			;No, Retransmit Packed
				cbr		USB_STATUS,0x20			;Clear USB TX1 active (Bit 5)
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine
INT0_TX1_RETRAN:;----- Enable Transmitter with complementarry Data PID (because it was toggeled by the first enable try) and previous data -----
				sbrc	USB_STATUS,6			;Test witch PID to use (originally this was a sbrs command)
				rjmp	INT0_TX1_PID_0
INT0_TX1_PID_1:	ldi		INT_LOAD,0x17			;DATA 1 PID (Load Transmit Register with 17h)
				rjmp	INT0_TX1_EN
INT0_TX1_PID_0:	ldi		INT_LOAD,0x13			;DATA 0 PID (Load Transmit Register with 13h)
INT0_TX1_EN:	sts		TXC1,INT_LOAD			;Enable Transmitter
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine

;--------------- End USB TX1  Event ---------------------------------------------

;--------------- End USB TX Event -----------------------------------------------



;--------------- Begin USB RX Event ---------------------------------------------

INT0_USB_RX:	lds		INT_TEMP,RXEV			;Get Receive Event Register
				sbrc	INT_TEMP,1				;RX FIFO 1?
				rjmp	INT0_RX1				;Yes, RX FIFO 1
				sbrc	INT_TEMP,0				;RX FIFO 0?
				rjmp	INT0_RX0				;Yes, RX FIFO 0
				rjmp	INT0_USBN_MEXIT			;No, Exit Interrupt Service Routine

;--------------- Begin USB RX0 Event ---------------------------------------------

INT0_RX0:		lds		INT_LOAD,RXS0			;Yes, Get Receive Status Register 0
				sbrs	INT_LOAD,6				;Setup Packed?
				rjmp	INT0_OUT_P				;No, Out Packed

;--------------- Begin USB Setup Event -------------------------------------------

INT0_SETUP_P:	;----- Exit all multipacked Modes and clear Data PIDs -----
				cbr		USB_STATUS,0x1F			;Clear all multipacked active Bits and Set TX/RX PID to 0
				;----- Clear eventual EP 0 Stall -----
				ldi		INT_LOAD,0x00			;Clear eventual Stall on Endpoint 0
				sts		EPC0,INT_LOAD		
				;----- Setup Packed Receive Code -> Get the 8 Setup Bytes -----
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_0,INT_TEMP
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_1,INT_TEMP
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_2,INT_TEMP
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_3,INT_TEMP
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_4,INT_TEMP
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_5,INT_TEMP
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_6,INT_TEMP
				lds		INT_TEMP,RXD0
				sts		USB_SETUP_7,INT_TEMP
				;----- Flush and disable Endpoint 0s Receiver and Transmitter
				ldi		INT_LOAD,0x08
				sts		TXC0,INT_LOAD			;Flush TX0 FIFO and disable Transmitter
				sts		RXC0,INT_LOAD			;Flush RX0 FIFO and disable Receiver
				;----- Determine Request Type -----
				lds		INT_LOAD,USB_SETUP_0
				andi	INT_LOAD,0x60			;Determine the Request Type
				cpi		INT_LOAD,0x00			;Standart Request?
				breq	INT0_STD_REQ			;Yes, goto Standart Request
				cpi		INT_LOAD,0x20			;Class Request?
				breq	INT0_CLASS_REQ			;Yes, goto Class Request
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request not supported
INT0_STD_REQ:	;----- Standart Request: Determine Standart Request Target (Device, Interface or Endpoint) -----
				lds		INT_LOAD,USB_SETUP_0
				andi	INT_LOAD,0x1F			;Determine the Request Target
				cpi		INT_LOAD,0x00			;Device Request?
				breq	INT0_STD_D_REQ			;Standart Device Request
				cpi		INT_LOAD,0x01			;Interface Request?
				breq	INT0_STD_I_REQ			;Standart Interface Request
				cpi		INT_LOAD,0x02			;Endpoint Request?
				breq	INT0_STD_E_REQ			;Standart Endpoint Request
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request not supported
INT0_STD_D_REQ: ;----- Standart Device Request: Determine Device Request Number -----
				lds		INT_LOAD,USB_SETUP_1
				cpi		INT_LOAD,0x00
				breq	INT0WGET_D_STAT			;Get Device Status
				cpi		INT_LOAD,0x05
				breq	INT0WSET_ADDR			;Set Address
				cpi		INT_LOAD,0x06
				breq	INT0WGET_DESC			;Get Descriptor
				cpi		INT_LOAD,0x08
				breq	INT0WGET_CONFIG			;Get Configuration
				cpi		INT_LOAD,0x09
				breq	INT0WSET_CONFIG			;Set Configuration
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request not supported
INT0_STD_I_REQ: ;----- Standart Interface Request: Determine Interface Request Number -----
				lds		INT_LOAD,USB_SETUP_1
				cpi		INT_LOAD,0x00
				breq	INT0WGET_I_STAT			;Get Interface Status
				cpi		INT_LOAD,0x06
				breq	INT0WGET_DESC			;Get Descriptor
				cpi		INT_LOAD,0x0A
				breq	INT0WGET_INTERF			;Get Interface
				cpi		INT_LOAD,0x0B
				breq	INT0WSET_INTERF			;Set Interface
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request not supported
INT0_STD_E_REQ: ;----- Standart Endpoint Request: Determine Endpoint Request Number -----
				lds		INT_LOAD,USB_SETUP_1
				cpi		INT_LOAD,0x00
				breq	INT0WGET_E_STAT			;Get Endpoint Status
				cpi		INT_LOAD,0x01
				breq	INT0WCLR_E_FEAT			;Clear Endpoint Feature
				cpi		INT_LOAD,0x03
				breq	INT0WSET_E_FEAT			;Set Endpoint Feature
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request not supported
INT0_CLASS_REQ:	;----- Class Request: Determine Class Request Number -----
				lds		INT_LOAD,USB_SETUP_1
				cpi		INT_LOAD,0x01
				breq	INT0WGET_REPORT			;Get Report
				cpi		INT_LOAD,0x09
				breq	INT0WSET_REPORT			;Set Report
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request not supported
				;----- Request Forwards -----
INT0WGET_D_STAT:rjmp	INT0_GET_D_STAT
INT0WSET_ADDR:	rjmp	INT0_SET_ADDR
INT0WGET_DESC:	rjmp	INT0_GET_DESC
INT0WGET_CONFIG:rjmp	INT0_GET_CONFIG
INT0WSET_CONFIG:rjmp	INT0_SET_CONFIG
INT0WGET_I_STAT:rjmp	INT0_GET_I_STAT
INT0WGET_INTERF:rjmp	INT0_GET_INTERF
INT0WSET_INTERF:rjmp	INT0_SET_INTERF
INT0WGET_E_STAT:rjmp	INT0_GET_E_STAT
INT0WCLR_E_FEAT:rjmp	INT0_CLR_E_FEAT
INT0WSET_E_FEAT:rjmp	INT0_SET_E_FEAT
INT0WGET_REPORT:rjmp	INT0_GET_REPORT
INT0WSET_REPORT:rjmp	INT0_SET_REPORT

;--------------- Begin USB Setup Request Service Routines --------------------------


INT0_GET_D_STAT:;----- Get Device Status -----
				ldi		INT_LOAD,0x01			;Indicates that the Device is self powered
				sbrs	DEV_STATUS,2			;Is Device Self Powered?
				ldi		INT_LOAD,0x00			;Indicates that the Device is bus powered
				sts		TXD0,INT_LOAD			;Write the 2 Status Bytes in TX 0 Fifo
				clr		INT_LOAD
				sts		TXD0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter


INT0_SET_ADDR:	;----- Set Address -----
				ldi		INT_LOAD,0x40			;First set DEF Bit in EPC0 so that the Address isn't changed untill the next Status Stage 
				sts		EPC0,INT_LOAD
				lds		INT_LOAD,USB_SETUP_2	;Get the new Address
				ori		INT_LOAD,0x80			;Add Bit 7 for Address Enable
				sts		FAR,INT_LOAD
				rjmp	INT0_SEND_STST			;Send Status Stage


INT0_GET_DESC:	;----- Get Descriptor -----
				sbr		USB_STATUS,0x01			;Enter Get Descriptor Mode
				;----- Get Size of selected Descriptor -----
				rcall	INT0_DESC_SIZE			;Get Size of selected Descriptor
				clr		INT_TEMP
				;----- Check if Descriptor Type is supported -----
				cp		USB_DESC_ENDPOINT_L,INT_TEMP;Check if Size > 0 (else Descriptor not supported)
				cpc		USB_DESC_ENDPOINT_H,INT_TEMP
				brne	INT0_GD_C_HOSTS			;Go on
				;----- If something is wrong, exit with "Request not supported" -----
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request (Interface) not supported
INT0_GD_C_HOSTS:;----- Lower Size if Host requested less Data -----
				lds		INT_TEMP,USB_SETUP_6	;Check if Host hast requested less Bytes than Descriptor Size
				lds		INT_LOAD,USB_SETUP_7	;If so, set USB_DESC_ENDPOINT to Host requested Size
				cp		USB_DESC_ENDPOINT_L,INT_TEMP
				cpc		USB_DESC_ENDPOINT_H,INT_LOAD
				brsh	INT0_GD_SET_HS			;Set Host Size to USB_DESC_ENDPOINT
				rjmp	INT0_GD_DOUB_S			;Go on
INT0_GD_SET_HS:	mov		USB_DESC_ENDPOINT_L,INT_TEMP;Move Host Size to USB_DESC_ENDPOINT
				mov		USB_DESC_ENDPOINT_H,INT_LOAD
INT0_GD_DOUB_S:	;----- Multiply Size by 2 because we have a 16 Bit Memory and only every second Byte in a Descriptor is valid -----
				lsl		USB_DESC_ENDPOINT_L		;Multiply by two because Mem is 16 Bit organised
				rol		USB_DESC_ENDPOINT_H
				;----- Get the Memory Start Address of the selected Descriptor -----
				rcall	INT0_DESC_START			;Get Descriptor Start Address
				;----- Set USB Descriptor Endpoint to its real Memory Address -----
				add		USB_DESC_ENDPOINT_L,USB_ACT_DESC_POS_L;Set USB Descriptor Endpoint to real End Memory Address
				adc		USB_DESC_ENDPOINT_H,USB_ACT_DESC_POS_H	
				;----- Load Data in the Fifo -----
				rcall	INT0_LOAD_DEC_P			;Load first 8 Byte Data Packed into TX0 Fifo
				;----- Enable the Transmitter and exit -----
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter with PID 1 for first Data Packed in Data Stage


INT0_GET_CONFIG:;----- Get Configuration -----
				lds		INT_LOAD,USB_CONFIG		;Get actual USB Config
				sts		TXD0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter


INT0_SET_CONFIG:;----- Set Configuration -----
				;----- Determine selected Configuration -----
				lds		INT_LOAD,USB_SETUP_2	;Get selected Configuration
				cpi		INT_LOAD,0x00
				breq	INT0_SC_N0				;Set Device to unconfigured State
				cpi		INT_LOAD,0x01
				breq	INT0_SC_N1				;Set Device to configured State 1
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request (Configuration) not supported
INT0_SC_N0:		;----- Configuration 0 -----
				;----- Disable non 0 Endpoints -----
				sts		USB_CONFIG,INT_LOAD		;Store new Configuration
				ldi		INT_LOAD,0x08			;Flush RX 1 FIFO and disable
				sts		RXC1,INT_LOAD
				clr		INT_LOAD				;Enable Endpoint 0 Only
				sts		EPC1,INT_LOAD
				sts		EPC2,INT_LOAD
				rjmp	INT0_SEND_STST			;Send Status Stage
INT0_SC_N1:		;----- Configuration 1 -----
				;----- Enable Endpoint 1 and Endpoint 2-----
				sts		USB_CONFIG,INT_LOAD		;Store new Configuration
				ldi		INT_LOAD,0x11			;Enable Endpoint 1 with EP Address 01h
				sts		EPC1,INT_LOAD
				ldi		INT_LOAD,0x12			;Enable Endpoint 2 with EP Address 02h
				sts		EPC2,INT_LOAD
				ldi		INT_LOAD,0x08			;Flush RX 1 FIFO
				sts		RXC1,INT_LOAD
				ldi		INT_LOAD,0x05			;Enable Receiver 1 and ignore SETUP Tokens
				sts		RXC1,INT_LOAD
				cbr		USB_STATUS,0x60			;Clear all TX1 Info Bits
				rjmp	INT0_SEND_STST			;Send Status Stage


INT0_GET_I_STAT:;----- Get Interface Status -----
				clr		INT_LOAD				;Return 2 Zero Data Bytes, because actual USB Specification doesn't specify any Interface Status Bits
				sts		TXD0,INT_LOAD
				sts		TXD0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter


INT0_GET_INTERF:;----- Get Interface -----
				;----- Determine selected Interface, only Interface 0 is supportet -----
				lds		INT_LOAD,USB_SETUP_4	;Get selected Interface
				cpi		INT_LOAD,0x00
				breq	INT0_GI_IN0
				;----- If something is wrong, exit with "Request not supported" -----
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request (Interface) not supported
INT0_GI_IN0:	;----- Get Interface 0 -----
				clr		INT_LOAD				;Return 1 Zero Data Byte because there is no alternate Interface
				sts		TXD0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter


INT0_SET_INTERF:;----- Set Interface -----
				;----- Determine selected Interface, only Interface 0 is supportet -----
				lds		INT_LOAD,USB_SETUP_4	;Get selected Interface
				cpi		INT_LOAD,0x00
				breq	INT0_SI_IN0
				;----- If something is wrong, exit with "Request not supported" -----
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request (Interface) not supported
INT0_SI_IN0:	;----- Set Interface 0 -----
				;----- Because Interface 0 is the only one, it is always set and here is nothing to do -----
				rjmp	INT0_SEND_STST			;Send Status Stage


INT0_SET_E_FEAT:;----- Set Endpoint Feature -----
				;----- Determine selected Feature, only Endpoint halt (0x0000) is supportet -----
				lds		INT_LOAD,USB_SETUP_2
				cpi		INT_LOAD,0x00
				brne	INT0_SET_EF_NS
				lds		INT_LOAD,USB_SETUP_3
				cpi		INT_LOAD,0x00
				brne	INT0_SET_EF_NS
				;----- Check if Device is configured -----
				lds		INT_LOAD,USB_CONFIG
				cpi		INT_LOAD,0x01
				brne	INT0_SET_EF_NS
				;----- Determine selected Endpoint, only Endpoint 1 and 2 are supportet -----
				lds		INT_LOAD,USB_SETUP_4
				andi	INT_LOAD,0x0F
				cpi		INT_LOAD,0x01
				breq	INT0_SET_EF_E1
				cpi		INT_LOAD,0x02
				breq	INT0_SET_EF_E2
INT0_SET_EF_NS:	;----- If something is wrong, exit with "Request not supported" -----
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request (Endpoint or Feature) not supported
INT0_SET_EF_E1:	;----- Stall Endpoint 1 -----
				ldi		INT_LOAD,0x91			;Set Stall, Endpoint enable (Device is configured, so it must be enabled), Endpoint Adress 0x01
				sts		EPC1,INT_LOAD
				rjmp	INT0_SEND_STST			;Send Status Stage
INT0_SET_EF_E2:	;----- Stall Endpoint 2 -----
				ldi		INT_LOAD,0x92			;Set Stall, Endpoint enable (Device is configured, so it must be enabled), Endpoint Adress 0x02
				sts		EPC2,INT_LOAD
				rjmp	INT0_SEND_STST			;Send Status Stage


INT0_CLR_E_FEAT:;----- Clear Endpoint Feature -----
				;----- Determine selected Feature, only Endpoint halt (0x0000) is supportet -----
				lds		INT_LOAD,USB_SETUP_2
				cpi		INT_LOAD,0x00
				brne	INT0_CLR_EF_NS
				lds		INT_LOAD,USB_SETUP_3
				cpi		INT_LOAD,0x00
				brne	INT0_CLR_EF_NS
				;----- Check if Endpoint 0 is selected -----
				lds		INT_LOAD,USB_SETUP_4
				andi	INT_LOAD,0x0F
				cpi		INT_LOAD,0x00
				breq	INT0_CLR_EF_E0
				;----- Check if Device is configured -----
				lds		INT_LOAD,USB_CONFIG
				cpi		INT_LOAD,0x01			;Only Config 1 for Endpoint 1 and 2 supported
				brne	INT0_CLR_EF_NS
				;----- Determine selected Endpoint, only Endpoint 1 and 2 are supportet -----
				lds		INT_LOAD,USB_SETUP_4
				andi	INT_LOAD,0x0F
				cpi		INT_LOAD,0x01
				breq	INT0_CLR_EF_E1
				cpi		INT_LOAD,0x02
				breq	INT0_CLR_EF_E2
INT0_CLR_EF_NS:	;----- If something is wrong, exit with "Request not supported" -----
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request (Endpoint or Feature) not supported
INT0_CLR_EF_E0:	;----- Unstall Endpoint 0 -----
				ldi		INT_LOAD,0x00			;Clear Stall, Endpoint Adress 0x00
				sts		EPC0,INT_LOAD
				rjmp	INT0_SEND_STST			;Send Status Stage
INT0_CLR_EF_E1:	;----- Unstall Endpoint 1 -----
				ldi		INT_LOAD,0x11			;Clear Stall, Endpoint enable (Device is configured, so it must be enabled), Endpoint Adress 0x01
				sts		EPC1,INT_LOAD
				rjmp	INT0_SEND_STST			;Send Status Stage
INT0_CLR_EF_E2:	;----- Unstall Endpoint 2 -----
				ldi		INT_LOAD,0x12			;Clear Stall, Endpoint enable (Device is configured, so it must be enabled), Endpoint Adress 0x02
				sts		EPC2,INT_LOAD
				rjmp	INT0_SEND_STST			;Send Status Stage


INT0_GET_E_STAT:;----- Get Endpoint Status -----
				;----- Check if Endpoint 0 is selected -----
				lds		INT_LOAD,USB_SETUP_4
				andi	INT_LOAD,0x0F
				cpi		INT_LOAD,0x00
				breq	INT0_GET_ES_E0
				;----- Check if Device is configured -----
				lds		INT_LOAD,USB_CONFIG
				cpi		INT_LOAD,0x01			;Only Config 1 for Endpoint 1 and 2 supported
				brne	INT0_GET_ES_NS
				;----- Determine selected Endpoint, only Endpoint 1 and 2 are supportet -----
				lds		INT_LOAD,USB_SETUP_4
				andi	INT_LOAD,0x0F
				cpi		INT_LOAD,0x01
				breq	INT0_GET_ES_E1
				cpi		INT_LOAD,0x02
				breq	INT0_GET_ES_E2
				;----- If something is wrong, exit with "Request not supported" -----
INT0_GET_ES_NS:	rjmp	INT0_REQ_NOT_SUPP		;Else, Request (Endpoint) not supported
INT0_GET_ES_E0:	;----- Get Status from Endpoint 0 -----
				lds		INT_LOAD,EPC0			;Get Endpoint 0 Stall Bit
				rol		INT_LOAD				;Rotate Stall Bit (Bit Pos 7) trough Carry in Pos 0
				rol		INT_LOAD
				andi	INT_LOAD,0x01			;Clear all other Bits
				sts		TXD0,INT_LOAD			;Write the 2 Status Bytes in TX 0 Fifo
				clr		INT_LOAD
				sts		TXD0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter
INT0_GET_ES_E1:	;----- Get Status from Endpoint 1 -----
				lds		INT_LOAD,EPC1			;Get Endpoint 1 Stall Bit
				rol		INT_LOAD				;Rotate Stall Bit (Bit Pos 7) trough Carry in Pos 0
				rol		INT_LOAD
				andi	INT_LOAD,0x01			;Clear all other Bits
				sts		TXD0,INT_LOAD			;Write the 2 Status Bytes in TX 0 Fifo
				clr		INT_LOAD
				sts		TXD0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter
INT0_GET_ES_E2:	;----- Get Status from Endpoint 2 -----
				lds		INT_LOAD,EPC2			;Get Endpoint 2 Stall Bit
				rol		INT_LOAD				;Rotate Stall Bit (Bit Pos 7) trough Carry in Pos 0
				rol		INT_LOAD
				andi	INT_LOAD,0x01			;Clear all other Bits
				sts		TXD0,INT_LOAD			;Write the 2 Status Bytes in TX 0 Fifo
				clr		INT_LOAD
				sts		TXD0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter


INT0_GET_REPORT:;----- Get Report -----
				ldi		INT_LOAD,0x08			;Flush TX0 FIFO to send a 0 Byte Data Packed (All Input Reports are sent by TX1)
				sts		TXC0,INT_LOAD
				rjmp	INT0_ENABLE_TX			;Enable the Transmitter


INT0_SET_REPORT:;----- Set Report -----
				lds		INT_LOAD,USB_SETUP_3	;Output Report?
				cpi		INT_LOAD,0x02
				brne	INT0_SET_REP_NS
				lds		INT_LOAD,USB_SETUP_2	;Report ID = 0?
				cpi		INT_LOAD,0x00
				brne	INT0_SET_REP_NS
				lds		INT_LOAD,USB_SETUP_6	;Report Report Length max 33 bytes?
				cpi		INT_LOAD,0x22
				brsh	INT0_SET_REP_NS
				lds		INT_LOAD,USB_SETUP_7	;Report Report Length max 33 bytes?
				cpi		INT_LOAD,0x00
				brne	INT0_SET_REP_NS
				sbr		USB_STATUS,0x04			;Enter Set Report Mode
				clr		USB_SET_REP_MEM_POS_L	;Clear Set Report Memory Backup Pointer
				clr		USB_SET_REP_MEM_POS_H
				rjmp	INT0_ENABLE_RX			;Re-Enable the Receiver
INT0_SET_REP_NS:;----- If something is wrong, exit with "Request not supported" -----
				rjmp	INT0_REQ_NOT_SUPP		;Else, Request not supported

;--------------- Begin USB Setup Get Descriptor Sub-Routines ---------------------

INT0_LOAD_DEC_P:;----- Load Descriptor Package -----
				;----- Store USB_ACT_POS in USB_ACT_DESC_PACKED and add 10h (Because Mem is 16 Bit organised) -----
				mov		USB_ACT_DESC_PACKE_L,USB_ACT_DESC_POS_L
				mov		USB_ACT_DESC_PACKE_H,USB_ACT_DESC_POS_H
				ldi		INT_LOAD,0x10
				add		USB_ACT_DESC_PACKE_L,INT_LOAD
				clr		INT_LOAD
				adc		USB_ACT_DESC_PACKE_H,INT_LOAD
				mov		ZL,USB_ACT_DESC_POS_L
				mov		ZH,USB_ACT_DESC_POS_H
INT0_LOAD_LOOP:	;----- Load 8 Byte Data Storage Loop -----
				;----- Check if 8 Bytes are reached -----
				cp		ZL,USB_ACT_DESC_PACKE_L
				cpc		ZH,USB_ACT_DESC_PACKE_H
				brsh	INT0_LDP_EL_DON
				;----- Check if Descriptor Endpoint is reached -----		
				cp		ZL,USB_DESC_ENDPOINT_L
				cpc		ZH,USB_DESC_ENDPOINT_H
				brsh	INT0_LDP_EL_CDE
				;----- If not, load one Byte to the TX0 Fifo -----
				lpm								;Load one Byte from Program Memory to LPM_LOAD
				;----- Check "Power Variables and adjust them" -----
				cpi		ZH,high(CONFIG_DESC_BP*2)
				brne	INT0_LDP_CH_SPB
				cpi		ZL,low(CONFIG_DESC_BP*2)
				brne	INT0_LDP_CH_SPB
				rjmp	INT0_LDP_LIT_PO
INT0_LDP_CH_SPB:cpi		ZH,high(CONFIG_DESC_SBP*2)
				brne	INT0_LDP_NORM_L
				cpi		ZL,low(CONFIG_DESC_SBP*2)
				brne	INT0_LDP_NORM_L
				sbrs	DEV_STATUS,2
				rjmp	INT0_LDP_NORM_L
				ldi		INT_LOAD,0xC0			;Because Device is Selfpowered the Self Powered Bit Information is set
				mov		LPM_LOAD,INT_LOAD
				rjmp	INT0_LDP_NORM_L
INT0_LDP_LIT_PO:sbrs	DEV_STATUS,2
				rjmp	INT0_LDP_NORM_L
				ldi		INT_LOAD,0x05			;Because Device is Selfpowered the BUS Power Information is '10 mA'
				mov		LPM_LOAD,INT_LOAD
				;----- "Adjustment End -----
INT0_LDP_NORM_L:sts		TXD0,LPM_LOAD
				adiw	ZL,0x02					;Inc Z by 02h
				rjmp	INT0_LOAD_LOOP
INT0_LDP_EL_CDE:;----- Clear Get Descriptor Mode in USB Status Register and exit ----
				cbr		USB_STATUS,0x01
				ret
INT0_LDP_EL_DON:;----- Store Actual USB Description Pointer for next Load Routine call and exit -----
				mov		USB_ACT_DESC_POS_L,ZL
				mov		USB_ACT_DESC_POS_H,ZH
				ret


INT0_DESC_START:;----- Get Descriptor Start Address -----
				;----- Determine selected Descriptor Type -----
				lds		INT_LOAD,USB_SETUP_3	;Determine selected Descriptor Type
				cpi		INT_LOAD,0x01			;Device Descriptor
				breq	INT0_DS_DEV_ADR
				cpi		INT_LOAD,0x02			;Configuration Descriptor
				breq	INT0_DS_CON_ADR
				cpi		INT_LOAD,0x03			;String Descriptor
				breq	INT0_DS_STR_SEL
				cpi		INT_LOAD,0x04			;Interface Descriptor
				breq	INT0_DS_INT_ADR
				cpi		INT_LOAD,0x05			;Endpoint Descriptor
				breq	INT0_DS_END_SEL
				cpi		INT_LOAD,0x21			;HID_Class Descriptor
				breq	INT0_DS_HID_A_W
				cpi		INT_LOAD,0x22			;Report Descriptor
				breq	INT0_DS_REP_A_W
				rjmp	INT0_DS_DEV_ADR			;If Type not supported, return Address of Device Descriptor
INT0_DS_HID_A_W:rjmp	INT0_DS_HID_ADR
INT0_DS_REP_A_W:rjmp	INT0_DS_REP_ADR
INT0_DS_STR_SEL:;----- Determine selected String Descriptor -----
				lds		INT_LOAD,USB_SETUP_2	;Determine selected String Descriptor
				cpi		INT_LOAD,0x00			;String 0
				breq	INT0_DS_SR0_ADR
				cpi		INT_LOAD,0x01			;String 1
				breq	INT0_DS_SR1_ADR
				cpi		INT_LOAD,0x02			;String 2
				breq	INT0_DS_SR2_ADR
				cpi		INT_LOAD,0x03			;String 3
				breq	INT0_DS_SR3_ADR
				rjmp	INT0_DS_EN1_ADR			;If Endpoint not supported, return Address of Endpoint 1 Descriptor
INT0_DS_END_SEL:;----- Determine selected Endpoint Descriptor -----
				lds		INT_LOAD,USB_SETUP_2	;Determine selected Endpoint Descriptor
				cpi		INT_LOAD,0x00			;Endpoint 1
				breq	INT0_DS_EN1_ADR
				cpi		INT_LOAD,0x01			;Endpoint 2
				breq	INT0_DS_EN2_ADR
				rjmp	INT0_DS_EN1_ADR			;If Endpoint not supported, return Address of Endpoint 1 Descriptor
				;----- Load Address constant for selected Descriptor -----
INT0_DS_DEV_ADR:ldi		INT_LOAD,low(DEVICE_DESC*2);Load Memory Address for Device Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(DEVICE_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_CON_ADR:ldi		INT_LOAD,low(CONFIG_DESC*2);Load Memory Address for Config Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(CONFIG_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_SR0_ADR:ldi		INT_LOAD,low(STRING0_DESC*2);Load Memory Address for String 0 Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(STRING0_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_SR1_ADR:ldi		INT_LOAD,low(STRING1_DESC*2);Load Memory Address for String 1 Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(STRING1_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_SR2_ADR:ldi		INT_LOAD,low(STRING2_DESC*2);Load Memory Address for String 2 Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(STRING2_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_SR3_ADR:ldi		INT_LOAD,low(STRING3_DESC*2);Load Memory Address for String 3 Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(STRING3_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_INT_ADR:ldi		INT_LOAD,low(INTERFACE_DESC*2);Load Memory Address for Interface Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(INTERFACE_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_EN1_ADR:ldi		INT_LOAD,low(ENDPOINT1_DESC*2);Load Memory Address for Endpoint 1 Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(ENDPOINT1_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_EN2_ADR:ldi		INT_LOAD,low(ENDPOINT2_DESC*2);Load Memory Address for Endpoint 2 Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(ENDPOINT2_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_HID_ADR:ldi		INT_LOAD,low(HID_CLASS_DESC*2);Load Memory Address for HID Class Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(HID_CLASS_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret
INT0_DS_REP_ADR:ldi		INT_LOAD,low(REPORT_DESC*2);Load Memory Address for Report Descriptor
				mov		USB_ACT_DESC_POS_L,INT_LOAD
				ldi		INT_LOAD,high(REPORT_DESC*2)
				mov		USB_ACT_DESC_POS_H,INT_LOAD
				ret


INT0_DESC_SIZE:	;----- Get Descriptor Size -----
				;----- Determine selected Descriptor -----
				lds		INT_LOAD,USB_SETUP_3	;Determine selected Descripter Type
				clr		USB_DESC_ENDPOINT_H		;Clear USB Descriptor Endpoint High Register
				cpi		INT_LOAD,0x01			;Device Descriptor
				breq	INT0_GET_DEV_DE
				cpi		INT_LOAD,0x02			;Config Descriptor
				breq	INT0_GET_CON_SE
				cpi		INT_LOAD,0x03			;String Descriptor
				breq	INT0_GET_STR_SE
				cpi		INT_LOAD,0x04			;Interface Descriptor
				breq	INT0_GET_INT_SE
				cpi		INT_LOAD,0x05			;Endpoint Descriptor
				breq	INT0_GET_END_DE
				cpi		INT_LOAD,0x21			;HID Class Descriptor
				breq	INT0_GET_HID_DE
				cpi		INT_LOAD,0x22			;Report Descriptor
				breq	INT0_GET_REP_SE
INT0_DSIZE_NSUP:ldi		INT_LOAD,0x00			;Load Size 00h for not supported Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_CON_SE:;----- Determine selected Config Descriptor -----
				lds		INT_LOAD,USB_SETUP_2	;Determine selected Config Descriptor
				cpi		INT_LOAD,0x00			;Config 0 ?
				breq	INT0_GET_CON_DE			;Load Config Descriptor Size
				rjmp	INT0_DSIZE_NSUP			;Only Config 0 supported, so exit with size 0
INT0_GET_STR_SE:;----- Determine selected String Descriptor -----
				lds		INT_LOAD,USB_SETUP_2	;Determine selected String Descriptor
				cpi		INT_LOAD,0x00			;String 0 ?
				breq	INT0_GET_SR0_DE			;Load String 0 Descriptor Size
				cpi		INT_LOAD,0x01			;String 1 ?
				breq	INT0_GET_SR1_DE			;Load String 1 Descriptor Size
				cpi		INT_LOAD,0x02			;String 2 ?
				breq	INT0_GET_SR2_DE			;Load String 2 Descriptor Size
				cpi		INT_LOAD,0x03			;String 3 ?
				breq	INT0_GET_SR3_DE			;Load String 3 Descriptor Size
				rjmp	INT0_DSIZE_NSUP			;String Index not supported, so exit with size 0
INT0_GET_INT_SE:;----- Determine selected Interface Descriptor -----
				lds		INT_LOAD,USB_SETUP_2	;Determine selected Config Descriptor
				cpi		INT_LOAD,0x00			;Interface 0 ?
				breq	INT0_GET_INT_DE			;Load Intergface Descriptor Size
				rjmp	INT0_DSIZE_NSUP			;Only Interface 0 supported, so exit with size 0
INT0_GET_REP_SE:;----- Determine selected Report Descriptor -----
				lds		INT_LOAD,USB_SETUP_2	;Determine selected Config Descriptor
				cpi		INT_LOAD,0x00			;Report 0 ?
				breq	INT0_GET_REP_DE			;Load Report Descriptor Size
				rjmp	INT0_DSIZE_NSUP			;Only Report 0 supported, so exit with size 0
				;----- Load Size constant for selected Descriptor -----
INT0_GET_DEV_DE:ldi		INT_LOAD,0x12			;Load Size Konstant for Device Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_CON_DE:ldi		INT_LOAD,0x29			;Load Size Konstant for Config Descriptor (includes following descriptors: Interface, HID Class and 2 Endpoint)
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_SR0_DE:ldi		INT_LOAD,0x04			;Load Size Konstant for String 0 Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_SR1_DE:ldi		INT_LOAD,0x2C			;Load Size Konstant for String 1 Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_SR2_DE:ldi		INT_LOAD,0x20			;Load Size Konstant for String 2 Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_SR3_DE:ldi		INT_LOAD,0x22			;Load Size Konstant for String 3 Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret		
INT0_GET_INT_DE:ldi		INT_LOAD,0x09			;Load Size Konstant for Interface Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_END_DE:ldi		INT_LOAD,0x07			;Load Size Konstant for Endpoint Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_HID_DE:ldi		INT_LOAD,0x09			;Load Size Konstant for HID Class Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret
INT0_GET_REP_DE:ldi		INT_LOAD,0x24			;Load Size Konstant for Report Descriptor
				mov		USB_DESC_ENDPOINT_L,INT_LOAD
				ret

;--------------- End USB Setup Get Descriptor Sub-Routines -----------------------

;--------------- End USB Setup Request Service Routines --------------------------

INT0_SEND_STST:	ldi		INT_LOAD,0x08			;Enable Transmitter for Endpoint 0 with PID 1 to send the Status Stage
				sts		TXC0,INT_LOAD
				ldi		INT_LOAD,0x05
				sts		TXC0,INT_LOAD
				rjmp	INT0_USBN_MEXIT			;Exit RX0

INT0_ENABLE_TX:	ldi		INT_LOAD,0x05			;Enable Transmitter for Endpoint 0 with PID 1 to send the first 8 Byte of Data Stage
				sts		TXC0,INT_LOAD
				rjmp	INT0_USBN_MEXIT			;Exit RX0

INT0_ENABLE_RX:	ldi		INT_LOAD,0x08			;Enable Receiver for Endpoint 0 to receive the first 8 Byte of Data Stage
				sts		RXC0,INT_LOAD
				ldi		INT_LOAD,0x01
				sts		RXC0,INT_LOAD
				rjmp	INT0_USBN_MEXIT			;Exit RX0

INT0_REQ_NOT_SUPP:;Stall Endpoint 0, remains stalled untill next SETUP Packed
				ldi		INT_LOAD,0x80			;Set Stall on Endpoint 0
				sts		EPC0,INT_LOAD
				ldi		INT_LOAD,0x05			;Enable Transmitter for Endpoint 0 (if an OUT Packed should come next, a NAK 0 Event will reenable the Receiver)
				sts		TXC0,INT_LOAD
				rjmp	INT0_USBN_MEXIT			;Exit RX0

;--------------- End USB Setup Event ---------------------------------------------

INT0_OUT_P:		sbrc	USB_STATUS,2			;Set Report Mode active?
				rjmp	INT0_SET_REPO_M
				cbr		USB_STATUS,0x03			;Clear Get Descritor Mode and Get Report Mode
				ldi		INT_LOAD,0x08			;Flush and disable TX0
				sts		TXC0,INT_LOAD
				rjmp	INT0_ENABLE_RX			;Re-Enabled Receiver
INT0_SET_REPO_M:;Code for Set Report Mode active
				clr		ZL
				clr		ZH
				cp		ZL,USB_SET_REP_MEM_POS_L
				cpc		ZH,USB_SET_REP_MEM_POS_H
				breq	INT0_SET_REPO_F
				;----- Non-First Data Packed -----
				mov		ZL,USB_SET_REP_MEM_POS_L
				mov		ZH,USB_SET_REP_MEM_POS_H
				lds		INT_LOAD,USB_SETUP_6	;Get Report Size
				dec		INT_LOAD				;Decrease INT_LOAD (Report Size) because first byte is the Pre-Data Byte
				lds		INT_TEMP,RXD0			;Read Byte 0 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				lds		INT_TEMP,RXD0			;Read Byte 1 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				lds		INT_TEMP,RXD0			;Read Byte 2 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				lds		INT_TEMP,RXD0			;Read Byte 3 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				lds		INT_TEMP,RXD0			;Read Byte 4 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				lds		INT_TEMP,RXD0			;Read Byte 5 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				lds		INT_TEMP,RXD0			;Read Byte 6 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				lds		INT_TEMP,RXD0			;Read Byte 7 into RAM
				st		Z+,INT_TEMP
				cp		ZL,INT_LOAD				;32 bytes read?
				brsh	INT0_SETREPO_CE			;Complete Exit (Clear Set Report Bit)
				rjmp	INT0_SETREPO_E			;Normal Exit Code;
INT0_SETREPO_CE:;----- Complete Exit Code -----
				cbr		USB_STATUS,0x04			;Clear Set Report Bit
				rjmp	INT0_SEND_STST			;Send Status Stage
INT0_SETREPO_C:	;----- Data is Command Data -----
				lds		DEV_CONFIG,RXD0			;Read new Config to DMX Device Config Register (second byte)
INT0_SETREPO_E:	;----- Exit Code -----
				mov		USB_SET_REP_MEM_POS_L,ZL
				mov		USB_SET_REP_MEM_POS_H,ZH
				rjmp	INT0_ENABLE_RX			;Exit with Re-Enabled Receiver
INT0_SET_REPO_F:;----- First Data Packed -----
				lds		ZL,RXD0					;Get Memposition Byte (first byte)
				cpi		ZL,0x10					;Equal to 16?
				breq	INT0_SETREPO_C			;Must be an Interface Command
				cpi		ZL,0x11					;Greater than 16?
				brsh	INT0_SETREPO_E			;Reserved for future use
INT0_SETREPO_D:	;----- Data is normal Data -----
				clr		ZH						;Clear Mem Pos High Byte
				lsl		ZL						;Multiply by 32
				lsl		ZL
				lsl		ZL
				lsl		ZL
				lsl		ZL
				rol		ZH						;A Start ZL Value of 15 here would be 480, so we must rol the high byte also
				subi	ZH,0xDE					;Add 2200h to get the Memory Position of PC Data In
				lds		INT_TEMP,RXD0			;Read Byte 0 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD0			;Read Byte 1 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD0			;Read Byte 2 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD0			;Read Byte 3 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD0			;Read Byte 4 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD0			;Read Byte 5 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD0			;Read Byte 6 into RAM
				st		Z+,INT_TEMP
				rjmp	INT0_SETREPO_E

;--------------- End USB RX0 Event ------------------------------------------------

;--------------- Begin USB RX1 Event ----------------------------------------------

INT0_RX1:		;----- Check Data consistence -----
				lds		INT_LOAD,RXS1			;RX 1 Service Routine -> First get Status Register
				sbrc	INT_LOAD,7				;Data Error?
				rjmp	INT0_RX1_EN_RX			;Do nothing with the received Data
				;----- Determine if received Data is a Command or Data -----
				lds		ZL,RXD1					;Get Memposition Byte (first byte)
				cpi		ZL,0x10					;Lower than 16?
				brlo	INT0_RX1_DATA_W			;Must be an Data Set
				cpi		ZL,0x10					;Equal to 16?
				breq	INT0_RX1_MODE			;Must be an Mode Command
				cpi		ZL,0x11					;Equal to 17?
				breq	INT0_RX1_CONF			;Must be an DMX-Transceiver Config Command
				cpi		ZL,0x12					;Equal to 18?
				breq	INT0_RX1_CMD			;Must be an General Command
				rjmp	INT0_RX1_EN_RX			;Higher than 16 -> Reserved for future Use
INT0_RX1_DATA_W:rjmp	INT0_RX1_DATA
INT0_RX1_MODE:	;----- Data is Mode Data -----
				lds		DEV_CONFIG,RXD1			;Read new Config to DMX Device Config Register (second byte) (is there to speed up normal data receive)
				rjmp	INT0_RX1_EN_RX
INT0_RX1_CONF:	;----- Data is DMX-Transceiver Config Data -----
				lds		INT_LOAD,RXD1
				sts		DMXTADV_CTRL_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_BRK_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_BRK_H_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_MARK_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_MARK_H_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_BYTE_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_BYTE_H_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_FRM_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_FRM_H_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_CNT_L_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_CNT_H_LOAD,INT_LOAD
				lds		INT_LOAD,RXD1
				sts		DMXTADV_START_LOAD,INT_LOAD
				rjmp	INT0_RX1_EN_RX
INT0_RX1_CMD:	;----- Data is General Command -----
				lds		INT_LOAD,RXD1
				cpi		INT_LOAD,0x01
				breq	INT0_RX1_CMD_1
				rjmp	INT0_RX1_EN_RX
INT0_RX1_CMD_1:	rcall	STORE_EEPROM
				rjmp	INT0_RX1_EN_RX
INT0_RX1_DATA:	;----- Data is normal Data -----
				clr		ZH						;Clear Mem Pos High Byte
				lsl		ZL						;Multiply by 32
				lsl		ZL
				lsl		ZL
				lsl		ZL
				lsl		ZL
				rol		ZH						;A Start ZL Value of 15 here would be 480, so we must rol the high byte also
				subi	ZH,0xDE					;Add 2200h to get the Memory Position of PC Data In
				lds		INT_TEMP,RXD1			;Read all Byte 0 into RAM  (Done without loop to speed up)
				st		Z+,INT_TEMP
				lds			INT_TEMP,RXD1		;Read all Byte 1 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 2 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 3 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 4 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 5 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 6 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 7 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 8 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 9 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 10 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 11 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 12 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 13 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 14 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 15 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 16 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 17 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 18 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 19 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 20 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 21 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 22 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 23 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 24 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 25 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 26 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 27 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 28 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 29 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 30 into RAM
				st		Z+,INT_TEMP
				lds		INT_TEMP,RXD1			;Read all Byte 31 into RAM
				st		Z+,INT_TEMP
INT0_RX1_EN_RX:	;----- Exit Code -----
				ldi		INT_LOAD,0x08			;Flush RX 1 FIFO
				sts		RXC1,INT_LOAD
				ldi		INT_LOAD,0x05			;Enable Receiver 1 and ignore SETUP Tokens
				sts		RXC1,INT_LOAD
				rjmp	INT0_USBN_MEXIT			;Exit Interrupt Service Routine

;--------------- End USB RX1 Event ----------------------------------------------

;--------------- End USB RX Event -----------------------------------------------

INT0_USBN_MEXIT:out		SREG,SREG_BACK			;Exit Interrupt Service Routine
				reti

;--------------- End USBN Main Interrupt Routine --------------------------------


;--------------- Begin USB Sub-Routines -----------------------------------------

USB_INIT:		;----- Init local USB Register -----
				clr		USB_STATUS				;Clear USB Status and Config Register
				clr		USB_INIT_LOAD
				sts		USB_CONFIG,USB_INIT_LOAD
				;----- Set Clockoutput -----
				ldi		USB_INIT_LOAD,0x03
				sts		CCONF,USB_INIT_LOAD		;Set Clockoutput to 12 MHz
				;----- Reset USBN -----
				ldi		USB_INIT_LOAD,0x01
				sts		MCNTRL,USB_INIT_LOAD	;Reset USBN9604
				;----- Wait until Reset is complete -----
USB_WAIT_SR_COM:lds		USB_INIT_LOAD,MCNTRL
				sbrc	USB_INIT_LOAD,0
				rjmp	USB_WAIT_SR_COM
				;----- Set Interrupt and VGE -----
				ldi		USB_INIT_LOAD,0xC4
				sts		MCNTRL,USB_INIT_LOAD	;Set Interrupt out to active low (a change must be refelcted in Interrupt sense control from AVR) and enable VGE
				;----- Delay 1 ms -----
				ldi		USB_INIT_LOAD,0x0B		;Delay 1 ms
USB_DELAY_J_1ms:rcall	DELAY
				dec		USB_INIT_LOAD
				brbc	1,USB_DELAY_J_1ms
				;----- Set Interrupt Bits -----
				ldi		USB_INIT_LOAD,0x30
				sts		NAKMSK,USB_INIT_LOAD	;Enable NAK Out 0 and NAK Out 1 Interrupt
				ldi		USB_INIT_LOAD,0x03
				sts		TXMSK,USB_INIT_LOAD		;Enable TX_EV for FIFO 0 and FIFO 1
				ldi		USB_INIT_LOAD,0x03
				sts		RXMSK,USB_INIT_LOAD		;Enable RX_EV for FIFO 0 and FIFO 1
				ldi		USB_INIT_LOAD,0x50
				sts		ALTMSK,USB_INIT_LOAD	;Enable SD3 and RESET Interrupt
				ldi		USB_INIT_LOAD,0x56
				sts		MAMSK,USB_INIT_LOAD		;Enable ALT, TX_EV, NAK, RX_EV Interrupts (INTR is still disabled)
				;----- Init Complete -----
				ret

USB_ATTACH:		;----- Set USBN to Reset State -----
				ldi		USB_INIT_LOAD,0x00		;Set USBN9604 to RESET State
				sts		NFSR,USB_INIT_LOAD
				;----- Reset USB Operation Registers -----
				clr		USB_STATUS				;Reset USB Operation Registers
				clr		USB_INIT_LOAD
				sts		USB_CONFIG,USB_INIT_LOAD
				cbr		DEV_STATUS,0x08			;Clear Suspend Bit
				;----- Set Function Adress to 0 and Enable FAR -----
				ldi		USB_INIT_LOAD,0x80		;Set Function Adress to 0 and Enable FAR
				sts		FAR,USB_INIT_LOAD
				;----- Disable non 0 Endpoints and Reset EP 0 -----
				ldi		USB_INIT_LOAD,0x00		;Enable Endpoint 0 Only
				sts		EPC0,USB_INIT_LOAD
				sts		EPC1,USB_INIT_LOAD
				sts		EPC2,USB_INIT_LOAD
				;----- Go to Operational State -----
				ldi		USB_INIT_LOAD,0x02		;Go to Operational State
				sts		NFSR,USB_INIT_LOAD
				;----- Flush TX 0 -----
				ldi		USB_INIT_LOAD,0x08		;Flush TX0 FIFO and disable Transmitter
				sts		TXC0,USB_INIT_LOAD
				;----- Flush RX 0 -----
				ldi		USB_INIT_LOAD,0x08		;Flush RX0 FIFO and disable Receiver
				sts		RXC0,USB_INIT_LOAD
				;----- Enable RX 0 -----
				ldi		USB_INIT_LOAD,0x01		;Flush RX0 FIFO and enable Receiver
				sts		RXC0,USB_INIT_LOAD
				;----- Connect to USB Hub -----
				ldi		USB_INIT_LOAD,0xCC		;Set Node Attach (NAT)
				sts		MCNTRL,USB_INIT_LOAD
				;----- Enable global Interrupts -----
				ldi		USB_INIT_LOAD,0xD6
				sts		MAMSK,USB_INIT_LOAD		;Enable INTR Interrupt
				;----- Attach Complete -----
				ret

USB_DEATTACH:	;----- Disable global Interrupts -----
				ldi		USB_INIT_LOAD,0x56
				sts		MAMSK,USB_INIT_LOAD		;Disable INTR Interrupt
				;----- Disconnect from USB Hub -----
				ldi		USB_INIT_LOAD,0xC4
				sts		MCNTRL,USB_INIT_LOAD	;Clear Node Attach (NAT)
				;----- Set USBN to Reset State -----
				ldi		USB_INIT_LOAD,0x00
				sts		NFSR,USB_INIT_LOAD		;Set USBN9604 to RESET State
				;----- Deattach Complete -----
				cbr		DEV_STATUS,0x08			;Clear Suspend Bit
				ret

ENABLE_USB_LED:	;----- Enable USB Active Link LED -----
				lds		TEMP,DMX_USBLED_STAT
				sbrc	TEMP,3
				rjmp	DMX_START_USB_E
				sbr		TEMP,0x08
				sbi		PORTD,LED
				ldi		LOAD,0x82
				out		TIMSK,LOAD				;Enable Timer 1/0 Overflow Interrupt
				ldi		LOAD,0x05
				out		TCCR0,LOAD				;Enable Timer 0 with CK/1024
DMX_START_USB_E:sts		DMX_USBLED_STAT,TEMP
				ret

DISABLE_USB_LED:;----- Disable USB Active Link LED -----
				lds		TEMP,DMX_USBLED_STAT
				sbrs	TEMP,3
				rjmp	DMX_STOP_USB_E
				cbr		TEMP,0x08
				ldi		LOAD,0x00
				out		TCCR0,LOAD				;Disable Timer 0
				ldi		LOAD,0x80
				out		TIMSK,LOAD				;Enable Timer 1 Overflow Interrupt only
				nop
				cbi		PORTD,LED
DMX_STOP_USB_E:	sts		DMX_USBLED_STAT,TEMP
				ret

;--------------- End USB Sub-Routines -------------------------------------------

;--------------- End USB Communication Routines ---------------------------------


;--------------- Begin Power Managment Routines ---------------------------------

GET_POWER_STAT:	;Get Power States
				sbis	PIND,USB_POWER			;Check USB Power
				rjmp	GPOW_NO_USB_P
				sbr		DEV_STATUS,0x02
				rjmp	GPOW_C_SELF_P
GPOW_NO_USB_P:	cbr		DEV_STATUS,0x02
GPOW_C_SELF_P:	sbis	PIND,EXT_POWER			;Check Self Power
				rjmp	GPOW_NO_SELF_P
				sbr		DEV_STATUS,0x04
				rjmp	GPOW_C_DMX_OO
GPOW_NO_SELF_P:	cbr		DEV_STATUS,0x04
GPOW_C_DMX_OO:	ret

ENTER_SUSPEND:	rcall	DMX_STOP_TX
				rcall	DMX_STOP_RX
				rcall	DMX_STOP_EN
				rcall	DISABLE_USB_LED
				in		TEMP,MCUCR
				sbr		TEMP,0x30				;Enable Sleep and set Sleep Mode
				out		MCUCR,TEMP
				sleep
				ret

POWER_CHANGE:	rcall	USB_DEATTACH
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rcall	DELAY
				rjmp	RESET

;--------------- End Power Managment Routines -----------------------------------


;--------------- Begin EEPROM Routines ------------------------------------------

EEPROM_READ:	sbic	EECR,1
				rjmp	EEPROM_READ
				clr		INT_LOAD
				out		EEARH,INT_LOAD
				lds		INT_LOAD,EEPROM_ADDR
				out		EEARL,INT_LOAD
				sbi		EECR,0
				in		INT_LOAD,EEDR
				sts		EEPROM_DATA,INT_LOAD
				ret

EEPROM_WRITE:	sbic	EECR,1
				rjmp	EEPROM_WRITE
				clr		INT_LOAD
				out		EEARH,INT_LOAD
				lds		INT_LOAD,EEPROM_ADDR
				out		EEARL,INT_LOAD
				sbi		EECR,0
				in		ZL,EEDR
				lds		INT_LOAD,EEPROM_DATA
				cp		ZL,INT_LOAD
				breq	EEPROM_WRITE_E
				out		EEDR,INT_LOAD
				cli
				sbi		EECR,2
				sbi		EECR,1
				sei
EEPROM_WRITE_E:	ret

RECALL_EEPROM:	ldi		TEMP,0x00
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_CTRL_LOAD,TEMP
				ldi		TEMP,0x01
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_BRK_LOAD,TEMP
				ldi		TEMP,0x02
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_BRK_H_LOAD,TEMP
				ldi		TEMP,0x03
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_MARK_LOAD,TEMP
				ldi		TEMP,0x04
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_MARK_H_LOAD,TEMP
				ldi		TEMP,0x05
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_BYTE_LOAD,TEMP
				ldi		TEMP,0x06
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_BYTE_H_LOAD,TEMP
				ldi		TEMP,0x07
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_FRM_LOAD,TEMP
				ldi		TEMP,0x08
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_FRM_H_LOAD,TEMP
				ldi		TEMP,0x09
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_CNT_L_LOAD,TEMP
				ldi		TEMP,0x0A
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_CNT_H_LOAD,TEMP
				ldi		TEMP,0x0B
				sts		EEPROM_ADDR,TEMP
				rcall	EEPROM_READ
				lds		TEMP,EEPROM_DATA
				sts		DMXTADV_START_LOAD,TEMP
				ret

STORE_EEPROM:	ldi		INT_LOAD,0x00
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_CTRL_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x01
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_BRK_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x02
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_BRK_H_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x03
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_MARK_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x04
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_MARK_H_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x05
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_BYTE_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x06
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_BYTE_H_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x07
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_FRM_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x08
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_FRM_H_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x09
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_CNT_L_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x0A
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_CNT_H_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ldi		INT_LOAD,0x0B
				sts		EEPROM_ADDR,INT_LOAD
				lds		INT_LOAD,DMXTADV_START_LOAD
				sts		EEPROM_DATA,INT_LOAD
				rcall	EEPROM_WRITE
				ret

;--------------- End EEPROM Routines --------------------------------------------


;--------------- Begin Inter Memory Area Subroutines ----------------------------

CLEAR_BUFFER:	ldi		XH,0x20
				clr		XL
				ldi		YH,0x40
				clr		YL
				clr		LOAD
CB_LOOP:		st		X+,LOAD
				cp		XL,YL
				cpc		XH,YH
				brlo	CB_LOOP
				ret

DMX_IN_DMX_OUT:	clr		XH						;DMX In -> DMX Out
				mov		XL,BYTE_TREAT_POS		;Load X Register with actual Block start Adress and multiply by 32
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				rol		XH
				subi	XH,0xE0					;Add 0x2000 to get the DMX In Area (2000h)
				mov		YL,XL
				mov		YH,XH
				subi	YH,0xF6					;Add 0x0A00 to get the DMX Out Area (2A00h)
				clr		TEMP_2					;Clear Byte Counter
DMX_I_O_LOOP:	ld		TEMP,X+					;Load DMX In Value
				st		Y+,TEMP					;Store DMX In Value in DMX Out Area and increase X Pointer
				inc		TEMP_2					;Increase Byte Counter
				sbrs	TEMP_2,5				;Check if Bit 5 is set -> 32 Bytes reached -> Exit DMX In
				rjmp	DMX_I_O_LOOP			;Copy next Byte
				ret

PC_OUT_DMX_OUT:	clr		XH						;PC Out -> DMX Out
				mov		XL,BYTE_TREAT_POS		;Load X Register with actual Block start Adress and multiply by 32
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				rol		XH
				subi	XH,0xDE					;Add 0x2200 to get the PC Out Area (2200h)
				mov		YL,XL
				mov		YH,XH
				subi	YH,0xF8					;Add 0x0800 to get the DMX Out Backup Area (2A00h)
				clr		TEMP_2					;Clear Byte Counter
PC_O_DMX_O_LOOP:ld		TEMP,X+					;Load PC In Value
				st		Y+,TEMP					;Store PC In Value in DMX Out Area and increase X Pointer
				inc		TEMP_2					;Increase Byte Counter
				sbrs	TEMP_2,5				;Check if Bit 5 is set -> 32 Bytes reached -> Exit PC OUT
				rjmp	PC_O_DMX_O_LOOP			;Copy next Byte
				ret

DMX_PC_IN_D_OUT:clr		XH						;PC Out + DMX In -> DMX Out
				mov		XL,BYTE_TREAT_POS		;Load X Register with actual Block start Adress and multiply by 32
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				rol		XH
				subi	XH,0xE0					;Add 0x2000 to get the DMX In Area (2000h)
				mov		YL,XL
				mov		YH,XH
				subi	YH,0xFE					;Add 0x0200 to get the PC Out Backup Area (2200h)
				clr		TEMP_2					;Clear Byte Counter
DMX_PC_IN_LOOP:	ld		TEMP,X					;Load DMX In Value
				ld		LOAD,Y+					;Load PC In Value
				cp		TEMP,LOAD				;Get the higher Value
				brsh	D_P_I_D_O_TEMP
D_P_I_D_O_LOAD:	mov		TEMP,LOAD				;Higher Value in TEMP
D_P_I_D_O_TEMP:	subi	XH,0xF6					;Add 0x0A00 to get the Address for the DMX Out Area
				st		X+,TEMP					;Store higher Value in DMX Out Area and increase X Pointer
				subi	XH,0x0A					;Sub 0x0A00 to get the original Address for the DMX In Area
				inc		TEMP_2					;Increase Byte Counter
				sbrs	TEMP_2,5				;Check if Bit 5 is set -> 32 Bytes reached -> Exit DMX PC IN D OUT
				rjmp	DMX_PC_IN_LOOP			;Copy next Byte
				ret

DMX_IN_PC_IN_CO:clr		XH						;DMX In -> PC In compare
				mov		XL,BYTE_TREAT_POS		;Load X Register with actual Block start Adress and multiply by 32
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				rol		XH
				subi	XH,0xE0					;Add 0x2000 to get the DMX In Area (2000h)
				mov		YL,XL
				mov		YH,XH
				subi	YH,0xFA					;Add 0x0600 to get the DMX In Backup Area (2600h)
				clr		TEMP_2					;Clear Byte Counter
D_I_P_32_LOOP:	ld		TEMP,X+					;Load DMX In Value
				ld		LOAD,Y+					;Load DMX In Backup Value
				cp		TEMP,LOAD				;Compare both
				brne	D_I_P_32_UPDATE
				inc		TEMP_2					;Increase Byte Counter
				sbrs	TEMP_2,5				;Check if Bit 5 is set -> 32 Bytes reached -> Exit Compare Routine
				rjmp	D_I_P_32_LOOP			;Else test next Byte
D_I_P_32_EXIT:	ret
D_I_P_32_UPDATE:clr		XH						;Send HID Input Report from actual DMX In Compare Position
				mov		XL,BYTE_TREAT_POS		;Load X Register with actual Block start Adress and multiply by 32
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				lsl		XL
				rol		XH
				subi	XH,0xE0					;Add 0x2000 to get the DMX In Area (2000h)
				mov		YL,XL
				mov		YH,XH
				subi	YH,0xFA					;Add 0x0600 to get the DMX In Backup Area (2600h)
				ldi		LOAD,0x80				;Flush TX1
				sts		TXC1,LOAD
				sts		TXD1,BYTE_TREAT_POS		;Store first Byte: 32 Byte Field Pr�fix
				clr		TEMP_2					;Clear Byte Counter
D_I_P_32_UD_LOO:ld		TEMP,X+					;Load Byte from DMX In Mem (This is a 32x Loop)
				sts		TXD1,TEMP				;Write Byte to USBN
				st		Y+,TEMP					;Update DMX In Backup Mem
				inc		TEMP_2					;Increase Byte Counter
				sbrs	TEMP_2,5				;Check if Bit 5 is set -> 32 Bytes reached -> Enable TX1
				rjmp	D_I_P_32_UD_LOO			;Else write next Byte
				sbr		USB_STATUS,0x20			;Set USB TX1 active (Bit 5)
				;----- Enable Transmitter with correct Data PID and toggle it -----
				sbrs	USB_STATUS,6			;Test witch PID to use
				rjmp	DIP32TX1_PID_0
DIP32TX1_PID_1:	ldi		LOAD,0x07				;DATA 1 PID (Load Transmit Register with 05h and Clear TX1 PID Toggle Bit)
				cbr		USB_STATUS,0x40
				rjmp	DIP32TX1_EN
DIP32TX1_PID_0:	ldi		LOAD,0x03				;DATA 0 PID (Load Transmit Register with 01h and Set TX1 PID Toggle Bit)
				sbr		USB_STATUS,0x40
DIP32TX1_EN:	sts		TXC1,LOAD				;Enable Transmitter
				rjmp	D_I_P_32_EXIT

;--------------- End Inter Memory Area Subroutines -----------------------------



;--------------- Begin Main Part -----------------------------------------------

;Initialisation:
RESET:			;Set SP to last Byte in RAM:
				ldi		TEMP,low(RAMEND)
				out		SPL,TEMP
				ldi		TEMP,high(RAMEND)
				out		SPH,TEMP
   	        	;Set Tri-States:
				ldi		TEMP,0x00				;Set Tri-States of Port A,B & C
				out		DDRA,TEMP
				out		PORTA,TEMP
				ldi		TEMP,0x01
				out		DDRB,TEMP
				ldi		TEMP,0x01				;Tranceiver is off when Output = 1
				out		PORTB,TEMP
				out		DDRC,TEMP
				out		PORTC,TEMP
				ldi		TEMP,0x22				;Set Tri-States of Port D
				out		DDRD,TEMP
				ldi		TEMP,0x05				;Set Output Levels of Port D
				out		PORTD,TEMP
				;Timer 0/1:
				ldi		TEMP,0x80
				out		TIMSK,TEMP				;Enable Timer 1 Overflow Interrupt
				ldi		TEMP,0x00
				out		TCNT0,TEMP				;Reset Timer 0
				;Init UART for DMX Data Receive (also think of the right set of Bit 0 and Bit 1 in DDRD and PORTD):
				ldi		LOAD,0x02
				out		UBRRL,LOAD				;Load UART Bautrate Register with 0x01
				sbi		UCSRB,2					;Enable 9-Bit Mode
				ldi		LOAD,0x86
				out		UCSRC,LOAD
				sbi		UCSRB,0					;Set Bit 8 for Transmitter
				;Enable External SRAM and Set Interrupt Edges for External Interrupts:
				ldi		TEMP,0xCC				;The rising Edge of Int1 and the low Level of Int0 generates an Interrupt (Bits 0-3) and SRAM incl. Wait State Enable (Bit 7,6)
				out		MCUCR,TEMP
				ldi		TEMP,0x1C				;Divide ext. RAM and set 1 Waitstates to RAM, 3 Waitstates to USBN
				out		EMCUCR,TEMP
				;Enable External Interrupt:
				ldi		TEMP,0x40
				out		GICR,TEMP
				;Init Variables:
				clr		DEV_CONFIG				;Select no DMX Device Configuration
				sts		DMX_USBLED_STAT,DEV_CONFIG	;Disable all DMX Tranceiver Parts
				clr		DEV_STATUS				;No USB Suspend Mode
				clr		LAST_DEV_CONFIG
				clr		BYTE_TREAT_POS			;Treat 0 - 31 first
				rcall	CLEAR_BUFFER
				;Load DMX Transceiver Configuration (should be done before sei because the eeprom subroutines use INT_LOAD and ZL)
				rcall	RECALL_EEPROM
				;Enable Global Interrupt:
				sei
				;Get initial Power Status
				rcall	GET_POWER_STAT
				mov		TEMP,DEV_STATUS
				andi	TEMP,0x06
				sts		DEV_STATUS_BAC,TEMP
				;Initiate USBN9602:
				rcall	USB_INIT
				;Set Device Mode
				sbrc	DEV_STATUS,1			;No USB? -> CONFIG 1
				rjmp	RES_USB
RES_NO_USB:		ldi		DEV_CONFIG,0x01
				rjmp	RES_GO_ON
RES_USB:		rcall	USB_ATTACH
				;Initiate DMX-512:
RES_GO_ON:		rcall	DMX_STOP_TX
				rcall	DMX_STOP_RX
				rcall	DMX_STOP_EN



;Main Loop:
MAIN:			;Check if Device is only Buspowered and not configured
				sbrc	DEV_STATUS,2
				rjmp	MAIN_NORMAL
				lds		TEMP,USB_CONFIG
				cpi		TEMP,0x00
				brne	MAIN_NORMAL
				rcall	DMX_STOP_TX
				rcall	DMX_STOP_RX
				rcall	DMX_STOP_EN
				rjmp	MAIN_MAX_100MA

MAIN_NORMAL:	;Check witch Data-Processing must be done
				mov		TEMP,DEV_CONFIG			;Check if / witch Output Function is selected (lowest 2 Bits)
				andi	TEMP,0x03
				cpi		TEMP,0x01
				breq	MAIN_DI_DO
				cpi		TEMP,0x02
				breq	MAIN_PCO_DO
				cpi		TEMP,0x03
				breq	MAIN_DI_PCO_DO
				rjmp	CHECK_DI_PCI
MAIN_DI_DO:		rcall	DMX_IN_DMX_OUT			;DMX In -> DMX Out
				rjmp	CHECK_DI_PCI
MAIN_PCO_DO:	rcall	PC_OUT_DMX_OUT			;PC Out -> DMX Out
				rjmp	CHECK_DI_PCI
MAIN_DI_PCO_DO:	rcall	DMX_PC_IN_D_OUT			;DMX In + PC Out -> DMX Out
CHECK_DI_PCI:	sbrs	DEV_CONFIG,2			;Check if Input Function is selected (Bit 2)
				rjmp	MAIN_INC_BYTE_P
				lds		LOAD,USB_CONFIG			;USB Configured?
				cpi		LOAD,0x01
				brne	MAIN_INC_BYTE_P
				sbrc	DEV_STATUS,3			;USB Suspend?
				rjmp	MAIN_INC_BYTE_P
				sbrs	USB_STATUS,5			;Check if TX1 is active (Bit 5), if do no DMX In -> PC In
				rcall	DMX_IN_PC_IN_CO			;DMX In -> PC In compare
				;Select next Data-Processing Part
MAIN_INC_BYTE_P:inc		BYTE_TREAT_POS
				sbrc	BYTE_TREAT_POS,4		;Check if 16 Cycles (Bit 4) are reached -> Reset
				clr		BYTE_TREAT_POS			;Reset BYTE_TREAT_POS to 0

				;Check Setting of DMX-Tranceiver
				mov		TEMP,DEV_CONFIG			;Check if / witch Output Function is selected (lowest 2 Bits)
				andi	TEMP,0x07
				cpi		TEMP,0x00
				breq	MAIN_DEV_0
				cpi		TEMP,0x02
				breq	MAIN_DEV_2
				cpi		TEMP,0x04
				breq	MAIN_DEV_4
				rcall	DMX_START_TX
				rcall	DMX_START_RX
				rcall	DMX_START_EN
				rjmp	MAIN_DEV_END
MAIN_DEV_0:		rcall	DMX_STOP_TX
				rcall	DMX_STOP_RX
				rcall	DMX_STOP_EN
				rjmp	MAIN_DEV_END
MAIN_DEV_2:		rcall	DMX_START_TX
				rcall	DMX_STOP_RX
				rcall	DMX_START_EN
				rjmp	MAIN_DEV_END
MAIN_DEV_4:		rcall	DMX_STOP_TX
				rcall	DMX_START_RX
				rcall	DMX_START_EN
MAIN_DEV_END:

MAIN_MAX_100MA:	;Check USB_LED
				sbrc	DEV_STATUS,1			;USB_Active? -> Enable USB LED
				rcall	ENABLE_USB_LED
				sbrs	DEV_STATUS,1
				rcall	DISABLE_USB_LED

				;Check Suspend
				sbrc	DEV_STATUS,2			;Self Power? -> No Suspend
				rjmp	MAIN_NO_SUSP
				sbrc	DEV_STATUS,3			;Suspend Requested?
				rcall	ENTER_SUSPEND			;Enter Suspend
MAIN_NO_SUSP:

				;Check for Change in Powersupply/Suspendmode
				rcall	GET_POWER_STAT			;Get Power Status
				mov		LOAD,DEV_STATUS
				andi	LOAD,0x06
				lds		TEMP,DEV_STATUS_BAC
				cp		LOAD,TEMP				;Check Power Change
				breq	MAIN_SAVE_DEV_C
				rjmp	POWER_CHANGE
MAIN_SAVE_DEV_C:rjmp	MAIN

;--------------- End Main Part ---------------------------------------------------------



;--------------- Begin Descriptor Part -------------------------------------------------

.org 0x0E00

DEVICE_DESC:	.DW		0x12					;Descriptor size in Bytes (18 Bytes)
				.DW		0x01					;Descriptor Type -> Constant DEVICE (01h)
				.DW		0x10,0x01				;USB specification release number (BCD) (Complies to USB Spec. Release 1.10)
				.DW		0x00					;Class code (0)
				.DW		0x00					;Subclass code (0)
				.DW		0x00					;Protocol code (No specific protocol)
				.DW		0x08					;Maximum packet size for Endpoint 0 (8 Bytes)
				.DW		0xB4,0x04				;Vendor ID (No yet available)
				.DW		0x1F,0x0F				;Product ID (No yet available)
				.DW		0x10,0x01				;Device release number (BCD) (1.10)
				.DW		0x01					;Index of string descriptor for the manufacturer (1)
				.DW		0x02					;Index of string descriptor for the product (2)
				.DW		0x03					;Index of string descriptor containing the serial number (3)
				.DW		0x01					;Number of possible configurations (1)
DECIVE_DESC_END:

CONFIG_DESC:	.DW		0x09					;Descriptor size in Bytes (9 Bytes)
				.DW		0x02					;Descriptor Type -> Constant CONFIGURATION (02h)
				.DW		0x29,0x00				;Size of all data returned for this configuration in bytes (41 Bytes)
				.DW		0x01					;Number of interfaces the configuration supports (1)
				.DW		0x01					;Identifier for Set_Configuration and Get_Configuration requests (1)
				.DW		0x00					;Index of string descriptor for the configuration (None)
CONFIG_DESC_SBP:.DW		0x80					;Self power/bus power and remote wakeup settings (Bus powered)
CONFIG_DESC_BP:	.DW		0x64					;Bus power required, expressed as (maximum milliamperes/2) (150 mA)
CONFIG_DESC_END:

INTERFACE_DESC:	.DW		0x09					;Descriptor size in Bytes (9 Bytes)
				.DW		0x04					;Descriptor Type -> Constant INTERFACE (04h)
				.DW		0x00					;Number identifying this interface (0)
				.DW		0x00					;Value used to select an alternate setting (0)
				.DW		0x02					;Number of endpoints supported, except Endpoint 0 (2)
				.DW		0x03					;Class code (03h for HID Class)
				.DW		0x00					;Subclass code (None)
				.DW		0x00					;Protocol code (None)
				.DW		0x00					;Index of string descriptor for the interface (None)
INTERFACE_DESC_END:

HID_CLASS_DESC:	.DW		0x09					;Descriptor size in Bytes (9 Bytes)
				.DW		0x21					;Descriptor Type -> Constant HID (21h)
				.DW		0x10,0x01				;HID specification release number (BCD) (1.10)
				.DW		0x00					;Numeric expression identifying the country for localized hardware (BCD) (None)
				.DW		0x01					;Number of subordinate class descriptors supported (1)
				.DW		0x22					;The type of class descriptor (HID -> 22h)
				.DW		REPORT_DESC_END - REPORT_DESC,0x00	;Total length of report descriptor (36 Bytes)
HID_CLASS_DESC_END:

ENDPOINT1_DESC:	.DW		0x07					;Descriptor size in Bytes (7 Bytes)
				.DW		0x05					;Descriptor type -> Constant ENDPOINT (05h)
				.DW		0x81					;Endpoint number and direction (Respond to IN, Endpoint 1
				.DW		0x03					;Transfer type supported (Interrupt -> 03h)
				.DW		0x21,0x00				;Maximum packet size supported (33 Bytes)
				.DW		0x01					;Maximum latency / polling interval / NAK rate (1 ms)
ENDPOINT1_DESC_END:

ENDPOINT2_DESC:	.DW		0x07					;Descriptor size in Bytes (7 Bytes)
				.DW		0x05					;Descriptor type -> Constant ENDPOINT (05h)
				.DW		0x02					;Endpoint number and direction (Respond to OUT, Endpoint 2
				.DW		0x03					;Transfer type supported (Interrupt -> 03h)
				.DW		0x21,0x00				;Maximum packet size supported (33 Bytes)
				.DW		0x01					;Maximum latency / polling interval / NAK rate (1 ms)
ENDPOINT2_DESC_END:

CONFIG_SET_DESC_END:

REPORT_DESC:	.DW		0x06,0xA0,0xFF			;Usage Page (vendor defined)
				.DW		0x09,0xA5				;Usage (vendor defined)
				;Collection
				.DW		0xA1,0x01				;Collection (Application)
				.DW		0x09,0xA6				;Usage (vendor defined)
				;Input Report
				.DW		0x09,0xA7				;Usage (vendor defined)
				.DW		0x15,0x00				;Logical minimum (0)
				.DW		0x25,0xFF				;Logical maximum (255)
				.DW		0x75,0x08				;Report Size (8 bits)
				.DW		0x95,0x21				;Report Count (33 fields/bytes)
				.DW		0x82,0x22,0x01			;Input (Data, Variable, Absolute, No pref. state, Buffered bytes)
				;Output Report
				.DW		0x09,0xA9				;Usage (vendor defined)
				.DW		0x15,0x00				;Logical minimum (0)
				.DW		0x25,0xFF				;Logical maximum (255)
				.DW		0x75,0x08				;Report Size (8 bits)
				.DW		0x95,0x21				;Report Count (33 fields/bytes)
				.DW		0x92,0x22,0x01			;Input (Data, Variable, Absolute, No pref. state, Buffered bytes)
				;Collection
				.DW		0xC0					;End Collection
REPORT_DESC_END:

STRING0_DESC:	.DW		0x04					;Descriptor size in Bytes (4 Bytes) - Language Description
				.DW		0x03					;Descriptor type -> Constant STRING (03h)
				.DW		0x09					;Language: English
				.DW		0x04					;Sub-Language: US
STRING0_DESC_END:

STRING1_DESC:	.DW		0x2C					;Descriptor size in Bytes (44 Bytes) - Manufacturer Name (Unicode)
				.DW		0x03					;Descriptor type -> Constant STRING (03h)
				.DW		0x44,0x00				;D
				.DW		0x69,0x00				;i
				.DW		0x67,0x00				;g
				.DW		0x69,0x00				;i
				.DW		0x74,0x00				;t
				.DW		0x61,0x00				;a
				.DW		0x6C,0x00				;l
				.DW		0x20,0x00				;
				.DW		0x45,0x00				;E
				.DW		0x6E,0x00				;n
				.DW		0x6C,0x00				;l
				.DW		0x69,0x00				;i
				.DW		0x67,0x00				;g
				.DW		0x68,0x00				;h
				.DW		0x74,0x00				;t
				.DW		0x65,0x00				;e
				.DW		0x6E,0x00				;n
				.DW		0x6D,0x00				;m
				.DW		0x65,0x00				;e
				.DW		0x6E,0x00				;n
				.DW		0x74,0x00				;t
STRING1_DESC_END:

STRING2_DESC:	.DW		0x20					;Descriptor size in Bytes (32 Bytes) - Product Name (Unicode)
				.DW		0x03					;Descriptor type -> Constant STRING (03h)
				.DW		0x53,0x00				;S
				.DW		0x75,0x00				;u
				.DW		0x6E,0x00				;n
				.DW		0x6C,0x00				;l
				.DW		0x69,0x00				;i
				.DW		0x67,0x00				;g
				.DW		0x68,0x00				;h
				.DW		0x74,0x00				;t
				.DW		0x20,0x00				;
				.DW		0x4B,0x00				;K
				.DW		0x69,0x00				;i
				.DW		0x6C,0x00				;l
				.DW		0x6C,0x00				;l
				.DW		0x65,0x00				;e
				.DW		0x72,0x00				;r
STRING2_DESC_END:

