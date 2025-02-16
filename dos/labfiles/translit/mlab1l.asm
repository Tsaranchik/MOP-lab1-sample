;*********************************************************
; Protsedury dlya uchebnogo prima laboratornoy raboty N 1  *
; po MOP. 10.09.02: Negoda V.N.                           *
;*********************************************************

.MODEL SMALL
.CODE
.386
 INCLUDE MLAB1.INC
 LOCALS
;=====================================================
; Podprogramma vyvoda na ekran stroki, adresuemoy SI, 
; s zaderzhkoy vremeni mezhdu simvolami v <CX,DX> mcs.
; Zavershitelyami stroki yavlyayutsya bayty 0 ili 0FFh.
; ESLI stroka zakanchivayetsya baytom 0,
;   TO dobavlyayetsya perekhod v nachalo novoy stroki
; 
;=====================================================
PUTSS   PROC	NEAR
@@L:    MOV	AL,	[SI]
        CMP	AL,	0FFH
        JE	@@R
        CMP	AL,	0
        JZ	@@E
        CALL	PUTC
        INC	SI
	CALL	DILAY
        JMP	SHORT @@L
        ; Perekhod na sleduyushchuyu stroku
@@E:    MOV	AL, CHCR
        CALL	PUTC
        MOV	AL, CHLF
        CALL	PUTC
@@R:    RET
PUTSS	ENDP

;==============================================
; Podprogramma vyvoda AL na terminal
;==============================================
PUTC	PROC	NEAR
        PUSH	DX
        MOV	DL,   AL
        MOV	AH,   FUPUTC
        INT	DOSFU
        POP	DX
        RET
PUTC	ENDP

;==============================================
; Podprogramma vvod simvola v AL s terminala
;==============================================
GETCH	PROC	NEAR
        MOV	AH,   FUGETCH
        INT	DOSFU
        RET
GETCH	ENDP

;=================================================
; Podprogramma vvod stroki v bufer, adresuemyy DX
;   i imeyushchiy strukturu: 
;    { char size; // razmer bufyera 
;      char len;  // real'no vvedeno
;      char str[size]; // simvoly stroki }
;=================================================
GETS	PROC	NEAR
	PUSH	SI
	MOV	SI,	DX
        MOV	AH,	FUGETS
        INT	DOSFU
	; propisat' bayt 0 v konets stroki
	XOR	AH,	AH
	MOV	AL,	[SI+1]
	ADD	SI,	AX
	MOV	BYTE PTR [SI+2], 0
	POP	SI
        RET
GETS	ENDP

;==============================================
; Podprogramma podscheta chisla simvolov v stroke,
; adresuemoy SI. Zavershitelyi stroki: 0 i 0FFh
; Rezultat vozvrashchayetsya v AX
;==============================================
SLEN	PROC	NEAR
	XOR     AX,   AX
LSLEN:  CMP     BYTE PTR [SI], 0
	JE	RSLEN
        CMP     BYTE PTR [SI], 0FFh
	JE	RSLEN
	INC	AX
	INC	SI
	JMP	SHORT	LSLEN
RSLEN:  RET
SLEN 	ENDP

;====================================================
; Podprogramma preobrazovaniya <EDX,EAX> v bezznakovoe 
; desyatechnoe, razmeshchayemoe po adresu DI
;==============================================
	.DATA
UBINARY	DQ	0  ; Ishodnoe dvoichnoe 64-razryadnoe
UPACK	DT	0  ; Upakovannye 18 desyatechnykh tsifr	
	.CODE
UTOA10	PROC	NEAR
	PUSH	CX
	PUSH	DI
	MOV	DWORD PTR [UBINARY],   EAX
	MOV	DWORD PTR [UBINARY+4], EDX
	FINIT			; initsializatsiya soprocessora
	FILD	UBINARY		; zabrosivanie v nego binarnogo
	FBSTP	UPACK		; izvlechenie upakovonnogo desyatechnogo
	MOV	CX,	LENPACK	; polucheno 9 par tsifr
	PUSH	DS		; pisat' 
	POP	ES 		;   budem
	CLD     		;     cherez stosw
	LEA	SI,	UPACK   ;     s kontsa 
	ADD	SI,	LENPACK	;     bufera upack        
	; Tsikl preobrazovaniya par polubaytov v ASCII-kody tsifr
@@L:	XOR	AX,	AX
	DEC	SI
	MOV	AL,	[SI]
	SHL	AX,	4
	SHR	AL,	4	
	ADD	AX,	3030h
	XCHG	AL,	AH
	STOSW		
	LOOP	@@L
	; Fiksatsiya kontsa stroki
	XOR	AL, 	AL
	STOSB
	; Ulichshim chitabel'nost' slishkom dlinnoe chislo
	CLD
	MOV	AX,	LENNUM-4	
@@L1:	MOV	CX,	AX
	POP	DI	   ; vstajem na nachalo stroki
	PUSH	DI	
	MOV	SI,	DI
	INC	SI
	REP	MOVSB
	MOV	BYTE PTR [DI], CHCOMMA ; vstavit' razdelyatel' troek tsifr
	SUB	AX,	4  ;     3 tsifry + razdelyatel' obrabotany
	JS	@@E        ; prekratit', esli ostalos' ne bol'she 3-kh tsifr
	JMP	SHORT	@@L1
@@E:	POP	SI
	PUSH	SI
	XOR	CX,	CX
	; S'yedem pervye nuli
	;   snachala podschetyvayem
@@L2:	CMP	BYTE PTR [SI], '0'
	JE	@@N
	CMP	BYTE PTR [SI], CHCOMMA		
	JNE	@@N1
@@N:	INC	CX
	INC	SI
	JMP	SHORT	@@L2
@@N1:	;   a teper' s'yedem
	POP	DI
	SUB	CX, LENNUM+1
	NEG	CX
	REP	MOVSB
	POP	CX
        RET
UTOA10	ENDP

;==============================================
; Podprogramma zaderzhki vypolneniya programmy 
; na <CX,DX> mikrosekund
;==============================================
DILAY	PROC	NEAR
	MOV	AH,	86h
        INT	15h
        RET
DILAY	ENDP

        PUBLIC	PUTSS, PUTC, GETCH, GETS, DILAY, SLEN, UTOA10

        END
