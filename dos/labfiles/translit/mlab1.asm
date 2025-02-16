;***************************************************************************************************
; MLAB1.ASM - uchebnyy primer dlya vypolneniya 
; laboratornoy raboty N1 po mashinno-orientirovannomu programmirovaniyu
; 10.09.02: Negoda V.N.
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       Ispol'zuyutsya deklaratsii konstant i makrosov
        INCLUDE MLAB1.INC	
        INCLUDE MLAB1.MAC

; Deklaratsii dannykh
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"Familiya I.O.: ",0FFh
MINIS	DB	"MINISTERSTVO OBRAZOVANIYA ROSSIYSKOY FEDERATSII",0
ULSTU	DB	"UL'YANOVSKIY GOSUDARSTVENNYY TEKHNICHESKIY UNIVERSITET",0
DEPT	DB	"Kafedra vychislitel'noy tekhniki",0
MOP	DB	"Mashinno-orientirovannoe programmirovanie",0
LABR	DB	"Laboratornaya rabota N 1",0
REQ1    DB      "Zamedlit'(-),uskorit'(+),vyyti(ESC)? ",0FFh
TACTS   DB	"Vremya raboty v taktakh: ",0FFh
EMPTYS	DB	0
BUFLEN = 70
BUF	DB	BUFLEN
LENS	DB	?
SNAME	DB	BUFLEN DUP (0)
PAUSE	DW	0, 0 ; mladshee i starshee slova zaderzhki pri vyvode stroki
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; stroka vyvoda chisla taktov
                                          ; zapas dlya razdelitel'nykh "`"

;========================= Programma =========================
        .CODE
; Makros zapolneniya stroki LINE ot pozitsii POS soderzhimym CNT ob'ektov,
; adresuemykh adresom ADR pri shirine polya vyvoda WFLD
BEGIN	LABEL	NEAR
	; initsializatsiya segmentnogo registra
	MOV	AX,	@DATA
	MOV	DS,	AX
	; initsializatsiya zaderzhki
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; zapros imeni
	; vvod imeni
	LEA	DX,	BUF
	CALL	GETS	
@@L:	; tsiklicheskiy protsess povtoreniya vyvoda zastavki
	; vyvod zastavki
	; IZMERENIE VREMENI NACHAT' ZDES'
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; razdelitel'naya cherta
	PUTL	EMPTYS
	PUTLSC	MINIS	; pervaya 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  i  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   posleduyushchie 
	PUTL	EMPTYS
	PUTLSC	MOP	;    stroki  
	PUTL	EMPTYS
	PUTLSC	LABR	;     zastavki
	PUTL	EMPTYS
	; privetstvie
	PUTLSC	SNAME   ; FIO studenta
	PUTL	EMPTYS
	; razdelitel'naya cherta
	PUTL	SLINE
	; IZMERENIE VREMENI ZAKONCHIT' ZDES' 
	DURAT    	; podschet zatrachennogo vremeni
	; Preobrazovanie chisla tikov v stroku i vyvod
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; vyvod chisla taktov
	; obrabotka komandy
	PUTL	REQ1
	CALL	GETCH
	CMP	AL,	'-'    ; udlinyat' zaderzhku?
	JNE	CMINUS
	INC	PAUSE+2        ; dobavit' 65536 mks
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; ukorachivat' zaderzhku?
	JNE	CEXIT
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; ubavit' 65536 mks
BACK:	JMP	@@L
CEXIT:	CMP	AL,	CHESC	
	JE	@@E
	TEST	AL,	AL
	JNE	BACK
	CALL	GETCH
	JMP	@@L
	; Vykhod iz programmy
@@E:	EXIT	
        EXTRN	PUTSS:  NEAR
        EXTRN	PUTC:   NEAR
	EXTRN   GETCH:  NEAR
	EXTRN   GETS:   NEAR
	EXTRN   SLEN:   NEAR
	EXTRN   UTOA10: NEAR
	END	BEGIN
