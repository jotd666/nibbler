* Generated with 6502to68k by JOTD
*
* include file which contains generic macros
* and also macros that the user must fill/tune
	.include	"options.inc"

    .macro    ERROR    arg
    .error    "\arg"     | comment out to disable errors
    .endm

	.ifdef	MC68020
* 68020 optimized


	.macro READ_LE_WORD    srcreg
	moveq    #0,d4
	move.w    (\srcreg),d4
	rol.w    #8,d4
* we have to use long else it will
* extend sign for > 0x7FFF and will compute wrong offset
	move.l    d4,\srcreg
	.endm

	.else
* 68000 compliant

	.macro READ_LE_WORD    srcreg
	moveq    #0,d4
	move.b    (1,\srcreg),d4
	rol.w    #8,d4
	move.b    (\srcreg),d4
* we have to use long else it will
* extend sign for > 0x7FFF and will compute wrong offset
	move.l    d4,\srcreg
	.endm

	.endif



	.macro OP_R_ON_ZP_ADDRESS	inst,offset,reg
	\inst\().b	(a6,\offset\().W),\reg
	.endm

	.macro OP_W_ON_ZP_ADDRESS	inst,offset,reg
	\inst\().b	\reg,(a6,\offset\().W)
	.endm

* fast way to set Z flag. It also sets C,N so if just Z
* must be set, use a direct ccr operation instead
	.macro SET_Z_FLAG
	cmp.b	d4,d4
	.endm

	.macro	SBC_X	address
	INVERT_XC_FLAGS
	GET_ADDRESS	\address
	move.b	(a0,d1.w),d4
	SET_Z_FLAG     | set Z flag, as subx doesn't set it
	subx.b	d4,d0
	INVERT_XC_FLAGS
	.endm
	
	.macro	SBC_Y	address
	INVERT_XC_FLAGS
	GET_ADDRESS	\address
	move.b	(a0,d2.w),d4
	SET_Z_FLAG     | set Z flag, as subx doesn't set it
	subx.b	d4,d0
	INVERT_XC_FLAGS
	.endm
	
	.macro	SBC_IND_Y	address
	INVERT_XC_FLAGS
	GET_INDIRECT_ADDRESS	\address
	move.b	(a0,d2.w),d4
	SET_Z_FLAG     | set Z flag, as subx doesn't set it
	subx.b	d4,d0
	INVERT_XC_FLAGS
	.endm
	
	.macro	SBC	address
	INVERT_XC_FLAGS
	GET_ADDRESS	\address
	move.b	(a0),d4
	SET_Z_FLAG     | set Z flag, as subx doesn't set it
	subx.b	d4,d0
	INVERT_XC_FLAGS
	.endm

	.macro	SBCD_DIRECT	address
	INVERT_XC_FLAGS
	GET_ADDRESS	\address
	move.b	(a0),d4
	SET_Z_FLAG     | set Z flag, as subx doesn't set it
	scbd	d4,d0
	INVERT_XC_FLAGS
	.endm
	
	.macro	SBC_IMM	param
	INVERT_XC_FLAGS
	move.b	#\param,d4
	SET_Z_FLAG     | set Z flag, as subx doesn't set it
	subx.b	d4,d0
	INVERT_XC_FLAGS
	.endm

	.macro	SBCD_IMM	param
	INVERT_XC_FLAGS
	move.b	#\param,d4
	SET_Z_FLAG     | set Z flag, as subx doesn't set it
	sbcd	d4,d0
	INVERT_XC_FLAGS
	.endm

	.macro INVERT_XC_FLAGS
	eor.b	#0x11,ccr
	.endm




    .macro CLR_XC_FLAGS
    and.b    #0xEE,ccr        | bit 4 = X, bit 0 = C
    .endm

    .macro SET_XC_FLAGS
    or.b    #0x11,ccr        | bit 4 = X, bit 0 = C
    .endm

    .macro CLR_V_FLAG
    and.b    #0xFD,ccr        | bit 1 = V
    .endm

    .macro SET_V_FLAG
    or.b    #0x2,ccr        | bit 1 = V
    .endm

    .macro    SET_NV_FLAGS
    or.b    #0xA,ccr        | bit 1 = V, bit 3 = N
    .endm


	.macro SET_I_FLAG
	jbsr	osd_disable_interrupts
	.endm
	.macro CLR_I_FLAG
	jbsr	osd_enable_interrupts
	.endm


	.macro	VIDEO_BYTE_DIRTY
	jbsr	osd_video_byte_dirty
	.endm

	.macro GET_ADDRESS	offset
	lea	\offset,a0
	GET_ADDRESS_FUNC
	.endm

	.macro GET_UNCHECKED_ADDRESS	offset
	lea	\offset,a0
	lea		(a6,a0.l),a0
	.endm
	
	.macro	PREP_GET_ADDRESS_X	offset
	.ifgt	\offset-0x8000
	lea	\offset,a0
	.else
	lea	\offset\().w,a0
	.endif
	GET_ADDRESS_FUNC
	lea	(a0,d1.w),a0
	READ_LE_WORD	a0
	.endm
	.macro GET_ADDRESS_X	offset
	PREP_GET_ADDRESS_X	\offset
	GET_ADDRESS_FUNC
	.endm
	.macro GET_UNCHECKED_ADDRESS_X	offset
	PREP_GET_ADDRESS_X	\offset
	GET_UNCHECKED_ADDRESS_FUNC
	.endm

	.macro GET_INDIRECT_ADDRESS	offset
	GET_ADDRESS	\offset
	READ_LE_WORD	a0
	GET_ADDRESS_FUNC
	.endm
	.macro GET_INDIRECT_UNCHECKED_ADDRESS	offset
	GET_ADDRESS	\offset
	READ_LE_WORD	a0
	GET_UNCHECKED_ADDRESS_FUNC
	.endm
	.macro	GET_UNCHECKED_ADDRESS_FUNC
	lea		(a6,a0.l),a0
	.endm
	.macro OP_1_ON_ZP_ADDRESS	inst,offset
	\inst\().b	(a6,\offset\().W)
	.endm
	.ifdef	RELEASE
	.macro	GET_ADDRESS_FUNC
	GET_UNCHECKED_ADDRESS_FUNC
	.endm
	.else
	.macro	GET_ADDRESS_FUNC
	jbsr	get_address
	.endm

* dev mode, more checks about the address
get_address:
	cmp.w	#0x3000,a0
	jcc		10f		| rom: ok
	cmp.w	#0x400,a0
	jcs		10f		| ram: ok
	
	cmp.w	#0x1000,a0
	jcc		9f
	* 0x400-0xFFF: video/attribute: must be done without "get_address"
	jbsr	osd_get_last_known_pc
	BREAKPOINT	"unsupported address range 0x400-0xFFF, PC in D6"
	jra		10f
9:
	cmp.w	#0x2000,a0
	jcs		10f			| character ram: skip

	jbsr	osd_get_last_known_pc
	BREAKPOINT	"unsupported address range 0x2000-0x3000, PC in D6"
10:
	GET_UNCHECKED_ADDRESS_FUNC
	rts

	* to trace at some virtual PCs, insert this macro
	
	.macro	LOG_REGS	the_pc
	move.w	sr,-(a7)
	move.w	#0x\the_pc,-(a7)
	move.w	#0,-(a7)
	jbsr	osd_log_cpu
	addq.w	#4,a7
	move.w	(a7)+,sr
	.endm
	
	.macro	ENABLE_LOG_REGS
	moveq	#1,d6		| enable
	jbsr	osd_cpu_logging_control	
	.endm
	.macro	DISABLE_LOG_REGS
	moveq	#0,d6		| disable
	jbsr	osd_cpu_logging_control	
	.endm	
	.endif
	