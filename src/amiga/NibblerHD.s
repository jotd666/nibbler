
	INCDIR	Include:
	INCLUDE	whdload.i
	INCLUDE	whdmacros.i

;CHIP_ONLY

; lowest chip possible. CD32 version must fit in $1E0000 bytes
; including stack, which is very close. Why wasting precious kbs?
CHIP_BASE = $200

	IFD	CHIP_ONLY
EXPMEM = 0
CHIPSIZE = $180000
	ELSE
EXPMEM = $E0000
CHIPSIZE = $80000
	ENDC

_base	SLAVE_HEADER					; ws_security + ws_id
	dc.w	17					; ws_version (was 10)
	dc.w	WHDLF_NoError
	dc.l	CHIPSIZE
	dc.l	0					; ws_execinstall
	dc.w	start-_base		; ws_gameloader
	dc.w	_data-_base					; ws_currentdir
	dc.w	0					; ws_dontcache
_keydebug
	dc.b	$0					; ws_keydebug
_keyexit
	dc.b	$59					; ws_keyexit
_expmem
	dc.l	EXPMEM					; ws_expmem
	dc.w	_name-_base				; ws_name
	dc.w	_copy-_base				; ws_copy
	dc.w	_info-_base				; ws_info
    dc.w    0     ; kickstart name
    dc.l    $0         ; kicksize
    dc.w    $0         ; kickcrc
    dc.w    _config-_base
;---
_config
	dc.b	"C1:X:infinite time:0;"
	dc.b	"C1:X:infinite lives:1;"
	dc.b	"C1:X:cheat keys:4;"
	dc.b	"C2:X:50 Hz update:0;"
	dc.b	"C2:X:startup menu:5;"

	dc.b	"C3:L:difficulty level:easy,hard;"
	dc.b	"C4:L:lives:3,4,5,6;"
	dc.b	"C5:L:start level:1,2,3,4,5,6,7,8,9,10,11,"
	dc.b	"12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32;"
	dc.b	0

	IFD BARFLY
	DOSCMD	"WDate  >T:date"
	ENDC


DECL_VERSION:MACRO
	dc.b	"1.0"
	IFD BARFLY
		dc.b	" "
		INCBIN	"T:date"
	ENDC
	IFD	DATETIME
		dc.b	" "
		incbin	datetime
	ENDC
	ENDM
_data   dc.b    0
_name	dc.b	"Nibbler"
	IFD	CHIP_ONLY
	dc.b	" (chip)"
	ENDC
	dc.b	0
_copy	dc.b	'2026 JOTD',0
_info
    dc.b    "Original 1982 Rock'ola",0
	dc.b	0
_kickname   dc.b    0
;--- version id

    dc.b	0
    even

start:
	LEA	_resload(PC),A1
	MOVE.L	A0,(A1)
	move.l	a0,a2
    
    IFEQ EXPMEM
    lea  _expmem(pc),a0
    move.l  #CHIP_BASE,(a0)
    ENDC
    lea progstart(pc),a0
    move.l  _expmem(pc),(a0)

	lea	exe(pc),a0
	move.l  progstart(pc),a1
	jsr	(resload_LoadFileDecrunch,a2)
	move.l  progstart(pc),a0
    bsr   _Relocate
	move.l	_resload(pc),a0
    move.l  #'WHDL',d0
    move.b  _keyexit(pc),d1
	move.l  progstart(pc),-(a7)
    
    lea  _custom,a1
    move.w  #$1200,bplcon0(a1)
    move.w  #$0024,bplcon2(a1)
    rts
	
_Relocate	movem.l	d0-d1/a0-a2,-(sp)
        clr.l   -(a7)                   ;TAG_DONE
;        pea     -1                      ;true
;        pea     WHDLTAG_LOADSEG
		IFNE		EXPMEM
        move.l  #CHIP_BASE,-(a7)       ;chip area
        pea     WHDLTAG_CHIPPTR        
        pea     8                       ;8 byte alignment
        pea     WHDLTAG_ALIGN
		ENDC
        move.l  a7,a1                   ;tags	
		move.l	_resload(pc),a2
		jsr	resload_Relocate(a2)
		IFNE		EXPMEM
        add.w   #5*4,a7
		ELSE
		addq.w	#4,a7
		ENDC
		
        movem.l	(sp)+,d0-d1/a0-a2
		rts

_resload:
	dc.l	0
progstart
    dc.l    0
exe
	
	dc.b	"nibbler_000",0
