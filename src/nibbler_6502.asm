;	map(0x0000, 0x03ff).ram();
;	map(0x0400, 0x07ff).ram().w(FUNC(fantasy_state::videoram2_w)).share("videoram2");
;	map(0x0800, 0x0bff).ram().w(FUNC(fantasy_state::videoram_w)).share("videoram");
;	map(0x0c00, 0x0fff).ram().w(FUNC(fantasy_state::colorram_w)).share("colorram");
;	map(0x1000, 0x1fff).ram().w(FUNC(fantasy_state::charram_w)).share("charram");
;	map(0x2000, 0x2000).w("crtc", FUNC(mc6845_device::address_w));
;	map(0x2001, 0x2001).w("crtc", FUNC(mc6845_device::register_w));
;	map(0x2100, 0x2102).w("snk6502", FUNC(fantasy_sound_device::sound_w));
;	map(0x2103, 0x2103).w(FUNC(fantasy_state::fantasy_flipscreen_w)); // affects both video and sound
;	map(0x2104, 0x2104).portr("IN0");
;	map(0x2105, 0x2105).portr("IN1");
;	map(0x2106, 0x2106).portr("DSW");
;	map(0x2107, 0x2107).portr("IN2");
;	map(0x2200, 0x2200).w(FUNC(fantasy_state::scrollx_w));
;	map(0x2300, 0x2300).w(FUNC(fantasy_state::scrolly_w));
;	map(0x3000, 0xffff).rom().region("maincpu", 0x3000);


flipscreen_2103 = $2103	
scroll_x_2200 = $2200
scroll_y_2300 = $2300
dsw_2106 = $2106
in0_2104 = $2104
in1_2105 = $2105
in2_2107 = $2107
sound_2100 = $2100
sound_2101 = $2101
sound_2102 = $2102
crtc_2000 = $2000
crtc_2001 = $2001

nmi_3000:    ; [global]
3000: 78       sei
3001: 4C 0E 32 jmp $320e
reset_3004:  ; [global]
3004: 78       sei
3005: 4C 00 78 jmp boot_7800

3008: 78       sei
irq_3009:    ; [global]
3009: 4C 68 30 jmp $3068

300C: 78       sei
300D: 4C 5E 4B jmp $4b5e
3010: 4C 87 3F jmp $3f87
3013: 4C 16 55 jmp $5516
3016: 4C 00 A6 jmp $a600
3019: 4C F4 5B jmp $5bf4
301C: 4C 06 59 jmp $5906

; cpu wait loop in mainloop
305F: E6 F3    inc $f3
3061: A0 11    ldy #$11
3063: 88       dey
3064: D0 FD    bne $3063
3066: F0 F7    beq $305f
3068: 78       sei
3069: 48       pha
306A: 8A       txa
306B: 48       pha
306C: 98       tya
306D: 48       pha
306E: A5 BD    lda $bd
3070: F0 02    beq $3074
3072: C6 BD    dec $bd
3074: A9 00    lda #$00
3076: 8D 00 22 sta scroll_x_2200		; no scrolling
3079: 8D 00 23 sta scroll_y_2300
307C: A5 FD    lda $fd
307E: F0 33    beq $30b3
3080: A0 00    ldy #$00
3082: 88       dey
3083: D0 FD    bne $3082
3085: A9 01    lda #$01
3087: 2D 05 21 and in1_2105
308A: D0 F9    bne $3085
308C: A0 00    ldy #$00
308E: 88       dey
308F: D0 FD    bne $308e
3091: A9 08    lda #$08
3093: 2D 05 21 and in1_2105
3096: F0 03    beq $309b
3098: 20 02 4D jsr $4d02
309B: A9 02    lda #$02
309D: 2D 05 21 and in1_2105
30A0: D0 0A    bne $30ac
30A2: A9 01    lda #$01
30A4: 2D 05 21 and in1_2105
30A7: F0 E3    beq $308c
30A9: 4C C1 30 jmp $30c1
30AC: A9 00    lda #$00
30AE: 85 FD    sta $fd
30B0: 4C C1 30 jmp $30c1
30B3: A9 01    lda #$01
30B5: 2D 05 21 and in1_2105
30B8: F0 07    beq $30c1
30BA: A9 FF    lda #$ff
30BC: 85 FD    sta $fd
30BE: 4C 85 30 jmp $3085
30C1: E6 F0    inc $f0
30C3: D0 06    bne $30cb
30C5: E6 F1    inc $f1
30C7: D0 02    bne $30cb
30C9: E6 F2    inc $f2
30CB: A5 4E    lda $4e
30CD: F0 04    beq $30d3
30CF: C6 4E    dec $4e
30D1: D0 09    bne $30dc
30D3: A5 A5    lda $a5
30D5: 29 EF    and #$ef
30D7: 85 A5    sta $a5
30D9: 8D 00 21 sta sound_2100
30DC: A5 4F    lda $4f
30DE: F0 0D    beq $30ed
30E0: C6 4F    dec $4f
30E2: D0 09    bne $30ed
30E4: A5 A6    lda $a6
30E6: 29 F0    and #$f0
30E8: 85 A6    sta $a6
30EA: 8D 01 21 sta sound_2101
30ED: A5 BE    lda $be
30EF: C9 10    cmp #$10
30F1: B0 3F    bcs $3132
30F3: A5 BD    lda $bd
30F5: D0 3B    bne $3132
30F7: A9 80    lda #$80
30F9: 2D 07 21 and in2_2107
30FC: F0 14    beq $3112
30FE: A9 20    lda #$20
3100: 2D 06 21 and dsw_2106
3103: D0 06    bne $310b
3105: A5 F5    lda $f5
3107: F0 29    beq $3132
3109: 30 27    bmi $3132
310B: A9 10    lda #$10
310D: 85 BE    sta $be
310F: 4C 2A 31 jmp $312a
3112: A9 40    lda #$40
3114: 2D 07 21 and in2_2107
3117: F0 19    beq $3132
3119: A9 20    lda #$20
311B: 2D 06 21 and dsw_2106
311E: D0 06    bne $3126
3120: A5 F5    lda $f5
3122: C9 02    cmp #$02
3124: 30 0C    bmi $3132
3126: A9 20    lda #$20
3128: 85 BE    sta $be
312A: A9 FF    lda #$ff
312C: 85 FC    sta $fc
312E: 58       cli
312F: 4C 61 5B jmp $5b61
3132: A5 FC    lda $fc
3134: F0 06    beq $313c
3136: 68       pla
3137: A8       tay
3138: 68       pla
3139: AA       tax
313A: 68       pla
313B: 40       rti
313C: 68       pla
313D: 68       pla
313E: 68       pla
313F: 68       pla
3140: 68       pla
3141: 68       pla
3142: A9 01    lda #$01
3144: 2D 04 21 and in0_2104
3147: F0 06    beq $314f
3149: A9 07    lda #$07
314B: 25 F0    and $f0
314D: D0 08    bne $3157
314F: A9 FF    lda #$ff
3151: 85 FC    sta $fc
3153: 58       cli
3154: 4C 5B 31 jmp $315b
3157: 58       cli

3158: 4C 5F 30 jmp $305f
315B: A9 04    lda #$04
315D: 2D 04 21 and in0_2104
3160: F0 03    beq $3165
3162: 20 C6 4D jsr $4dc6
3165: A9 08    lda #$08
3167: 2D 04 21 and in0_2104
316A: F0 03    beq $316f
316C: 20 26 4E jsr $4e26
316F: A9 04    lda #$04
3171: 2D 05 21 and in1_2105
3174: F0 03    beq $3179
3176: 4C DE 59 jmp $59de
3179: A5 4D    lda $4d
317B: F0 0D    beq $318a
317D: C6 4D    dec $4d
317F: D0 09    bne $318a
3181: A5 A5    lda $a5
3183: 29 F0    and #$f0
3185: 85 A5    sta $a5
3187: 8D 00 21 sta sound_2100
318A: C6 A4    dec $a4
318C: 10 17    bpl $31a5
318E: A9 1E    lda #$1e
3190: 85 A4    sta $a4
3192: C6 A3    dec $a3
3194: D0 0F    bne $31a5
3196: A5 5A    lda $5a
3198: F0 05    beq $319f
319A: E6 A3    inc $a3
319C: 4C A5 31 jmp $31a5
319F: 20 72 39 jsr $3972
31A2: 20 16 55 jsr $5516
31A5: 20 32 35 jsr $3532
31A8: 20 72 39 jsr $3972
31AB: A5 BA    lda $ba
31AD: D0 03    bne $31b2
31AF: 20 99 32 jsr $3299
31B2: A4 BC    ldy $bc
31B4: A9 04    lda #$04
31B6: 2D 06 21 and dsw_2106
31B9: D0 17    bne $31d2
31BB: C0 02    cpy #$02
31BD: D0 07    bne $31c6
31BF: A5 F0    lda $f0
31C1: 29 01    and #$01
31C3: D0 07    bne $31cc
31C5: 88       dey
31C6: C0 1F    cpy #$1f
31C8: 90 02    bcc $31cc
31CA: A0 1F    ldy #$1f
31CC: B9 91 33 lda $3391, y
31CF: 4C DB 31 jmp $31db
31D2: C0 0E    cpy #$0e
31D4: 90 02    bcc $31d8
31D6: A0 0E    ldy #$0e
31D8: B9 B2 33 lda $33b2, y
31DB: 85 59    sta $59
31DD: A9 00    lda #$00
31DF: 18       clc
31E0: A4 FB    ldy $fb
31E2: 65 59    adc $59
31E4: 88       dey
31E5: D0 FB    bne $31e2
31E7: 85 5F    sta $5f
31E9: A9 08    lda #$08
31EB: 2D 05 21 and in1_2105
31EE: F0 03    beq $31f3
31F0: 20 02 4D jsr $4d02
31F3: A9 08    lda #$08
31F5: 2D 05 21 and in1_2105
31F8: F0 11    beq $320b
31FA: A9 BF    lda #$bf
31FC: 85 17    sta $17
31FE: A9 04    lda #$04
3200: 85 18    sta $18
3202: A5 F3    lda $f3
3204: A0 00    ldy #$00
3206: 84 F3    sty $f3
3208: 20 00 4C jsr $4c00
320B: 4C A7 39 jmp $39a7
320E: 48       pha
320F: A5 BD    lda $bd
3211: F0 02    beq $3215
3213: 68       pla
3214: 40       rti
3215: A9 0A    lda #$0a
3217: 85 BD    sta $bd
3219: 8A       txa
321A: 48       pha
321B: 98       tya
321C: 48       pha
321D: A5 17    lda $17
321F: 48       pha
3220: A5 18    lda $18
3222: 48       pha
3223: A5 19    lda $19
3225: 48       pha
3226: A5 1A    lda $1a
3228: 48       pha
3229: E6 F4    inc $f4
322B: A9 03    lda #$03
322D: 25 F4    and $f4
322F: 85 17    sta $17
3231: A9 C0    lda #$c0
3233: 2D 06 21 and dsw_2106
3236: 4A       lsr a
3237: 4A       lsr a
3238: 4A       lsr a
3239: 4A       lsr a
323A: 18       clc
323B: 65 17    adc $17
323D: AA       tax
323E: BD 89 32 lda $3289, x
3241: 18       clc
3242: 65 F5    adc $f5
3244: 85 F5    sta $f5
3246: C9 09    cmp #$09
3248: 30 04    bmi $324e
324A: A9 09    lda #$09
324C: 85 F5    sta $f5
324E: 29 07    and #$07
3250: 0A       asl a
3251: 0A       asl a
3252: 0A       asl a
3253: 0A       asl a
3254: 85 17    sta $17
3256: A5 A8    lda $a8
3258: 29 88    and #$88
325A: 05 17    ora $17
325C: 85 A8    sta $a8
325E: 8D 03 21 sta flipscreen_2103
3261: A5 A5    lda $a5
3263: 29 EF    and #$ef
3265: 8D 00 21 sta sound_2100
3268: 09 10    ora #$10
326A: 85 A5    sta $a5
326C: 8D 00 21 sta sound_2100
326F: A9 40    lda #$40
3271: 85 4E    sta $4e
3273: 20 8A 4C jsr $4c8a
3276: 68       pla
3277: 85 1A    sta $1a
3279: 68       pla
327A: 85 19    sta $19
327C: 68       pla
327D: 85 18    sta $18
327F: 68       pla
3280: 85 17    sta $17
3282: 68       pla
3283: A8       tay
3284: 68       pla
3285: AA       tax
3286: 68       pla
3287: 58       cli
3288: 40       rti

3299: A9 00    lda #$00
329B: 85 A5    sta $a5
329D: 8D 00 21 sta sound_2100
32A0: 85 A6    sta $a6
32A2: 8D 01 21 sta sound_2101
32A5: A5 A8    lda $a8
32A7: 29 80    and #$80
32A9: 85 A8    sta $a8
32AB: 8D 03 21 sta flipscreen_2103
32AE: A5 BC    lda $bc
32B0: F0 03    beq $32b5
32B2: 20 DC 38 jsr $38dc
32B5: 20 24 4B jsr $4b24
32B8: E6 BC    inc $bc
32BA: A5 BC    lda $bc
32BC: C9 64    cmp #$64
32BE: 30 04    bmi $32c4
32C0: A9 50    lda #$50
32C2: 85 BC    sta $bc
32C4: A0 00    ldy #$00
32C6: A9 00    lda #$00
32C8: 85 17    sta $17
32CA: A9 0C    lda #$0c
32CC: 85 18    sta $18
32CE: A9 2D    lda #$2d
32D0: 91 17    sta ($17), y   ; [video_address]
32D2: 88       dey
32D3: D0 FB    bne $32d0
32D5: E6 18    inc $18
32D7: A5 18    lda $18
32D9: C9 10    cmp #$10
32DB: D0 F1    bne $32ce
32DD: A5 BC    lda $bc
32DF: 29 1F    and #$1f
32E1: 0A       asl a
32E2: A8       tay
32E3: B9 C2 33 lda $33c2, y
32E6: 85 F9    sta $f9
32E8: B9 C3 33 lda $33c3, y
32EB: 85 FA    sta $fa
32ED: 20 1E 4C jsr $4c1e
32F0: 20 EE 5C jsr $5cee
32F3: A4 BC    ldy $bc
32F5: A9 04    lda #$04
32F7: 2D 06 21 and dsw_2106
32FA: D0 0C    bne $3308
32FC: C0 1F    cpy #$1f
32FE: 90 02    bcc $3302
3300: A0 1F    ldy #$1f
3302: B9 91 33 lda $3391, y
3305: 4C 11 33 jmp $3311
3308: C0 0E    cpy #$0e
330A: 90 02    bcc $330e
330C: A0 0E    ldy #$0e
330E: B9 B2 33 lda $33b2, y
3311: 85 59    sta $59
3313: 20 FA 5D jsr $5dfa
3316: A9 3C    lda #$3c
3318: 85 A4    sta $a4
331A: A5 BC    lda $bc
331C: 29 1F    and #$1f
331E: A8       tay
331F: B9 02 34 lda $3402, y
3322: 85 A3    sta $a3
3324: A5 BE    lda $be
3326: C9 30    cmp #$30
3328: 30 0B    bmi $3335
332A: B9 71 33 lda $3371, y
332D: 18       clc
332E: 65 B1    adc $b1
3330: 85 B1    sta $b1
3332: 4C 3D 33 jmp $333d
3335: B9 71 33 lda $3371, y
3338: 18       clc
3339: 65 B0    adc $b0
333B: 85 B0    sta $b0
333D: A5 F0    lda $f0
333F: 29 C0    and #$c0
3341: 85 F0    sta $f0
3343: 20 EE 35 jsr $35ee
3346: 20 32 35 jsr $3532
3349: 20 72 39 jsr $3972
334C: A9 00    lda #$00
334E: 85 28    sta $28
3350: 85 29    sta $29
3352: 20 AB 49 jsr $49ab
3355: 20 00 AA jsr $aa00
3358: A5 BE    lda $be
335A: C9 10    cmp #$10
335C: 90 12    bcc $3370
335E: A9 10    lda #$10
3360: 2D 06 21 and dsw_2106
3363: F0 0B    beq $3370
3365: A9 10    lda #$10
3367: 2D 04 21 and in0_2104
336A: D0 04    bne $3370
336C: A9 00    lda #$00
336E: 85 BA    sta $ba
3370: 60       rts

3422: A9 08    lda #$08
3424: 85 BB    sta $bb
3426: A0 00    ldy #$00
3428: A9 30    lda #$30
342A: 91 2D    sta ($2d), y
342C: A5 BE    lda $be
342E: C9 10    cmp #$10
3430: B0 01    bcs $3433
3432: 60       rts
3433: A9 01    lda #$01
3435: 8D 01 21 sta sound_2101
3438: A9 09    lda #$09
343A: 8D 01 21 sta sound_2101
343D: 85 4F    sta $4f
343F: 08       php
3440: D8       cld
3441: A4 BC    ldy $bc
3443: A5 BE    lda $be
3445: C9 30    cmp #$30
3447: 30 1E    bmi $3467
3449: B9 90 34 lda $3490, y
344C: F8       sed
344D: 18       clc
344E: 65 B6    adc $b6
3450: 85 B6    sta $b6
3452: A5 B7    lda $b7
3454: 69 00    adc #$00
3456: 85 B7    sta $b7
3458: A5 B8    lda $b8
345A: 69 00    adc #$00
345C: 85 B8    sta $b8
345E: A5 B9    lda $b9
3460: 69 00    adc #$00
3462: 85 B9    sta $b9
3464: 4C 82 34 jmp $3482
3467: B9 90 34 lda $3490, y
346A: F8       sed
346B: 18       clc
346C: 65 B2    adc $b2
346E: 85 B2    sta $b2
3470: A5 B3    lda $b3
3472: 69 00    adc #$00
3474: 85 B3    sta $b3
3476: A5 B4    lda $b4
3478: 69 00    adc #$00
347A: 85 B4    sta $b4
347C: A5 B5    lda $b5
347E: 69 00    adc #$00
3480: 85 B5    sta $b5
3482: D8       cld
3483: A5 BA    lda $ba
3485: D0 05    bne $348c
3487: A9 9D    lda #$9d
3489: 4C 87 3F jmp $3f87
348C: C6 BA    dec $ba
348E: 28       plp
348F: 60       rts

34F6: 08       php
34F7: D8       cld
34F8: A5 BC    lda $bc
34FA: 0A       asl a
34FB: C9 63    cmp #$63
34FD: 90 02    bcc $3501
34FF: A9 63    lda #$63
3501: A8       tay
3502: B9 90 34 lda $3490, y
3505: F8       sed
3506: 18       clc
3507: 65 B2    adc $b2
3509: 85 B2    sta $b2
350B: A5 B3    lda $b3
350D: 69 00    adc #$00
350F: 85 B3    sta $b3
3511: A5 B4    lda $b4
3513: 69 00    adc #$00
3515: 85 B4    sta $b4
3517: A5 B5    lda $b5
3519: 69 00    adc #$00
351B: 85 B5    sta $b5
351D: D8       cld
351E: C6 BA    dec $ba
3520: A0 00    ldy #$00
3522: A9 30    lda #$30
3524: 91 2D    sta ($2d), y
3526: A5 57    lda $57
3528: C5 58    cmp $58
352A: F0 04    beq $3530
352C: A9 FF    lda #$ff
352E: 85 BF    sta $bf
3530: 28       plp
3531: 60       rts
3532: A9 FF    lda #$ff
3534: 85 CB    sta $cb
3536: A9 00    lda #$00
3538: 85 CA    sta $ca
353A: A5 B2    lda $b2
353C: 20 90 4B jsr $4b90
353F: 86 C9    stx $c9
3541: 85 C8    sta $c8
3543: A5 B3    lda $b3
3545: 20 90 4B jsr $4b90
3548: 86 C6    stx $c6
354A: 85 C5    sta $c5
354C: A5 B4    lda $b4
354E: 20 90 4B jsr $4b90
3551: 86 C4    stx $c4
3553: 85 C2    sta $c2
3555: A5 B5    lda $b5
3557: 20 90 4B jsr $4b90
355A: 86 C1    stx $c1
355C: 85 C0    sta $c0
355E: A9 27    lda #$27
3560: 85 C3    sta $c3
3562: 85 C7    sta $c7
3564: A2 00    ldx #$00
3566: B5 C0    lda $c0, x
3568: F0 04    beq $356e
356A: C9 27    cmp #$27
356C: D0 09    bne $3577
356E: A9 30    lda #$30
3570: 95 C0    sta $c0, x
3572: E8       inx
3573: E0 0A    cpx #$0a
3575: D0 EF    bne $3566
3577: A9 C0    lda #$c0
3579: 85 17    sta $17
357B: A9 06    lda #$06
357D: 85 18    sta $18
357F: A9 C0    lda #$c0
3581: 85 19    sta $19
3583: A9 00    lda #$00
3585: 85 1A    sta $1a
3587: 20 6E 4B jsr write_text_4b6e
358A: A5 BE    lda $be
358C: C9 10    cmp #$10
358E: 30 05    bmi $3595
3590: C9 20    cmp #$20
3592: 10 01    bpl $3595
3594: 60       rts
3595: A9 FF    lda #$ff
3597: 85 CB    sta $cb
3599: A9 00    lda #$00
359B: 85 CA    sta $ca
359D: A5 B6    lda $b6
359F: 20 90 4B jsr $4b90
35A2: 86 C9    stx $c9
35A4: 85 C8    sta $c8
35A6: A5 B7    lda $b7
35A8: 20 90 4B jsr $4b90
35AB: 86 C6    stx $c6
35AD: 85 C5    sta $c5
35AF: A5 B8    lda $b8
35B1: 20 90 4B jsr $4b90
35B4: 86 C4    stx $c4
35B6: 85 C2    sta $c2
35B8: A5 B9    lda $b9
35BA: 20 90 4B jsr $4b90
35BD: 86 C1    stx $c1
35BF: 85 C0    sta $c0
35C1: A9 27    lda #$27
35C3: 85 C3    sta $c3
35C5: 85 C7    sta $c7
35C7: A2 00    ldx #$00
35C9: B5 C0    lda $c0, x
35CB: F0 04    beq $35d1
35CD: C9 27    cmp #$27
35CF: D0 09    bne $35da
35D1: A9 30    lda #$30
35D3: 95 C0    sta $c0, x
35D5: E8       inx
35D6: E0 0A    cpx #$0a
35D8: D0 EF    bne $35c9
35DA: A9 C1    lda #$c1
35DC: 85 17    sta $17
35DE: A9 06    lda #$06
35E0: 85 18    sta $18
35E2: A9 C0    lda #$c0
35E4: 85 19    sta $19
35E6: A9 00    lda #$00
35E8: 85 1A    sta $1a
35EA: 20 6E 4B jsr write_text_4b6e
35ED: 60       rts
35EE: A5 BE    lda $be
35F0: C9 10    cmp #$10
35F2: 30 19    bmi $360d
35F4: C9 20    cmp #$20
35F6: 10 15    bpl $360d
35F8: A9 2E    lda #$2e
35FA: 8D 80 04 sta $0480
35FD: A9 2D    lda #$2d
35FF: 8D A0 04 sta $04a0
3602: A9 CC    lda #$cc
3604: 85 19    sta $19
3606: A9 38    lda #$38
3608: 85 1A    sta $1a
360A: 4C 25 36 jmp $3625
360D: A9 2E    lda #$2e
360F: 8D 80 04 sta $0480
3612: 8D 81 04 sta $0481
3615: A9 2D    lda #$2d
3617: 8D A0 04 sta $04a0
361A: 8D A1 04 sta $04a1
361D: A9 B6    lda #$b6
361F: 85 19    sta $19
3621: A9 38    lda #$38
3623: 85 1A    sta $1a
3625: A2 03    ldx #$03
3627: A9 00    lda #$00
3629: 85 17    sta $17
362B: A9 07    lda #$07
362D: 85 18    sta $18
362F: A0 03    ldy #$03
3631: B1 19    lda ($19), y
3633: 91 17    sta ($17), y   ; [video_address]
3635: 88       dey
3636: 10 F9    bpl $3631
3638: A5 17    lda $17
363A: 18       clc
363B: 69 20    adc #$20
363D: 85 17    sta $17
363F: A5 18    lda $18
3641: 69 00    adc #$00
3643: 85 18    sta $18
3645: A5 19    lda $19
3647: 18       clc
3648: 69 04    adc #$04
364A: 85 19    sta $19
364C: A5 1A    lda $1a
364E: 69 00    adc #$00
3650: 85 1A    sta $1a
3652: CA       dex
3653: 10 DA    bpl $362f
3655: A0 00    ldy #$00
3657: A9 03    lda #$03
3659: 85 16    sta $16
365B: A9 05    lda #$05
365D: 85 1F    sta $1f
365F: A5 BE    lda $be
3661: C9 08    cmp #$08
3663: F0 04    beq $3669
3665: C9 30    cmp #$30
3667: 30 08    bmi $3671
3669: A9 02    lda #$02
366B: 85 16    sta $16
366D: A9 02    lda #$02
366F: 85 1F    sta $1f
3671: A9 20    lda #$20
3673: 85 17    sta $17
3675: A9 0C    lda #$0c
3677: 85 18    sta $18
3679: A2 01    ldx #$01
367B: A5 16    lda $16
367D: 91 17    sta ($17), y   ; [video_address]
367F: A5 17    lda $17
3681: 18       clc
3682: 69 20    adc #$20
3684: 85 17    sta $17
3686: A5 18    lda $18
3688: 69 00    adc #$00
368A: 85 18    sta $18
368C: CA       dex
368D: 10 EC    bpl $367b
368F: A5 17    lda $17
3691: 18       clc
3692: 69 20    adc #$20
3694: 85 17    sta $17
3696: A5 18    lda $18
3698: 69 00    adc #$00
369A: 85 18    sta $18
369C: A2 01    ldx #$01
369E: A5 1F    lda $1f
36A0: 91 17    sta ($17), y   ; [video_address]
36A2: A5 17    lda $17
36A4: 18       clc
36A5: 69 20    adc #$20
36A7: 85 17    sta $17
36A9: A5 18    lda $18
36AB: 69 00    adc #$00
36AD: 85 18    sta $18
36AF: CA       dex
36B0: 10 EC    bpl $369e
36B2: A5 17    lda $17
36B4: 18       clc
36B5: 69 C0    adc #$c0
36B7: 85 17    sta $17
36B9: A5 18    lda $18
36BB: 69 00    adc #$00
36BD: 85 18    sta $18
36BF: A2 0A    ldx #$0a
36C1: A5 16    lda $16
36C3: 91 17    sta ($17), y   ; [video_address]
36C5: A5 17    lda $17
36C7: 18       clc
36C8: 69 20    adc #$20
36CA: 85 17    sta $17
36CC: A5 18    lda $18
36CE: 69 00    adc #$00
36D0: 85 18    sta $18
36D2: CA       dex
36D3: 10 EC    bpl $36c1
36D5: A5 17    lda $17
36D7: 18       clc
36D8: 69 20    adc #$20
36DA: 85 17    sta $17
36DC: A5 18    lda $18
36DE: 69 00    adc #$00
36E0: 85 18    sta $18
36E2: A2 03    ldx #$03
36E4: A5 1F    lda $1f
36E6: 91 17    sta ($17), y   ; [video_address]
36E8: A5 17    lda $17
36EA: 18       clc
36EB: 69 20    adc #$20
36ED: 85 17    sta $17
36EF: A5 18    lda $18
36F1: 69 00    adc #$00
36F3: 85 18    sta $18
36F5: CA       dex
36F6: 10 EC    bpl $36e4
36F8: C0 01    cpy #$01
36FA: F0 23    beq $371f
36FC: A9 03    lda #$03
36FE: 85 16    sta $16
3700: A9 05    lda #$05
3702: 85 1F    sta $1f
3704: A5 BE    lda $be
3706: C9 07    cmp #$07
3708: F0 08    beq $3712
370A: C9 10    cmp #$10
370C: 30 0C    bmi $371a
370E: C9 30    cmp #$30
3710: 10 08    bpl $371a
3712: A9 02    lda #$02
3714: 85 16    sta $16
3716: A9 02    lda #$02
3718: 85 1F    sta $1f
371A: A0 01    ldy #$01
371C: 4C 71 36 jmp $3671
371F: A0 00    ldy #$00
3721: A9 23    lda #$23
3723: 85 17    sta $17
3725: A9 0C    lda #$0c
3727: 85 18    sta $18
3729: A2 03    ldx #$03
372B: A9 03    lda #$03
372D: 91 17    sta ($17), y   ; [video_address]
372F: A5 17    lda $17
3731: 18       clc
3732: 69 20    adc #$20
3734: 85 17    sta $17
3736: A5 18    lda $18
3738: 69 00    adc #$00
373A: 85 18    sta $18
373C: CA       dex
373D: 10 EC    bpl $372b
373F: A2 03    ldx #$03
3741: A9 05    lda #$05
3743: 91 17    sta ($17), y   ; [video_address]
3745: A5 17    lda $17
3747: 18       clc
3748: 69 20    adc #$20
374A: 85 17    sta $17
374C: A5 18    lda $18
374E: 69 00    adc #$00
3750: 85 18    sta $18
3752: CA       dex
3753: 10 EC    bpl $3741
3755: A5 17    lda $17
3757: 18       clc
3758: 69 60    adc #$60
375A: 85 17    sta $17
375C: A5 18    lda $18
375E: 69 00    adc #$00
3760: 85 18    sta $18
3762: A2 0A    ldx #$0a
3764: A9 01    lda #$01
3766: 91 17    sta ($17), y   ; [video_address]
3768: A5 17    lda $17
376A: 18       clc
376B: 69 20    adc #$20
376D: 85 17    sta $17
376F: A5 18    lda $18
3771: 69 00    adc #$00
3773: 85 18    sta $18
3775: CA       dex
3776: 10 EC    bpl $3764
3778: A5 17    lda $17
377A: 18       clc
377B: 69 20    adc #$20
377D: 85 17    sta $17
377F: A5 18    lda $18
3781: 69 00    adc #$00
3783: 85 18    sta $18
3785: A2 03    ldx #$03
3787: A9 06    lda #$06
3789: 91 17    sta ($17), y   ; [video_address]
378B: A5 17    lda $17
378D: 18       clc
378E: 69 20    adc #$20
3790: 85 17    sta $17
3792: A5 18    lda $18
3794: 69 00    adc #$00
3796: 85 18    sta $18
3798: CA       dex
3799: 10 EC    bpl $3787
379B: A9 1D    lda #$1d
379D: 8D 03 05 sta $0503
37A0: A9 12    lda #$12
37A2: 8D E3 04 sta $04e3
37A5: A9 16    lda #$16
37A7: 8D C3 04 sta $04c3
37AA: A9 0E    lda #$0e
37AC: 8D A3 04 sta $04a3
37AF: A9 FF    lda #$ff
37B1: 85 CB    sta $cb
37B3: A9 00    lda #$00
37B5: 85 CA    sta $ca
37B7: AD 90 02 lda $0290
37BA: 20 90 4B jsr $4b90
37BD: 86 C9    stx $c9
37BF: 85 C8    sta $c8
37C1: AD 91 02 lda $0291
37C4: 20 90 4B jsr $4b90
37C7: 86 C6    stx $c6
37C9: 85 C5    sta $c5
37CB: AD 92 02 lda $0292
37CE: 20 90 4B jsr $4b90
37D1: 86 C4    stx $c4
37D3: 85 C2    sta $c2
37D5: AD 93 02 lda $0293
37D8: 20 90 4B jsr $4b90
37DB: 86 C1    stx $c1
37DD: 85 C0    sta $c0
37DF: A9 27    lda #$27
37E1: 85 C3    sta $c3
37E3: 85 C7    sta $c7
37E5: A2 00    ldx #$00
37E7: B5 C0    lda $c0, x
37E9: F0 04    beq $37ef
37EB: C9 27    cmp #$27
37ED: D0 09    bne $37f8
37EF: A9 30    lda #$30
37F1: 95 C0    sta $c0, x
37F3: E8       inx
37F4: E0 0A    cpx #$0a
37F6: D0 EF    bne $37e7
37F8: A9 C3    lda #$c3
37FA: 85 17    sta $17
37FC: A9 06    lda #$06
37FE: 85 18    sta $18
3800: A9 C0    lda #$c0
3802: 85 19    sta $19
3804: A9 00    lda #$00
3806: 85 1A    sta $1a
3808: 20 6E 4B jsr write_text_4b6e
380B: A9 40    lda #$40
380D: 85 17    sta $17
380F: A9 04    lda #$04
3811: 85 18    sta $18
3813: A4 B0    ldy $b0
3815: B9 90 34 lda $3490, y
3818: 20 00 4C jsr $4c00
381B: A5 BE    lda $be
381D: C9 10    cmp #$10
381F: 30 04    bmi $3825
3821: C9 20    cmp #$20
3823: 30 10    bmi $3835
3825: A9 41    lda #$41
3827: 85 17    sta $17
3829: A9 04    lda #$04
382B: 85 18    sta $18
382D: A4 B1    ldy $b1
382F: B9 90 34 lda $3490, y
3832: 20 00 4C jsr $4c00
3835: A9 C0    lda #$c0
3837: 85 19    sta $19
3839: A9 00    lda #$00
383B: 85 1A    sta $1a
383D: A0 05    ldy #$05
383F: B9 C6 38 lda $38c6, y		; "WAVE"
3842: 99 C0 00 sta $00c0, y
3845: 88       dey
3846: 10 F7    bpl $383f
3848: A5 BC    lda $bc
384A: 85 16    sta $16
384C: C9 64    cmp #$64
384E: 90 18    bcc $3868
3850: 38       sec
3851: E9 64    sbc #$64
3853: 85 16    sta $16
3855: A9 01    lda #$01
3857: 85 C5    sta $c5
3859: A5 16    lda $16
385B: C9 64    cmp #$64
385D: 90 09    bcc $3868
385F: 38       sec
3860: E9 64    sbc #$64
3862: 85 16    sta $16
3864: A9 02    lda #$02
3866: 85 C5    sta $c5
3868: A4 16    ldy $16
386A: B9 90 34 lda $3490, y
386D: 20 90 4B jsr $4b90
3870: 85 C6    sta $c6
3872: 86 C7    stx $c7
3874: A9 FF    lda #$ff
3876: 85 C8    sta $c8
3878: A5 BC    lda $bc
387A: C9 0A    cmp #$0a
387C: B0 08    bcs $3886
387E: A5 C6    lda $c6
3880: D0 04    bne $3886
3882: A9 30    lda #$30
3884: 85 C6    sta $c6
3886: A9 3F    lda #$3f
3888: 85 17    sta $17
388A: A9 06    lda #$06
388C: 85 18    sta $18
; write "WAVE" plus wave number
388E: 20 6E 4B jsr write_text_4b6e
3891: A9 1F    lda #$1f
3893: 85 17    sta $17
3895: A9 0C    lda #$0c
3897: 85 18    sta $18
3899: A0 00    ldy #$00
389B: A9 03    lda #$03
389D: 91 17    sta ($17), y   ; [video_address]
389F: A5 17    lda $17
38A1: 18       clc
38A2: 69 20    adc #$20
38A4: 85 17    sta $17
38A6: A5 18    lda $18
38A8: 69 00    adc #$00
38AA: 85 18    sta $18
38AC: A5 18    lda $18
38AE: C9 10    cmp #$10
38B0: 90 E9    bcc $389b
38B2: 20 8A 4C jsr $4c8a
38B5: 60       rts

38DC: A9 47    lda #$47
38DE: 8D A3 04 sta $04a3
38E1: A9 46    lda #$46
38E3: 8D C3 04 sta $04c3
38E6: A9 45    lda #$45
38E8: 8D E3 04 sta $04e3
38EB: A9 30    lda #$30
38ED: 8D 03 05 sta $0503
38F0: A9 05    lda #$05
38F2: 8D A3 0C sta $0ca3
38F5: 8D C3 0C sta $0cc3
38F8: 8D E3 0C sta $0ce3
38FB: 8D 03 0D sta $0d03
38FE: C6 A3    dec $a3
3900: A4 BC    ldy $bc
3902: A5 BE    lda $be
3904: C9 30    cmp #$30
3906: 90 1E    bcc $3926
3908: B9 90 34 lda $3490, y
390B: F8       sed
390C: 18       clc
390D: 65 B6    adc $b6
390F: 85 B6    sta $b6
3911: A5 B7    lda $b7
3913: 69 00    adc #$00
3915: 85 B7    sta $b7
3917: A5 B8    lda $b8
3919: 69 00    adc #$00
391B: 85 B8    sta $b8
391D: A5 B9    lda $b9
391F: 69 00    adc #$00
3921: 85 B9    sta $b9
3923: 4C 41 39 jmp $3941
3926: B9 90 34 lda $3490, y
3929: F8       sed
392A: 18       clc
392B: 65 B2    adc $b2
392D: 85 B2    sta $b2
392F: A5 B3    lda $b3
3931: 69 00    adc #$00
3933: 85 B3    sta $b3
3935: A5 B4    lda $b4
3937: 69 00    adc #$00
3939: 85 B4    sta $b4
393B: A5 B5    lda $b5
393D: 69 00    adc #$00
393F: 85 B5    sta $b5
3941: D8       cld
3942: 20 32 35 jsr $3532
3945: 20 72 39 jsr $3972
3948: A9 03    lda #$03
394A: 25 A3    and $a3
394C: D0 B0    bne $38fe
394E: A9 0A    lda #$0a
3950: 8D 01 21 sta sound_2101
3953: A9 01    lda #$01
3955: 85 18    sta $18
3957: A9 20    lda #$20
3959: 85 17    sta $17
395B: A2 00    ldx #$00
395D: CA       dex
395E: D0 FD    bne $395d
3960: C6 17    dec $17
3962: D0 F9    bne $395d
3964: C6 18    dec $18
3966: D0 F5    bne $395d
3968: A9 00    lda #$00
396A: 8D 01 21 sta sound_2101
396D: A5 A3    lda $a3
396F: D0 8D    bne $38fe
3971: 60       rts
3972: A9 FF    lda #$ff
3974: 85 C3    sta $c3
3976: A9 00    lda #$00
3978: 85 C2    sta $c2
397A: A4 A3    ldy $a3
397C: B9 90 34 lda $3490, y
397F: 20 90 4B jsr $4b90
3982: 86 C1    stx $c1
3984: 85 C0    sta $c0
3986: C9 00    cmp #$00
3988: D0 0A    bne $3994
398A: A9 30    lda #$30
398C: 85 C0    sta $c0
398E: E0 00    cpx #$00
3990: D0 02    bne $3994
3992: 85 C1    sta $c1
3994: A9 63    lda #$63
3996: 85 17    sta $17
3998: A9 04    lda #$04
399A: 85 18    sta $18
399C: A9 C0    lda #$c0
399E: 85 19    sta $19
39A0: A9 00    lda #$00
39A2: 85 1A    sta $1a
39A4: 4C 6E 4B jmp write_text_4b6e
39A7: E6 49    inc $49
39A9: A9 00    lda #$00
39AB: 85 31    sta $31
39AD: A5 BE    lda $be
39AF: C9 10    cmp #$10
39B1: 90 4C    bcc $39ff
39B3: A5 53    lda $53
39B5: C9 01    cmp #$01
39B7: F0 0D    beq $39c6
39B9: C9 02    cmp #$02
39BB: F0 0E    beq $39cb
39BD: C9 04    cmp #$04
39BF: F0 0F    beq $39d0
39C1: A9 04    lda #$04
39C3: 4C D2 39 jmp $39d2
39C6: A9 02    lda #$02
39C8: 4C D2 39 jmp $39d2
39CB: A9 01    lda #$01
39CD: 4C D2 39 jmp $39d2
39D0: A9 08    lda #$08
39D2: 85 30    sta $30
39D4: A9 08    lda #$08
39D6: 2D 06 21 and dsw_2106
39D9: F0 0C    beq $39e7
39DB: A5 BE    lda $be
39DD: C9 30    cmp #$30
39DF: 90 06    bcc $39e7
39E1: AD 05 21 lda in1_2105
39E4: 4C EA 39 jmp $39ea
39E7: AD 04 21 lda in0_2104
39EA: 4A       lsr a
39EB: 4A       lsr a
39EC: 4A       lsr a
39ED: 4A       lsr a
39EE: 85 31    sta $31
39F0: C5 30    cmp $30
39F2: D0 0B    bne $39ff
39F4: A9 03    lda #$03
39F6: 85 4F    sta $4f
39F8: A9 0F    lda #$0f
39FA: 85 A6    sta $a6
39FC: 8D 01 21 sta sound_2101
39FF: A9 1B    lda #$1b
3A01: 38       sec
3A02: E5 51    sbc $51
3A04: 18       clc
3A05: 2A       rol a
3A06: 2A       rol a
3A07: 2A       rol a
3A08: 2A       rol a
3A09: 85 5C    sta $5c
3A0B: A9 00    lda #$00
3A0D: 69 00    adc #$00
3A0F: 0A       asl a
3A10: 26 5C    rol $5c
3A12: 69 04    adc #$04
3A14: 85 5D    sta $5d
3A16: A9 1F    lda #$1f
3A18: 38       sec
3A19: E5 52    sbc $52
3A1B: 18       clc
3A1C: 65 5C    adc $5c
3A1E: 85 5C    sta $5c
3A20: A5 5C    lda $5c
3A22: 85 10    sta $10
3A24: A5 5D    lda $5d
3A26: 85 11    sta $11
3A28: A5 5C    lda $5c
3A2A: 85 28    sta $28
3A2C: A5 5D    lda $5d
3A2E: 38       sec
3A2F: E9 04    sbc #$04
3A31: 85 5D    sta $5d
3A33: 85 29    sta $29
3A35: A5 5C    lda $5c
3A37: 18       clc
3A38: 65 F9    adc $f9
3A3A: 85 5C    sta $5c
3A3C: A5 5D    lda $5d
3A3E: 65 FA    adc $fa
3A40: 85 5D    sta $5d
3A42: A2 00    ldx #$00
3A44: A9 0F    lda #$0f
3A46: 21 5C    and ($5c, x)
3A48: 85 17    sta $17
3A4A: A5 53    lda $53
3A4C: A2 0D    ldx #$0d
3A4E: A0 00    ldy #$00
3A50: C9 01    cmp #$01
3A52: F0 14    beq $3a68
3A54: A2 0E    ldx #$0e
3A56: A0 01    ldy #$01
3A58: C9 02    cmp #$02
3A5A: F0 0C    beq $3a68
3A5C: A2 07    ldx #$07
3A5E: A0 02    ldy #$02
3A60: C9 04    cmp #$04
3A62: F0 04    beq $3a68
3A64: A2 0B    ldx #$0b
3A66: A0 03    ldy #$03
3A68: 86 18    stx $18
3A6A: 84 1B    sty $1b
3A6C: A5 17    lda $17
3A6E: 25 18    and $18
3A70: 85 18    sta $18
3A72: 85 4B    sta $4b
3A74: 85 D1    sta $d1
3A76: A5 31    lda $31
3A78: 85 D2    sta $d2
3A7A: 25 18    and $18
3A7C: 85 17    sta $17
3A7E: 85 D3    sta $d3
3A80: A5 5E    lda $5e
3A82: D0 4B    bne $3acf
3A84: A5 17    lda $17
3A86: F0 03    beq $3a8b
3A88: 4C 66 3B jmp $3b66
3A8B: A5 53    lda $53
3A8D: 49 0F    eor #$0f
3A8F: 25 31    and $31
3A91: 25 48    and $48
3A93: 85 D4    sta $d4
3A95: F0 38    beq $3acf
3A97: 85 17    sta $17
3A99: A9 0A    lda #$0a
3A9B: 85 4A    sta $4a
3A9D: A5 10    lda $10
3A9F: 38       sec
3AA0: E9 21    sbc #$21
3AA2: 85 10    sta $10
3AA4: A5 11    lda $11
3AA6: E9 00    sbc #$00
3AA8: 85 11    sta $11
3AAA: A2 02    ldx #$02
3AAC: A0 02    ldy #$02
3AAE: A9 30    lda #$30
3AB0: 91 10    sta ($10), y
3AB2: 88       dey
3AB3: 10 FB    bpl $3ab0
3AB5: A5 10    lda $10
3AB7: 18       clc
3AB8: 69 20    adc #$20
3ABA: 85 10    sta $10
3ABC: A5 11    lda $11
3ABE: 69 00    adc #$00
3AC0: 85 11    sta $11
3AC2: CA       dex
3AC3: 10 E7    bpl $3aac
3AC5: 20 57 3F jsr $3f57
3AC8: A9 00    lda #$00
3ACA: 85 48    sta $48
3ACC: 4C 66 3B jmp $3b66
3ACF: A5 18    lda $18
3AD1: 85 48    sta $48
3AD3: C9 10    cmp #$10
3AD5: 90 05    bcc $3adc
3AD7: A9 B4    lda #$b4
3AD9: 4C 87 3F jmp $3f87
3ADC: A5 53    lda $53
3ADE: 25 18    and $18
3AE0: F0 0C    beq $3aee
3AE2: 4C FD 3A jmp $3afd

3AEE: A5 FB    lda $fb
3AF0: C9 02    cmp #$02
3AF2: 10 31    bpl $3b25
3AF4: A5 E9    lda $e9
3AF6: 18       clc
3AF7: 65 59    adc $59
3AF9: C9 05    cmp #$05
3AFB: 10 28    bpl $3b25
3AFD: A4 BC    ldy $bc
3AFF: C0 07    cpy #$07
3B01: 90 02    bcc $3b05
3B03: A0 07    ldy #$07
3B05: B9 E5 3A lda $3ae5, y
3B08: 85 4C    sta $4c
3B0A: A5 59    lda $59
3B0C: 29 07    and #$07
3B0E: 85 16    sta $16
3B10: A5 A5    lda $a5
3B12: 29 F0    and #$f0
3B14: 05 16    ora $16
3B16: 09 08    ora #$08
3B18: 85 A5    sta $a5
3B1A: 8D 00 21 sta sound_2100
3B1D: A9 54    lda #$54
3B1F: 20 4D 7F jsr $7f4d
3B22: 4C DA 4E jmp $4eda
3B25: A9 00    lda #$00
3B27: 85 BB    sta $bb
3B29: 85 5E    sta $5e
3B2B: C6 A4    dec $a4
3B2D: A5 A6    lda $a6
3B2F: 29 F0    and #$f0
3B31: 09 0C    ora #$0c
3B33: 85 A6    sta $a6
3B35: 8D 01 21 sta sound_2101
3B38: A9 02    lda #$02
3B3A: 85 4F    sta $4f
3B3C: A5 4C    lda $4c
3B3E: 30 0A    bmi $3b4a
3B40: C6 4C    dec $4c
3B42: A9 44    lda #$44
3B44: 20 4D 7F jsr $7f4d
3B47: 4C DB 4F jmp $4fdb
3B4A: A5 4B    lda $4b
3B4C: C9 01    cmp #$01
3B4E: F0 14    beq $3b64
3B50: C9 02    cmp #$02
3B52: F0 10    beq $3b64
3B54: C9 04    cmp #$04
3B56: F0 0C    beq $3b64
3B58: C9 08    cmp #$08
3B5A: F0 08    beq $3b64
3B5C: A9 51    lda #$51
3B5E: 20 4D 7F jsr $7f4d
3B61: 4C DB 4F jmp $4fdb
3B64: 85 17    sta $17
3B66: A5 18    lda $18
3B68: 85 48    sta $48
3B6A: C9 10    cmp #$10
3B6C: 90 05    bcc $3b73
3B6E: A9 B5    lda #$b5
3B70: 4C 87 3F jmp $3f87
3B73: A5 17    lda $17
3B75: 25 53    and $53
3B77: F0 0C    beq $3b85
3B79: A5 17    lda $17
3B7B: 38       sec
3B7C: E5 53    sbc $53
3B7E: 85 17    sta $17
3B80: D0 03    bne $3b85
3B82: 4C FD 3A jmp $3afd
3B85: A5 17    lda $17
3B87: 20 71 3F jsr $3f71
3B8A: A9 00    lda #$00
3B8C: 85 48    sta $48
3B8E: A5 5A    lda $5a
3B90: F0 0F    beq $3ba1
3B92: A5 17    lda $17
3B94: 48       pha
3B95: A5 1B    lda $1b
3B97: 48       pha
3B98: 20 00 AF jsr $af00
3B9B: 68       pla
3B9C: 85 1B    sta $1b
3B9E: 68       pla
3B9F: 85 17    sta $17
3BA1: A5 17    lda $17
3BA3: A0 00    ldy #$00
3BA5: C9 01    cmp #$01
3BA7: F0 17    beq $3bc0
3BA9: A0 01    ldy #$01
3BAB: C9 02    cmp #$02
3BAD: F0 11    beq $3bc0
3BAF: A0 02    ldy #$02
3BB1: C9 04    cmp #$04
3BB3: F0 0B    beq $3bc0
3BB5: A0 03    ldy #$03
3BB7: C9 08    cmp #$08
3BB9: F0 05    beq $3bc0
3BBB: A9 B6    lda #$b6
3BBD: 4C 87 3F jmp $3f87
3BC0: A5 1B    lda $1b
3BC2: 0A       asl a
3BC3: 0A       asl a
3BC4: 84 1B    sty $1b
3BC6: 18       clc
3BC7: 65 1B    adc $1b
3BC9: A8       tay
3BCA: B9 2D 3F lda $3f2d, y
3BCD: 85 3D    sta $3d
3BCF: 85 19    sta $19
3BD1: A5 17    lda $17
3BD3: 85 53    sta $53
3BD5: A5 53    lda $53
3BD7: C9 03    cmp #$03
3BD9: 10 07    bpl $3be2
3BDB: A5 51    lda $51
3BDD: 85 17    sta $17
3BDF: 4C E6 3B jmp $3be6
3BE2: A5 52    lda $52
3BE4: 85 17    sta $17
3BE6: A5 17    lda $17
3BE8: A4 57    ldy $57
3BEA: 91 E2    sta ($e2), y
3BEC: C8       iny
3BED: A5 19    lda $19
3BEF: 91 E2    sta ($e2), y
3BF1: C8       iny
3BF2: 84 57    sty $57
3BF4: A9 3F    lda #$3f
3BF6: 25 57    and $57
3BF8: 85 57    sta $57
3BFA: C5 58    cmp $58
3BFC: D0 0C    bne $3c0a
3BFE: A9 00    lda #$00
3C00: 85 BA    sta $ba
3C02: A9 09    lda #$09
3C04: 20 4D 7F jsr $7f4d
3C07: 4C DB 4F jmp $4fdb
3C0A: A9 0F    lda #$0f
3C0C: 85 5E    sta $5e
3C0E: 85 5A    sta $5a
3C10: A5 51    lda $51
3C12: 85 3B    sta $3b
3C14: A5 52    lda $52
3C16: 85 3C    sta $3c
3C18: A9 10    lda #$10
3C1A: 20 4D 7F jsr $7f4d
3C1D: A9 03    lda #$03
3C1F: 8D 01 21 sta sound_2101
3C22: A9 0B    lda #$0b
3C24: 8D 01 21 sta sound_2101
3C27: A9 04    lda #$04
3C29: 85 4F    sta $4f
3C2B: A5 53    lda $53
3C2D: C9 01    cmp #$01
3C2F: F0 1F    beq $3c50
3C31: C9 02    cmp #$02
3C33: F0 2E    beq $3c63
3C35: A9 88    lda #$88
3C37: 85 1B    sta $1b
3C39: A9 11    lda #$11
3C3B: 85 1C    sta $1c
3C3D: A9 C0    lda #$c0
3C3F: 85 17    sta $17
3C41: A9 60    lda #$60
3C43: 85 18    sta $18
3C45: A9 10    lda #$10
3C47: 85 19    sta $19
3C49: A9 63    lda #$63
3C4B: 85 1A    sta $1a
3C4D: 4C 7B 3C jmp $3c7b
3C50: A9 00    lda #$00
3C52: 85 17    sta $17
3C54: A9 6A    lda #$6a
3C56: 85 18    sta $18
3C58: A9 50    lda #$50
3C5A: 85 19    sta $19
3C5C: A9 6C    lda #$6c
3C5E: 85 1A    sta $1a
3C60: 4C 73 3C jmp $3c73
3C63: A9 60    lda #$60
3C65: 85 17    sta $17
3C67: A9 65    lda #$65
3C69: 85 18    sta $18
3C6B: A9 B0    lda #$b0
3C6D: 85 19    sta $19
3C6F: A9 67    lda #$67
3C71: 85 1A    sta $1a
3C73: A9 08    lda #$08
3C75: 85 1B    sta $1b
3C77: A9 13    lda #$13
3C79: 85 1C    sta $1c
3C7B: A9 00    lda #$00
3C7D: 85 EC    sta $ec
3C7F: A5 E9    lda $e9
3C81: 0A       asl a
3C82: A8       tay
3C83: B1 17    lda ($17), y
3C85: 85 31    sta $31
3C87: B1 19    lda ($19), y
3C89: 85 33    sta $33
3C8B: C8       iny
3C8C: B1 17    lda ($17), y
3C8E: 85 32    sta $32
3C90: B1 19    lda ($19), y
3C92: 85 34    sta $34
3C94: A5 53    lda $53
3C96: C9 08    cmp #$08
3C98: F0 1C    beq $3cb6
3C9A: A0 47    ldy #$47
3C9C: B1 31    lda ($31), y
3C9E: 91 1B    sta ($1b), y
3CA0: 88       dey
3CA1: 10 F9    bpl $3c9c
3CA3: A0 47    ldy #$47
3CA5: A5 1C    lda $1c
3CA7: 18       clc
3CA8: 69 08    adc #$08
3CAA: 85 1C    sta $1c
3CAC: B1 33    lda ($33), y
3CAE: 91 1B    sta ($1b), y
3CB0: 88       dey
3CB1: 10 F9    bpl $3cac
3CB3: 4C DF 3C jmp $3cdf
3CB6: A0 47    ldy #$47
3CB8: 84 16    sty $16
3CBA: 98       tya
3CBB: 49 07    eor #$07
3CBD: A8       tay
3CBE: B1 31    lda ($31), y
3CC0: A4 16    ldy $16
3CC2: 91 1B    sta ($1b), y
3CC4: 88       dey
3CC5: 10 F1    bpl $3cb8
3CC7: A0 47    ldy #$47
3CC9: A5 1C    lda $1c
3CCB: 18       clc
3CCC: 69 08    adc #$08
3CCE: 85 1C    sta $1c
3CD0: 84 16    sty $16
3CD2: 98       tya
3CD3: 49 07    eor #$07
3CD5: A8       tay
3CD6: B1 31    lda ($31), y
3CD8: A4 16    ldy $16
3CDA: 91 1B    sta ($1b), y
3CDC: 88       dey
3CDD: 10 F1    bpl $3cd0
3CDF: A5 53    lda $53
3CE1: C9 01    cmp #$01
3CE3: F0 12    beq $3cf7
3CE5: C9 02    cmp #$02
3CE7: F0 13    beq $3cfc
3CE9: C9 04    cmp #$04
3CEB: F0 05    beq $3cf2
3CED: E6 43    inc $43
3CEF: 4C FE 3C jmp $3cfe
3CF2: E6 42    inc $42
3CF4: 4C FE 3C jmp $3cfe
3CF7: E6 40    inc $40
3CF9: 4C FE 3C jmp $3cfe
3CFC: E6 41    inc $41
3CFE: A9 9D    lda #$9d
3D00: 85 17    sta $17
3D02: A9 3E    lda #$3e
3D04: 85 18    sta $18
3D06: A5 3D    lda $3d
3D08: 18       clc
3D09: 65 17    adc $17
3D0B: 85 17    sta $17
3D0D: A5 18    lda $18
3D0F: 69 00    adc #$00
3D11: 85 18    sta $18
3D13: A0 00    ldy #$00
3D15: B1 17    lda ($17), y
3D17: 18       clc
3D18: 65 51    adc $51
3D1A: 85 19    sta $19
3D1C: A0 08    ldy #$08
3D1E: B1 17    lda ($17), y
3D20: 18       clc
3D21: 65 52    adc $52
3D23: 85 1A    sta $1a
3D25: A0 10    ldy #$10
3D27: B1 17    lda ($17), y
3D29: 85 31    sta $31
3D2B: A0 18    ldy #$18
3D2D: B1 17    lda ($17), y
3D2F: 85 32    sta $32
3D31: A9 2D    lda #$2d
3D33: 85 1D    sta $1d
3D35: A9 3E    lda #$3e
3D37: 85 1E    sta $1e
3D39: A5 4A    lda $4a
3D3B: F0 08    beq $3d45
3D3D: A9 BD    lda #$bd
3D3F: 85 1D    sta $1d
3D41: A9 3E    lda #$3e
3D43: 85 1E    sta $1e
3D45: A5 3D    lda $3d
3D47: 0A       asl a
3D48: A8       tay
3D49: B1 1D    lda ($1d), y
3D4B: 85 1B    sta $1b
3D4D: C8       iny
3D4E: B1 1D    lda ($1d), y
3D50: 85 1C    sta $1c
3D52: A6 31    ldx $31
3D54: A5 19    lda $19
3D56: C9 1C    cmp #$1c
3D58: 90 05    bcc $3d5f
3D5A: A9 93    lda #$93
3D5C: 4C 87 3F jmp $3f87
3D5F: A9 1B    lda #$1b
3D61: 38       sec
3D62: E5 19    sbc $19
3D64: 18       clc
3D65: 2A       rol a
3D66: 2A       rol a
3D67: 2A       rol a
3D68: 2A       rol a
3D69: 85 17    sta $17
3D6B: A9 00    lda #$00
3D6D: 69 00    adc #$00
3D6F: 0A       asl a
3D70: 26 17    rol $17
3D72: 69 04    adc #$04
3D74: 85 18    sta $18
3D76: A9 1F    lda #$1f
3D78: 38       sec
3D79: E5 1A    sbc $1a
3D7B: 18       clc
3D7C: 65 17    adc $17
3D7E: 85 17    sta $17
3D80: A5 18    lda $18
3D82: C9 08    cmp #$08
3D84: 90 05    bcc $3d8b
3D86: A9 94    lda #$94
3D88: 4C 87 3F jmp $3f87
3D8B: A5 17    lda $17
3D8D: 85 1D    sta $1d
3D8F: A5 18    lda $18
3D91: 18       clc
3D92: 69 08    adc #$08
3D94: 85 1E    sta $1e
3D96: A4 32    ldy $32
3D98: B1 1B    lda ($1b), y
3D9A: 91 17    sta ($17), y   ; [video_address]
3D9C: B1 1D    lda ($1d), y
3D9E: 29 38    and #$38
3DA0: 09 03    ora #$03
3DA2: 91 1D    sta ($1d), y
3DA4: 88       dey
3DA5: 10 F1    bpl $3d98
3DA7: A5 17    lda $17
3DA9: 18       clc
3DAA: 69 20    adc #$20
3DAC: 85 17    sta $17
3DAE: A5 18    lda $18
3DB0: 69 00    adc #$00
3DB2: 85 18    sta $18
3DB4: A5 1D    lda $1d
3DB6: 18       clc
3DB7: 69 20    adc #$20
3DB9: 85 1D    sta $1d
3DBB: A5 1E    lda $1e
3DBD: 69 00    adc #$00
3DBF: 85 1E    sta $1e
3DC1: A5 32    lda $32
3DC3: 18       clc
3DC4: 69 01    adc #$01
3DC6: 18       clc
3DC7: 65 1B    adc $1b
3DC9: 85 1B    sta $1b
3DCB: A5 1C    lda $1c
3DCD: 69 00    adc #$00
3DCF: 85 1C    sta $1c
3DD1: CA       dex
3DD2: 10 C2    bpl $3d96
3DD4: A5 4A    lda $4a
3DD6: F0 52    beq $3e2a
3DD8: A5 5E    lda $5e
3DDA: 38       sec
3DDB: E9 08    sbc #$08
3DDD: 85 5E    sta $5e
3DDF: A5 53    lda $53
3DE1: C9 01    cmp #$01
3DE3: F0 0D    beq $3df2
3DE5: C9 02    cmp #$02
3DE7: F0 0E    beq $3df7
3DE9: C9 04    cmp #$04
3DEB: F0 0F    beq $3dfc
3DED: C6 51    dec $51
3DEF: 4C FE 3D jmp $3dfe
3DF2: C6 52    dec $52
3DF4: 4C FE 3D jmp $3dfe
3DF7: E6 52    inc $52
3DF9: 4C FE 3D jmp $3dfe
3DFC: E6 51    inc $51
3DFE: A9 1B    lda #$1b
3E00: 38       sec
3E01: E5 51    sbc $51
3E03: 18       clc
3E04: 2A       rol a
3E05: 2A       rol a
3E06: 2A       rol a
3E07: 2A       rol a
3E08: 85 28    sta $28
3E0A: A9 00    lda #$00
3E0C: 69 00    adc #$00
3E0E: 0A       asl a
3E0F: 26 28    rol $28
3E11: 69 04    adc #$04
3E13: 85 29    sta $29
3E15: A9 1F    lda #$1f
3E17: 38       sec
3E18: E5 52    sbc $52
3E1A: 18       clc
3E1B: 65 28    adc $28
3E1D: 85 28    sta $28
3E1F: A5 29    lda $29
3E21: 38       sec
3E22: E9 04    sbc #$04
3E24: 85 29    sta $29
3E26: A9 00    lda #$00
3E28: 85 4A    sta $4a
3E2A: 4C DA 4E jmp $4eda

3F57: A5 53    lda $53
3F59: C9 01    cmp #$01
3F5B: F0 0B    beq $3f68
3F5D: C9 02    cmp #$02
3F5F: F0 0A    beq $3f6b
3F61: C9 04    cmp #$04
3F63: F0 09    beq $3f6e
3F65: E6 51    inc $51
3F67: 60       rts
3F68: E6 52    inc $52
3F6A: 60       rts
3F6B: C6 52    dec $52
3F6D: 60       rts
3F6E: C6 51    dec $51
3F70: 60       rts
3F71: C9 01    cmp #$01
3F73: F0 11    beq $3f86
3F75: C9 02    cmp #$02
3F77: F0 0D    beq $3f86
3F79: C9 04    cmp #$04
3F7B: F0 09    beq $3f86
3F7D: C9 08    cmp #$08
3F7F: F0 05    beq $3f86
3F81: A9 B3    lda #$b3
3F83: 4C 87 3F jmp $3f87
3F86: 60       rts
3F87: 78       sei
3F88: 85 D0    sta $d0
3F8A: A9 FF    lda #$ff
3F8C: 85 FD    sta $fd
3F8E: A9 10    lda #$10
3F90: 85 17    sta $17
3F92: A9 06    lda #$06
3F94: 85 18    sta $18
3F96: A5 D0    lda $d0
3F98: A0 00    ldy #$00
3F9A: A2 00    ldx #$00
3F9C: 20 9A 4B jsr $4b9a
3F9F: 20 02 4D jsr $4d02
3FA2: A0 00    ldy #$00
3FA4: 88       dey
3FA5: D0 FD    bne $3fa4
3FA7: A9 80    lda #$80
3FA9: 2D 07 21 and in2_2107
3FAC: F0 F1    beq $3f9f
3FAE: 4C 06 59 jmp $5906

4000: 85 00    sta $00
4002: A5 00    lda $00
4004: 30 09    bmi $400f
4006: 20 24 4B jsr $4b24
4009: 20 EE 35 jsr $35ee
400C: 20 32 35 jsr $3532
400F: A5 00    lda $00
4011: 29 7F    and #$7f
4013: 0A       asl a
4014: A8       tay
4015: B9 44 44 lda $4444, y
4018: 85 01    sta $01
401A: B9 45 44 lda $4445, y
401D: 85 02    sta $02
401F: A0 00    ldy #$00
4021: B1 01    lda ($01), y
4023: 85 03    sta $03
4025: 85 09    sta $09
4027: C8       iny
4028: B1 01    lda ($01), y
402A: 85 04    sta $04
402C: 85 0A    sta $0a
402E: C8       iny
402F: B1 01    lda ($01), y
4031: 85 05    sta $05
4033: C8       iny
4034: B1 01    lda ($01), y
4036: 85 06    sta $06
4038: A5 01    lda $01
403A: 18       clc
403B: 69 04    adc #$04
403D: 85 01    sta $01
403F: A5 02    lda $02
4041: 69 00    adc #$00
4043: 85 02    sta $02
4045: A0 00    ldy #$00
4047: B1 01    lda ($01), y
4049: C9 F0    cmp #$f0
404B: 90 6D    bcc $40ba
404D: C9 FF    cmp #$ff
404F: D0 01    bne $4052
4051: 60       rts
4052: C9 F0    cmp #$f0
4054: D0 10    bne $4066
4056: A5 01    lda $01
4058: 18       clc
4059: 69 01    adc #$01
405B: 85 01    sta $01
405D: A5 02    lda $02
405F: 69 00    adc #$00
4061: 85 02    sta $02
4063: 4C 1F 40 jmp $401f
4066: C9 F1    cmp #$f1
4068: D0 16    bne $4080
406A: A9 04    lda #$04
406C: 85 18    sta $18
406E: A9 00    lda #$00
4070: 85 17    sta $17
4072: A2 00    ldx #$00
4074: CA       dex
4075: D0 FD    bne $4074
4077: C6 17    dec $17
4079: D0 F9    bne $4074
407B: C6 18    dec $18
407D: D0 F5    bne $4074
407F: 60       rts
4080: C9 F2    cmp #$f2
4082: D0 16    bne $409a
4084: A9 02    lda #$02
4086: 85 18    sta $18
4088: A9 00    lda #$00
408A: 85 17    sta $17
408C: A2 00    ldx #$00
408E: CA       dex
408F: D0 FD    bne $408e
4091: C6 17    dec $17
4093: D0 F9    bne $408e
4095: C6 18    dec $18
4097: D0 F5    bne $408e
4099: 60       rts
409A: C9 F3    cmp #$f3
409C: D0 03    bne $40a1
409E: 4C 07 41 jmp $4107
40A1: C9 F4    cmp #$f4
40A3: D0 10    bne $40b5
40A5: A5 BE    lda $be
40A7: C9 07    cmp #$07
40A9: D0 05    bne $40b0
40AB: A9 01    lda #$01
40AD: 4C BA 40 jmp $40ba
40B0: A9 02    lda #$02
40B2: 4C BA 40 jmp $40ba
40B5: A9 A2    lda #$a2
40B7: 4C 87 3F jmp $3f87
40BA: 91 03    sta ($03), y		; [video_address]
40BC: A5 03    lda $03
40BE: 85 07    sta $07
40C0: A5 04    lda $04
40C2: 18       clc
40C3: 69 08    adc #$08
40C5: 85 08    sta $08
40C7: B1 07    lda ($07), y		; [unchecked_address]
40C9: 29 F8    and #$f8
40CB: 05 05    ora $05
40CD: 91 07    sta ($07), y		; [video_address]
40CF: A5 01    lda $01
40D1: 18       clc
40D2: 69 01    adc #$01
40D4: 85 01    sta $01
40D6: A5 02    lda $02
40D8: 69 00    adc #$00
40DA: 85 02    sta $02
40DC: A5 03    lda $03
40DE: 38       sec
40DF: E9 20    sbc #$20
40E1: 85 03    sta $03
40E3: A5 04    lda $04
40E5: E9 00    sbc #$00
40E7: 85 04    sta $04
40E9: A5 04    lda $04
40EB: C9 04    cmp #$04
40ED: 10 05    bpl $40f4
40EF: A9 A3    lda #$a3
40F1: 4C 87 3F jmp $3f87
40F4: A5 06    lda $06
40F6: D0 03    bne $40fb
40F8: 4C 45 40 jmp $4045
40FB: AA       tax
40FC: A0 00    ldy #$00
40FE: 88       dey
40FF: D0 FD    bne $40fe
4101: CA       dex
4102: D0 F8    bne $40fc
4104: 4C 45 40 jmp $4045
4107: A9 44    lda #$44
4109: 85 19    sta $19
410B: A9 0F    lda #$0f
410D: 85 1A    sta $1a
410F: A2 19    ldx #$19
4111: A0 15    ldy #$15
4113: A9 04    lda #$04
4115: 91 19    sta ($19), y		; [video_address]
4117: 88       dey
4118: 10 FB    bpl $4115
411A: A5 19    lda $19
411C: 38       sec
411D: E9 20    sbc #$20
411F: 85 19    sta $19
4121: A5 1A    lda $1a
4123: E9 00    sbc #$00
4125: 85 1A    sta $1a
4127: CA       dex
4128: 10 E7    bpl $4111
412A: A0 14    ldy #$14
412C: A9 5B    lda #$5b
412E: 99 44 07 sta $0744, y
4131: 88       dey
4132: 10 FA    bpl $412e
4134: A9 5C    lda #$5c
4136: 8D 59 07 sta $0759
4139: A9 01    lda #$01
413B: 85 18    sta $18
413D: A9 20    lda #$20
413F: 85 17    sta $17
4141: A2 00    ldx #$00
4143: CA       dex
4144: D0 FD    bne $4143
4146: C6 17    dec $17
4148: D0 F9    bne $4143
414A: C6 18    dec $18
414C: D0 F5    bne $4143
414E: A9 24    lda #$24
4150: 85 19    sta $19
4152: A9 07    lda #$07
4154: 85 1A    sta $1a
4156: A9 18    lda #$18
4158: 85 16    sta $16
415A: A0 14    ldy #$14
415C: A9 5E    lda #$5e
415E: 91 19    sta ($19), y		; [video_address]
4160: 88       dey
4161: 10 FB    bpl $415e
4163: A9 5F    lda #$5f
4165: A0 15    ldy #$15
4167: 91 19    sta ($19), y		; [video_address]
4169: A9 01    lda #$01
416B: 85 18    sta $18
416D: A9 20    lda #$20
416F: 85 17    sta $17
4171: A2 00    ldx #$00
4173: CA       dex
4174: D0 FD    bne $4173
4176: C6 17    dec $17
4178: D0 F9    bne $4173
417A: C6 18    dec $18
417C: D0 F5    bne $4173
417E: A5 19    lda $19
4180: 38       sec
4181: E9 20    sbc #$20
4183: 85 19    sta $19
4185: A5 1A    lda $1a
4187: E9 00    sbc #$00
4189: 85 1A    sta $1a
418B: C6 16    dec $16
418D: 10 CB    bpl $415a
418F: A9 C5    lda #$c5
4191: 85 19    sta $19
4193: A9 42    lda #$42
4195: 85 1A    sta $1a
4197: A9 44    lda #$44
4199: 85 1B    sta $1b
419B: A9 07    lda #$07
419D: 85 1C    sta $1c
419F: A9 44    lda #$44
41A1: 85 35    sta $35
41A3: A9 0B    lda #$0b
41A5: 85 36    sta $36
41A7: A9 01    lda #$01
41A9: 85 18    sta $18
41AB: A9 20    lda #$20
41AD: 85 17    sta $17
41AF: A2 00    ldx #$00
41B1: CA       dex
41B2: D0 FD    bne $41b1
41B4: C6 17    dec $17
41B6: D0 F9    bne $41b1
41B8: C6 18    dec $18
41BA: D0 F5    bne $41b1
41BC: A0 15    ldy #$15
41BE: A5 1B    lda $1b
41C0: 85 31    sta $31
41C2: A5 1C    lda $1c
41C4: 18       clc
41C5: 69 08    adc #$08
41C7: 85 32    sta $32
41C9: A9 00    lda #$00
41CB: 91 31    sta ($31), y		; [video_address]
41CD: 88       dey
41CE: 10 FB    bpl $41cb
41D0: A0 06    ldy #$06
41D2: A9 30    lda #$30
41D4: 91 1B    sta ($1b), y		; [video_address]
41D6: 88       dey
41D7: 10 FB    bpl $41d4
41D9: A0 06    ldy #$06
41DB: B1 19    lda ($19), y
41DD: 91 35    sta ($35), y		; [video_address]
41DF: 88       dey
41E0: 10 F9    bpl $41db
41E2: A5 19    lda $19
41E4: 18       clc
41E5: 69 07    adc #$07
41E7: 85 19    sta $19
41E9: A5 1A    lda $1a
41EB: 69 00    adc #$00
41ED: 85 1A    sta $1a
41EF: A5 1B    lda $1b
41F1: 18       clc
41F2: 69 07    adc #$07
41F4: 85 1B    sta $1b
41F6: A5 1C    lda $1c
41F8: 69 00    adc #$00
41FA: 85 1C    sta $1c
41FC: A5 35    lda $35
41FE: 38       sec
41FF: E9 20    sbc #$20
4201: 85 35    sta $35
4203: A5 36    lda $36
4205: E9 00    sbc #$00
4207: 85 36    sta $36
4209: A0 00    ldy #$00
420B: B1 19    lda ($19), y
420D: F0 4F    beq $425e
420F: C9 01    cmp #$01
4211: F0 1F    beq $4232
4213: 91 1B    sta ($1b), y		; [video_address]
4215: A5 19    lda $19
4217: 18       clc
4218: 69 01    adc #$01
421A: 85 19    sta $19
421C: A5 1A    lda $1a
421E: 69 00    adc #$00
4220: 85 1A    sta $1a
4222: A5 1B    lda $1b
4224: 18       clc
4225: 69 01    adc #$01
4227: 85 1B    sta $1b
4229: A5 1C    lda $1c
422B: 69 00    adc #$00
422D: 85 1C    sta $1c
422F: 4C 0B 42 jmp $420b
4232: A5 19    lda $19
4234: 18       clc
4235: 69 01    adc #$01
4237: 85 19    sta $19
4239: A5 1A    lda $1a
423B: 69 00    adc #$00
423D: 85 1A    sta $1a
423F: A5 1B    lda $1b
4241: 85 31    sta $31
4243: A5 1C    lda $1c
4245: 18       clc
4246: 69 08    adc #$08
4248: 85 32    sta $32
424A: B1 19    lda ($19), y
424C: 91 31    sta ($31), y		; [video_address]
424E: A5 19    lda $19
4250: 18       clc
4251: 69 01    adc #$01
4253: 85 19    sta $19
4255: A5 1A    lda $1a
4257: 69 00    adc #$00
4259: 85 1A    sta $1a
425B: 4C 0B 42 jmp $420b
425E: A9 30    lda #$30
4260: 91 1B    sta ($1b), y		; [video_address]
4262: A5 1B    lda $1b
4264: 18       clc
4265: 69 01    adc #$01
4267: 85 1B    sta $1b
4269: A5 1C    lda $1c
426B: 69 00    adc #$00
426D: 85 1C    sta $1c
426F: A5 1B    lda $1b
4271: 29 0F    and #$0f
4273: C9 0A    cmp #$0a
4275: D0 E7    bne $425e
4277: A5 19    lda $19
4279: 18       clc
427A: 69 01    adc #$01
427C: 85 19    sta $19
427E: A5 1A    lda $1a
4280: 69 00    adc #$00
4282: 85 1A    sta $1a
4284: A5 1B    lda $1b
4286: 38       sec
4287: E9 36    sbc #$36
4289: 85 1B    sta $1b
428B: A5 1C    lda $1c
428D: E9 00    sbc #$00
428F: 85 1C    sta $1c
4291: A5 1C    lda $1c
4293: C9 04    cmp #$04
4295: F0 03    beq $429a
4297: 4C A7 41 jmp $41a7
429A: A5 1B    lda $1b
429C: C9 04    cmp #$04
429E: F0 03    beq $42a3
42A0: 4C A7 41 jmp $41a7
42A3: A9 03    lda #$03
42A5: 8D 65 0C sta $0c65
42A8: 8D 45 0C sta $0c45
42AB: A9 1D    lda #$1d
42AD: 8D 65 04 sta $0465
42B0: A9 16    lda #$16
42B2: 8D 45 04 sta $0445
42B5: A5 01    lda $01
42B7: 18       clc
42B8: 69 01    adc #$01
42BA: 85 01    sta $01
42BC: A5 02    lda $02
42BE: 69 00    adc #$00
42C0: 85 02    sta $02
42C2: 4C 1F 40 jmp $401f

49AB: A5 A9    lda $a9
49AD: F0 05    beq $49b4
49AF: C6 A9    dec $a9
49B1: 4C BB 49 jmp $49bb

49B4: A5 A4    lda $a4
49B6: 38       sec
49B7: E9 06    sbc #$06
49B9: 85 A4    sta $a4
49BB: A5 BC    lda $bc
49BD: 29 1F    and #$1f
49BF: 0A       asl a
49C0: A8       tay
49C1: B9 47 4A lda $4a47, y
49C4: 85 2B    sta $2b
49C6: B9 48 4A lda $4a48, y
49C9: 85 2C    sta $2c
49CB: A5 F0    lda $f0
49CD: 29 38    and #$38
49CF: 4A       lsr a
49D0: 4A       lsr a
49D1: 4A       lsr a
49D2: A8       tay
49D3: A5 BC    lda $bc
49D5: C9 13    cmp #$13
49D7: 90 07    bcc $49e0
49D9: A5 F0    lda $f0
49DB: 29 1C    and #$1c
49DD: 4A       lsr a
49DE: 4A       lsr a
49DF: A8       tay
49E0: B1 2B    lda ($2b), y
49E2: 85 2F    sta $2f
49E4: A5 BA    lda $ba
49E6: D0 04    bne $49ec
49E8: A9 30    lda #$30
49EA: 85 2F    sta $2f
49EC: A5 29    lda $29
49EE: 18       clc
49EF: 69 08    adc #$08
49F1: 85 29    sta $29
49F3: A5 BE    lda $be
49F5: C9 30    cmp #$30
49F7: 30 0B    bmi $4a04
49F9: A9 40    lda #$40
49FB: 85 2B    sta $2b
49FD: A9 03    lda #$03
49FF: 85 2C    sta $2c
4A01: 4C 0C 4A jmp $4a0c
4A04: A9 00    lda #$00
4A06: 85 2B    sta $2b
4A08: A9 03    lda #$03
4A0A: 85 2C    sta $2c
4A0C: A0 00    ldy #$00
4A0E: A2 00    ldx #$00
4A10: 4C 14 4A jmp $4a14
4A13: C8       iny
4A14: B1 2B    lda ($2b), y
4A16: 85 2D    sta $2d
4A18: C8       iny
4A19: B1 2B    lda ($2b), y
4A1B: F0 F6    beq $4a13
4A1D: 30 27    bmi $4a46
4A1F: 85 2E    sta $2e
4A21: C5 29    cmp $29
4A23: D0 06    bne $4a2b
4A25: A5 2D    lda $2d
4A27: C5 28    cmp $28
4A29: F0 07    beq $4a32
4A2B: A5 2F    lda $2f
4A2D: 81 2D    sta ($2d, x)		; [video_address]
4A2F: 4C 13 4A jmp $4a13
4A32: 84 2A    sty $2a
4A34: 20 22 34 jsr $3422
4A37: A4 2A    ldy $2a
4A39: A2 00    ldx #$00
4A3B: A9 00    lda #$00
4A3D: 91 2B    sta ($2b), y
4A3F: A9 FF    lda #$ff
4A41: 85 A9    sta $a9
4A43: 4C 13 4A jmp $4a13
4A46: 60       rts

4B07: A0 0D    ldy #$0d
4B09: 8C 00 20 sty crtc_2000
4B0C: B9 16 4B lda $4b16, y
4B0F: 8D 01 20 sta crtc_2001
4B12: 88       dey
4B13: 10 F4    bpl $4b09
4B15: 60       rts

4B24: A0 00    ldy #$00
4B26: 84 10    sty $10
4B28: A9 04    lda #$04
4B2A: 85 11    sta $11
4B2C: A9 30    lda #$30
4B2E: 91 10    sta ($10), y		; [video_address]
4B30: 88       dey
4B31: D0 FB    bne $4b2e
4B33: E6 11    inc $11
4B35: A5 11    lda $11
4B37: C9 10    cmp #$10
4B39: 90 F1    bcc $4b2c
4B3B: 60       rts
4B3C: A9 00    lda #$00
4B3E: 85 10    sta $10
4B40: 85 12    sta $12
4B42: A9 10    lda #$10
4B44: 85 11    sta $11
4B46: A9 80    lda #$80
4B48: 85 13    sta $13
4B4A: A0 00    ldy #$00
4B4C: B1 12    lda ($12), y
4B4E: 91 10    sta ($10), y
4B50: 88       dey
4B51: D0 F9    bne $4b4c
4B53: E6 11    inc $11
4B55: E6 13    inc $13
4B57: A5 11    lda $11
4B59: C9 20    cmp #$20
4B5B: 90 ED    bcc $4b4a
4B5D: 60       rts
4B5E: 20 24 4B jsr $4b24
4B61: 68       pla
4B62: 18       clc
4B63: 69 08    adc #$08
4B65: 48       pha
4B66: 4C 6E 4B jmp write_text_4b6e

4B69: A0 00    ldy #$00
4B6B: 91 17    sta ($17), y   ; [video_address]
4B6D: 60       rts

; < ($19): source ($FF terminated)
; < ($17): destination

write_text_4b6e:
4B6E: A0 00    ldy #$00
4B70: B1 19    lda ($19), y
4B72: C9 FF    cmp #$ff
4B74: F0 19    beq $4b8f
4B76: 91 17    sta ($17), y   ; [video_address]
4B78: E6 19    inc $19
4B7A: D0 02    bne $4b7e
4B7C: E6 1A    inc $1a
4B7E: A5 17    lda $17
4B80: 38       sec
4B81: E9 20    sbc #$20		; screen X++
4B83: 85 17    sta $17
4B85: A5 18    lda $18
4B87: E9 00    sbc #$00
4B89: 85 18    sta $18
4B8B: C9 04    cmp #$04
4B8D: B0 E1    bcs $4b70	; avoid overflow & write to ROM
4B8F: 60       rts

4B90: 48       pha
4B91: 29 0F    and #$0f
4B93: AA       tax
4B94: 68       pla
4B95: 4A       lsr a
4B96: 4A       lsr a
4B97: 4A       lsr a
4B98: 4A       lsr a
4B99: 60       rts
4B9A: 48       pha
4B9B: A9 FF    lda #$ff
4B9D: 85 C6    sta $c6
4B9F: 8A       txa
4BA0: 20 90 4B jsr $4b90
4BA3: 85 C2    sta $c2
4BA5: 86 C3    stx $c3
4BA7: 98       tya
4BA8: 20 90 4B jsr $4b90
4BAB: 85 C4    sta $c4
4BAD: 86 C5    stx $c5
4BAF: 68       pla
4BB0: 20 90 4B jsr $4b90
4BB3: 85 C0    sta $c0
4BB5: 86 C1    stx $c1
4BB7: A9 C0    lda #$c0
4BB9: 85 19    sta $19
4BBB: A9 00    lda #$00
4BBD: 85 1A    sta $1a
4BBF: A2 00    ldx #$00
4BC1: B5 C0    lda $c0, x
4BC3: D0 09    bne $4bce
4BC5: A9 30    lda #$30
4BC7: 95 C0    sta $c0, x
4BC9: E8       inx
4BCA: E0 05    cpx #$05
4BCC: 90 F3    bcc $4bc1
4BCE: 4C 6E 4B jmp write_text_4b6e
4BD1: 48       pha
4BD2: A9 FF    lda #$ff
4BD4: 85 C4    sta $c4
4BD6: 8A       txa
4BD7: 20 90 4B jsr $4b90
4BDA: 85 C2    sta $c2
4BDC: 86 C3    stx $c3
4BDE: 68       pla
4BDF: 20 90 4B jsr $4b90
4BE2: 85 C0    sta $c0
4BE4: 86 C1    stx $c1
4BE6: A9 C0    lda #$c0
4BE8: 85 19    sta $19
4BEA: A9 00    lda #$00
4BEC: 85 1A    sta $1a
4BEE: A2 00    ldx #$00
4BF0: B5 C0    lda $c0, x
4BF2: D0 09    bne $4bfd
4BF4: A9 30    lda #$30
4BF6: 95 C0    sta $c0, x
4BF8: E8       inx
4BF9: E0 03    cpx #$03
4BFB: 90 F3    bcc $4bf0
4BFD: 4C 6E 4B jmp write_text_4b6e
4C00: 20 90 4B jsr $4b90
4C03: 85 C0    sta $c0
4C05: 86 C1    stx $c1
4C07: A9 FF    lda #$ff
4C09: 85 C2    sta $c2
4C0B: A9 C0    lda #$c0
4C0D: 85 19    sta $19
4C0F: A9 00    lda #$00
4C11: 85 1A    sta $1a
4C13: A5 C0    lda $c0
4C15: D0 04    bne $4c1b
4C17: A9 30    lda #$30
4C19: 85 C0    sta $c0
4C1B: 4C 6E 4B jmp write_text_4b6e
4C1E: A9 00    lda #$00
4C20: 85 19    sta $19
4C22: A9 08    lda #$08
4C24: 85 1A    sta $1a
4C26: A5 F9    lda $f9
4C28: 85 17    sta $17
4C2A: A5 FA    lda $fa
4C2C: 85 18    sta $18
4C2E: A0 00    ldy #$00
4C30: B1 17    lda ($17), y
4C32: C9 40    cmp #$40
4C34: 10 02    bpl $4c38
4C36: A9 30    lda #$30
4C38: 91 19    sta ($19), y		; [video_address]
4C3A: 88       dey
4C3B: D0 F3    bne $4c30
4C3D: E6 18    inc $18
4C3F: E6 1A    inc $1a
4C41: A5 1A    lda $1a
4C43: C9 0C    cmp #$0c
4C45: 90 E9    bcc $4c30
4C47: A5 BC    lda $bc
4C49: 29 1F    and #$1f
4C4B: A8       tay
4C4C: B9 6A 4C lda $4c6a, y
4C4F: 85 19    sta $19
4C51: A9 00    lda #$00
4C53: 85 17    sta $17
4C55: A8       tay
4C56: A9 0C    lda #$0c
4C58: 85 18    sta $18
4C5A: A5 19    lda $19
4C5C: 91 17    sta ($17), y   ; [video_address]
4C5E: C8       iny
4C5F: D0 FB    bne $4c5c
4C61: E6 18    inc $18
4C63: A5 18    lda $18
4C65: C9 10    cmp #$10
4C67: D0 F1    bne $4c5a
4C69: 60       rts


4C8A: A9 20    lda #$20
4C8C: 2D 06 21 and dsw_2106
4C8F: D0 48    bne $4cd9
4C91: A9 0C    lda #$0c
4C93: 85 17    sta $17
4C95: A9 04    lda #$04
4C97: 85 18    sta $18
4C99: A9 C5    lda #$c5
4C9B: 85 19    sta $19
4C9D: A9 4C    lda #$4c
4C9F: 85 1A    sta $1a
4CA1: A0 06    ldy #$06
4CA3: B1 19    lda ($19), y
4CA5: 91 17    sta ($17), y   ; [video_address]
4CA7: 88       dey
4CA8: 10 F9    bpl $4ca3
4CAA: A0 07    ldy #$07
4CAC: A5 F5    lda $f5
4CAE: 91 17    sta ($17), y   ; [video_address]
4CB0: A9 0C    lda #$0c
4CB2: 85 17    sta $17
4CB4: A9 0C    lda #$0c
4CB6: 85 18    sta $18
4CB8: A0 08    ldy #$08
4CBA: A6 F5    ldx $f5
4CBC: BD CC 4C lda $4ccc, x
4CBF: 91 17    sta ($17), y   ; [video_address]
4CC1: 88       dey
4CC2: 10 FB    bpl $4cbf
4CC4: 60       rts

4CD9: A9 0C    lda #$0c
4CDB: 85 17    sta $17
4CDD: A9 04    lda #$04
4CDF: 85 18    sta $18
4CE1: A9 F9    lda #$f9
4CE3: 85 19    sta $19
4CE5: A9 4C    lda #$4c
4CE7: 85 1A    sta $1a
4CE9: A0 08    ldy #$08
4CEB: B1 19    lda ($19), y
4CED: 91 17    sta ($17), y   ; [video_address]
4CEF: 88       dey
4CF0: 10 F9    bpl $4ceb
4CF2: A9 02    lda #$02
4CF4: 85 F5    sta $f5
4CF6: 4C B0 4C jmp $4cb0

4D02: A0 00    ldy #$00
4D04: A9 08    lda #$08
4D06: 39 04 21 and in0_2104, y
4D09: F0 03    beq $4d0e
4D0B: 20 26 4E jsr $4e26
4D0E: A0 01    ldy #$01
4D10: A9 40    lda #$40
4D12: 31 E0    and ($e0), y		; [unchecked_address] (ports)
4D14: F0 02    beq $4d18
4D16: C6 DF    dec $df
4D18: A9 80    lda #$80
4D1A: 31 E0    and ($e0), y		; [unchecked_address] (ports)
4D1C: F0 02    beq $4d20
4D1E: E6 DF    inc $df
4D20: A9 0F    lda #$0f
4D22: 25 DF    and $df
4D24: A8       tay
4D25: A2 00    ldx #$00
4D27: A9 E0    lda #$e0
4D29: 85 17    sta $17
4D2B: A9 04    lda #$04
4D2D: 85 18    sta $18
4D2F: A9 00    lda #$00
4D31: 20 9A 4B jsr $4b9a
4D34: A9 E3    lda #$e3
4D36: 85 1B    sta $1b
4D38: A9 04    lda #$04
4D3A: 85 1C    sta $1c
4D3C: A9 0F    lda #$0f
4D3E: 25 DF    and $df
4D40: 0A       asl a
4D41: 0A       asl a
4D42: 0A       asl a
4D43: 0A       asl a
4D44: 85 10    sta $10
4D46: A9 00    lda #$00
4D48: 85 11    sta $11
4D4A: A5 1B    lda $1b
4D4C: 85 17    sta $17
4D4E: A5 1C    lda $1c
4D50: 85 18    sta $18
4D52: A0 00    ldy #$00
4D54: B1 10    lda ($10), y
4D56: A8       tay
4D57: A2 00    ldx #$00
4D59: A9 00    lda #$00
4D5B: 20 9A 4B jsr $4b9a
4D5E: A5 1B    lda $1b
4D60: C9 F2    cmp #$f2
4D62: F0 07    beq $4d6b
4D64: E6 1B    inc $1b
4D66: E6 10    inc $10
4D68: 4C 4A 4D jmp $4d4a
4D6B: A0 01    ldy #$01
4D6D: A9 20    lda #$20
4D6F: 31 E0    and ($e0), y		; [unchecked_address]
4D71: F0 52    beq $4dc5
4D73: A9 40    lda #$40
4D75: 85 17    sta $17
4D77: A9 05    lda #$05
4D79: 85 18    sta $18
4D7B: A4 57    ldy $57
4D7D: A2 00    ldx #$00
4D7F: A9 00    lda #$00
4D81: 20 9A 4B jsr $4b9a
4D84: A9 41    lda #$41
4D86: 85 17    sta $17
4D88: A9 05    lda #$05
4D8A: 85 18    sta $18
4D8C: A4 58    ldy $58
4D8E: A2 00    ldx #$00
4D90: A9 00    lda #$00
4D92: 20 9A 4B jsr $4b9a
4D95: A9 43    lda #$43
4D97: 85 1B    sta $1b
4D99: A9 05    lda #$05
4D9B: 85 1C    sta $1c
4D9D: A5 E2    lda $e2
4D9F: 85 10    sta $10
4DA1: A5 E3    lda $e3
4DA3: 85 11    sta $11
4DA5: A5 1B    lda $1b
4DA7: 85 17    sta $17
4DA9: A5 1C    lda $1c
4DAB: 85 18    sta $18
4DAD: A0 00    ldy #$00
4DAF: B1 10    lda ($10), y
4DB1: AA       tax
4DB2: E6 10    inc $10
4DB4: B1 10    lda ($10), y
4DB6: A8       tay
4DB7: A9 00    lda #$00
4DB9: 20 9A 4B jsr $4b9a
4DBC: E6 10    inc $10
4DBE: F0 05    beq $4dc5
4DC0: E6 1B    inc $1b
4DC2: 4C A5 4D jmp $4da5
4DC5: 60       rts
4DC6: A0 01    ldy #$01
4DC8: A9 01    lda #$01
4DCA: 39 04 21 and in0_2104, y
4DCD: F0 02    beq $4dd1
4DCF: C6 EB    dec $eb
4DD1: A9 02    lda #$02
4DD3: 39 04 21 and in0_2104, y
4DD6: F0 02    beq $4dda
4DD8: E6 EB    inc $eb
4DDA: A0 00    ldy #$00
4DDC: A9 04    lda #$04
4DDE: 39 04 21 and in0_2104, y
4DE1: D0 17    bne $4dfa
4DE3: A9 90    lda #$90
4DE5: 85 17    sta $17
4DE7: A9 05    lda #$05
4DE9: 85 18    sta $18
4DEB: A9 30    lda #$30
4DED: A0 00    ldy #$00
4DEF: 91 17    sta ($17), y   ; [video_address]
4DF1: A9 70    lda #$70
4DF3: 85 17    sta $17
4DF5: A9 30    lda #$30
4DF7: 91 17    sta ($17), y   ; [video_address]
4DF9: 60       rts
4DFA: A9 00    lda #$00
4DFC: 85 17    sta $17
4DFE: A8       tay
4DFF: A9 0C    lda #$0c
4E01: 85 18    sta $18
4E03: A5 EB    lda $eb
4E05: 91 17    sta ($17), y   ; [video_address]
4E07: C8       iny
4E08: D0 FB    bne $4e05
4E0A: E6 18    inc $18
4E0C: A5 18    lda $18
4E0E: C9 10    cmp #$10
4E10: D0 F1    bne $4e03
4E12: A9 10    lda #$10
4E14: 85 17    sta $17
4E16: A9 06    lda #$06
4E18: 85 18    sta $18
4E1A: A9 00    lda #$00
4E1C: A2 00    ldx #$00
4E1E: A4 EB    ldy $eb
4E20: 20 9A 4B jsr $4b9a
4E23: 4C C6 4D jmp $4dc6
4E26: A0 01    ldy #$01
4E28: A9 01    lda #$01
4E2A: 39 04 21 and in0_2104, y
4E2D: F0 02    beq $4e31
4E2F: C6 46    dec $46
4E31: A9 02    lda #$02
4E33: 39 04 21 and in0_2104, y
4E36: F0 02    beq $4e3a
4E38: E6 46    inc $46
4E3A: A9 10    lda #$10
4E3C: 2D 04 21 and in0_2104
4E3F: F0 0D    beq $4e4e
4E41: A5 44    lda $44
4E43: 18       clc
4E44: 69 01    adc #$01
4E46: 85 44    sta $44
4E48: A5 45    lda $45
4E4A: 69 00    adc #$00
4E4C: 85 45    sta $45
4E4E: A9 20    lda #$20
4E50: 2D 04 21 and in0_2104
4E53: F0 0D    beq $4e62
4E55: A5 44    lda $44
4E57: 38       sec
4E58: E9 01    sbc #$01
4E5A: 85 44    sta $44
4E5C: A5 45    lda $45
4E5E: E9 00    sbc #$00
4E60: 85 45    sta $45
4E62: A9 40    lda #$40
4E64: 2D 04 21 and in0_2104
4E67: F0 0D    beq $4e76
4E69: A5 44    lda $44
4E6B: 38       sec
4E6C: E9 20    sbc #$20
4E6E: 85 44    sta $44
4E70: A5 45    lda $45
4E72: E9 00    sbc #$00
4E74: 85 45    sta $45
4E76: A9 80    lda #$80
4E78: 2D 04 21 and in0_2104
4E7B: F0 0D    beq $4e8a
4E7D: A5 44    lda $44
4E7F: 18       clc
4E80: 69 20    adc #$20
4E82: 85 44    sta $44
4E84: A5 45    lda $45
4E86: 69 00    adc #$00
4E88: 85 45    sta $45
4E8A: A0 00    ldy #$00
4E8C: A9 22    lda #$22
4E8E: 85 17    sta $17
4E90: A9 06    lda #$06
4E92: 85 18    sta $18
4E94: B1 44    lda ($44), y
4E96: A8       tay
4E97: A6 44    ldx $44
4E99: A5 45    lda $45
4E9B: 20 9A 4B jsr $4b9a
4E9E: A9 42    lda #$42
4EA0: 85 17    sta $17
4EA2: A9 05    lda #$05
4EA4: 85 18    sta $18
4EA6: A5 46    lda $46
4EA8: 20 00 4C jsr $4c00
4EAB: A0 01    ldy #$01
4EAD: A9 10    lda #$10
4EAF: 39 04 21 and in0_2104, y
4EB2: F0 06    beq $4eba
4EB4: A0 00    ldy #$00
4EB6: A5 46    lda $46
4EB8: 91 44    sta ($44), y
4EBA: A9 04    lda #$04
4EBC: 2D 04 21 and in0_2104
4EBF: F0 01    beq $4ec2
4EC1: 60       rts
4EC2: A2 04    ldx #$04
4EC4: A0 01    ldy #$01
4EC6: A9 08    lda #$08
4EC8: 39 04 21 and in0_2104, y
4ECB: F0 02    beq $4ecf
4ECD: A2 80    ldx #$80
4ECF: A0 00    ldy #$00
4ED1: 88       dey
4ED2: D0 FD    bne $4ed1
4ED4: CA       dex
4ED5: D0 F8    bne $4ecf
4ED7: 4C 26 4E jmp $4e26
4EDA: A5 5E    lda $5e
4EDC: 38       sec
4EDD: E5 5F    sbc $5f
4EDF: 10 02    bpl $4ee3
4EE1: A9 00    lda #$00
4EE3: 85 5E    sta $5e
4EE5: A5 5B    lda $5b
4EE7: 38       sec
4EE8: E5 5F    sbc $5f
4EEA: 10 02    bpl $4eee
4EEC: A9 00    lda #$00
4EEE: 85 5B    sta $5b
4EF0: A9 00    lda #$00
4EF2: 85 ED    sta $ed
4EF4: A5 E9    lda $e9
4EF6: 18       clc
4EF7: 65 5F    adc $5f
4EF9: 85 E9    sta $e9
4EFB: C9 08    cmp #$08
4EFD: 30 08    bmi $4f07
4EFF: 29 07    and #$07
4F01: 85 E9    sta $e9
4F03: A9 FF    lda #$ff
4F05: 85 ED    sta $ed
4F07: 20 F4 5B jsr $5bf4
4F0A: A5 47    lda $47
4F0C: F0 0E    beq $4f1c
4F0E: A5 F0    lda $f0
4F10: 4A       lsr a
4F11: B0 09    bcs $4f1c
4F13: A5 BB    lda $bb
4F15: 30 36    bmi $4f4d
4F17: D0 34    bne $4f4d
4F19: 4C 20 4F jmp $4f20
4F1C: A5 BB    lda $bb
4F1E: D0 2D    bne $4f4d
4F20: A5 ED    lda $ed
4F22: F0 29    beq $4f4d
4F24: A5 56    lda $56
4F26: C9 01    cmp #$01
4F28: F0 1A    beq $4f44
4F2A: C9 02    cmp #$02
4F2C: F0 10    beq $4f3e
4F2E: C9 04    cmp #$04
4F30: F0 06    beq $4f38
4F32: C6 54    dec $54
4F34: D0 17    bne $4f4d
4F36: F0 10    beq $4f48
4F38: E6 54    inc $54
4F3A: D0 11    bne $4f4d
4F3C: F0 0A    beq $4f48
4F3E: E6 55    inc $55
4F40: D0 0B    bne $4f4d
4F42: F0 04    beq $4f48
4F44: C6 55    dec $55
4F46: D0 05    bne $4f4d
4F48: A9 82    lda #$82
4F4A: 4C 87 3F jmp $3f87
4F4D: A5 58    lda $58
4F4F: C5 57    cmp $57
4F51: D0 03    bne $4f56
4F53: 4C 98 4F jmp $4f98
4F56: A4 58    ldy $58
4F58: A5 56    lda $56
4F5A: C9 01    cmp #$01
4F5C: F0 20    beq $4f7e
4F5E: C9 02    cmp #$02
4F60: F0 14    beq $4f76
4F62: C9 04    cmp #$04
4F64: F0 08    beq $4f6e
4F66: B1 E2    lda ($e2), y
4F68: C5 54    cmp $54
4F6A: 30 2C    bmi $4f98
4F6C: 10 16    bpl $4f84
4F6E: A5 54    lda $54
4F70: D1 E2    cmp ($e2), y
4F72: 30 24    bmi $4f98
4F74: 10 0E    bpl $4f84
4F76: A5 55    lda $55
4F78: D1 E2    cmp ($e2), y
4F7A: 30 1C    bmi $4f98
4F7C: 10 06    bpl $4f84
4F7E: B1 E2    lda ($e2), y
4F80: C5 55    cmp $55
4F82: 30 14    bmi $4f98
4F84: 20 91 5E jsr $5e91
4F87: A9 00    lda #$00
4F89: 85 BF    sta $bf
4F8B: A4 58    ldy $58
4F8D: C8       iny
4F8E: C8       iny
4F8F: 98       tya
4F90: 29 3F    and #$3f
4F92: 85 58    sta $58
4F94: A9 0A    lda #$0a
4F96: 85 5B    sta $5b
4F98: 20 00 A6 jsr $a600
4F9B: C6 BB    dec $bb
4F9D: 10 04    bpl $4fa3
4F9F: A9 00    lda #$00
4FA1: 85 BB    sta $bb
4FA3: A5 ED    lda $ed
4FA5: F0 31    beq $4fd8
4FA7: A5 51    lda $51
4FA9: 85 31    sta $31
4FAB: A5 52    lda $52
4FAD: 85 32    sta $32
4FAF: A5 53    lda $53
4FB1: C9 01    cmp #$01
4FB3: F0 1A    beq $4fcf
4FB5: C9 02    cmp #$02
4FB7: F0 10    beq $4fc9
4FB9: C9 04    cmp #$04
4FBB: F0 06    beq $4fc3
4FBD: C6 51    dec $51
4FBF: D0 17    bne $4fd8
4FC1: F0 10    beq $4fd3
4FC3: E6 51    inc $51
4FC5: D0 11    bne $4fd8
4FC7: F0 0A    beq $4fd3
4FC9: E6 52    inc $52
4FCB: D0 0B    bne $4fd8
4FCD: F0 04    beq $4fd3
4FCF: C6 52    dec $52
4FD1: D0 05    bne $4fd8
4FD3: A9 85    lda #$85
4FD5: 4C 87 3F jmp $3f87
4FD8: 20 8F 5C jsr $5c8f
4FDB: 20 AB 49 jsr $49ab
4FDE: A9 10    lda #$10
4FE0: 25 F0    and $f0
4FE2: F0 05    beq $4fe9
4FE4: A9 05    lda #$05
4FE6: 4C EB 4F jmp $4feb
4FE9: A9 02    lda #$02
4FEB: 8D A3 0C sta $0ca3
4FEE: 8D C3 0C sta $0cc3
4FF1: 8D E3 0C sta $0ce3
4FF4: 8D 03 0D sta $0d03
4FF7: A9 00    lda #$00
4FF9: 85 FC    sta $fc
4FFB: 4C 5F 30 jmp $305f

5000: A9 40    lda #$40
5002: 85 BE    sta $be
5004: 38       sec
5005: A5 B2    lda $b2
5007: ED B4 02 sbc $02b4
500A: A5 B3    lda $b3
500C: ED B5 02 sbc $02b5
500F: A5 B4    lda $b4
5011: ED B6 02 sbc $02b6
5014: A5 B5    lda $b5
5016: ED B7 02 sbc $02b7
5019: B0 1E    bcs $5039
501B: A9 41    lda #$41
501D: 85 BE    sta $be
501F: 38       sec
5020: A5 B6    lda $b6
5022: ED B4 02 sbc $02b4
5025: A5 B7    lda $b7
5027: ED B5 02 sbc $02b5
502A: A5 B8    lda $b8
502C: ED B6 02 sbc $02b6
502F: A5 B9    lda $b9
5031: ED B7 02 sbc $02b7
5034: B0 03    bcs $5039
5036: 4C D9 53 jmp $53d9
5039: A9 09    lda #$09
503B: 85 16    sta $16
503D: A9 B0    lda #$b0
503F: 85 17    sta $17
5041: A9 02    lda #$02
5043: 85 18    sta $18
5045: A9 30    lda #$30
5047: 85 19    sta $19
5049: A9 00    lda #$00
504B: 85 1A    sta $1a
504D: A0 03    ldy #$03
504F: B1 17    lda ($17), y
5051: 91 19    sta ($19), y
5053: 88       dey
5054: 10 F9    bpl $504f
5056: A5 BE    lda $be
5058: C9 40    cmp #$40
505A: D0 16    bne $5072
505C: 38       sec
505D: A5 B2    lda $b2
505F: E5 30    sbc $30
5061: A5 B3    lda $b3
5063: E5 31    sbc $31
5065: A5 B4    lda $b4
5067: E5 32    sbc $32
5069: A5 B5    lda $b5
506B: E5 33    sbc $33
506D: B0 28    bcs $5097
506F: 4C 85 50 jmp $5085
5072: 38       sec
5073: A5 B6    lda $b6
5075: E5 30    sbc $30
5077: A5 B7    lda $b7
5079: E5 31    sbc $31
507B: A5 B8    lda $b8
507D: E5 32    sbc $32
507F: A5 B9    lda $b9
5081: E5 33    sbc $33
5083: B0 12    bcs $5097
5085: A5 17    lda $17
5087: 18       clc
5088: 69 04    adc #$04
508A: 85 17    sta $17
508C: A5 18    lda $18
508E: 69 00    adc #$00
5090: 85 18    sta $18
5092: E6 16    inc $16
5094: 4C B7 50 jmp $50b7
5097: A5 17    lda $17
5099: 38       sec
509A: E9 04    sbc #$04
509C: 85 17    sta $17
509E: A5 18    lda $18
50A0: E9 00    sbc #$00
50A2: 85 18    sta $18
50A4: C6 16    dec $16
50A6: D0 A5    bne $504d
50A8: A5 17    lda $17
50AA: 18       clc
50AB: 69 04    adc #$04
50AD: 85 17    sta $17
50AF: A5 18    lda $18
50B1: 69 00    adc #$00
50B3: 85 18    sta $18
50B5: E6 16    inc $16
50B7: A9 0A    lda #$0a
50B9: 85 1F    sta $1f
50BB: A9 B0    lda #$b0
50BD: 85 19    sta $19
50BF: A9 02    lda #$02
50C1: 85 1A    sta $1a
50C3: A9 B4    lda #$b4
50C5: 85 1B    sta $1b
50C7: A9 02    lda #$02
50C9: 85 1C    sta $1c
50CB: A5 1F    lda $1f
50CD: C5 16    cmp $16
50CF: F0 2C    beq $50fd
50D1: A0 03    ldy #$03
50D3: B1 19    lda ($19), y
50D5: 91 1B    sta ($1b), y
50D7: 88       dey
50D8: 10 F9    bpl $50d3
50DA: A5 19    lda $19
50DC: 38       sec
50DD: E9 04    sbc #$04
50DF: 85 19    sta $19
50E1: A5 1A    lda $1a
50E3: E9 00    sbc #$00
50E5: 85 1A    sta $1a
50E7: A5 1B    lda $1b
50E9: 38       sec
50EA: E9 04    sbc #$04
50EC: 85 1B    sta $1b
50EE: A5 1C    lda $1c
50F0: E9 00    sbc #$00
50F2: 85 1C    sta $1c
50F4: C6 1F    dec $1f
50F6: 10 D3    bpl $50cb
50F8: A9 A5    lda #$a5
50FA: 4C 87 3F jmp $3f87
50FD: A5 1B    lda $1b
50FF: C5 17    cmp $17
5101: D0 06    bne $5109
5103: A5 1C    lda $1c
5105: C5 18    cmp $18
5107: F0 05    beq $510e
5109: A9 A4    lda #$a4
510B: 4C 87 3F jmp $3f87
510E: A5 BE    lda $be
5110: C9 40    cmp #$40
5112: D0 0B    bne $511f
5114: A9 B2    lda #$b2
5116: 85 19    sta $19
5118: A9 00    lda #$00
511A: 85 1A    sta $1a
511C: 4C 27 51 jmp $5127
511F: A9 B6    lda #$b6
5121: 85 19    sta $19
5123: A9 00    lda #$00
5125: 85 1A    sta $1a
5127: A0 03    ldy #$03
5129: B1 19    lda ($19), y
512B: 91 17    sta ($17), y   ; [video_address]
512D: 88       dey
512E: 10 F9    bpl $5129
5130: A9 0A    lda #$0a
5132: 85 1F    sta $1f
5134: A9 E8    lda #$e8
5136: 85 19    sta $19
5138: A9 02    lda #$02
513A: 85 1A    sta $1a
513C: A9 EB    lda #$eb
513E: 85 1B    sta $1b
5140: A9 02    lda #$02
5142: 85 1C    sta $1c
5144: A5 1F    lda $1f
5146: C5 16    cmp $16
5148: F0 2C    beq $5176
514A: A0 02    ldy #$02
514C: B1 19    lda ($19), y
514E: 91 1B    sta ($1b), y
5150: 88       dey
5151: 10 F9    bpl $514c
5153: A5 19    lda $19
5155: 38       sec
5156: E9 03    sbc #$03
5158: 85 19    sta $19
515A: A5 1A    lda $1a
515C: E9 00    sbc #$00
515E: 85 1A    sta $1a
5160: A5 1B    lda $1b
5162: 38       sec
5163: E9 03    sbc #$03
5165: 85 1B    sta $1b
5167: A5 1C    lda $1c
5169: E9 00    sbc #$00
516B: 85 1C    sta $1c
516D: C6 1F    dec $1f
516F: 10 D3    bpl $5144
5171: A9 A6    lda #$a6
5173: 4C 87 3F jmp $3f87
5176: A5 1B    lda $1b
5178: 85 37    sta $37
517A: A5 1C    lda $1c
517C: 85 38    sta $38
517E: A0 00    ldy #$00
5180: A9 25    lda #$25
5182: 91 37    sta ($37), y
5184: C8       iny
5185: A9 25    lda #$25
5187: 91 37    sta ($37), y
5189: C8       iny
518A: A9 25    lda #$25
518C: 91 37    sta ($37), y
518E: A5 BE    lda $be
5190: C9 40    cmp #$40
5192: D0 07    bne $519b
5194: A9 07    lda #$07
5196: 85 BE    sta $be
5198: 4C AF 51 jmp $51af
519B: A9 08    lda #$08
519D: 85 BE    sta $be
519F: A9 08    lda #$08
51A1: 2D 06 21 and dsw_2106
51A4: F0 09    beq $51af
51A6: A5 A8    lda $a8
51A8: 09 80    ora #$80
51AA: 85 A8    sta $a8
51AC: 8D 03 21 sta flipscreen_2103
51AF: A9 06    lda #$06
51B1: 20 00 40 jsr $4000
51B4: A9 09    lda #$09
51B6: 85 31    sta $31
51B8: 85 32    sta $32
51BA: 85 33    sta $33
51BC: A9 0D    lda #$0d
51BE: 85 19    sta $19
51C0: A9 06    lda #$06
51C2: 85 1A    sta $1a
51C4: A9 00    lda #$00
51C6: 85 16    sta $16
51C8: A9 03    lda #$03
51CA: 85 1B    sta $1b
51CC: A9 63    lda #$63
51CE: 85 1C    sta $1c
51D0: A9 08    lda #$08
51D2: 85 1D    sta $1d
51D4: A9 03    lda #$03
51D6: 8D 0E 0E sta $0e0e
51D9: 8D EE 0D sta $0dee
51DC: 8D CE 0D sta $0dce
51DF: A5 31    lda $31
51E1: C9 09    cmp #$09
51E3: D0 02    bne $51e7
51E5: A9 30    lda #$30
51E7: 8D 0E 06 sta $060e
51EA: A5 32    lda $32
51EC: C9 09    cmp #$09
51EE: D0 02    bne $51f2
51F0: A9 30    lda #$30
51F2: 8D EE 05 sta $05ee
51F5: A5 33    lda $33
51F7: C9 09    cmp #$09
51F9: D0 02    bne $51fd
51FB: A9 30    lda #$30
51FD: 8D CE 05 sta $05ce
5200: A9 05    lda #$05
5202: 8D CD 0D sta $0dcd
5205: 8D ED 0D sta $0ded
5208: 8D 0D 0E sta $0e0d
520B: 8D CF 0D sta $0dcf
520E: 8D EF 0D sta $0def
5211: 8D 0F 0E sta $0e0f
5214: A0 00    ldy #$00
5216: A9 C4    lda #$c4
5218: 91 19    sta ($19), y
521A: C8       iny
521B: C8       iny
521C: A9 C3    lda #$c3
521E: 91 19    sta ($19), y
5220: A5 19    lda $19
5222: 85 1E    sta $1e
5224: A5 1A    lda $1a
5226: 18       clc
5227: 69 08    adc #$08
5229: 85 1F    sta $1f
522B: A0 01    ldy #$01
522D: A9 05    lda #$05
522F: 91 1E    sta ($1e), y
5231: A4 1C    ldy $1c
5233: B9 90 34 lda $3490, y
5236: 20 90 4B jsr $4b90
5239: 8D FB 04 sta $04fb
523C: 8E DB 04 stx $04db
523F: A9 08    lda #$08
5241: 2D 06 21 and dsw_2106
5244: F0 0C    beq $5252
5246: A5 BE    lda $be
5248: C9 07    cmp #$07
524A: F0 06    beq $5252
524C: AD 05 21 lda in1_2105
524F: 4C 55 52 jmp $5255
5252: AD 04 21 lda in0_2104
5255: 29 F0    and #$f0
5257: 85 30    sta $30
5259: A5 16    lda $16
525B: C9 03    cmp #$03
525D: B0 2A    bcs $5289
525F: A9 10    lda #$10
5261: 25 30    and $30
5263: F0 0F    beq $5274
5265: A6 16    ldx $16
5267: B5 31    lda $31, x
5269: 38       sec
526A: E9 01    sbc #$01
526C: C9 09    cmp #$09
526E: B0 02    bcs $5272
5270: A9 23    lda #$23
5272: 95 31    sta $31, x
5274: A9 20    lda #$20
5276: 25 30    and $30
5278: F0 0F    beq $5289
527A: A6 16    ldx $16
527C: B5 31    lda $31, x
527E: 18       clc
527F: 69 01    adc #$01
5281: C9 24    cmp #$24
5283: 90 02    bcc $5287
5285: A9 09    lda #$09
5287: 95 31    sta $31, x
5289: A9 40    lda #$40
528B: 25 30    and $30
528D: F0 46    beq $52d5
528F: A5 1B    lda $1b
5291: 38       sec
5292: E9 01    sbc #$01
5294: F0 05    beq $529b
5296: 85 1B    sta $1b
5298: 4C D5 52 jmp $52d5
529B: A9 03    lda #$03
529D: 85 1B    sta $1b
529F: A5 16    lda $16
52A1: 18       clc
52A2: 69 01    adc #$01
52A4: C9 04    cmp #$04
52A6: 90 03    bcc $52ab
52A8: 4C 56 53 jmp $5356
52AB: 85 16    sta $16
52AD: A0 00    ldy #$00
52AF: A9 30    lda #$30
52B1: 91 19    sta ($19), y
52B3: C8       iny
52B4: C8       iny
52B5: 91 19    sta ($19), y
52B7: A5 19    lda $19
52B9: 85 17    sta $17
52BB: A5 1A    lda $1a
52BD: 18       clc
52BE: 69 08    adc #$08
52C0: 85 18    sta $18
52C2: A0 01    ldy #$01
52C4: A9 03    lda #$03
52C6: 91 17    sta ($17), y   ; [video_address]
52C8: A5 19    lda $19
52CA: 38       sec
52CB: E9 20    sbc #$20
52CD: 85 19    sta $19
52CF: A5 1A    lda $1a
52D1: E9 00    sbc #$00
52D3: 85 1A    sta $1a
52D5: A9 80    lda #$80
52D7: 25 30    and $30
52D9: F0 41    beq $531c
52DB: A5 1B    lda $1b
52DD: 38       sec
52DE: E9 01    sbc #$01
52E0: F0 05    beq $52e7
52E2: 85 1B    sta $1b
52E4: 4C 1C 53 jmp $531c
52E7: A9 03    lda #$03
52E9: 85 1B    sta $1b
52EB: A5 16    lda $16
52ED: 38       sec
52EE: E9 01    sbc #$01
52F0: 30 2A    bmi $531c
52F2: 85 16    sta $16
52F4: A0 00    ldy #$00
52F6: A9 30    lda #$30
52F8: 91 19    sta ($19), y
52FA: C8       iny
52FB: C8       iny
52FC: 91 19    sta ($19), y
52FE: A5 19    lda $19
5300: 85 17    sta $17
5302: A5 1A    lda $1a
5304: 18       clc
5305: 69 08    adc #$08
5307: 85 18    sta $18
5309: A0 01    ldy #$01
530B: A9 03    lda #$03
530D: 91 17    sta ($17), y   ; [video_address]
530F: A5 19    lda $19
5311: 18       clc
5312: 69 20    adc #$20
5314: 85 19    sta $19
5316: A5 1A    lda $1a
5318: 69 00    adc #$00
531A: 85 1A    sta $1a
531C: A9 C0    lda #$c0
531E: 25 30    and $30
5320: D0 04    bne $5326
5322: A9 03    lda #$03
5324: 85 1B    sta $1b
5326: C6 1D    dec $1d
5328: D0 0B    bne $5335
532A: A9 08    lda #$08
532C: 85 1D    sta $1d
532E: C6 1C    dec $1c
5330: 10 03    bpl $5335
5332: 4C 56 53 jmp $5356
5335: A5 16    lda $16
5337: C9 02    cmp #$02
5339: 90 03    bcc $533e
533B: 20 DE 53 jsr $53de
533E: A9 01    lda #$01
5340: 85 18    sta $18
5342: A9 28    lda #$28
5344: 85 17    sta $17
5346: A2 00    ldx #$00
5348: CA       dex
5349: D0 FD    bne $5348
534B: C6 17    dec $17
534D: D0 F9    bne $5348
534F: C6 18    dec $18
5351: D0 F5    bne $5348
5353: 4C DF 51 jmp $51df
5356: 20 DE 53 jsr $53de
5359: A5 31    lda $31
535B: C9 13    cmp #$13
535D: D0 11    bne $5370
535F: A5 32    lda $32
5361: C9 11    cmp #$11
5363: D0 0B    bne $5370
5365: A5 33    lda $33
5367: C9 1E    cmp #$1e
5369: D0 05    bne $5370
536B: A9 08    lda #$08
536D: 20 00 40 jsr $4000
5370: A5 31    lda $31
5372: C9 16    cmp #$16
5374: D0 11    bne $5387
5376: A5 32    lda $32
5378: C9 1B    cmp #$1b
537A: D0 0B    bne $5387
537C: A5 33    lda $33
537E: C9 1C    cmp #$1c
5380: D0 05    bne $5387
5382: A9 09    lda #$09
5384: 20 00 40 jsr $4000
5387: A5 31    lda $31
5389: C9 1B    cmp #$1b
538B: D0 11    bne $539e
538D: A5 32    lda $32
538F: C9 10    cmp #$10
5391: D0 0B    bne $539e
5393: A5 33    lda $33
5395: C9 1E    cmp #$1e
5397: D0 05    bne $539e
5399: A9 0A    lda #$0a
539B: 20 00 40 jsr $4000
539E: A5 31    lda $31
53A0: C9 14    cmp #$14
53A2: D0 11    bne $53b5
53A4: A5 32    lda $32
53A6: C9 16    cmp #$16
53A8: D0 0B    bne $53b5
53AA: A5 33    lda $33
53AC: C9 1E    cmp #$1e
53AE: D0 05    bne $53b5
53B0: A9 0B    lda #$0b
53B2: 20 00 40 jsr $4000
53B5: A5 31    lda $31
53B7: C9 0F    cmp #$0f
53B9: D0 11    bne $53cc
53BB: A5 32    lda $32
53BD: C9 13    cmp #$13
53BF: D0 0B    bne $53cc
53C1: A5 33    lda $33
53C3: C9 1E    cmp #$1e
53C5: D0 05    bne $53cc
53C7: A9 0A    lda #$0a
53C9: 20 00 40 jsr $4000
53CC: A5 BE    lda $be
53CE: C9 07    cmp #$07
53D0: D0 07    bne $53d9
53D2: A9 41    lda #$41
53D4: 85 BE    sta $be
53D6: 4C 1F 50 jmp $501f
53D9: A9 00    lda #$00
53DB: 85 BE    sta $be
53DD: 60       rts
53DE: A0 00    ldy #$00
53E0: A5 31    lda $31
53E2: C9 09    cmp #$09
53E4: D0 02    bne $53e8
53E6: A9 30    lda #$30
53E8: 91 37    sta ($37), y
53EA: C8       iny
53EB: A5 32    lda $32
53ED: C9 09    cmp #$09
53EF: D0 02    bne $53f3
53F1: A9 30    lda #$30
53F3: 91 37    sta ($37), y
53F5: C8       iny
53F6: A5 33    lda $33
53F8: C9 09    cmp #$09
53FA: D0 02    bne $53fe
53FC: A9 30    lda #$30
53FE: 91 37    sta ($37), y
5400: 60       rts
5401: A9 07    lda #$07
5403: 20 00 40 jsr $4000
5406: A9 49    lda #$49
5408: 85 17    sta $17
540A: A9 06    lda #$06
540C: 85 18    sta $18
540E: A9 D0    lda #$d0
5410: 85 19    sta $19
5412: A9 02    lda #$02
5414: 85 1A    sta $1a
5416: A9 09    lda #$09
5418: 85 1F    sta $1f
541A: A0 00    ldy #$00
541C: B1 19    lda ($19), y
541E: 91 17    sta ($17), y   ; [video_address]
5420: A5 19    lda $19
5422: 18       clc
5423: 69 01    adc #$01
5425: 85 19    sta $19
5427: A5 1A    lda $1a
5429: 69 00    adc #$00
542B: 85 1A    sta $1a
542D: A5 17    lda $17
542F: 38       sec
5430: E9 20    sbc #$20
5432: 85 17    sta $17
5434: A5 18    lda $18
5436: E9 00    sbc #$00
5438: 85 18    sta $18
543A: B1 19    lda ($19), y
543C: 91 17    sta ($17), y   ; [video_address]
543E: A5 19    lda $19
5440: 18       clc
5441: 69 01    adc #$01
5443: 85 19    sta $19
5445: A5 1A    lda $1a
5447: 69 00    adc #$00
5449: 85 1A    sta $1a
544B: A5 17    lda $17
544D: 38       sec
544E: E9 20    sbc #$20
5450: 85 17    sta $17
5452: A5 18    lda $18
5454: E9 00    sbc #$00
5456: 85 18    sta $18
5458: B1 19    lda ($19), y
545A: 91 17    sta ($17), y   ; [video_address]
545C: A5 19    lda $19
545E: 18       clc
545F: 69 01    adc #$01
5461: 85 19    sta $19
5463: A5 1A    lda $1a
5465: 69 00    adc #$00
5467: 85 1A    sta $1a
5469: A5 17    lda $17
546B: 18       clc
546C: 69 42    adc #$42
546E: 85 17    sta $17
5470: A5 18    lda $18
5472: 69 00    adc #$00
5474: 85 18    sta $18
5476: C6 1F    dec $1f
5478: 10 A0    bpl $541a
547A: A9 90    lda #$90
547C: 85 1B    sta $1b
547E: A9 02    lda #$02
5480: 85 1C    sta $1c
5482: A9 E9    lda #$e9
5484: 85 1D    sta $1d
5486: A9 05    lda #$05
5488: 85 1E    sta $1e
548A: A9 C0    lda #$c0
548C: 85 19    sta $19
548E: A9 00    lda #$00
5490: 85 1A    sta $1a
5492: A9 09    lda #$09
5494: 85 1F    sta $1f
5496: A5 1D    lda $1d
5498: 85 17    sta $17
549A: A5 1E    lda $1e
549C: 85 18    sta $18
549E: 20 CB 54 jsr $54cb
54A1: 20 6E 4B jsr write_text_4b6e
54A4: A5 1B    lda $1b
54A6: 18       clc
54A7: 69 04    adc #$04
54A9: 85 1B    sta $1b
54AB: A5 1C    lda $1c
54AD: 69 00    adc #$00
54AF: 85 1C    sta $1c
54B1: A5 1D    lda $1d
54B3: 18       clc
54B4: 69 02    adc #$02
54B6: 85 1D    sta $1d
54B8: A5 1E    lda $1e
54BA: 69 00    adc #$00
54BC: 85 1E    sta $1e
54BE: A9 C0    lda #$c0
54C0: 85 19    sta $19
54C2: A9 00    lda #$00
54C4: 85 1A    sta $1a
54C6: C6 1F    dec $1f
54C8: 10 CC    bpl $5496
54CA: 60       rts
54CB: A9 FF    lda #$ff
54CD: 85 CB    sta $cb
54CF: A9 00    lda #$00
54D1: 85 CA    sta $ca
54D3: A0 00    ldy #$00
54D5: B1 1B    lda ($1b), y
54D7: 20 90 4B jsr $4b90
54DA: 86 C9    stx $c9
54DC: 85 C8    sta $c8
54DE: C8       iny
54DF: B1 1B    lda ($1b), y
54E1: 20 90 4B jsr $4b90
54E4: 86 C6    stx $c6
54E6: 85 C5    sta $c5
54E8: C8       iny
54E9: B1 1B    lda ($1b), y
54EB: 20 90 4B jsr $4b90
54EE: 86 C4    stx $c4
54F0: 85 C2    sta $c2
54F2: C8       iny
54F3: B1 1B    lda ($1b), y
54F5: 20 90 4B jsr $4b90
54F8: 86 C1    stx $c1
54FA: 85 C0    sta $c0
54FC: A9 27    lda #$27
54FE: 85 C3    sta $c3
5500: 85 C7    sta $c7
5502: A2 00    ldx #$00
5504: B5 C0    lda $c0, x
5506: F0 04    beq $550c
5508: C9 27    cmp #$27
550A: D0 09    bne $5515
550C: A9 30    lda #$30
550E: 95 C0    sta $c0, x
5510: E8       inx
5511: C9 0A    cmp #$0a
5513: D0 EF    bne $5504
5515: 60       rts
5516: A9 00    lda #$00
5518: 8D 00 21 sta sound_2100
551B: 8D 01 21 sta sound_2101
551E: 85 4D    sta $4d
5520: 85 4E    sta $4e
5522: 85 4F    sta $4f
5524: A5 BE    lda $be
5526: C9 10    cmp #$10
5528: 90 12    bcc $553c
552A: A9 80    lda #$80
552C: 85 A5    sta $a5
552E: 8D 00 21 sta sound_2100
5531: A9 0E    lda #$0e
5533: 85 A6    sta $a6
5535: 8D 01 21 sta sound_2101
5538: A9 B0    lda #$b0
553A: 85 4F    sta $4f
553C: A5 A3    lda $a3
553E: D0 03    bne $5543
5540: 4C 17 56 jmp $5617
5543: A9 1B    lda #$1b
5545: 38       sec
5546: E5 51    sbc $51
5548: 18       clc
5549: 2A       rol a
554A: 2A       rol a
554B: 2A       rol a
554C: 2A       rol a
554D: 85 1D    sta $1d
554F: A9 00    lda #$00
5551: 69 00    adc #$00
5553: 0A       asl a
5554: 26 1D    rol $1d
5556: 69 04    adc #$04
5558: 85 1E    sta $1e
555A: A9 1F    lda #$1f
555C: 38       sec
555D: E5 52    sbc $52
555F: 18       clc
5560: 65 1D    adc $1d
5562: 85 1D    sta $1d
5564: A5 53    lda $53
5566: C9 01    cmp #$01
5568: F0 57    beq $55c1
556A: C9 02    cmp #$02
556C: F0 43    beq $55b1
556E: C9 04    cmp #$04
5570: F0 10    beq $5582
5572: A5 1D    lda $1d
5574: 38       sec
5575: E9 21    sbc #$21
5577: 85 1D    sta $1d
5579: A5 1E    lda $1e
557B: E9 00    sbc #$00
557D: 85 1E    sta $1e
557F: 4C 8F 55 jmp $558f
5582: A5 1D    lda $1d
5584: 18       clc
5585: 69 1F    adc #$1f
5587: 85 1D    sta $1d
5589: A5 1E    lda $1e
558B: 69 00    adc #$00
558D: 85 1E    sta $1e
558F: A9 0B    lda #$0b
5591: 85 1B    sta $1b
5593: A9 56    lda #$56
5595: 85 1C    sta $1c
5597: A5 EC    lda $ec
5599: 0A       asl a
559A: 18       clc
559B: 65 1B    adc $1b
559D: 85 1B    sta $1b
559F: A5 1C    lda $1c
55A1: 69 00    adc #$00
55A3: 85 1C    sta $1c
55A5: A0 02    ldy #$02
55A7: B1 1B    lda ($1b), y
55A9: 91 1D    sta ($1d), y
55AB: 88       dey
55AC: 10 F9    bpl $55a7
55AE: 4C 17 56 jmp $5617
55B1: A5 1D    lda $1d
55B3: 38       sec
55B4: E9 1F    sbc #$1f
55B6: 85 1D    sta $1d
55B8: A5 1E    lda $1e
55BA: E9 00    sbc #$00
55BC: 85 1E    sta $1e
55BE: 4C CE 55 jmp $55ce
55C1: A5 1D    lda $1d
55C3: 38       sec
55C4: E9 21    sbc #$21
55C6: 85 1D    sta $1d
55C8: A5 1E    lda $1e
55CA: E9 00    sbc #$00
55CC: 85 1E    sta $1e
55CE: A9 FF    lda #$ff
55D0: 85 1B    sta $1b
55D2: A9 55    lda #$55
55D4: 85 1C    sta $1c
55D6: A5 EC    lda $ec
55D8: 0A       asl a
55D9: 18       clc
55DA: 65 1B    adc $1b
55DC: 85 1B    sta $1b
55DE: A5 1C    lda $1c
55E0: 69 00    adc #$00
55E2: 85 1C    sta $1c
55E4: A0 02    ldy #$02
55E6: A2 00    ldx #$00
55E8: B1 1B    lda ($1b), y
55EA: 81 1D    sta ($1d, x)
55EC: A5 1D    lda $1d
55EE: 18       clc
55EF: 69 20    adc #$20
55F1: 85 1D    sta $1d
55F3: A5 1E    lda $1e
55F5: 69 00    adc #$00
55F7: 85 1E    sta $1e
55F9: 88       dey
55FA: 10 EC    bpl $55e8
55FC: 4C 17 56 jmp $5617

5617: A9 08    lda #$08
5619: 85 19    sta $19
561B: A9 00    lda #$00
561D: 85 16    sta $16
561F: 20 4D 5E jsr $5e4d
5622: C6 19    dec $19
5624: D0 F9    bne $561f
5626: A9 1B    lda #$1b
5628: 38       sec
5629: E5 54    sbc $54
562B: 18       clc
562C: 2A       rol a
562D: 2A       rol a
562E: 2A       rol a
562F: 2A       rol a
5630: 85 1B    sta $1b
5632: A9 00    lda #$00
5634: 69 00    adc #$00
5636: 0A       asl a
5637: 26 1B    rol $1b
5639: 69 04    adc #$04
563B: 85 1C    sta $1c
563D: A9 1F    lda #$1f
563F: 38       sec
5640: E5 55    sbc $55
5642: 18       clc
5643: 65 1B    adc $1b
5645: 85 1B    sta $1b
5647: A0 00    ldy #$00
5649: B1 1B    lda ($1b), y
564B: C9 49    cmp #$49
564D: 90 08    bcc $5657
564F: C9 4F    cmp #$4f
5651: B0 04    bcs $5657
5653: A9 30    lda #$30
5655: 91 1B    sta ($1b), y
5657: A9 00    lda #$00
5659: 85 EF    sta $ef
565B: C6 EF    dec $ef
565D: 10 10    bpl $566f
565F: 20 4D 5E jsr $5e4d
5662: A4 BC    ldy $bc
5664: C0 10    cpy #$10
5666: 90 02    bcc $566a
5668: A0 10    ldy #$10
566A: B9 D7 58 lda $58d7, y
566D: 85 EF    sta $ef
566F: A5 56    lda $56
5671: C9 01    cmp #$01
5673: F0 0D    beq $5682
5675: C9 02    cmp #$02
5677: F0 0E    beq $5687
5679: C9 04    cmp #$04
567B: F0 0F    beq $568c
567D: C6 54    dec $54
567F: 4C 8E 56 jmp $568e
5682: C6 55    dec $55
5684: 4C 8E 56 jmp $568e
5687: E6 55    inc $55
5689: 4C 8E 56 jmp $568e
568C: E6 54    inc $54
568E: A9 1B    lda #$1b
5690: 38       sec
5691: E5 54    sbc $54
5693: 18       clc
5694: 2A       rol a
5695: 2A       rol a
5696: 2A       rol a
5697: 2A       rol a
5698: 85 1B    sta $1b
569A: A9 00    lda #$00
569C: 69 00    adc #$00
569E: 0A       asl a
569F: 26 1B    rol $1b
56A1: 69 04    adc #$04
56A3: 85 1C    sta $1c
56A5: A9 1F    lda #$1f
56A7: 38       sec
56A8: E5 55    sbc $55
56AA: 18       clc
56AB: 65 1B    adc $1b
56AD: 85 1B    sta $1b
56AF: A0 00    ldy #$00
56B1: A9 30    lda #$30
56B3: 91 1B    sta ($1b), y
56B5: A5 57    lda $57
56B7: C5 58    cmp $58
56B9: F0 03    beq $56be
56BB: 4C 78 58 jmp $5878
56BE: A5 51    lda $51
56C0: C5 54    cmp $54
56C2: D0 97    bne $565b
56C4: A5 52    lda $52
56C6: C5 55    cmp $55
56C8: D0 91    bne $565b
56CA: A5 53    lda $53
56CC: A2 42    ldx #$42
56CE: C9 01    cmp #$01
56D0: F0 0E    beq $56e0
56D2: A2 21    ldx #$21
56D4: C9 02    cmp #$02
56D6: F0 08    beq $56e0
56D8: A2 22    ldx #$22
56DA: C9 04    cmp #$04
56DC: F0 02    beq $56e0
56DE: A2 42    ldx #$42
56E0: 86 1F    stx $1f
56E2: A5 1B    lda $1b
56E4: 38       sec
56E5: E5 1F    sbc $1f
56E7: 85 1B    sta $1b
56E9: A5 1C    lda $1c
56EB: E9 00    sbc #$00
56ED: 85 1C    sta $1c
56EF: A2 03    ldx #$03
56F1: A0 03    ldy #$03
56F3: A9 30    lda #$30
56F5: 91 1B    sta ($1b), y
56F7: 88       dey
56F8: 10 FB    bpl $56f5
56FA: A5 1B    lda $1b
56FC: 18       clc
56FD: 69 20    adc #$20
56FF: 85 1B    sta $1b
5701: A5 1C    lda $1c
5703: 69 00    adc #$00
5705: 85 1C    sta $1c
5707: CA       dex
5708: 10 E7    bpl $56f1
570A: A9 00    lda #$00
570C: 85 A5    sta $a5
570E: 8D 00 21 sta sound_2100
5711: A9 00    lda #$00
5713: 85 A6    sta $a6
5715: 8D 01 21 sta sound_2101
5718: 85 4F    sta $4f
571A: A9 03    lda #$03
571C: 85 16    sta $16
571E: 20 4D 5E jsr $5e4d
5721: A5 A3    lda $a3
5723: D0 05    bne $572a
5725: A9 05    lda #$05
5727: 20 00 40 jsr $4000
572A: A5 BE    lda $be
572C: C9 20    cmp #$20
572E: 30 52    bmi $5782
5730: C9 30    cmp #$30
5732: 30 2D    bmi $5761
5734: A5 B1    lda $b1
5736: D0 05    bne $573d
5738: A9 0D    lda #$0d
573A: 20 00 40 jsr $4000
573D: A5 B0    lda $b0
573F: D0 4C    bne $578d
5741: A5 B1    lda $b1
5743: F0 10    beq $5755
5745: A9 02    lda #$02
5747: 20 00 40 jsr $4000
574A: C6 B1    dec $b1
574C: 20 E9 58 jsr $58e9
574F: 20 1E 4C jsr $4c1e
5752: 4C 48 58 jmp $5848
5755: A5 A8    lda $a8
5757: 29 7F    and #$7f
5759: 85 A8    sta $a8
575B: 8D 03 21 sta flipscreen_2103
575E: 4C DE 59 jmp $59de
5761: A5 B0    lda $b0
5763: D0 05    bne $576a
5765: A9 0C    lda #$0c
5767: 20 00 40 jsr $4000
576A: A5 B1    lda $b1
576C: D0 56    bne $57c4
576E: A5 B0    lda $b0
5770: F0 E3    beq $5755
5772: A9 01    lda #$01
5774: 20 00 40 jsr $4000
5777: C6 B0    dec $b0
5779: 20 E9 58 jsr $58e9
577C: 20 1E 4C jsr $4c1e
577F: 4C 48 58 jmp $5848
5782: C6 B0    dec $b0
5784: 10 7C    bpl $5802
5786: A9 00    lda #$00
5788: 85 B0    sta $b0
578A: 4C DE 59 jmp $59de
578D: A5 A8    lda $a8
578F: 29 7F    and #$7f
5791: 85 A8    sta $a8
5793: 8D 03 21 sta flipscreen_2103
5796: A9 20    lda #$20
5798: 85 BE    sta $be
579A: A5 59    lda $59
579C: 85 AB    sta $ab
579E: A5 BC    lda $bc
57A0: 85 AD    sta $ad
57A2: A5 BA    lda $ba
57A4: 85 AF    sta $af
57A6: A5 AA    lda $aa
57A8: 85 59    sta $59
57AA: A5 AC    lda $ac
57AC: 85 BC    sta $bc
57AE: A5 AE    lda $ae
57B0: 85 BA    sta $ba
57B2: A9 01    lda #$01
57B4: 20 00 40 jsr $4000
57B7: C6 B0    dec $b0
57B9: A9 00    lda #$00
57BB: 85 2B    sta $2b
57BD: A9 03    lda #$03
57BF: 85 2C    sta $2c
57C1: 4C 02 58 jmp $5802
57C4: 20 24 4B jsr $4b24
57C7: A9 08    lda #$08
57C9: 2D 06 21 and dsw_2106
57CC: F0 09    beq $57d7
57CE: A5 A8    lda $a8
57D0: 09 80    ora #$80
57D2: 85 A8    sta $a8
57D4: 8D 03 21 sta flipscreen_2103
57D7: A9 30    lda #$30
57D9: 85 BE    sta $be
57DB: A5 59    lda $59
57DD: 85 AA    sta $aa
57DF: A5 BC    lda $bc
57E1: 85 AC    sta $ac
57E3: A5 BA    lda $ba
57E5: 85 AE    sta $ae
57E7: A5 AB    lda $ab
57E9: 85 59    sta $59
57EB: A5 AD    lda $ad
57ED: 85 BC    sta $bc
57EF: A5 AF    lda $af
57F1: 85 BA    sta $ba
57F3: A9 02    lda #$02
57F5: 20 00 40 jsr $4000
57F8: C6 B1    dec $b1
57FA: A9 40    lda #$40
57FC: 85 2B    sta $2b
57FE: A9 03    lda #$03
5800: 85 2C    sta $2c
5802: 20 24 4B jsr $4b24
5805: A5 BC    lda $bc
5807: 29 1F    and #$1f
5809: A8       tay
580A: B9 DA 5D lda $5dda, y
580D: 85 2A    sta $2a
580F: 98       tya
5810: 0A       asl a
5811: A8       tay
5812: B9 C2 33 lda $33c2, y
5815: 85 F9    sta $f9
5817: B9 C3 33 lda $33c3, y
581A: 85 FA    sta $fa
581C: 20 1E 4C jsr $4c1e
581F: A0 00    ldy #$00
5821: A2 00    ldx #$00
5823: B1 2B    lda ($2b), y
5825: 85 2D    sta $2d
5827: C8       iny
5828: B1 2B    lda ($2b), y
582A: F0 13    beq $583f
582C: 30 1A    bmi $5848
582E: 18       clc
582F: 69 04    adc #$04
5831: 85 2E    sta $2e
5833: C9 0C    cmp #$0c
5835: 30 0C    bmi $5843
5837: C9 10    cmp #$10
5839: 10 08    bpl $5843
583B: A5 2A    lda $2a
583D: 81 2D    sta ($2d, x)
583F: C8       iny
5840: 4C 23 58 jmp $5823
5843: A9 A1    lda #$a1
5845: 4C 87 3F jmp $3f87
5848: A5 BC    lda $bc
584A: C9 20    cmp #$20
584C: 90 03    bcc $5851
584E: 20 EE 5C jsr $5cee
5851: A9 1E    lda #$1e
5853: 85 A4    sta $a4
5855: A5 BC    lda $bc
5857: 29 0F    and #$0f
5859: A8       tay
585A: B9 02 34 lda $3402, y
585D: 85 A3    sta $a3
585F: 20 EE 35 jsr $35ee
5862: 20 32 35 jsr $3532
5865: 20 72 39 jsr $3972
5868: 20 FA 5D jsr $5dfa
586B: A9 00    lda #$00
586D: 85 28    sta $28
586F: 85 29    sta $29
5871: 20 AB 49 jsr $49ab
5874: 20 00 AA jsr $aa00
5877: 60       rts
5878: A4 58    ldy $58
587A: A5 56    lda $56
587C: C9 01    cmp #$01
587E: F0 23    beq $58a3
5880: C9 02    cmp #$02
5882: F0 16    beq $589a
5884: C9 04    cmp #$04
5886: F0 09    beq $5891
5888: B9 C0 03 lda $03c0, y
588B: C5 54    cmp $54
588D: 30 45    bmi $58d4
588F: 10 19    bpl $58aa
5891: A5 54    lda $54
5893: D9 C0 03 cmp $03c0, y
5896: 30 3C    bmi $58d4
5898: 10 10    bpl $58aa
589A: A5 55    lda $55
589C: D9 C0 03 cmp $03c0, y
589F: 30 33    bmi $58d4
58A1: 10 07    bpl $58aa
58A3: B9 C0 03 lda $03c0, y
58A6: C5 55    cmp $55
58A8: 30 2A    bmi $58d4
58AA: C8       iny
58AB: B9 C0 03 lda $03c0, y
58AE: 29 0F    and #$0f
58B0: A2 02    ldx #$02
58B2: C9 00    cmp #$00
58B4: F0 16    beq $58cc
58B6: C9 02    cmp #$02
58B8: F0 12    beq $58cc
58BA: A2 01    ldx #$01
58BC: C9 01    cmp #$01
58BE: F0 0C    beq $58cc
58C0: C9 03    cmp #$03
58C2: F0 08    beq $58cc
58C4: A2 04    ldx #$04
58C6: C9 06    cmp #$06
58C8: 10 02    bpl $58cc
58CA: A2 08    ldx #$08
58CC: 86 56    stx $56
58CE: C8       iny
58CF: 98       tya
58D0: 29 3F    and #$3f
58D2: 85 58    sta $58
58D4: 4C 5B 56 jmp $565b

58E9: A0 00    ldy #$00
58EB: A9 30    lda #$30
58ED: 99 00 04 sta $0400, y
58F0: C8       iny
58F1: D0 FA    bne $58ed
58F3: 99 00 05 sta $0500, y
58F6: C8       iny
58F7: D0 FA    bne $58f3
58F9: 99 00 06 sta $0600, y
58FC: C8       iny
58FD: D0 FA    bne $58f9
58FF: 99 00 07 sta $0700, y
5902: C8       iny
5903: D0 FA    bne $58ff
5905: 60       rts
5906: 78       sei
5907: A2 00    ldx #$00
5909: A9 00    lda #$00
590B: 95 00    sta $00, x
590D: E8       inx
590E: D0 FB    bne $590b
5910: A2 FF    ldx #$ff
5912: 9A       txs
5913: D8       cld
5914: B8       clv
5915: 20 07 4B jsr $4b07
5918: 20 3C 4B jsr $4b3c
591B: 20 24 4B jsr $4b24
591E: A9 00    lda #$00
5920: 85 F4    sta $f4
5922: 85 F5    sta $f5
5924: A9 00    lda #$00
5926: 8D 00 22 sta scroll_x_2200
5929: 8D 00 23 sta scroll_y_2300
592C: 8D 00 21 sta sound_2100
592F: 8D 01 21 sta sound_2101
5932: 8D 02 21 sta sound_2102
5935: 8D 03 21 sta flipscreen_2103
5938: 85 F3    sta $f3
593A: 85 FC    sta $fc
593C: A9 04    lda #$04
593E: 85 E0    sta $e0
5940: A9 21    lda #$21
5942: 85 E1    sta $e1
5944: A9 00    lda #$00
5946: 85 FD    sta $fd
5948: A9 C0    lda #$c0
594A: 85 E2    sta $e2
594C: A9 03    lda #$03
594E: 85 E3    sta $e3
5950: A9 01    lda #$01
5952: 85 FB    sta $fb
5954: 20 EE 35 jsr $35ee
5957: 20 32 35 jsr $3532
595A: A9 05    lda #$05
595C: 85 DF    sta $df
595E: A9 90    lda #$90
5960: 85 17    sta $17
5962: A9 02    lda #$02
5964: 85 18    sta $18
5966: A9 93    lda #$93
5968: 85 19    sta $19
596A: A9 59    lda #$59
596C: 85 1A    sta $1a
596E: A0 28    ldy #$28
5970: B1 19    lda ($19), y
5972: 91 17    sta ($17), y
5974: 88       dey
5975: 10 F9    bpl $5970
5977: A9 D0    lda #$d0
5979: 85 17    sta $17
597B: A9 02    lda #$02
597D: 85 18    sta $18
597F: A9 BB    lda #$bb
5981: 85 19    sta $19
5983: A9 59    lda #$59
5985: 85 1A    sta $1a
5987: A0 1E    ldy #$1e
5989: B1 19    lda ($19), y
598B: 91 17    sta ($17), y
598D: 88       dey
598E: 10 F9    bpl $5989
5990: 4C D9 59 jmp $59d9

59D9: A9 FF    lda #$ff
59DB: 85 FC    sta $fc
59DD: 58       cli
59DE: A5 A8    lda $a8
59E0: 29 78    and #$78
59E2: 85 A8    sta $a8
59E4: 8D 03 21 sta flipscreen_2103
59E7: A5 BE    lda $be
59E9: C9 10    cmp #$10
59EB: B0 03    bcs $59f0
59ED: 4C 66 5A jmp $5a66
59F0: A9 00    lda #$00
59F2: 85 B0    sta $b0
59F4: 85 B1    sta $b1
59F6: 8D 00 21 sta sound_2100
59F9: 8D 01 21 sta sound_2101
59FC: 8D 02 21 sta sound_2102
59FF: 8D 03 21 sta flipscreen_2103
5A02: A0 05    ldy #$05
5A04: 46 F2    lsr $f2
5A06: 66 F1    ror $f1
5A08: 66 F0    ror $f0
5A0A: 88       dey
5A0B: 10 F7    bpl $5a04
5A0D: A5 F0    lda $f0
5A0F: 85 0D    sta $0d
5A11: A5 F1    lda $f1
5A13: 85 0E    sta $0e
5A15: A5 F2    lda $f2
5A17: 85 0F    sta $0f
5A19: A0 03    ldy #$03
5A1B: 46 F2    lsr $f2
5A1D: 66 F1    ror $f1
5A1F: 66 F0    ror $f0
5A21: 88       dey
5A22: 10 F7    bpl $5a1b
5A24: A5 0D    lda $0d
5A26: 18       clc
5A27: 65 F0    adc $f0
5A29: 85 17    sta $17
5A2B: A5 0E    lda $0e
5A2D: 65 F1    adc $f1
5A2F: 85 18    sta $18
5A31: A9 00    lda #$00
5A33: 85 19    sta $19
5A35: E6 19    inc $19
5A37: A5 17    lda $17
5A39: 38       sec
5A3A: E9 64    sbc #$64
5A3C: 85 17    sta $17
5A3E: A5 18    lda $18
5A40: E9 00    sbc #$00
5A42: 85 18    sta $18
5A44: B0 EF    bcs $5a35
5A46: C6 19    dec $19
5A48: A5 17    lda $17
5A4A: 18       clc
5A4B: 69 64    adc #$64
5A4D: 85 17    sta $17
5A4F: A5 18    lda $18
5A51: 69 00    adc #$00
5A53: 85 18    sta $18
5A55: A4 17    ldy $17
5A57: B9 90 34 lda $3490, y
5A5A: 85 0D    sta $0d
5A5C: A4 19    ldy $19
5A5E: B9 90 34 lda $3490, y
5A61: 85 0E    sta $0e
5A63: 20 00 50 jsr $5000
5A66: A5 A8    lda $a8
5A68: 29 7F    and #$7f
5A6A: 85 A8    sta $a8
5A6C: 8D 03 21 sta flipscreen_2103
5A6F: A9 00    lda #$00
5A71: 20 00 40 jsr $4000
5A74: A9 83    lda #$83
5A76: 85 17    sta $17
5A78: A9 04    lda #$04
5A7A: 85 18    sta $18
5A7C: A6 0D    ldx $0d
5A7E: A5 0E    lda $0e
5A80: 20 D1 4B jsr $4bd1
5A83: A9 06    lda #$06
5A85: 85 18    sta $18
5A87: A9 01    lda #$01
5A89: 85 17    sta $17
5A8B: A2 00    ldx #$00
5A8D: CA       dex
5A8E: D0 FD    bne $5a8d
5A90: C6 17    dec $17
5A92: D0 F9    bne $5a8d
5A94: C6 18    dec $18
5A96: D0 F5    bne $5a8d
5A98: 20 01 54 jsr $5401
5A9B: A9 0C    lda #$0c
5A9D: 85 18    sta $18
5A9F: A9 01    lda #$01
5AA1: 85 17    sta $17
5AA3: A2 00    ldx #$00
5AA5: CA       dex
5AA6: D0 FD    bne $5aa5
5AA8: C6 17    dec $17
5AAA: D0 F9    bne $5aa5
5AAC: C6 18    dec $18
5AAE: D0 F5    bne $5aa5
5AB0: AD 04 21 lda in0_2104
5AB3: 29 10    and #$10
5AB5: D0 F9    bne $5ab0
5AB7: A9 03    lda #$03
5AB9: 20 00 40 jsr $4000
5ABC: AD 04 21 lda in0_2104
5ABF: 29 10    and #$10
5AC1: F0 0A    beq $5acd
5AC3: A9 02    lda #$02
5AC5: 8D 3F 0F sta $0f3f
5AC8: A9 09    lda #$09
5ACA: 8D 3F 07 sta $073f
5ACD: A9 03    lda #$03
5ACF: 85 18    sta $18
5AD1: A9 01    lda #$01
5AD3: 85 17    sta $17
5AD5: A2 00    ldx #$00
5AD7: CA       dex
5AD8: D0 FD    bne $5ad7
5ADA: C6 17    dec $17
5ADC: D0 F9    bne $5ad7
5ADE: C6 18    dec $18
5AE0: D0 F5    bne $5ad7
5AE2: A9 40    lda #$40
5AE4: 85 19    sta $19
5AE6: A9 00    lda #$00
5AE8: 85 16    sta $16
5AEA: A9 84    lda #$84
5AEC: 85 31    sta $31
5AEE: A9 0C    lda #$0c
5AF0: 85 32    sta $32
5AF2: A0 06    ldy #$06
5AF4: A5 16    lda $16
5AF6: 91 31    sta ($31), y		; [video_address]
5AF8: 88       dey
5AF9: 10 FB    bpl $5af6
5AFB: A5 31    lda $31
5AFD: 18       clc
5AFE: 69 20    adc #$20
5B00: 85 31    sta $31
5B02: A5 32    lda $32
5B04: 69 00    adc #$00
5B06: 85 32    sta $32
5B08: A5 32    lda $32
5B0A: C9 10    cmp #$10
5B0C: 90 E4    bcc $5af2
5B0E: A5 16    lda $16
5B10: 18       clc
5B11: 69 08    adc #$08
5B13: 85 16    sta $16
5B15: A9 01    lda #$01
5B17: 85 18    sta $18
5B19: A9 20    lda #$20
5B1B: 85 17    sta $17
5B1D: A2 00    ldx #$00
5B1F: CA       dex
5B20: D0 FD    bne $5b1f
5B22: C6 17    dec $17
5B24: D0 F9    bne $5b1f
5B26: C6 18    dec $18
5B28: D0 F5    bne $5b1f
5B2A: C6 19    dec $19
5B2C: D0 BC    bne $5aea
5B2E: A9 04    lda #$04
5B30: 20 00 40 jsr $4000
5B33: A9 0B    lda #$0b
5B35: 85 18    sta $18
5B37: A9 01    lda #$01
5B39: 85 17    sta $17
5B3B: A2 00    ldx #$00
5B3D: CA       dex
5B3E: D0 FD    bne $5b3d
5B40: C6 17    dec $17
5B42: D0 F9    bne $5b3d
5B44: C6 18    dec $18
5B46: D0 F5    bne $5b3d
5B48: AD 04 21 lda in0_2104
5B4B: 29 10    and #$10
5B4D: D0 F9    bne $5b48
5B4F: A9 03    lda #$03
5B51: 85 BE    sta $be
5B53: A9 00    lda #$00
5B55: 85 BC    sta $bc
5B57: 20 99 32 jsr $3299
5B5A: A9 00    lda #$00
5B5C: 85 FC    sta $fc
5B5E: 4C 5F 30 jmp $305f
5B61: A9 00    lda #$00
5B63: 85 F4    sta $f4
5B65: A5 A8    lda $a8
5B67: 29 7F    and #$7f
5B69: 85 A8    sta $a8
5B6B: 8D 03 21 sta flipscreen_2103
5B6E: A5 BE    lda $be
5B70: C9 20    cmp #$20
5B72: B0 19    bcs $5b8d
5B74: A9 03    lda #$03
5B76: 2D 06 21 and dsw_2106
5B79: AA       tax
5B7A: BD F0 5B lda $5bf0, x
5B7D: 85 B0    sta $b0
5B7F: C6 B0    dec $b0
5B81: A9 20    lda #$20
5B83: 2D 06 21 and dsw_2106
5B86: D0 3D    bne $5bc5
5B88: C6 F5    dec $f5
5B8A: 4C C5 5B jmp $5bc5
5B8D: A9 03    lda #$03
5B8F: 2D 06 21 and dsw_2106
5B92: AA       tax
5B93: BD F0 5B lda $5bf0, x
5B96: 85 B0    sta $b0
5B98: 85 B1    sta $b1
5B9A: A9 20    lda #$20
5B9C: 2D 06 21 and dsw_2106
5B9F: D0 04    bne $5ba5
5BA1: C6 F5    dec $f5
5BA3: C6 F5    dec $f5
5BA5: A9 01    lda #$01
5BA7: 85 BC    sta $bc
5BA9: 85 AD    sta $ad
5BAB: A9 30    lda #$30
5BAD: 85 BE    sta $be
5BAF: 20 EE 5C jsr $5cee
5BB2: A5 BA    lda $ba
5BB4: 85 AF    sta $af
5BB6: A9 20    lda #$20
5BB8: 85 BE    sta $be
5BBA: A9 01    lda #$01
5BBC: 20 00 40 jsr $4000
5BBF: C6 B0    dec $b0
5BC1: A9 02    lda #$02
5BC3: 85 AB    sta $ab
5BC5: A9 00    lda #$00
5BC7: 85 B2    sta $b2
5BC9: 85 B3    sta $b3
5BCB: 85 B4    sta $b4
5BCD: 85 B5    sta $b5
5BCF: 85 B6    sta $b6
5BD1: 85 B7    sta $b7
5BD3: 85 B8    sta $b8
5BD5: 85 B9    sta $b9
5BD7: 85 BC    sta $bc
5BD9: 85 BD    sta $bd
5BDB: 85 F0    sta $f0
5BDD: 85 F1    sta $f1
5BDF: 85 F2    sta $f2
5BE1: A9 66    lda #$66
5BE3: 8D 02 21 sta sound_2102
5BE6: 20 99 32 jsr $3299
5BE9: A9 00    lda #$00
5BEB: 85 FC    sta $fc
5BED: 4C 5F 30 jmp $305f
5BF4: A5 E9    lda $e9
5BF6: 0A       asl a
5BF7: 0A       asl a
5BF8: 0A       asl a
5BF9: 85 16    sta $16
5BFB: 0A       asl a
5BFC: 85 1F    sta $1f
5BFE: A5 40    lda $40
5C00: F0 1E    beq $5c20
5C02: A9 40    lda #$40
5C04: 18       clc
5C05: 65 16    adc $16
5C07: 85 17    sta $17
5C09: A9 60    lda #$60
5C0B: 69 00    adc #$00
5C0D: 85 18    sta $18
5C0F: A9 F8    lda #$f8
5C11: 85 19    sta $19
5C13: A9 19    lda #$19
5C15: 85 1A    sta $1a
5C17: A0 07    ldy #$07
5C19: B1 17    lda ($17), y
5C1B: 91 19    sta ($19), y
5C1D: 88       dey
5C1E: 10 F9    bpl $5c19
5C20: A5 41    lda $41
5C22: F0 1E    beq $5c42
5C24: A9 80    lda #$80
5C26: 18       clc
5C27: 65 16    adc $16
5C29: 85 17    sta $17
5C2B: A9 60    lda #$60
5C2D: 69 00    adc #$00
5C2F: 85 18    sta $18
5C31: A9 00    lda #$00
5C33: 85 19    sta $19
5C35: A9 1A    lda #$1a
5C37: 85 1A    sta $1a
5C39: A0 07    ldy #$07
5C3B: B1 17    lda ($17), y
5C3D: 91 19    sta ($19), y
5C3F: 88       dey
5C40: 10 F9    bpl $5c3b
5C42: A5 42    lda $42
5C44: F0 1E    beq $5c64
5C46: A9 00    lda #$00
5C48: 18       clc
5C49: 65 16    adc $16
5C4B: 85 17    sta $17
5C4D: A9 60    lda #$60
5C4F: 69 00    adc #$00
5C51: 85 18    sta $18
5C53: A9 E8    lda #$e8
5C55: 85 19    sta $19
5C57: A9 19    lda #$19
5C59: 85 1A    sta $1a
5C5B: A0 07    ldy #$07
5C5D: B1 17    lda ($17), y
5C5F: 91 19    sta ($19), y
5C61: 88       dey
5C62: 10 F9    bpl $5c5d
5C64: A5 43    lda $43
5C66: F0 26    beq $5c8e
5C68: A9 00    lda #$00
5C6A: 18       clc
5C6B: 65 16    adc $16
5C6D: 85 17    sta $17
5C6F: A9 60    lda #$60
5C71: 69 00    adc #$00
5C73: 85 18    sta $18
5C75: A9 F0    lda #$f0
5C77: 85 19    sta $19
5C79: A9 19    lda #$19
5C7B: 85 1A    sta $1a
5C7D: A0 07    ldy #$07
5C7F: 84 1B    sty $1b
5C81: 98       tya
5C82: 49 07    eor #$07
5C84: A8       tay
5C85: B1 17    lda ($17), y
5C87: A4 1B    ldy $1b
5C89: 91 19    sta ($19), y
5C8B: 88       dey
5C8C: 10 F1    bpl $5c7f
5C8E: 60       rts
5C8F: A5 ED    lda $ed
5C91: D0 03    bne $5c96
5C93: 4C DE 5C jmp $5cde
5C96: A5 5A    lda $5a
5C98: D0 03    bne $5c9d
5C9A: 4C DE 5C jmp $5cde
5C9D: A5 53    lda $53
5C9F: C9 01    cmp #$01
5CA1: F0 2C    beq $5ccf
5CA3: C9 02    cmp #$02
5CA5: F0 1C    beq $5cc3
5CA7: C9 04    cmp #$04
5CA9: F0 0C    beq $5cb7
5CAB: A5 3B    lda $3b
5CAD: 38       sec
5CAE: E5 51    sbc $51
5CB0: C9 02    cmp #$02
5CB2: 10 27    bpl $5cdb
5CB4: 4C DE 5C jmp $5cde
5CB7: A5 51    lda $51
5CB9: 38       sec
5CBA: E5 3B    sbc $3b
5CBC: C9 02    cmp #$02
5CBE: 10 1B    bpl $5cdb
5CC0: 4C DE 5C jmp $5cde
5CC3: A5 52    lda $52
5CC5: 38       sec
5CC6: E5 3C    sbc $3c
5CC8: C9 02    cmp #$02
5CCA: 10 0F    bpl $5cdb
5CCC: 4C DE 5C jmp $5cde
5CCF: A5 3C    lda $3c
5CD1: 38       sec
5CD2: E5 52    sbc $52
5CD4: C9 02    cmp #$02
5CD6: 10 03    bpl $5cdb
5CD8: 4C DE 5C jmp $5cde
5CDB: 20 00 AF jsr $af00
5CDE: A5 53    lda $53
5CE0: C9 04    cmp #$04
5CE2: F0 04    beq $5ce8
5CE4: C9 08    cmp #$08
5CE6: D0 03    bne $5ceb
5CE8: 4C 00 A0 jmp $a000
5CEB: 4C 00 A3 jmp $a300
5CEE: A5 BE    lda $be
5CF0: C9 30    cmp #$30
5CF2: 30 13    bmi $5d07
5CF4: A9 40    lda #$40
5CF6: 85 17    sta $17
5CF8: A9 03    lda #$03
5CFA: 85 18    sta $18
5CFC: A9 40    lda #$40
5CFE: 85 D9    sta $d9
5D00: A9 03    lda #$03
5D02: 85 DA    sta $da
5D04: 4C 0F 5D jmp $5d0f
5D07: A9 00    lda #$00
5D09: 85 17    sta $17
5D0B: A9 03    lda #$03
5D0D: 85 18    sta $18
5D0F: A5 BC    lda $bc
5D11: 29 1F    and #$1f
5D13: A8       tay
5D14: B9 DA 5D lda $5dda, y
5D17: 85 1F    sta $1f
5D19: 98       tya
5D1A: 0A       asl a
5D1B: A8       tay
5D1C: B9 9A 5D lda $5d9a, y
5D1F: 85 19    sta $19
5D21: B9 9B 5D lda $5d9b, y
5D24: 85 1A    sta $1a
5D26: A9 00    lda #$00
5D28: 85 BA    sta $ba
5D2A: A0 00    ldy #$00
5D2C: B1 19    lda ($19), y
5D2E: 85 1B    sta $1b
5D30: C8       iny
5D31: B1 19    lda ($19), y
5D33: 85 1C    sta $1c
5D35: 30 59    bmi $5d90
5D37: E6 BA    inc $ba
5D39: A9 1B    lda #$1b
5D3B: 38       sec
5D3C: E5 1B    sbc $1b
5D3E: 18       clc
5D3F: 2A       rol a
5D40: 2A       rol a
5D41: 2A       rol a
5D42: 2A       rol a
5D43: 85 1D    sta $1d
5D45: A9 00    lda #$00
5D47: 69 00    adc #$00
5D49: 0A       asl a
5D4A: 26 1D    rol $1d
5D4C: 69 04    adc #$04
5D4E: 85 1E    sta $1e
5D50: A9 1F    lda #$1f
5D52: 38       sec
5D53: E5 1C    sbc $1c
5D55: 18       clc
5D56: 65 1D    adc $1d
5D58: 85 1D    sta $1d
5D5A: A0 00    ldy #$00
5D5C: A5 1D    lda $1d
5D5E: 91 17    sta ($17), y
5D60: C8       iny
5D61: A5 1E    lda $1e
5D63: 18       clc
5D64: 69 04    adc #$04
5D66: 91 17    sta ($17), y
5D68: 18       clc
5D69: 69 04    adc #$04
5D6B: 85 1E    sta $1e
5D6D: A0 00    ldy #$00
5D6F: A5 1F    lda $1f
5D71: 91 1D    sta ($1d), y		; [video_address]
5D73: A5 17    lda $17
5D75: 18       clc
5D76: 69 02    adc #$02
5D78: 85 17    sta $17
5D7A: A5 18    lda $18
5D7C: 69 00    adc #$00
5D7E: 85 18    sta $18
5D80: A5 19    lda $19
5D82: 18       clc
5D83: 69 02    adc #$02
5D85: 85 19    sta $19
5D87: A5 1A    lda $1a
5D89: 69 00    adc #$00
5D8B: 85 1A    sta $1a
5D8D: 4C 2A 5D jmp $5d2a
5D90: A9 FF    lda #$ff
5D92: A0 00    ldy #$00
5D94: 91 17    sta ($17), y
5D96: C8       iny
5D97: 91 17    sta ($17), y
5D99: 60       rts

5DF9: 08       php
5DFA: A9 02    lda #$02
5DFC: 85 52    sta $52
5DFE: 85 55    sta $55
5E00: A9 10    lda #$10
5E02: 85 51    sta $51
5E04: A9 08    lda #$08
5E06: 85 54    sta $54
5E08: A9 04    lda #$04
5E0A: 85 53    sta $53
5E0C: 85 56    sta $56
5E0E: A9 01    lda #$01
5E10: 85 42    sta $42
5E12: A9 FF    lda #$ff
5E14: 85 A9    sta $a9
5E16: A9 00    lda #$00
5E18: 85 57    sta $57
5E1A: 85 58    sta $58
5E1C: 85 5E    sta $5e
5E1E: 85 5B    sta $5b
5E20: 85 5A    sta $5a
5E22: 85 3D    sta $3d
5E24: 85 EC    sta $ec
5E26: 85 EE    sta $ee
5E28: 85 E9    sta $e9
5E2A: 85 ED    sta $ed
5E2C: 85 BB    sta $bb
5E2E: 85 40    sta $40
5E30: 85 41    sta $41
5E32: 85 43    sta $43
5E34: 85 20    sta $20
5E36: 85 21    sta $21
5E38: 85 22    sta $22
5E3A: 85 23    sta $23
5E3C: 85 24    sta $24
5E3E: 85 25    sta $25
5E40: 85 26    sta $26
5E42: 85 27    sta $27
5E44: 85 3B    sta $3b
5E46: 85 3C    sta $3c
5E48: 85 BF    sta $bf
5E4A: 85 48    sta $48
5E4C: 60       rts
5E4D: A0 03    ldy #$03
5E4F: A5 16    lda $16
5E51: C9 04    cmp #$04
5E53: 30 02    bmi $5e57
5E55: A0 04    ldy #$04
5E57: A9 00    lda #$00
5E59: 85 17    sta $17
5E5B: A8       tay
5E5C: A9 0C    lda #$0c
5E5E: 85 18    sta $18
5E60: B1 17    lda ($17), y
5E62: 29 F8    and #$f8
5E64: 05 16    ora $16
5E66: 91 17    sta ($17), y   ; [video_address]
5E68: C8       iny
5E69: D0 F5    bne $5e60
5E6B: E6 18    inc $18
5E6D: A5 18    lda $18
5E6F: C9 10    cmp #$10
5E71: D0 ED    bne $5e60
5E73: E6 16    inc $16
5E75: A5 16    lda $16
5E77: 29 07    and #$07
5E79: 85 16    sta $16
5E7B: A9 01    lda #$01
5E7D: 85 18    sta $18
5E7F: A9 20    lda #$20
5E81: 85 17    sta $17
5E83: A2 00    ldx #$00
5E85: CA       dex
5E86: D0 FD    bne $5e85
5E88: C6 17    dec $17
5E8A: D0 F9    bne $5e85
5E8C: C6 18    dec $18
5E8E: D0 F5    bne $5e85
5E90: 60       rts
5E91: A5 56    lda $56
5E93: C9 01    cmp #$01
5E95: F0 12    beq $5ea9
5E97: C9 02    cmp #$02
5E99: F0 13    beq $5eae
5E9B: C9 04    cmp #$04
5E9D: F0 05    beq $5ea4
5E9F: C6 43    dec $43
5EA1: 4C B0 5E jmp $5eb0
5EA4: C6 42    dec $42
5EA6: 4C B0 5E jmp $5eb0
5EA9: C6 40    dec $40
5EAB: 4C B0 5E jmp $5eb0
5EAE: C6 41    dec $41
5EB0: 10 05    bpl $5eb7
5EB2: A9 96    lda #$96
5EB4: 4C 87 3F jmp $3f87
5EB7: A5 54    lda $54
5EB9: 85 19    sta $19
5EBB: A5 55    lda $55
5EBD: 85 1A    sta $1a
5EBF: A9 1B    lda #$1b
5EC1: 38       sec
5EC2: E5 19    sbc $19
5EC4: 18       clc
5EC5: 2A       rol a
5EC6: 2A       rol a
5EC7: 2A       rol a
5EC8: 2A       rol a
5EC9: 85 17    sta $17
5ECB: A9 00    lda #$00
5ECD: 69 00    adc #$00
5ECF: 0A       asl a
5ED0: 26 17    rol $17
5ED2: 69 04    adc #$04
5ED4: 85 18    sta $18
5ED6: A9 1F    lda #$1f
5ED8: 38       sec
5ED9: E5 1A    sbc $1a
5EDB: 18       clc
5EDC: 65 17    adc $17
5EDE: 85 17    sta $17
5EE0: A4 58    ldy $58
5EE2: C8       iny
5EE3: B9 C0 03 lda $03c0, y
5EE6: 29 0F    and #$0f
5EE8: D0 03    bne $5eed
5EEA: 4C 64 5F jmp $5f64
5EED: C9 01    cmp #$01
5EEF: F0 53    beq $5f44
5EF1: C9 02    cmp #$02
5EF3: D0 03    bne $5ef8
5EF5: 4C 64 5F jmp $5f64
5EF8: C9 03    cmp #$03
5EFA: F0 48    beq $5f44
5EFC: C9 04    cmp #$04
5EFE: F0 24    beq $5f24
5F00: C9 05    cmp #$05
5F02: F0 20    beq $5f24
5F04: A9 04    lda #$04
5F06: 85 56    sta $56
5F08: A5 17    lda $17
5F0A: 38       sec
5F0B: E9 21    sbc #$21
5F0D: 85 17    sta $17
5F0F: A5 18    lda $18
5F11: E9 00    sbc #$00
5F13: 85 18    sta $18
5F15: A0 02    ldy #$02
5F17: A2 03    ldx #$03
5F19: A9 EC    lda #$ec
5F1B: 85 19    sta $19
5F1D: A9 5F    lda #$5f
5F1F: 85 1A    sta $1a
5F21: 4C 81 5F jmp $5f81
5F24: A9 08    lda #$08
5F26: 85 56    sta $56
5F28: A5 17    lda $17
5F2A: 38       sec
5F2B: E9 21    sbc #$21
5F2D: 85 17    sta $17
5F2F: A5 18    lda $18
5F31: E9 00    sbc #$00
5F33: 85 18    sta $18
5F35: A0 02    ldy #$02
5F37: A2 03    ldx #$03
5F39: A9 E3    lda #$e3
5F3B: 85 19    sta $19
5F3D: A9 5F    lda #$5f
5F3F: 85 1A    sta $1a
5F41: 4C 81 5F jmp $5f81
5F44: A9 01    lda #$01
5F46: 85 56    sta $56
5F48: A5 17    lda $17
5F4A: 38       sec
5F4B: E9 21    sbc #$21
5F4D: 85 17    sta $17
5F4F: A5 18    lda $18
5F51: E9 00    sbc #$00
5F53: 85 18    sta $18
5F55: A0 03    ldy #$03
5F57: A2 02    ldx #$02
5F59: A9 DA    lda #$da
5F5B: 85 19    sta $19
5F5D: A9 5F    lda #$5f
5F5F: 85 1A    sta $1a
5F61: 4C 81 5F jmp $5f81
5F64: A9 02    lda #$02
5F66: 85 56    sta $56
5F68: A5 17    lda $17
5F6A: 38       sec
5F6B: E9 21    sbc #$21
5F6D: 85 17    sta $17
5F6F: A5 18    lda $18
5F71: E9 00    sbc #$00
5F73: 85 18    sta $18
5F75: A0 03    ldy #$03
5F77: A2 02    ldx #$02
5F79: A9 D1    lda #$d1
5F7B: 85 19    sta $19
5F7D: A9 5F    lda #$5f
5F7F: 85 1A    sta $1a
5F81: 84 16    sty $16
5F83: A9 48    lda #$48
5F85: 85 1B    sta $1b
5F87: A9 12    lda #$12
5F89: 85 1C    sta $1c
5F8B: A9 48    lda #$48
5F8D: 85 1D    sta $1d
5F8F: A9 1A    lda #$1a
5F91: 85 1E    sta $1e
5F93: A0 2F    ldy #$2f
5F95: A9 00    lda #$00
5F97: 91 1B    sta ($1b), y
5F99: 91 1D    sta ($1d), y
5F9B: 88       dey
5F9C: 10 F9    bpl $5f97
5F9E: A4 16    ldy $16
5FA0: A0 02    ldy #$02
5FA2: A2 02    ldx #$02
5FA4: B1 19    lda ($19), y
5FA6: 91 17    sta ($17), y   ; [video_address]
5FA8: 88       dey
5FA9: 10 F9    bpl $5fa4
5FAB: A5 17    lda $17
5FAD: 18       clc
5FAE: 69 20    adc #$20
5FB0: 85 17    sta $17
5FB2: A5 18    lda $18
5FB4: 69 00    adc #$00
5FB6: 85 18    sta $18
5FB8: A0 02    ldy #$02
5FBA: 98       tya
5FBB: 18       clc
5FBC: 69 01    adc #$01
5FBE: 18       clc
5FBF: 65 19    adc $19
5FC1: 85 19    sta $19
5FC3: A5 1A    lda $1a
5FC5: 69 00    adc #$00
5FC7: 85 1A    sta $1a
5FC9: CA       dex
5FCA: 10 D8    bpl $5fa4
5FCC: A9 04    lda #$04
5FCE: 85 EE    sta $ee
5FD0: 60       rts

boot_7800:
7800: A9 00    lda #$00
7802: 8D 00 21 sta sound_2100
7805: 8D 01 21 sta sound_2101
7808: 8D 03 21 sta flipscreen_2103
780B: 8D 02 21 sta sound_2102
780E: A2 00    ldx #$00
; memory test
7810: A9 55    lda #$55
7812: 95 00    sta $00, x
7814: E8       inx
7815: A9 AA    lda #$aa
7817: 95 00    sta $00, x
7819: E8       inx
781A: D0 F4    bne $7810
781C: A9 55    lda #$55
781E: D5 00    cmp $00, x
7820: D0 49    bne $786b
7822: E8       inx
7823: A9 AA    lda #$aa
7825: D5 00    cmp $00, x
7827: D0 42    bne $786b
7829: E8       inx
782A: D0 F0    bne $781c
782C: A9 AA    lda #$aa
782E: 95 00    sta $00, x
7830: E8       inx
7831: A9 55    lda #$55
7833: 95 00    sta $00, x
7835: E8       inx
7836: D0 F4    bne $782c
7838: A9 AA    lda #$aa
783A: D5 00    cmp $00, x
783C: D0 2D    bne $786b
783E: E8       inx
783F: A9 55    lda #$55
7841: D5 00    cmp $00, x
7843: D0 26    bne $786b
7845: E8       inx
7846: D0 F0    bne $7838
7848: 8A       txa
7849: 95 00    sta $00, x
784B: E8       inx
784C: D0 FA    bne $7848
784E: 8A       txa
784F: D5 00    cmp $00, x
7851: D0 18    bne $786b
7853: E8       inx
7854: D0 F8    bne $784e
7856: A0 00    ldy #$00
7858: 98       tya
7859: 95 00    sta $00, x
785B: 88       dey
785C: E8       inx
785D: D0 F9    bne $7858
785F: 98       tya
7860: D5 00    cmp $00, x
7862: D0 07    bne $786b
7864: 88       dey
7865: E8       inx
7866: D0 F7    bne $785f
7868: 4C 78 78 jmp $7878
; memory error
786B: A9 66    lda #$66
786D: 8D 02 21 sta sound_2102
7870: A9 0C    lda #$0c
7872: 8D 01 21 sta sound_2101
7875: 4C 75 78 jmp $7875

7878: A2 00    ldx #$00
787A: A9 55    lda #$55
787C: 9D 00 01 sta $0100, x
787F: E8       inx
7880: A9 AA    lda #$aa
7882: 9D 00 01 sta $0100, x
7885: E8       inx
7886: D0 F2    bne $787a
7888: A9 55    lda #$55
788A: DD 00 01 cmp $0100, x
788D: D0 52    bne $78e1
788F: E8       inx
7890: A9 AA    lda #$aa
7892: DD 00 01 cmp $0100, x
7895: D0 4A    bne $78e1
7897: E8       inx
7898: D0 EE    bne $7888
789A: A9 AA    lda #$aa
789C: 9D 00 01 sta $0100, x
789F: E8       inx
78A0: A9 55    lda #$55
78A2: 9D 00 01 sta $0100, x
78A5: E8       inx
78A6: D0 F2    bne $789a
78A8: A9 AA    lda #$aa
78AA: DD 00 01 cmp $0100, x
78AD: D0 32    bne $78e1
78AF: E8       inx
78B0: A9 55    lda #$55
78B2: DD 00 01 cmp $0100, x
78B5: D0 2A    bne $78e1
78B7: E8       inx
78B8: D0 EE    bne $78a8
78BA: 8A       txa
78BB: 9D 00 01 sta $0100, x
78BE: E8       inx
78BF: D0 F9    bne $78ba
78C1: 8A       txa
78C2: DD 00 01 cmp $0100, x
78C5: D0 1A    bne $78e1
78C7: E8       inx
78C8: D0 F7    bne $78c1
78CA: A0 00    ldy #$00
78CC: 98       tya
78CD: 9D 00 01 sta $0100, x
78D0: 88       dey
78D1: E8       inx
78D2: D0 F8    bne $78cc
78D4: 98       tya
78D5: DD 00 01 cmp $0100, x
78D8: D0 07    bne $78e1
78DA: 88       dey
78DB: E8       inx
78DC: D0 F6    bne $78d4
78DE: 4C EE 78 jmp $78ee
; memory error
78E1: A9 66    lda #$66
78E3: 8D 02 21 sta sound_2102
78E6: A9 0C    lda #$0c
78E8: 8D 01 21 sta sound_2101
78EB: 4C EB 78 jmp $78eb

78EE: A2 FF    ldx #$ff		; set high stack
78F0: 9A       txs
78F1: D8       cld
78F2: B8       clv
78F3: 20 F6 7E jsr $7ef6
78F6: 20 2B 7F jsr $7f2b
78F9: 20 13 7F jsr $7f13
78FC: A2 20    ldx #$20
78FE: A9 00    lda #$00
7900: 95 40    sta $40, x
7902: CA       dex
7903: 10 FB    bpl $7900
7905: A9 00    lda #$00
7907: 85 17    sta $17
7909: A9 02    lda #$02
790B: 85 18    sta $18
790D: 20 B5 7D jsr $7db5
7910: A5 16    lda $16
7912: 05 40    ora $40
7914: 85 40    sta $40
7916: A9 00    lda #$00
7918: 85 17    sta $17
791A: A9 03    lda #$03
791C: 85 18    sta $18
791E: 20 B5 7D jsr $7db5
7921: A5 16    lda $16
7923: 05 40    ora $40
7925: 85 40    sta $40
7927: A9 00    lda #$00
7929: 85 17    sta $17
792B: A9 04    lda #$04
792D: 85 18    sta $18
792F: 20 B5 7D jsr $7db5
7932: A5 16    lda $16
7934: 85 1F    sta $1f
7936: A9 00    lda #$00
7938: 85 17    sta $17
793A: A9 05    lda #$05
793C: 85 18    sta $18
793E: 20 B5 7D jsr $7db5
7941: A5 16    lda $16
7943: 05 1F    ora $1f
7945: 85 1F    sta $1f
7947: A9 00    lda #$00
7949: 85 17    sta $17
794B: A9 06    lda #$06
794D: 85 18    sta $18
794F: 20 B5 7D jsr $7db5
7952: A5 16    lda $16
7954: 05 1F    ora $1f
7956: 85 1F    sta $1f
7958: A9 00    lda #$00
795A: 85 17    sta $17
795C: A9 07    lda #$07
795E: 85 18    sta $18
7960: 20 B5 7D jsr $7db5
7963: A5 16    lda $16
7965: 05 1F    ora $1f
7967: 85 1F    sta $1f
7969: 29 02    and #$02
796B: F0 04    beq $7971
796D: A9 80    lda #$80
796F: 85 42    sta $42
7971: A5 1F    lda $1f
7973: 29 01    and #$01
7975: F0 04    beq $797b
7977: A9 80    lda #$80
7979: 85 41    sta $41
797B: A9 00    lda #$00
797D: 85 17    sta $17
797F: A9 08    lda #$08
7981: 85 18    sta $18
7983: 20 B5 7D jsr $7db5
7986: A5 16    lda $16
7988: 85 1F    sta $1f
798A: A9 00    lda #$00
798C: 85 17    sta $17
798E: A9 09    lda #$09
7990: 85 18    sta $18
7992: 20 B5 7D jsr $7db5
7995: A5 16    lda $16
7997: 05 1F    ora $1f
7999: 85 1F    sta $1f
799B: A9 00    lda #$00
799D: 85 17    sta $17
799F: A9 0A    lda #$0a
79A1: 85 18    sta $18
79A3: 20 B5 7D jsr $7db5
79A6: A5 16    lda $16
79A8: 05 1F    ora $1f
79AA: 85 1F    sta $1f
79AC: A9 00    lda #$00
79AE: 85 17    sta $17
79B0: A9 0B    lda #$0b
79B2: 85 18    sta $18
79B4: 20 B5 7D jsr $7db5
79B7: A5 16    lda $16
79B9: 05 1F    ora $1f
79BB: 85 1F    sta $1f
79BD: 29 02    and #$02
79BF: F0 04    beq $79c5
79C1: A9 80    lda #$80
79C3: 85 44    sta $44
79C5: A5 1F    lda $1f
79C7: 29 01    and #$01
79C9: F0 04    beq $79cf
79CB: A9 80    lda #$80
79CD: 85 43    sta $43
79CF: A9 00    lda #$00
79D1: 85 17    sta $17
79D3: A9 0C    lda #$0c
79D5: 85 18    sta $18
79D7: 20 2C 7E jsr $7e2c
79DA: A5 16    lda $16
79DC: 85 1F    sta $1f
79DE: A9 00    lda #$00
79E0: 85 17    sta $17
79E2: A9 0D    lda #$0d
79E4: 85 18    sta $18
79E6: 20 2C 7E jsr $7e2c
79E9: A5 16    lda $16
79EB: 05 1F    ora $1f
79ED: 85 1F    sta $1f
79EF: A9 00    lda #$00
79F1: 85 17    sta $17
79F3: A9 0E    lda #$0e
79F5: 85 18    sta $18
79F7: 20 2C 7E jsr $7e2c
79FA: A5 16    lda $16
79FC: 05 1F    ora $1f
79FE: 85 1F    sta $1f
7A00: A9 00    lda #$00
7A02: 85 17    sta $17
7A04: A9 0F    lda #$0f
7A06: 85 18    sta $18
7A08: 20 2C 7E jsr $7e2c
7A0B: A5 16    lda $16
7A0D: 05 1F    ora $1f
7A0F: 85 1F    sta $1f
7A11: 29 02    and #$02
7A13: F0 04    beq $7a19
7A15: A9 80    lda #$80
7A17: 85 46    sta $46
7A19: A5 1F    lda $1f
7A1B: 29 01    and #$01
7A1D: F0 04    beq $7a23
7A1F: A9 80    lda #$80
7A21: 85 45    sta $45
7A23: A9 00    lda #$00
7A25: 85 17    sta $17
7A27: A9 10    lda #$10
7A29: 85 18    sta $18
7A2B: A9 00    lda #$00
7A2D: 85 1F    sta $1f
7A2F: 20 B5 7D jsr $7db5
7A32: A5 16    lda $16
7A34: 05 1F    ora $1f
7A36: 85 1F    sta $1f
7A38: A5 18    lda $18
7A3A: 18       clc
7A3B: 69 01    adc #$01
7A3D: 85 18    sta $18
7A3F: C9 18    cmp #$18
7A41: 90 EC    bcc $7a2f
7A43: A5 1F    lda $1f
7A45: 85 47    sta $47
7A47: A9 00    lda #$00
7A49: 85 17    sta $17
7A4B: A9 18    lda #$18
7A4D: 85 18    sta $18
7A4F: A9 00    lda #$00
7A51: 85 1F    sta $1f
7A53: 20 B5 7D jsr $7db5
7A56: A5 16    lda $16
7A58: 05 1F    ora $1f
7A5A: 85 1F    sta $1f
7A5C: A5 18    lda $18
7A5E: 18       clc
7A5F: 69 01    adc #$01
7A61: 85 18    sta $18
7A63: C9 20    cmp #$20
7A65: 90 EC    bcc $7a53
7A67: A5 1F    lda $1f
7A69: 85 48    sta $48
7A6B: 20 2B 7F jsr $7f2b
7A6E: 20 13 7F jsr $7f13
7A71: A9 A6    lda #$a6
7A73: 85 17    sta $17
7A75: A9 7A    lda #$7a
7A77: 85 18    sta $18
7A79: A9 E3    lda #$e3
7A7B: 85 19    sta $19
7A7D: A9 06    lda #$06
7A7F: 85 1A    sta $1a
7A81: A0 00    ldy #$00
7A83: B1 17    lda ($17), y
7A85: 30 34    bmi $7abb
7A87: 91 19    sta ($19), y
7A89: A5 17    lda $17
7A8B: 18       clc
7A8C: 69 01    adc #$01
7A8E: 85 17    sta $17
7A90: A5 18    lda $18
7A92: 69 00    adc #$00
7A94: 85 18    sta $18
7A96: A5 19    lda $19
7A98: 38       sec
7A99: E9 20    sbc #$20
7A9B: 85 19    sta $19
7A9D: A5 1A    lda $1a
7A9F: E9 00    sbc #$00
7AA1: 85 1A    sta $1a
7AA3: 4C 83 7A jmp $7a83
; power up diagnostics printed
7ABB: A9 01    lda #$01
7ABD: 8D E5 0D sta $0de5
7AC0: 8D C5 0D sta $0dc5
7AC3: 8D A5 0D sta $0da5
7AC6: 8D 13 0E sta $0e13
7AC9: 8D F3 0D sta $0df3
7ACC: 8D D3 0D sta $0dd3
7ACF: 8D B3 0D sta $0db3
7AD2: A9 1B    lda #$1b
7AD4: 8D E5 05 sta $05e5
7AD7: A9 0A    lda #$0a
7AD9: 8D C5 05 sta $05c5
7ADC: A9 16    lda #$16
7ADE: 8D A5 05 sta $05a5
7AE1: A9 19    lda #$19
7AE3: 8D 13 06 sta $0613
7AE6: A9 1B    lda #$1b
7AE8: 8D F3 05 sta $05f3
7AEB: A9 18    lda #$18
7AED: 8D D3 05 sta $05d3
7AF0: A9 16    lda #$16
7AF2: 8D B3 05 sta $05b3
7AF5: A9 07    lda #$07
7AF7: 85 17    sta $17
7AF9: A9 07    lda #$07
7AFB: 85 18    sta $18
7AFD: A2 04    ldx #$04
7AFF: 20 6A 7E jsr $7e6a
7B02: A5 17    lda $17
7B04: 18       clc
7B05: 69 02    adc #$02
7B07: 85 17    sta $17
7B09: A5 18    lda $18
7B0B: 69 00    adc #$00
7B0D: 85 18    sta $18
7B0F: CA       dex
7B10: 10 ED    bpl $7aff
7B12: A9 15    lda #$15
7B14: 85 17    sta $17
7B16: A9 07    lda #$07
7B18: 85 18    sta $18
7B1A: A2 03    ldx #$03
7B1C: 20 6A 7E jsr $7e6a
7B1F: A5 17    lda $17
7B21: 18       clc
7B22: 69 02    adc #$02
7B24: 85 17    sta $17
7B26: A5 18    lda $18
7B28: 69 00    adc #$00
7B2A: 85 18    sta $18
7B2C: CA       dex
7B2D: 10 ED    bpl $7b1c
7B2F: A9 47    lda #$47
7B31: 85 17    sta $17
7B33: A9 05    lda #$05
7B35: 85 18    sta $18
7B37: A2 03    ldx #$03
7B39: 20 6A 7E jsr $7e6a
7B3C: A5 17    lda $17
7B3E: 18       clc
7B3F: 69 02    adc #$02
7B41: 85 17    sta $17
7B43: A5 18    lda $18
7B45: 69 00    adc #$00
7B47: 85 18    sta $18
7B49: CA       dex
7B4A: 10 ED    bpl $7b39
7B4C: A9 55    lda #$55
7B4E: 85 17    sta $17
7B50: A9 05    lda #$05
7B52: 85 18    sta $18
7B54: A2 03    ldx #$03
7B56: 20 6A 7E jsr $7e6a
7B59: A5 17    lda $17
7B5B: 18       clc
7B5C: 69 02    adc #$02
7B5E: 85 17    sta $17
7B60: A5 18    lda $18
7B62: 69 00    adc #$00
7B64: 85 18    sta $18
7B66: CA       dex
7B67: 10 ED    bpl $7b56
7B69: A9 A7    lda #$a7
7B6B: 85 17    sta $17
7B6D: A9 06    lda #$06
7B6F: 85 18    sta $18
7B71: A9 9C    lda #$9c
7B73: 85 19    sta $19
7B75: A9 7B    lda #$7b
7B77: 85 1A    sta $1a
7B79: A9 00    lda #$00
7B7B: 85 1F    sta $1f
7B7D: A4 1F    ldy $1f
7B7F: B1 19    lda ($19), y
7B81: 20 E1 7E jsr $7ee1
7B84: A5 17    lda $17
7B86: 18       clc
7B87: 69 02    adc #$02
7B89: 85 17    sta $17
7B8B: A5 18    lda $18
7B8D: 69 00    adc #$00
7B8F: 85 18    sta $18
7B91: E6 1F    inc $1f
7B93: A5 1F    lda $1f
7B95: C9 05    cmp #$05
7B97: D0 E4    bne $7b7d
7B99: 4C A1 7B jmp $7ba1

7BA1: A9 01    lda #$01
7BA3: 8D DB 06 sta $06db
7BA6: A9 00    lda #$00
7BA8: 8D BB 06 sta $06bb
7BAB: A9 07    lda #$07
7BAD: 8D B5 06 sta $06b5
7BB0: A9 08    lda #$08
7BB2: 8D B7 06 sta $06b7
7BB5: A9 09    lda #$09
7BB7: 8D B9 06 sta $06b9
7BBA: A9 E7    lda #$e7
7BBC: 85 17    sta $17
7BBE: A9 04    lda #$04
7BC0: 85 18    sta $18
7BC2: A9 ED    lda #$ed
7BC4: 85 19    sta $19
7BC6: A9 7B    lda #$7b
7BC8: 85 1A    sta $1a
7BCA: A9 00    lda #$00
7BCC: 85 1F    sta $1f
7BCE: A4 1F    ldy $1f
7BD0: B1 19    lda ($19), y
7BD2: 20 E1 7E jsr $7ee1
7BD5: A5 17    lda $17
7BD7: 18       clc
7BD8: 69 02    adc #$02
7BDA: 85 17    sta $17
7BDC: A5 18    lda $18
7BDE: 69 00    adc #$00
7BE0: 85 18    sta $18
7BE2: E6 1F    inc $1f
7BE4: A5 1F    lda $1f
7BE6: C9 04    cmp #$04
7BE8: D0 E4    bne $7bce
7BEA: 4C F1 7B jmp $7bf1

7BF1: A9 F5    lda #$f5
7BF3: 85 17    sta $17
7BF5: A9 04    lda #$04
7BF7: 85 18    sta $18
7BF9: A9 24    lda #$24
7BFB: 85 19    sta $19
7BFD: A9 7C    lda #$7c
7BFF: 85 1A    sta $1a
7C01: A9 00    lda #$00
7C03: 85 1F    sta $1f
7C05: A4 1F    ldy $1f
7C07: B1 19    lda ($19), y
7C09: 20 E1 7E jsr $7ee1
7C0C: A5 17    lda $17
7C0E: 18       clc
7C0F: 69 02    adc #$02
7C11: 85 17    sta $17
7C13: A5 18    lda $18
7C15: 69 00    adc #$00
7C17: 85 18    sta $18
7C19: E6 1F    inc $1f
7C1B: A5 1F    lda $1f
7C1D: C9 04    cmp #$04
7C1F: D0 E4    bne $7c05
7C21: 4C 28 7C jmp $7c28

7C28: A9 72    lda #$72
7C2A: 85 1D    sta $1d
7C2C: A9 7C    lda #$7c
7C2E: 85 1E    sta $1e
7C30: A9 84    lda #$84
7C32: 85 19    sta $19
7C34: A9 7C    lda #$7c
7C36: 85 1A    sta $1a
7C38: A0 00    ldy #$00
7C3A: B1 19    lda ($19), y
7C3C: 30 4F    bmi $7c8d
7C3E: AA       tax
7C3F: B1 1D    lda ($1d), y
7C41: 85 17    sta $17
7C43: C8       iny
7C44: B1 1D    lda ($1d), y
7C46: 85 18    sta $18
7C48: B5 00    lda $00, x
7C4A: F0 06    beq $7c52
7C4C: 20 AB 7E jsr $7eab
7C4F: 4C 55 7C jmp $7c55

7C52: 20 77 7E jsr $7e77
7C55: A5 1D    lda $1d
7C57: 18       clc
7C58: 69 02    adc #$02
7C5A: 85 1D    sta $1d
7C5C: A5 1E    lda $1e
7C5E: 69 00    adc #$00
7C60: 85 1E    sta $1e
7C62: A5 19    lda $19
7C64: 18       clc
7C65: 69 01    adc #$01
7C67: 85 19    sta $19
7C69: A5 1A    lda $1a
7C6B: 69 00    adc #$00
7C6D: 85 1A    sta $1a
7C6F: 4C 38 7C jmp $7c38

7C8D: A9 16    lda #$16
7C8F: 85 31    sta $31
7C91: A9 7D    lda #$7d
7C93: 85 32    sta $32
7C95: A9 05    lda #$05
7C97: 85 33    sta $33
7C99: A9 7D    lda #$7d
7C9B: 85 34    sta $34
7C9D: A9 0E    lda #$0e
7C9F: 85 35    sta $35
7CA1: A9 7D    lda #$7d
7CA3: 85 36    sta $36
7CA5: A0 00    ldy #$00
7CA7: A9 00    lda #$00
7CA9: A8       tay
7CAA: 85 17    sta $17
7CAC: B1 33    lda ($33), y
7CAE: F0 76    beq $7d26
7CB0: 85 18    sta $18
7CB2: 20 8B 7D jsr $7d8b
7CB5: A0 00    ldy #$00
7CB7: B1 31    lda ($31), y
7CB9: 85 17    sta $17
7CBB: C8       iny
7CBC: B1 31    lda ($31), y
7CBE: 85 18    sta $18
7CC0: 88       dey
7CC1: B1 35    lda ($35), y
7CC3: AA       tax
7CC4: BD 00 FF lda $ff00, x
7CC7: C5 1B    cmp $1b
7CC9: D0 34    bne $7cff
7CCB: BD 01 FF lda $ff01, x
7CCE: C5 1C    cmp $1c
7CD0: D0 2D    bne $7cff
7CD2: 20 77 7E jsr $7e77
7CD5: A5 31    lda $31
7CD7: 18       clc
7CD8: 69 02    adc #$02
7CDA: 85 31    sta $31
7CDC: A5 32    lda $32
7CDE: 69 00    adc #$00
7CE0: 85 32    sta $32
7CE2: A5 33    lda $33
7CE4: 18       clc
7CE5: 69 01    adc #$01
7CE7: 85 33    sta $33
7CE9: A5 34    lda $34
7CEB: 69 00    adc #$00
7CED: 85 34    sta $34
7CEF: A5 35    lda $35
7CF1: 18       clc
7CF2: 69 01    adc #$01
7CF4: 85 35    sta $35
7CF6: A5 36    lda $36
7CF8: 69 00    adc #$00
7CFA: 85 36    sta $36
7CFC: 4C A7 7C jmp $7ca7
7CFF: 20 AB 7E jsr $7eab
7D02: 4C D5 7C jmp $7cd5

; at this point, system tests are done
end_of_system_tests_7d26:   ; [global]
7D26: A9 02    lda #$02
7D28: 85 18    sta $18
7D2A: A9 01    lda #$01
7D2C: 85 17    sta $17
7D2E: A2 00    ldx #$00
7D30: CA       dex
7D31: D0 FD    bne $7d30
7D33: C6 17    dec $17
7D35: D0 F9    bne $7d30
7D37: C6 18    dec $18
7D39: D0 F5    bne $7d30
7D3B: A9 10    lda #$10
7D3D: 2D 06 21 and dsw_2106
7D40: F0 07    beq $7d49
7D42: A9 10    lda #$10
7D44: 2D 04 21 and in0_2104
7D47: D0 F9    bne $7d42
7D49: 20 13 7F jsr $7f13
7D4C: A2 00    ldx #$00
7D4E: A9 C7    lda #$c7
7D50: 9D 00 04 sta $0400, x 		; [video_address]
7D53: 9D 00 05 sta $0500, x 		; [video_address]
7D56: 9D 00 06 sta $0600, x 		; [video_address]
7D59: 9D 00 07 sta $0700, x 		; [video_address]
7D5C: A9 33    lda #$33
7D5E: 9D 00 0C sta $0c00, x    		; [video_address]
7D61: 9D 00 0D sta $0d00, x    		; [video_address]
7D64: 9D 00 0E sta $0e00, x    		; [video_address]
7D67: 9D 00 0F sta $0f00, x    		; [video_address]
7D6A: E8       inx
7D6B: D0 E1    bne $7d4e
7D6D: A9 10    lda #$10
7D6F: 2D 06 21 and dsw_2106
7D72: D0 03    bne $7d77
7D74: 4C 1C 30 jmp $301c
7D77: A9 80    lda #$80
7D79: 2D 07 21 and in2_2107
7D7C: F0 03    beq $7d81
7D7E: 4C 1C 30 jmp $301c
7D81: A9 40    lda #$40
7D83: 2D 07 21 and in2_2107
7D86: F0 EF    beq $7d77
7D88: 4C 00 78 jmp boot_7800
7D8B: A5 18    lda $18
7D8D: 18       clc
7D8E: 69 10    adc #$10
7D90: 85 1A    sta $1a
7D92: A9 00    lda #$00
7D94: 85 1B    sta $1b
7D96: 85 1C    sta $1c
7D98: A8       tay
7D99: B1 17    lda ($17), y
7D9B: 18       clc
7D9C: 65 1B    adc $1b
7D9E: 85 1B    sta $1b
7DA0: A5 1C    lda $1c
7DA2: 69 00    adc #$00
7DA4: 85 1C    sta $1c
7DA6: C8       iny
7DA7: D0 F0    bne $7d99
7DA9: A5 18    lda $18
7DAB: 18       clc
7DAC: 69 01    adc #$01
7DAE: 85 18    sta $18
7DB0: C5 1A    cmp $1a
7DB2: D0 E5    bne $7d99
7DB4: 60       rts
7DB5: A9 00    lda #$00
7DB7: 85 16    sta $16
7DB9: A8       tay
7DBA: A9 55    lda #$55
7DBC: 91 17    sta ($17), y   ; [video_address]
7DBE: C8       iny
7DBF: A9 AA    lda #$aa
7DC1: 91 17    sta ($17), y   ; [video_address]
7DC3: C8       iny
7DC4: D0 F4    bne $7dba
7DC6: A9 55    lda #$55
7DC8: D1 17    cmp ($17), y
7DCA: D0 47    bne $7e13
7DCC: C8       iny
7DCD: A9 AA    lda #$aa
7DCF: D1 17    cmp ($17), y
7DD1: D0 40    bne $7e13
7DD3: C8       iny
7DD4: D0 F0    bne $7dc6
7DD6: A9 AA    lda #$aa
7DD8: 91 17    sta ($17), y   ; [video_address]
7DDA: C8       iny
7DDB: A9 55    lda #$55
7DDD: 91 17    sta ($17), y   ; [video_address]
7DDF: C8       iny
7DE0: D0 F4    bne $7dd6
7DE2: A9 AA    lda #$aa
7DE4: D1 17    cmp ($17), y
7DE6: D0 2B    bne $7e13
7DE8: C8       iny
7DE9: A9 55    lda #$55
7DEB: D1 17    cmp ($17), y
7DED: D0 24    bne $7e13
7DEF: C8       iny
7DF0: D0 F0    bne $7de2
7DF2: 98       tya
7DF3: 91 17    sta ($17), y   ; [video_address]
7DF5: C8       iny
7DF6: D0 FA    bne $7df2
7DF8: 98       tya
7DF9: D1 17    cmp ($17), y
7DFB: D0 16    bne $7e13
7DFD: C8       iny
7DFE: D0 F8    bne $7df8
7E00: A2 00    ldx #$00
7E02: 8A       txa
7E03: 91 17    sta ($17), y   ; [video_address]
7E05: CA       dex
7E06: C8       iny
7E07: D0 F9    bne $7e02
7E09: 8A       txa
7E0A: D1 17    cmp ($17), y
7E0C: D0 05    bne $7e13
7E0E: CA       dex
7E0F: C8       iny
7E10: D0 F7    bne $7e09
7E12: 60       rts
7E13: 51 17    eor ($17), y
7E15: AA       tax
7E16: C9 10    cmp #$10
7E18: 90 06    bcc $7e20
7E1A: A9 82    lda #$82
7E1C: 05 16    ora $16
7E1E: 85 16    sta $16
7E20: 8A       txa
7E21: 29 0F    and #$0f
7E23: F0 06    beq $7e2b
7E25: A9 81    lda #$81
7E27: 05 16    ora $16
7E29: 85 16    sta $16
7E2B: 60       rts
7E2C: A0 00    ldy #$00
7E2E: 84 16    sty $16
7E30: 98       tya
7E31: 91 17    sta ($17), y   ; [video_address]
7E33: C8       iny
7E34: D0 FA    bne $7e30
7E36: 98       tya
7E37: 51 17    eor ($17), y
7E39: 29 3F    and #$3f
7E3B: D0 18    bne $7e55
7E3D: C8       iny
7E3E: D0 F6    bne $7e36
7E40: A2 00    ldx #$00
7E42: 8A       txa
7E43: 91 17    sta ($17), y   ; [video_address]
7E45: CA       dex
7E46: C8       iny
7E47: D0 F9    bne $7e42
7E49: 8A       txa
7E4A: 51 17    eor ($17), y
7E4C: 29 3F    and #$3f
7E4E: D0 05    bne $7e55
7E50: CA       dex
7E51: C8       iny
7E52: D0 F5    bne $7e49
7E54: 60       rts
7E55: AA       tax
7E56: C9 08    cmp #$08
7E58: 90 04    bcc $7e5e
7E5A: A9 82    lda #$82
7E5C: 85 16    sta $16
7E5E: 8A       txa
7E5F: 29 07    and #$07
7E61: F0 06    beq $7e69
7E63: A9 81    lda #$81
7E65: 05 16    ora $16
7E67: 85 16    sta $16
7E69: 60       rts
7E6A: A0 00    ldy #$00
7E6C: A9 0C    lda #$0c
7E6E: 91 17    sta ($17), y   ; [video_address]
7E70: A0 20    ldy #$20
7E72: A9 12    lda #$12
7E74: 91 17    sta ($17), y   ; [video_address]
7E76: 60       rts
7E77: A0 00    ldy #$00
7E79: A9 30    lda #$30
7E7B: 91 17    sta ($17), y   ; [video_address]
7E7D: A0 20    ldy #$20
7E7F: 91 17    sta ($17), y   ; [video_address]
7E81: A0 40    ldy #$40
7E83: A9 14    lda #$14
7E85: 91 17    sta ($17), y   ; [video_address]
7E87: A0 60    ldy #$60
7E89: A9 18    lda #$18
7E8B: 91 17    sta ($17), y   ; [video_address]
7E8D: A5 18    lda $18
7E8F: 48       pha
7E90: 18       clc
7E91: 69 08    adc #$08
7E93: 85 18    sta $18
7E95: A9 05    lda #$05
7E97: A0 00    ldy #$00
7E99: 91 17    sta ($17), y   ; [video_address]
7E9B: A0 20    ldy #$20
7E9D: 91 17    sta ($17), y   ; [video_address]
7E9F: A0 40    ldy #$40
7EA1: 91 17    sta ($17), y   ; [video_address]
7EA3: A0 60    ldy #$60
7EA5: 91 17    sta ($17), y   ; [video_address]
7EA7: 68       pla
7EA8: 85 18    sta $18
7EAA: 60       rts
7EAB: A0 00    ldy #$00
7EAD: A9 15    lda #$15
7EAF: 91 17    sta ($17), y   ; [video_address]
7EB1: A0 20    ldy #$20
7EB3: A9 12    lda #$12
7EB5: 91 17    sta ($17), y   ; [video_address]
7EB7: A0 40    ldy #$40
7EB9: A9 0A    lda #$0a
7EBB: 91 17    sta ($17), y   ; [video_address]
7EBD: A0 60    ldy #$60
7EBF: A9 0F    lda #$0f
7EC1: 91 17    sta ($17), y   ; [video_address]
7EC3: A5 18    lda $18
7EC5: 48       pha
7EC6: 18       clc
7EC7: 69 08    adc #$08
7EC9: 85 18    sta $18
7ECB: A9 06    lda #$06
7ECD: A0 00    ldy #$00
7ECF: 91 17    sta ($17), y   ; [video_address]
7ED1: A0 20    ldy #$20
7ED3: 91 17    sta ($17), y   ; [video_address]
7ED5: A0 40    ldy #$40
7ED7: 91 17    sta ($17), y   ; [video_address]
7ED9: A0 60    ldy #$60
7EDB: 91 17    sta ($17), y   ; [video_address]
7EDD: 68       pla
7EDE: 85 18    sta $18
7EE0: 60       rts
7EE1: 48       pha
7EE2: 29 F0    and #$f0
7EE4: 4A       lsr a
7EE5: 4A       lsr a
7EE6: 4A       lsr a
7EE7: 4A       lsr a
7EE8: AA       tax
7EE9: 68       pla
7EEA: 29 0F    and #$0f
7EEC: A0 00    ldy #$00
7EEE: 91 17    sta ($17), y   ; [video_address]
7EF0: A0 20    ldy #$20
7EF2: 8A       txa
7EF3: 91 17    sta ($17), y   ; [video_address]
7EF5: 60       rts
7EF6: A0 0D    ldy #$0d
7EF8: 8C 00 20 sty crtc_2000
7EFB: B9 05 7F lda $7f05, y
7EFE: 8D 01 20 sta crtc_2001
7F01: 88       dey
7F02: 10 F4    bpl $7ef8
7F04: 60       rts

7F13: A0 00    ldy #$00
7F15: 84 10    sty $10
7F17: A9 04    lda #$04
7F19: 85 11    sta $11
7F1B: A9 30    lda #$30
7F1D: 91 10    sta ($10), y		; [video_address]
7F1F: 88       dey
7F20: D0 FB    bne $7f1d
7F22: E6 11    inc $11
7F24: A5 11    lda $11
7F26: C9 10    cmp #$10
7F28: 90 F1    bcc $7f1b
7F2A: 60       rts
7F2B: A9 00    lda #$00
7F2D: 85 10    sta $10
7F2F: 85 12    sta $12
7F31: A9 10    lda #$10
7F33: 85 11    sta $11
7F35: A9 80    lda #$80
7F37: 85 13    sta $13
7F39: A0 00    ldy #$00
7F3B: B1 12    lda ($12), y
7F3D: 91 10    sta ($10), y
7F3F: 88       dey
7F40: D0 F9    bne $7f3b
7F42: E6 11    inc $11
7F44: E6 13    inc $13
7F46: A5 11    lda $11
7F48: C9 20    cmp #$20
7F4A: 90 ED    bcc $7f39
7F4C: 60       rts
7F4D: 85 D5    sta $d5
7F4F: A9 07    lda #$07
7F51: 25 49    and $49
7F53: 0A       asl a
7F54: 0A       asl a
7F55: 0A       asl a
7F56: 0A       asl a
7F57: AA       tax
7F58: A5 F0    lda $f0
7F5A: 9D 00 02 sta $0200, x
7F5D: E8       inx
7F5E: A5 F1    lda $f1
7F60: 9D 00 02 sta $0200, x
7F63: E8       inx
7F64: AD 04 21 lda in0_2104
7F67: 9D 00 02 sta $0200, x
7F6A: E8       inx
7F6B: A5 D5    lda $d5
7F6D: 9D 00 02 sta $0200, x
7F70: E8       inx
7F71: A5 51    lda $51
7F73: 9D 00 02 sta $0200, x
7F76: E8       inx
7F77: A5 52    lda $52
7F79: 9D 00 02 sta $0200, x
7F7C: E8       inx
7F7D: A5 53    lda $53
7F7F: 9D 00 02 sta $0200, x
7F82: E8       inx
7F83: A5 5A    lda $5a
7F85: 9D 00 02 sta $0200, x
7F88: E8       inx
7F89: A5 5E    lda $5e
7F8B: 9D 00 02 sta $0200, x
7F8E: E8       inx
7F8F: A5 E9    lda $e9
7F91: 9D 00 02 sta $0200, x
7F94: E8       inx
7F95: A5 ED    lda $ed
7F97: 9D 00 02 sta $0200, x
7F9A: E8       inx
7F9B: A5 48    lda $48
7F9D: 9D 00 02 sta $0200, x
7FA0: E8       inx
7FA1: A5 D1    lda $d1
7FA3: 9D 00 02 sta $0200, x
7FA6: E8       inx
7FA7: A5 D2    lda $d2
7FA9: 9D 00 02 sta $0200, x
7FAC: E8       inx
7FAD: A5 D3    lda $d3
7FAF: 9D 00 02 sta $0200, x
7FB2: E8       inx
7FB3: A5 D4    lda $d4
7FB5: 9D 00 02 sta $0200, x
7FB8: E8       inx
7FB9: 60       rts

A000: A5 ED    lda $ed
A002: D0 03    bne $a007
A004: 4C 61 A1 jmp $a161
A007: A5 53    lda $53
A009: C9 04    cmp #$04
A00B: F0 0E    beq $a01b
A00D: A5 51    lda $51
A00F: 18       clc
A010: 69 02    adc #$02
A012: 85 33    sta $33
A014: A5 51    lda $51
A016: 85 17    sta $17
A018: 4C 26 A0 jmp $a026
A01B: A5 51    lda $51
A01D: 38       sec
A01E: E9 02    sbc #$02
A020: 85 33    sta $33
A022: A5 51    lda $51
A024: 85 17    sta $17
A026: A5 52    lda $52
A028: 85 18    sta $18
A02A: 18       clc
A02B: 69 01    adc #$01
A02D: 85 34    sta $34
A02F: A9 1B    lda #$1b
A031: 38       sec
A032: E5 33    sbc $33
A034: 18       clc
A035: 2A       rol a
A036: 2A       rol a
A037: 2A       rol a
A038: 2A       rol a
A039: 85 31    sta $31
A03B: A9 00    lda #$00
A03D: 69 00    adc #$00
A03F: 0A       asl a
A040: 26 31    rol $31
A042: 69 04    adc #$04
A044: 85 32    sta $32
A046: A9 1F    lda #$1f
A048: 38       sec
A049: E5 34    sbc $34
A04B: 18       clc
A04C: 65 31    adc $31
A04E: 85 31    sta $31
A050: A5 53    lda $53
A052: C9 04    cmp #$04
A054: F0 1B    beq $a071
A056: A5 3B    lda $3b
A058: 38       sec
A059: E5 51    sbc $51
A05B: 30 0F    bmi $a06c
A05D: C9 04    cmp #$04
A05F: 30 2C    bmi $a08d
A061: A9 3A    lda #$3a
A063: 85 1B    sta $1b
A065: A9 A1    lda #$a1
A067: 85 1C    sta $1c
A069: 4C 84 A0 jmp $a084
A06C: A9 92    lda #$92
A06E: 4C 10 30 jmp $3010
A071: A5 51    lda $51
A073: 38       sec
A074: E5 3B    sbc $3b
A076: 30 F4    bmi $a06c
A078: C9 04    cmp #$04
A07A: 30 11    bmi $a08d
A07C: A9 43    lda #$43
A07E: 85 1B    sta $1b
A080: A9 A1    lda #$a1
A082: 85 1C    sta $1c
A084: A0 02    ldy #$02
A086: B1 1B    lda ($1b), y
A088: 91 31    sta ($31), y
A08A: 88       dey
A08B: 10 F9    bpl $a086
A08D: A9 58    lda #$58
A08F: 85 17    sta $17
A091: A9 A1    lda #$a1
A093: 85 18    sta $18
A095: A4 EC    ldy $ec
A097: B1 17    lda ($17), y
A099: 85 19    sta $19
A09B: C8       iny
A09C: B1 17    lda ($17), y
A09E: 85 1A    sta $1a
A0A0: A0 17    ldy #$17
A0A2: A9 00    lda #$00
A0A4: 91 19    sta ($19), y
A0A6: 88       dey
A0A7: 10 FB    bpl $a0a4
A0A9: A5 1A    lda $1a
A0AB: 18       clc
A0AC: 69 08    adc #$08
A0AE: 85 1A    sta $1a
A0B0: A0 17    ldy #$17
A0B2: A9 00    lda #$00
A0B4: 91 19    sta ($19), y
A0B6: 88       dey
A0B7: 10 FB    bpl $a0b4
A0B9: A5 53    lda $53
A0BB: C9 04    cmp #$04
A0BD: F0 10    beq $a0cf
A0BF: A5 31    lda $31
A0C1: 18       clc
A0C2: 69 60    adc #$60
A0C4: 85 31    sta $31
A0C6: A5 32    lda $32
A0C8: 69 00    adc #$00
A0CA: 85 32    sta $32
A0CC: 4C E3 A0 jmp $a0e3
A0CF: A5 31    lda $31
A0D1: 38       sec
A0D2: E9 60    sbc #$60
A0D4: 85 31    sta $31
A0D6: A5 32    lda $32
A0D8: E9 00    sbc #$00
A0DA: 85 32    sta $32
A0DC: C9 04    cmp #$04
A0DE: B0 03    bcs $a0e3
A0E0: 4C 28 A1 jmp $a128
A0E3: A9 4C    lda #$4c
A0E5: 85 1B    sta $1b
A0E7: A9 A1    lda #$a1
A0E9: 85 1C    sta $1c
A0EB: A5 EC    lda $ec
A0ED: 0A       asl a
A0EE: 18       clc
A0EF: 65 1B    adc $1b
A0F1: 85 1B    sta $1b
A0F3: A5 1C    lda $1c
A0F5: 69 00    adc #$00
A0F7: 85 1C    sta $1c
A0F9: A0 02    ldy #$02
A0FB: A5 32    lda $32
A0FD: AA       tax
A0FE: 18       clc
A0FF: 69 08    adc #$08
A101: 85 32    sta $32
A103: B1 31    lda ($31), y
A105: 29 F8    and #$f8
A107: 09 03    ora #$03
A109: 91 31    sta ($31), y
A10B: 88       dey
A10C: 10 F5    bpl $a103
A10E: 86 32    stx $32
A110: A0 01    ldy #$01
A112: B1 31    lda ($31), y
A114: C9 30    cmp #$30
A116: D0 46    bne $a15e
A118: B1 1B    lda ($1b), y
A11A: 91 31    sta ($31), y
A11C: 88       dey
A11D: B1 1B    lda ($1b), y
A11F: 91 31    sta ($31), y
A121: A0 02    ldy #$02
A123: B1 1B    lda ($1b), y
A125: 91 31    sta ($31), y
A127: 88       dey
A128: A5 EC    lda $ec
A12A: 18       clc
A12B: 69 02    adc #$02
A12D: 85 EC    sta $ec
A12F: C9 05    cmp #$05
A131: 30 2E    bmi $a161
A133: A9 00    lda #$00
A135: 85 EC    sta $ec
A137: 4C 61 A1 jmp $a161

A15E: 4C 13 30 jmp $3013
A161: A5 E9    lda $e9
A163: 0A       asl a
A164: A8       tay
A165: B9 C0 60 lda $60c0, y
A168: 85 1B    sta $1b
A16A: B9 C1 60 lda $60c1, y
A16D: 85 1C    sta $1c
A16F: B9 10 63 lda $6310, y
A172: 85 31    sta $31
A174: B9 11 63 lda $6311, y
A177: 85 32    sta $32
A179: A9 73    lda #$73
A17B: 85 19    sta $19
A17D: A9 A2    lda #$a2
A17F: 85 1A    sta $1a
A181: A4 EC    ldy $ec
A183: B1 19    lda ($19), y
A185: 85 1D    sta $1d
A187: C8       iny
A188: B1 19    lda ($19), y
A18A: 85 1E    sta $1e
A18C: A9 79    lda #$79
A18E: 85 17    sta $17
A190: A9 A2    lda #$a2
A192: 85 18    sta $18
A194: A4 EC    ldy $ec
A196: B1 17    lda ($17), y
A198: 85 16    sta $16
A19A: C8       iny
A19B: B1 17    lda ($17), y
A19D: 85 1F    sta $1f
A19F: A4 16    ldy $16
A1A1: A5 53    lda $53
A1A3: C9 08    cmp #$08
A1A5: F0 0A    beq $a1b1
A1A7: B1 1B    lda ($1b), y
A1A9: 91 1D    sta ($1d), y
A1AB: 88       dey
A1AC: 10 F9    bpl $a1a7
A1AE: 4C C0 A1 jmp $a1c0
A1B1: 84 17    sty $17
A1B3: 98       tya
A1B4: 49 07    eor #$07
A1B6: A8       tay
A1B7: B1 1B    lda ($1b), y
A1B9: A4 17    ldy $17
A1BB: 91 1D    sta ($1d), y
A1BD: 88       dey
A1BE: 10 F1    bpl $a1b1
A1C0: E6 16    inc $16
A1C2: A4 1F    ldy $1f
A1C4: 30 39    bmi $a1ff
A1C6: A5 1B    lda $1b
A1C8: 18       clc
A1C9: 65 16    adc $16
A1CB: 85 1B    sta $1b
A1CD: A5 1C    lda $1c
A1CF: 69 00    adc #$00
A1D1: 85 1C    sta $1c
A1D3: A0 00    ldy #$00
A1D5: B1 19    lda ($19), y
A1D7: 85 1D    sta $1d
A1D9: C8       iny
A1DA: B1 19    lda ($19), y
A1DC: 85 1E    sta $1e
A1DE: A4 1F    ldy $1f
A1E0: A5 53    lda $53
A1E2: C9 08    cmp #$08
A1E4: F0 0A    beq $a1f0
A1E6: B1 1B    lda ($1b), y
A1E8: 91 1D    sta ($1d), y
A1EA: 88       dey
A1EB: 10 F9    bpl $a1e6
A1ED: 4C FF A1 jmp $a1ff
A1F0: 84 17    sty $17
A1F2: 98       tya
A1F3: 49 07    eor #$07
A1F5: A8       tay
A1F6: B1 1B    lda ($1b), y
A1F8: A4 17    ldy $17
A1FA: 91 1D    sta ($1d), y
A1FC: 88       dey
A1FD: 10 F1    bpl $a1f0
A1FF: A4 EC    ldy $ec
A201: B1 19    lda ($19), y
A203: 85 1D    sta $1d
A205: C8       iny
A206: B1 19    lda ($19), y
A208: 18       clc
A209: 69 08    adc #$08
A20B: 85 1E    sta $1e
A20D: C6 16    dec $16
A20F: A4 16    ldy $16
A211: A5 53    lda $53
A213: C9 08    cmp #$08
A215: F0 0A    beq $a221
A217: B1 31    lda ($31), y
A219: 91 1D    sta ($1d), y
A21B: 88       dey
A21C: 10 F9    bpl $a217
A21E: 4C 30 A2 jmp $a230
A221: 84 17    sty $17
A223: 98       tya
A224: 49 07    eor #$07
A226: A8       tay
A227: B1 31    lda ($31), y
A229: A4 17    ldy $17
A22B: 91 1D    sta ($1d), y
A22D: 88       dey
A22E: 10 F1    bpl $a221
A230: E6 16    inc $16
A232: A4 1F    ldy $1f
A234: 30 3C    bmi $a272
A236: A5 31    lda $31
A238: 18       clc
A239: 65 16    adc $16
A23B: 85 31    sta $31
A23D: A5 32    lda $32
A23F: 69 00    adc #$00
A241: 85 32    sta $32
A243: A0 00    ldy #$00
A245: B1 19    lda ($19), y
A247: 85 1D    sta $1d
A249: C8       iny
A24A: B1 19    lda ($19), y
A24C: 18       clc
A24D: 69 08    adc #$08
A24F: 85 1E    sta $1e
A251: A4 1F    ldy $1f
A253: A5 53    lda $53
A255: C9 08    cmp #$08
A257: F0 0A    beq $a263
A259: B1 31    lda ($31), y
A25B: 91 1D    sta ($1d), y
A25D: 88       dey
A25E: 10 F9    bpl $a259
A260: 4C 72 A2 jmp $a272
A263: 84 17    sty $17
A265: 98       tya
A266: 49 07    eor #$07
A268: A8       tay
A269: B1 31    lda ($31), y
A26B: A4 17    ldy $17
A26D: 91 1D    sta ($1d), y
A26F: 88       dey
A270: 10 F1    bpl $a263
A272: 60       rts

A300: A5 ED    lda $ed
A302: D0 03    bne $a307
A304: 4C A1 A4 jmp $a4a1
A307: A5 53    lda $53
A309: C9 02    cmp #$02
A30B: F0 0E    beq $a31b
A30D: A5 52    lda $52
A30F: 18       clc
A310: 69 02    adc #$02
A312: 85 34    sta $34
A314: A5 52    lda $52
A316: 85 18    sta $18
A318: 4C 26 A3 jmp $a326
A31B: A5 52    lda $52
A31D: 38       sec
A31E: E9 02    sbc #$02
A320: 85 34    sta $34
A322: A5 52    lda $52
A324: 85 18    sta $18
A326: A5 51    lda $51
A328: 85 17    sta $17
A32A: 18       clc
A32B: 69 01    adc #$01
A32D: 85 33    sta $33
A32F: A9 1B    lda #$1b
A331: 38       sec
A332: E5 33    sbc $33
A334: 18       clc
A335: 2A       rol a
A336: 2A       rol a
A337: 2A       rol a
A338: 2A       rol a
A339: 85 31    sta $31
A33B: A9 00    lda #$00
A33D: 69 00    adc #$00
A33F: 0A       asl a
A340: 26 31    rol $31
A342: 69 04    adc #$04
A344: 85 32    sta $32
A346: A9 1F    lda #$1f
A348: 38       sec
A349: E5 34    sbc $34
A34B: 18       clc
A34C: 65 31    adc $31
A34E: 85 31    sta $31
A350: A5 31    lda $31
A352: 85 33    sta $33
A354: A5 32    lda $32
A356: 85 34    sta $34
A358: A5 53    lda $53
A35A: C9 02    cmp #$02
A35C: F0 1B    beq $a379
A35E: A5 3C    lda $3c
A360: 38       sec
A361: E5 52    sbc $52
A363: 30 0F    bmi $a374
A365: C9 04    cmp #$04
A367: 30 3B    bmi $a3a4
A369: A9 86    lda #$86
A36B: 85 1B    sta $1b
A36D: A9 A4    lda #$a4
A36F: 85 1C    sta $1c
A371: 4C 8C A3 jmp $a38c
A374: A9 92    lda #$92
A376: 4C 10 30 jmp $3010
A379: A5 52    lda $52
A37B: 38       sec
A37C: E5 3C    sbc $3c
A37E: 30 F4    bmi $a374
A380: C9 04    cmp #$04
A382: 30 20    bmi $a3a4
A384: A9 89    lda #$89
A386: 85 1B    sta $1b
A388: A9 A4    lda #$a4
A38A: 85 1C    sta $1c
A38C: A0 02    ldy #$02
A38E: A2 00    ldx #$00
A390: B1 1B    lda ($1b), y
A392: 81 31    sta ($31, x)
A394: A5 31    lda $31
A396: 18       clc
A397: 69 20    adc #$20
A399: 85 31    sta $31
A39B: A5 32    lda $32
A39D: 69 00    adc #$00
A39F: 85 32    sta $32
A3A1: 88       dey
A3A2: 10 EC    bpl $a390
A3A4: A9 98    lda #$98
A3A6: 85 17    sta $17
A3A8: A9 A4    lda #$a4
A3AA: 85 18    sta $18
A3AC: A4 EC    ldy $ec
A3AE: B1 17    lda ($17), y
A3B0: 85 19    sta $19
A3B2: C8       iny
A3B3: B1 17    lda ($17), y
A3B5: 85 1A    sta $1a
A3B7: A0 17    ldy #$17
A3B9: A9 00    lda #$00
A3BB: 91 19    sta ($19), y
A3BD: 88       dey
A3BE: 10 FB    bpl $a3bb
A3C0: A5 1A    lda $1a
A3C2: 18       clc
A3C3: 69 08    adc #$08
A3C5: 85 1A    sta $1a
A3C7: A0 17    ldy #$17
A3C9: A9 00    lda #$00
A3CB: 91 19    sta ($19), y
A3CD: 88       dey
A3CE: 10 FB    bpl $a3cb
A3D0: A5 53    lda $53
A3D2: C9 02    cmp #$02
A3D4: F0 10    beq $a3e6
A3D6: A5 33    lda $33
A3D8: 18       clc
A3D9: 69 03    adc #$03
A3DB: 85 33    sta $33
A3DD: A5 34    lda $34
A3DF: 69 00    adc #$00
A3E1: 85 34    sta $34
A3E3: 4C F3 A3 jmp $a3f3
A3E6: A5 33    lda $33
A3E8: 38       sec
A3E9: E9 03    sbc #$03
A3EB: 85 33    sta $33
A3ED: A5 34    lda $34
A3EF: E9 00    sbc #$00
A3F1: 85 34    sta $34
A3F3: A9 8C    lda #$8c
A3F5: 85 1B    sta $1b
A3F7: A9 A4    lda #$a4
A3F9: 85 1C    sta $1c
A3FB: A5 EC    lda $ec
A3FD: 0A       asl a
A3FE: 18       clc
A3FF: 65 1B    adc $1b
A401: 85 1B    sta $1b
A403: A5 1C    lda $1c
A405: 69 00    adc #$00
A407: 85 1C    sta $1c
A409: A0 02    ldy #$02
A40B: A2 00    ldx #$00
A40D: A5 33    lda $33
A40F: 48       pha
A410: A5 34    lda $34
A412: 48       pha
A413: 18       clc
A414: 69 08    adc #$08
A416: 85 34    sta $34
A418: A1 33    lda ($33, x)
A41A: 29 F8    and #$f8
A41C: 09 03    ora #$03
A41E: 81 33    sta ($33, x)
A420: A5 33    lda $33
A422: 18       clc
A423: 69 20    adc #$20
A425: 85 33    sta $33
A427: A5 34    lda $34
A429: 69 00    adc #$00
A42B: 85 34    sta $34
A42D: 88       dey
A42E: 10 E8    bpl $a418
A430: 68       pla
A431: 85 34    sta $34
A433: 68       pla
A434: 85 33    sta $33
A436: A5 33    lda $33
A438: 18       clc
A439: 69 20    adc #$20
A43B: 85 33    sta $33
A43D: A5 34    lda $34
A43F: 69 00    adc #$00
A441: 85 34    sta $34
A443: A0 01    ldy #$01
A445: A1 33    lda ($33, x)
A447: C9 30    cmp #$30
A449: D0 53    bne $a49e
A44B: B1 1B    lda ($1b), y
A44D: 81 33    sta ($33, x)
A44F: A5 33    lda $33
A451: 18       clc
A452: 69 20    adc #$20
A454: 85 33    sta $33
A456: A5 34    lda $34
A458: 69 00    adc #$00
A45A: 85 34    sta $34
A45C: 88       dey
A45D: B1 1B    lda ($1b), y
A45F: 81 33    sta ($33, x)
A461: A0 02    ldy #$02
A463: A5 33    lda $33
A465: 38       sec
A466: E9 40    sbc #$40
A468: 85 33    sta $33
A46A: A5 34    lda $34
A46C: E9 00    sbc #$00
A46E: 85 34    sta $34
A470: B1 1B    lda ($1b), y
A472: 81 33    sta ($33, x)
A474: A5 EC    lda $ec
A476: 18       clc
A477: 69 02    adc #$02
A479: 85 EC    sta $ec
A47B: C9 05    cmp #$05
A47D: 30 22    bmi $a4a1
A47F: A9 00    lda #$00
A481: 85 EC    sta $ec
A483: 4C A1 A4 jmp $a4a1

A49E: 4C 13 30 jmp $3013

A4A1: A5 E9    lda $e9
A4A3: 0A       asl a
A4A4: A8       tay
A4A5: A5 53    lda $53
A4A7: C9 01    cmp #$01
A4A9: F0 17    beq $a4c2
A4AB: B9 60 65 lda $6560, y
A4AE: 85 1B    sta $1b
A4B0: B9 61 65 lda $6561, y
A4B3: 85 1C    sta $1c
A4B5: B9 B0 67 lda $67b0, y
A4B8: 85 31    sta $31
A4BA: B9 B1 67 lda $67b1, y
A4BD: 85 32    sta $32
A4BF: 4C D6 A4 jmp $a4d6
A4C2: B9 00 6A lda $6a00, y
A4C5: 85 1B    sta $1b
A4C7: B9 01 6A lda $6a01, y
A4CA: 85 1C    sta $1c
A4CC: B9 50 6C lda $6c50, y
A4CF: 85 31    sta $31
A4D1: B9 51 6C lda $6c51, y
A4D4: 85 32    sta $32
A4D6: A9 D0    lda #$d0
A4D8: 85 19    sta $19
A4DA: A9 A5    lda #$a5
A4DC: 85 1A    sta $1a
A4DE: A4 EC    ldy $ec
A4E0: B1 19    lda ($19), y
A4E2: 85 1D    sta $1d
A4E4: C8       iny
A4E5: B1 19    lda ($19), y
A4E7: 85 1E    sta $1e
A4E9: A9 D6    lda #$d6
A4EB: 85 17    sta $17
A4ED: A9 A5    lda #$a5
A4EF: 85 18    sta $18
A4F1: A4 EC    ldy $ec
A4F3: B1 17    lda ($17), y
A4F5: 85 16    sta $16
A4F7: C8       iny
A4F8: B1 17    lda ($17), y
A4FA: 85 1F    sta $1f
A4FC: A4 16    ldy $16
A4FE: A5 53    lda $53
A500: C9 08    cmp #$08
A502: F0 0A    beq $a50e
A504: B1 1B    lda ($1b), y
A506: 91 1D    sta ($1d), y
A508: 88       dey
A509: 10 F9    bpl $a504
A50B: 4C 1D A5 jmp $a51d
A50E: 84 17    sty $17
A510: 98       tya
A511: 49 07    eor #$07
A513: A8       tay
A514: B1 1B    lda ($1b), y
A516: A4 17    ldy $17
A518: 91 1D    sta ($1d), y
A51A: 88       dey
A51B: 10 F1    bpl $a50e
A51D: E6 16    inc $16
A51F: A4 1F    ldy $1f
A521: 30 39    bmi $a55c
A523: A5 1B    lda $1b
A525: 18       clc
A526: 65 16    adc $16
A528: 85 1B    sta $1b
A52A: A5 1C    lda $1c
A52C: 69 00    adc #$00
A52E: 85 1C    sta $1c
A530: A0 00    ldy #$00
A532: B1 19    lda ($19), y
A534: 85 1D    sta $1d
A536: C8       iny
A537: B1 19    lda ($19), y
A539: 85 1E    sta $1e
A53B: A4 1F    ldy $1f
A53D: A5 53    lda $53
A53F: C9 08    cmp #$08
A541: F0 0A    beq $a54d
A543: B1 1B    lda ($1b), y
A545: 91 1D    sta ($1d), y
A547: 88       dey
A548: 10 F9    bpl $a543
A54A: 4C 5C A5 jmp $a55c
A54D: 84 17    sty $17
A54F: 98       tya
A550: 49 07    eor #$07
A552: A8       tay
A553: B1 1B    lda ($1b), y
A555: A4 17    ldy $17
A557: 91 1D    sta ($1d), y
A559: 88       dey
A55A: 10 F1    bpl $a54d
A55C: A4 EC    ldy $ec
A55E: B1 19    lda ($19), y
A560: 85 1D    sta $1d
A562: C8       iny
A563: B1 19    lda ($19), y
A565: 18       clc
A566: 69 08    adc #$08
A568: 85 1E    sta $1e
A56A: C6 16    dec $16
A56C: A4 16    ldy $16
A56E: A5 53    lda $53
A570: C9 08    cmp #$08
A572: F0 0A    beq $a57e
A574: B1 31    lda ($31), y
A576: 91 1D    sta ($1d), y
A578: 88       dey
A579: 10 F9    bpl $a574
A57B: 4C 8D A5 jmp $a58d
A57E: 84 17    sty $17
A580: 98       tya
A581: 49 07    eor #$07
A583: A8       tay
A584: B1 31    lda ($31), y
A586: A4 17    ldy $17
A588: 91 1D    sta ($1d), y
A58A: 88       dey
A58B: 10 F1    bpl $a57e
A58D: E6 16    inc $16
A58F: A4 1F    ldy $1f
A591: 30 3C    bmi $a5cf
A593: A5 31    lda $31
A595: 18       clc
A596: 65 16    adc $16
A598: 85 31    sta $31
A59A: A5 32    lda $32
A59C: 69 00    adc #$00
A59E: 85 32    sta $32
A5A0: A0 00    ldy #$00
A5A2: B1 19    lda ($19), y
A5A4: 85 1D    sta $1d
A5A6: C8       iny
A5A7: B1 19    lda ($19), y
A5A9: 18       clc
A5AA: 69 08    adc #$08
A5AC: 85 1E    sta $1e
A5AE: A4 1F    ldy $1f
A5B0: A5 53    lda $53
A5B2: C9 08    cmp #$08
A5B4: F0 0A    beq $a5c0
A5B6: B1 31    lda ($31), y
A5B8: 91 1D    sta ($1d), y
A5BA: 88       dey
A5BB: 10 F9    bpl $a5b6
A5BD: 4C CF A5 jmp $a5cf
A5C0: 84 17    sty $17
A5C2: 98       tya
A5C3: 49 07    eor #$07
A5C5: A8       tay
A5C6: B1 31    lda ($31), y
A5C8: A4 17    ldy $17
A5CA: 91 1D    sta ($1d), y
A5CC: 88       dey
A5CD: 10 F1    bpl $a5c0
A5CF: 60       rts

A600: A5 BB    lda $bb
A602: F0 01    beq $a605
A604: 60       rts
A605: A5 ED    lda $ed
A607: D0 03    bne $a60c
A609: 4C E3 A7 jmp $a7e3
A60C: A5 54    lda $54
A60E: 85 17    sta $17
A610: A5 55    lda $55
A612: 85 18    sta $18
A614: A9 1B    lda #$1b
A616: 38       sec
A617: E5 17    sbc $17
A619: 18       clc
A61A: 2A       rol a
A61B: 2A       rol a
A61C: 2A       rol a
A61D: 2A       rol a
A61E: 85 19    sta $19
A620: A9 00    lda #$00
A622: 69 00    adc #$00
A624: 0A       asl a
A625: 26 19    rol $19
A627: 69 04    adc #$04
A629: 85 1A    sta $1a
A62B: A9 1F    lda #$1f
A62D: 38       sec
A62E: E5 18    sbc $18
A630: 18       clc
A631: 65 19    adc $19
A633: 85 19    sta $19
A635: A5 56    lda $56
A637: C9 01    cmp #$01
A639: F0 38    beq $a673
A63B: C9 02    cmp #$02
A63D: F0 24    beq $a663
A63F: C9 04    cmp #$04
A641: F0 10    beq $a653
A643: A5 19    lda $19
A645: 38       sec
A646: E9 20    sbc #$20
A648: 85 19    sta $19
A64A: A5 1A    lda $1a
A64C: E9 00    sbc #$00
A64E: 85 1A    sta $1a
A650: 4C 80 A6 jmp $a680
A653: A5 19    lda $19
A655: 18       clc
A656: 69 20    adc #$20
A658: 85 19    sta $19
A65A: A5 1A    lda $1a
A65C: 69 00    adc #$00
A65E: 85 1A    sta $1a
A660: 4C 80 A6 jmp $a680
A663: A5 19    lda $19
A665: 18       clc
A666: 69 01    adc #$01
A668: 85 19    sta $19
A66A: A5 1A    lda $1a
A66C: 69 00    adc #$00
A66E: 85 1A    sta $1a
A670: 4C 80 A6 jmp $a680
A673: A5 19    lda $19
A675: 38       sec
A676: E9 01    sbc #$01
A678: 85 19    sta $19
A67A: A5 1A    lda $1a
A67C: E9 00    sbc #$00
A67E: 85 1A    sta $1a
A680: A0 00    ldy #$00
A682: B1 19    lda ($19), y
A684: C9 49    cmp #$49
A686: 90 08    bcc $a690
A688: C9 4F    cmp #$4f
A68A: B0 04    bcs $a690
A68C: A9 30    lda #$30
A68E: 91 19    sta ($19), y
A690: A5 56    lda $56
A692: C9 01    cmp #$01
A694: F0 38    beq $a6ce
A696: C9 02    cmp #$02
A698: F0 24    beq $a6be
A69A: C9 04    cmp #$04
A69C: F0 10    beq $a6ae
A69E: A9 60    lda #$60
A6A0: 18       clc
A6A1: 65 19    adc $19
A6A3: 85 19    sta $19
A6A5: A5 1A    lda $1a
A6A7: 69 00    adc #$00
A6A9: 85 1A    sta $1a
A6AB: 4C DB A6 jmp $a6db
A6AE: A5 19    lda $19
A6B0: 38       sec
A6B1: E9 60    sbc #$60
A6B3: 85 19    sta $19
A6B5: A5 1A    lda $1a
A6B7: E9 00    sbc #$00
A6B9: 85 1A    sta $1a
A6BB: 4C DB A6 jmp $a6db
A6BE: A5 19    lda $19
A6C0: 38       sec
A6C1: E9 03    sbc #$03
A6C3: 85 19    sta $19
A6C5: A5 1A    lda $1a
A6C7: E9 00    sbc #$00
A6C9: 85 1A    sta $1a
A6CB: 4C DB A6 jmp $a6db
A6CE: A9 03    lda #$03
A6D0: 18       clc
A6D1: 65 19    adc $19
A6D3: 85 19    sta $19
A6D5: A5 1A    lda $1a
A6D7: 69 00    adc #$00
A6D9: 85 1A    sta $1a
A6DB: A5 58    lda $58
A6DD: C5 57    cmp $57
A6DF: F0 5C    beq $a73d
A6E1: A8       tay
A6E2: B9 C0 03 lda $03c0, y
A6E5: 85 16    sta $16
A6E7: C8       iny
A6E8: B9 C0 03 lda $03c0, y
A6EB: 29 F0    and #$f0
A6ED: A8       tay
A6EE: A5 56    lda $56
A6F0: C9 01    cmp #$01
A6F2: F0 2C    beq $a720
A6F4: C9 02    cmp #$02
A6F6: F0 1C    beq $a714
A6F8: C9 04    cmp #$04
A6FA: F0 0C    beq $a708
A6FC: A5 54    lda $54
A6FE: 38       sec
A6FF: E5 16    sbc $16
A701: E9 03    sbc #$03
A703: 10 38    bpl $a73d
A705: 4C C5 A7 jmp $a7c5
A708: A5 16    lda $16
A70A: 38       sec
A70B: E5 54    sbc $54
A70D: E9 03    sbc #$03
A70F: 10 2C    bpl $a73d
A711: 4C C5 A7 jmp $a7c5
A714: A5 16    lda $16
A716: 38       sec
A717: E5 55    sbc $55
A719: E9 03    sbc #$03
A71B: 10 20    bpl $a73d
A71D: 4C C5 A7 jmp $a7c5
A720: 98       tya
A721: C9 30    cmp #$30
A723: F0 0C    beq $a731
A725: A5 55    lda $55
A727: 38       sec
A728: E5 16    sbc $16
A72A: E9 03    sbc #$03
A72C: 10 0F    bpl $a73d
A72E: 4C C5 A7 jmp $a7c5
A731: A5 55    lda $55
A733: 38       sec
A734: E5 16    sbc $16
A736: E9 04    sbc #$04
A738: 10 03    bpl $a73d
A73A: 4C C5 A7 jmp $a7c5
A73D: A9 DD    lda #$dd
A73F: 85 17    sta $17
A741: A9 A7    lda #$a7
A743: 85 18    sta $18
A745: A4 EE    ldy $ee
A747: B1 17    lda ($17), y
A749: 85 1B    sta $1b
A74B: C8       iny
A74C: B1 17    lda ($17), y
A74E: 18       clc
A74F: 69 08    adc #$08
A751: 85 1C    sta $1c
A753: A5 56    lda $56
A755: C9 03    cmp #$03
A757: 10 03    bpl $a75c
A759: 4C 5C A7 jmp $a75c
A75C: A5 56    lda $56
A75E: C9 01    cmp #$01
A760: F0 1A    beq $a77c
A762: C9 02    cmp #$02
A764: F0 0B    beq $a771
A766: A9 00    lda #$00
A768: 85 17    sta $17
A76A: A9 60    lda #$60
A76C: 85 18    sta $18
A76E: 4C 84 A7 jmp $a784
A771: A9 80    lda #$80
A773: 85 17    sta $17
A775: A9 60    lda #$60
A777: 85 18    sta $18
A779: 4C 84 A7 jmp $a784
A77C: A9 40    lda #$40
A77E: 85 17    sta $17
A780: A9 60    lda #$60
A782: 85 18    sta $18
A784: A5 E9    lda $e9
A786: 0A       asl a
A787: 0A       asl a
A788: 0A       asl a
A789: 18       clc
A78A: 65 17    adc $17
A78C: 85 17    sta $17
A78E: A5 18    lda $18
A790: 69 00    adc #$00
A792: 85 18    sta $18
A794: A0 07    ldy #$07
A796: A5 56    lda $56
A798: C9 08    cmp #$08
A79A: F0 0A    beq $a7a6
A79C: B1 17    lda ($17), y
A79E: 91 1B    sta ($1b), y
A7A0: 88       dey
A7A1: 10 F9    bpl $a79c
A7A3: 4C B5 A7 jmp $a7b5
A7A6: 84 16    sty $16
A7A8: 98       tya
A7A9: 49 07    eor #$07
A7AB: A8       tay
A7AC: B1 17    lda ($17), y
A7AE: A4 16    ldy $16
A7B0: 91 1B    sta ($1b), y
A7B2: 88       dey
A7B3: 10 F1    bpl $a7a6
A7B5: A9 D7    lda #$d7
A7B7: 85 17    sta $17
A7B9: A9 A7    lda #$a7
A7BB: 85 18    sta $18
A7BD: A4 EE    ldy $ee
A7BF: B1 17    lda ($17), y
A7C1: A0 00    ldy #$00
A7C3: 91 19    sta ($19), y
A7C5: A5 EE    lda $ee
A7C7: 18       clc
A7C8: 69 02    adc #$02
A7CA: 85 EE    sta $ee
A7CC: C9 05    cmp #$05
A7CE: 30 13    bmi $a7e3
A7D0: A9 00    lda #$00
A7D2: 85 EE    sta $ee
A7D4: 4C E3 A7 jmp $a7e3


A7E3: A5 56    lda $56
A7E5: C9 01    cmp #$01
A7E7: F0 17    beq $a800
A7E9: C9 02    cmp #$02
A7EB: F0 26    beq $a813
A7ED: A9 A0    lda #$a0
A7EF: 85 19    sta $19
A7F1: A9 6E    lda #$6e
A7F3: 85 1A    sta $1a
A7F5: A9 30    lda #$30
A7F7: 85 33    sta $33
A7F9: A9 70    lda #$70
A7FB: 85 34    sta $34
A7FD: 4C 23 A8 jmp $a823
A800: A9 C0    lda #$c0
A802: 85 19    sta $19
A804: A9 71    lda #$71
A806: 85 1A    sta $1a
A808: A9 50    lda #$50
A80A: 85 33    sta $33
A80C: A9 73    lda #$73
A80E: 85 34    sta $34
A810: 4C 23 A8 jmp $a823
A813: A9 E0    lda #$e0
A815: 85 19    sta $19
A817: A9 74    lda #$74
A819: 85 1A    sta $1a
A81B: A9 70    lda #$70
A81D: 85 33    sta $33
A81F: A9 76    lda #$76
A821: 85 34    sta $34
A823: A5 E9    lda $e9
A825: 0A       asl a
A826: A8       tay
A827: B1 19    lda ($19), y
A829: 85 17    sta $17
A82B: B1 33    lda ($33), y
A82D: 85 31    sta $31
A82F: C8       iny
A830: B1 19    lda ($19), y
A832: 85 18    sta $18
A834: B1 33    lda ($33), y
A836: 85 32    sta $32
A838: A9 31    lda #$31
A83A: 85 19    sta $19
A83C: A9 A9    lda #$a9
A83E: 85 1A    sta $1a
A840: A4 EE    ldy $ee
A842: B1 19    lda ($19), y
A844: 85 1B    sta $1b
A846: C8       iny
A847: B1 19    lda ($19), y
A849: 85 1C    sta $1c
A84B: A9 37    lda #$37
A84D: 85 19    sta $19
A84F: A9 A9    lda #$a9
A851: 85 1A    sta $1a
A853: A4 EE    ldy $ee
A855: B1 19    lda ($19), y
A857: 85 1D    sta $1d
A859: C8       iny
A85A: B1 19    lda ($19), y
A85C: 85 1E    sta $1e
A85E: A4 1D    ldy $1d
A860: A5 56    lda $56
A862: C9 08    cmp #$08
A864: F0 0A    beq $a870
A866: B1 17    lda ($17), y
A868: 91 1B    sta ($1b), y
A86A: 88       dey
A86B: 10 F9    bpl $a866
A86D: 4C 7F A8 jmp $a87f
A870: 84 16    sty $16
A872: 98       tya
A873: 49 07    eor #$07
A875: A8       tay
A876: B1 17    lda ($17), y
A878: A4 16    ldy $16
A87A: 91 1B    sta ($1b), y
A87C: 88       dey
A87D: 10 F1    bpl $a870
A87F: A4 1E    ldy $1e
A881: 30 3A    bmi $a8bd
A883: E6 1D    inc $1d
A885: A5 1D    lda $1d
A887: 18       clc
A888: 65 17    adc $17
A88A: 85 17    sta $17
A88C: A5 18    lda $18
A88E: 69 00    adc #$00
A890: 85 18    sta $18
A892: C6 1D    dec $1d
A894: A9 48    lda #$48
A896: 85 1B    sta $1b
A898: A9 12    lda #$12
A89A: 85 1C    sta $1c
A89C: A4 1E    ldy $1e
A89E: A5 56    lda $56
A8A0: C9 08    cmp #$08
A8A2: F0 0A    beq $a8ae
A8A4: B1 17    lda ($17), y
A8A6: 91 1B    sta ($1b), y
A8A8: 88       dey
A8A9: 10 F9    bpl $a8a4
A8AB: 4C BD A8 jmp $a8bd
A8AE: 84 16    sty $16
A8B0: 98       tya
A8B1: 49 07    eor #$07
A8B3: A8       tay
A8B4: B1 17    lda ($17), y
A8B6: A4 16    ldy $16
A8B8: 91 1B    sta ($1b), y
A8BA: 88       dey
A8BB: 10 F1    bpl $a8ae
A8BD: A9 31    lda #$31
A8BF: 85 19    sta $19
A8C1: A9 A9    lda #$a9
A8C3: 85 1A    sta $1a
A8C5: A4 EE    ldy $ee
A8C7: B1 19    lda ($19), y
A8C9: 85 1B    sta $1b
A8CB: C8       iny
A8CC: B1 19    lda ($19), y
A8CE: 18       clc
A8CF: 69 08    adc #$08
A8D1: 85 1C    sta $1c
A8D3: A4 1D    ldy $1d
A8D5: A5 56    lda $56
A8D7: C9 08    cmp #$08
A8D9: F0 0A    beq $a8e5
A8DB: B1 31    lda ($31), y
A8DD: 91 1B    sta ($1b), y
A8DF: 88       dey
A8E0: 10 F9    bpl $a8db
A8E2: 4C F4 A8 jmp $a8f4
A8E5: 84 16    sty $16
A8E7: 98       tya
A8E8: 49 07    eor #$07
A8EA: A8       tay
A8EB: B1 31    lda ($31), y
A8ED: A4 16    ldy $16
A8EF: 91 1B    sta ($1b), y
A8F1: 88       dey
A8F2: 10 F1    bpl $a8e5
A8F4: A4 1E    ldy $1e
A8F6: 30 38    bmi $a930
A8F8: E6 1D    inc $1d
A8FA: A5 1D    lda $1d
A8FC: 18       clc
A8FD: 65 31    adc $31
A8FF: 85 31    sta $31
A901: A5 32    lda $32
A903: 69 00    adc #$00
A905: 85 32    sta $32
A907: A9 48    lda #$48
A909: 85 1B    sta $1b
A90B: A9 1A    lda #$1a
A90D: 85 1C    sta $1c
A90F: A4 1E    ldy $1e
A911: A5 56    lda $56
A913: C9 08    cmp #$08
A915: F0 0A    beq $a921
A917: B1 31    lda ($31), y
A919: 91 1B    sta ($1b), y
A91B: 88       dey
A91C: 10 F9    bpl $a917
A91E: 4C 30 A9 jmp $a930
A921: 84 16    sty $16
A923: 98       tya
A924: 49 07    eor #$07
A926: A8       tay
A927: B1 31    lda ($31), y
A929: A4 16    ldy $16
A92B: 91 1B    sta ($1b), y
A92D: 88       dey
A92E: 10 F1    bpl $a921
A930: 60       rts

AA00: A5 52    lda $52
AA02: C5 55    cmp $55
AA04: D0 10    bne $aa16
AA06: A9 04    lda #$04
AA08: C5 53    cmp $53
AA0A: D0 0A    bne $aa16
AA0C: C5 56    cmp $56
AA0E: D0 06    bne $aa16
AA10: A5 57    lda $57
AA12: C5 58    cmp $58
AA14: F0 05    beq $aa1b
AA16: A9 97    lda #$97
AA18: 4C 10 30 jmp $3010
AA1B: A5 BE    lda $be
AA1D: C9 10    cmp #$10
AA1F: 90 05    bcc $aa26
AA21: A9 08    lda #$08
AA23: 8D 01 21 sta sound_2101
AA26: A9 00    lda #$00
AA28: 85 E9    sta $e9
AA2A: A5 54    lda $54
AA2C: 85 19    sta $19
AA2E: A5 55    lda $55
AA30: 18       clc
AA31: 69 01    adc #$01
AA33: 85 1A    sta $1a
AA35: A9 1B    lda #$1b
AA37: 38       sec
AA38: E5 19    sbc $19
AA3A: 18       clc
AA3B: 2A       rol a
AA3C: 2A       rol a
AA3D: 2A       rol a
AA3E: 2A       rol a
AA3F: 85 10    sta $10
AA41: A9 00    lda #$00
AA43: 69 00    adc #$00
AA45: 0A       asl a
AA46: 26 10    rol $10
AA48: 69 04    adc #$04
AA4A: 85 11    sta $11
AA4C: A9 1F    lda #$1f
AA4E: 38       sec
AA4F: E5 1A    sbc $1a
AA51: 18       clc
AA52: 65 10    adc $10
AA54: 85 10    sta $10
AA56: A5 51    lda $51
AA58: 18       clc
AA59: 69 01    adc #$01
AA5B: 85 19    sta $19
AA5D: A5 52    lda $52
AA5F: 18       clc
AA60: 69 01    adc #$01
AA62: 85 1A    sta $1a
AA64: A9 1B    lda #$1b
AA66: 38       sec
AA67: E5 19    sbc $19
AA69: 18       clc
AA6A: 2A       rol a
AA6B: 2A       rol a
AA6C: 2A       rol a
AA6D: 2A       rol a
AA6E: 85 12    sta $12
AA70: A9 00    lda #$00
AA72: 69 00    adc #$00
AA74: 0A       asl a
AA75: 26 12    rol $12
AA77: 69 04    adc #$04
AA79: 85 13    sta $13
AA7B: A9 1F    lda #$1f
AA7D: 38       sec
AA7E: E5 1A    sbc $1a
AA80: 18       clc
AA81: 65 12    adc $12
AA83: 85 12    sta $12
AA85: A5 10    lda $10
AA87: 85 19    sta $19
AA89: A5 11    lda $11
AA8B: 18       clc
AA8C: 69 08    adc #$08
AA8E: 85 1A    sta $1a
AA90: A5 12    lda $12
AA92: 85 33    sta $33
AA94: A5 13    lda $13
AA96: 18       clc
AA97: 69 08    adc #$08
AA99: 85 34    sta $34
AA9B: A0 02    ldy #$02
AA9D: B1 19    lda ($19), y		; [unchecked_address]
AA9F: 29 F8    and #$f8
AAA1: 09 04    ora #$04
AAA3: 91 19    sta ($19), y		; [video_address]
AAA5: 88       dey
AAA6: 10 F5    bpl $aa9d
AAA8: A5 1A    lda $1a
AAAA: C9 0C    cmp #$0c
AAAC: B0 05    bcs $aab3
AAAE: A9 40    lda #$40
AAB0: 4C 10 30 jmp $3010
AAB3: C9 10    cmp #$10
AAB5: B0 F7    bcs $aaae
AAB7: A5 19    lda $19
AAB9: 38       sec
AABA: E9 20    sbc #$20
AABC: 85 19    sta $19
AABE: A5 1A    lda $1a
AAC0: E9 00    sbc #$00
AAC2: 85 1A    sta $1a
AAC4: A5 1A    lda $1a
AAC6: C5 34    cmp $34
AAC8: D0 D1    bne $aa9b
AACA: A5 19    lda $19
AACC: C5 33    cmp $33
AACE: D0 CB    bne $aa9b
AAD0: A0 02    ldy #$02
AAD2: B1 19    lda ($19), y		; [unchecked_address]
AAD4: 29 F8    and #$f8
AAD6: 09 04    ora #$04
AAD8: 91 19    sta ($19), y		; [video_address]
AADA: 88       dey
AADB: 10 F5    bpl $aad2
AADD: A5 10    lda $10
AADF: 85 19    sta $19
AAE1: A5 11    lda $11
AAE3: 85 1A    sta $1a
AAE5: A0 02    ldy #$02
AAE7: B9 4B AB lda $ab4b, y
AAEA: 91 19    sta ($19), y		; [video_address]
AAEC: 88       dey
AAED: 10 F8    bpl $aae7
AAEF: A5 19    lda $19
AAF1: 38       sec
AAF2: E9 20    sbc #$20
AAF4: 85 19    sta $19
AAF6: A5 1A    lda $1a
AAF8: E9 00    sbc #$00
AAFA: 85 1A    sta $1a
AAFC: A0 02    ldy #$02
AAFE: A5 1A    lda $1a
AB00: C5 13    cmp $13
AB02: D0 09    bne $ab0d
AB04: A5 19    lda $19
AB06: C5 12    cmp $12
AB08: D0 03    bne $ab0d
AB0A: 4C 51 AB jmp $ab51
AB0D: A0 02    ldy #$02
AB0F: B9 4E AB lda $ab4e, y
AB12: 91 19    sta ($19), y		; [video_address]
AB14: 88       dey
AB15: 10 F8    bpl $ab0f
AB17: A5 1A    lda $1a
AB19: C9 04    cmp #$04
AB1B: B0 05    bcs $ab22
AB1D: A9 41    lda #$41
AB1F: 4C 10 30 jmp $3010
AB22: C9 08    cmp #$08
AB24: B0 F7    bcs $ab1d
AB26: A5 19    lda $19
AB28: 38       sec
AB29: E9 20    sbc #$20
AB2B: 85 19    sta $19
AB2D: A5 1A    lda $1a
AB2F: E9 00    sbc #$00
AB31: 85 1A    sta $1a
AB33: A9 01    lda #$01
AB35: 85 18    sta $18
AB37: A9 20    lda #$20
AB39: 85 17    sta $17
AB3B: A2 00    ldx #$00
AB3D: CA       dex
AB3E: D0 FD    bne $ab3d
AB40: C6 17    dec $17
AB42: D0 F9    bne $ab3d
AB44: C6 18    dec $18
AB46: D0 F5    bne $ab3d
AB48: 4C FC AA jmp $aafc

AB51: A0 02    ldy #$02
AB53: B9 4E AB lda $ab4e, y
AB56: 91 19    sta ($19), y		; [video_address]
AB58: 88       dey
AB59: 10 F8    bpl $ab53
AB5B: A5 1A    lda $1a
AB5D: C9 04    cmp #$04
AB5F: B0 05    bcs $ab66
AB61: A9 42    lda #$42
AB63: 4C 10 30 jmp $3010
AB66: C9 08    cmp #$08
AB68: B0 F7    bcs $ab61
AB6A: A9 01    lda #$01
AB6C: 85 18    sta $18
AB6E: A9 90    lda #$90
AB70: 85 17    sta $17
AB72: A2 00    ldx #$00
AB74: CA       dex
AB75: D0 FD    bne $ab74
AB77: C6 17    dec $17
AB79: D0 F9    bne $ab74
AB7B: C6 18    dec $18
AB7D: D0 F5    bne $ab74
AB7F: A9 00    lda #$00
AB81: 85 ED    sta $ed
AB83: A9 01    lda #$01
AB85: 85 42    sta $42
AB87: 20 00 A6 jsr $a600
AB8A: 20 19 30 jsr $3019
AB8D: 20 00 A0 jsr $a000
AB90: A5 12    lda $12
AB92: 18       clc
AB93: 69 40    adc #$40
AB95: 85 12    sta $12
AB97: A5 13    lda $13
AB99: 69 00    adc #$00
AB9B: 85 13    sta $13
AB9D: A5 10    lda $10
AB9F: 85 19    sta $19
ABA1: A5 11    lda $11
ABA3: 85 1A    sta $1a
ABA5: A0 00    ldy #$00
ABA7: A0 02    ldy #$02
ABA9: B9 A5 AC lda $aca5, y
ABAC: 91 19    sta ($19), y		; [video_address]
ABAE: 88       dey
ABAF: 10 F8    bpl $aba9
ABB1: A5 19    lda $19
ABB3: 38       sec
ABB4: E9 20    sbc #$20
ABB6: 85 19    sta $19
ABB8: A5 1A    lda $1a
ABBA: E9 00    sbc #$00
ABBC: 85 1A    sta $1a
ABBE: A9 01    lda #$01
ABC0: 85 18    sta $18
ABC2: A9 20    lda #$20
ABC4: 85 17    sta $17
ABC6: A2 00    ldx #$00
ABC8: CA       dex
ABC9: D0 FD    bne $abc8
ABCB: C6 17    dec $17
ABCD: D0 F9    bne $abc8
ABCF: C6 18    dec $18
ABD1: D0 F5    bne $abc8
ABD3: A0 02    ldy #$02
ABD5: A5 1A    lda $1a
ABD7: C9 04    cmp #$04
ABD9: B0 05    bcs $abe0
ABDB: A9 43    lda #$43
ABDD: 4C 10 30 jmp $3010
ABE0: C9 08    cmp #$08
ABE2: B0 F7    bcs $abdb
ABE4: B9 A8 AC lda $aca8, y
ABE7: 91 19    sta ($19), y		; [video_address]
ABE9: 88       dey
ABEA: 10 F8    bpl $abe4
ABEC: A5 19    lda $19
ABEE: 38       sec
ABEF: E9 20    sbc #$20
ABF1: 85 19    sta $19
ABF3: A5 1A    lda $1a
ABF5: E9 00    sbc #$00
ABF7: 85 1A    sta $1a
ABF9: A9 01    lda #$01
ABFB: 85 18    sta $18
ABFD: A9 20    lda #$20
ABFF: 85 17    sta $17
AC01: A2 00    ldx #$00
AC03: CA       dex
AC04: D0 FD    bne $ac03
AC06: C6 17    dec $17
AC08: D0 F9    bne $ac03
AC0A: C6 18    dec $18
AC0C: D0 F5    bne $ac03
AC0E: A0 02    ldy #$02
AC10: A5 1A    lda $1a
AC12: C9 04    cmp #$04
AC14: B0 05    bcs $ac1b
AC16: A9 44    lda #$44
AC18: 4C 10 30 jmp $3010
AC1B: C9 08    cmp #$08
AC1D: B0 F7    bcs $ac16
AC1F: B9 AB AC lda $acab, y
AC22: 91 19    sta ($19), y		; [video_address]
AC24: 88       dey
AC25: 10 F8    bpl $ac1f
AC27: A5 19    lda $19
AC29: 38       sec
AC2A: E9 20    sbc #$20
AC2C: 85 19    sta $19
AC2E: A5 1A    lda $1a
AC30: E9 00    sbc #$00
AC32: 85 1A    sta $1a
AC34: A9 01    lda #$01
AC36: 85 18    sta $18
AC38: A9 20    lda #$20
AC3A: 85 17    sta $17
AC3C: A2 00    ldx #$00
AC3E: CA       dex
AC3F: D0 FD    bne $ac3e
AC41: C6 17    dec $17
AC43: D0 F9    bne $ac3e
AC45: C6 18    dec $18
AC47: D0 F5    bne $ac3e
AC49: A5 1A    lda $1a
AC4B: C9 04    cmp #$04
AC4D: B0 05    bcs $ac54
AC4F: A9 45    lda #$45
AC51: 4C 10 30 jmp $3010
AC54: C9 08    cmp #$08
AC56: B0 F7    bcs $ac4f
AC58: A5 1A    lda $1a
AC5A: C5 13    cmp $13
AC5C: D0 09    bne $ac67
AC5E: A5 19    lda $19
AC60: C5 12    cmp $12
AC62: D0 03    bne $ac67
AC64: 4C B1 AC jmp $acb1
AC67: A0 02    ldy #$02
AC69: B9 AE AC lda $acae, y
AC6C: 91 19    sta ($19), y		; [video_address]
AC6E: 88       dey
AC6F: 10 F8    bpl $ac69
AC71: A5 19    lda $19
AC73: 38       sec
AC74: E9 20    sbc #$20
AC76: 85 19    sta $19
AC78: A5 1A    lda $1a
AC7A: E9 00    sbc #$00
AC7C: 85 1A    sta $1a
AC7E: A5 1A    lda $1a
AC80: C9 04    cmp #$04
AC82: B0 05    bcs $ac89
AC84: A9 46    lda #$46
AC86: 4C 10 30 jmp $3010
AC89: C9 08    cmp #$08
AC8B: B0 F7    bcs $ac84
AC8D: A9 01    lda #$01
AC8F: 85 18    sta $18
AC91: A9 20    lda #$20
AC93: 85 17    sta $17
AC95: A2 00    ldx #$00
AC97: CA       dex
AC98: D0 FD    bne $ac97
AC9A: C6 17    dec $17
AC9C: D0 F9    bne $ac97
AC9E: C6 18    dec $18
ACA0: D0 F5    bne $ac97
ACA2: 4C 58 AC jmp $ac58

ACB1: A0 02    ldy #$02
ACB3: A9 39    lda #$39
ACB5: 91 19    sta ($19), y		; [video_address]
ACB7: 88       dey
ACB8: A9 38    lda #$38
ACBA: 91 19    sta ($19), y		; [video_address]
ACBC: 88       dey
ACBD: A9 37    lda #$37
ACBF: 91 19    sta ($19), y		; [video_address]
ACC1: A5 1A    lda $1a
ACC3: C9 04    cmp #$04
ACC5: B0 05    bcs $accc
ACC7: A9 47    lda #$47
ACC9: 4C 10 30 jmp $3010
ACCC: C9 08    cmp #$08
ACCE: B0 F7    bcs $acc7
ACD0: A9 01    lda #$01
ACD2: 85 18    sta $18
ACD4: A9 20    lda #$20
ACD6: 85 17    sta $17
ACD8: A2 00    ldx #$00
ACDA: CA       dex
ACDB: D0 FD    bne $acda
ACDD: C6 17    dec $17
ACDF: D0 F9    bne $acda
ACE1: C6 18    dec $18
ACE3: D0 F5    bne $acda
ACE5: A5 19    lda $19
ACE7: 38       sec
ACE8: E9 20    sbc #$20
ACEA: 85 19    sta $19
ACEC: A5 1A    lda $1a
ACEE: E9 00    sbc #$00
ACF0: 85 1A    sta $1a
ACF2: A0 02    ldy #$02
ACF4: A9 36    lda #$36
ACF6: 91 19    sta ($19), y		; [video_address]
ACF8: 88       dey
ACF9: A9 35    lda #$35
ACFB: 91 19    sta ($19), y		; [video_address]
ACFD: 88       dey
ACFE: A9 34    lda #$34
AD00: 91 19    sta ($19), y		; [video_address]
AD02: A5 1A    lda $1a
AD04: C9 04    cmp #$04
AD06: B0 05    bcs $ad0d
AD08: A9 48    lda #$48
AD0A: 4C 10 30 jmp $3010
AD0D: C9 08    cmp #$08
AD0F: B0 F7    bcs $ad08
AD11: A9 01    lda #$01
AD13: 85 18    sta $18
AD15: A9 20    lda #$20
AD17: 85 17    sta $17
AD19: A2 00    ldx #$00
AD1B: CA       dex
AD1C: D0 FD    bne $ad1b
AD1E: C6 17    dec $17
AD20: D0 F9    bne $ad1b
AD22: C6 18    dec $18
AD24: D0 F5    bne $ad1b
AD26: A5 19    lda $19
AD28: 38       sec
AD29: E9 20    sbc #$20
AD2B: 85 19    sta $19
AD2D: A5 1A    lda $1a
AD2F: E9 00    sbc #$00
AD31: 85 1A    sta $1a
AD33: A0 02    ldy #$02
AD35: A9 33    lda #$33
AD37: 91 19    sta ($19), y		; [video_address]
AD39: 88       dey
AD3A: A9 32    lda #$32
AD3C: 91 19    sta ($19), y		; [video_address]
AD3E: 88       dey
AD3F: A9 31    lda #$31
AD41: 91 19    sta ($19), y		; [video_address]
AD43: A5 1A    lda $1a
AD45: C9 04    cmp #$04
AD47: B0 05    bcs $ad4e
AD49: A9 49    lda #$49
AD4B: 4C 10 30 jmp $3010
AD4E: C9 08    cmp #$08
AD50: B0 F7    bcs $ad49
AD52: A9 01    lda #$01
AD54: 85 18    sta $18
AD56: A9 90    lda #$90
AD58: 85 17    sta $17
AD5A: A2 00    ldx #$00
AD5C: CA       dex
AD5D: D0 FD    bne $ad5c
AD5F: C6 17    dec $17
AD61: D0 F9    bne $ad5c
AD63: C6 18    dec $18
AD65: D0 F5    bne $ad5c
AD67: A9 2B    lda #$2b
AD69: 85 1F    sta $1f
AD6B: A5 10    lda $10
AD6D: 85 19    sta $19
AD6F: A5 11    lda $11
AD71: 18       clc
AD72: 69 08    adc #$08
AD74: 85 1A    sta $1a
AD76: A5 12    lda $12
AD78: 38       sec
AD79: E9 40    sbc #$40
AD7B: 85 33    sta $33
AD7D: A5 13    lda $13
AD7F: E9 00    sbc #$00
AD81: 18       clc
AD82: 69 08    adc #$08
AD84: 85 34    sta $34
AD86: A0 02    ldy #$02
AD88: A5 1F    lda $1f
AD8A: B1 19    lda ($19), y		; [unchecked_address]
AD8C: 29 F8    and #$f8
AD8E: 09 03    ora #$03
AD90: 91 19    sta ($19), y		; [video_address]
AD92: 88       dey
AD93: 10 F5    bpl $ad8a
AD95: A5 1A    lda $1a
AD97: C9 0C    cmp #$0c
AD99: B0 05    bcs $ada0
AD9B: A9 4A    lda #$4a
AD9D: 4C 10 30 jmp $3010
ADA0: C9 10    cmp #$10
ADA2: B0 F7    bcs $ad9b
ADA4: A9 01    lda #$01
ADA6: 85 18    sta $18
ADA8: A9 20    lda #$20
ADAA: 85 17    sta $17
ADAC: A2 00    ldx #$00
ADAE: CA       dex
ADAF: D0 FD    bne $adae
ADB1: C6 17    dec $17
ADB3: D0 F9    bne $adae
ADB5: C6 18    dec $18
ADB7: D0 F5    bne $adae
ADB9: A5 19    lda $19
ADBB: 38       sec
ADBC: E9 20    sbc #$20
ADBE: 85 19    sta $19
ADC0: A5 1A    lda $1a
ADC2: E9 00    sbc #$00
ADC4: 85 1A    sta $1a
ADC6: A5 1A    lda $1a
ADC8: C5 34    cmp $34
ADCA: D0 BA    bne $ad86
ADCC: A5 19    lda $19
ADCE: C5 33    cmp $33
ADD0: D0 B4    bne $ad86
ADD2: A0 02    ldy #$02
ADD4: B1 19    lda ($19), y		; [unchecked_address]
ADD6: 29 F8    and #$f8
ADD8: 09 03    ora #$03
ADDA: 91 19    sta ($19), y		; [video_address]
ADDC: 88       dey
ADDD: 10 F5    bpl $add4
ADDF: A5 1A    lda $1a
ADE1: C9 0C    cmp #$0c
ADE3: B0 05    bcs $adea
ADE5: A9 4B    lda #$4b
ADE7: 4C 10 30 jmp $3010
ADEA: C9 10    cmp #$10
ADEC: B0 F7    bcs $ade5
ADEE: A9 00    lda #$00
ADF0: 8D 01 21 sta sound_2101
ADF3: 60       rts

AF00: A5 3B    lda $3b
AF02: 18       clc
AF03: 69 01    adc #$01
AF05: 85 19    sta $19
AF07: A5 3C    lda $3c
AF09: 18       clc
AF0A: 69 01    adc #$01
AF0C: 85 1A    sta $1a
AF0E: A9 1B    lda #$1b
AF10: 38       sec
AF11: E5 19    sbc $19
AF13: 18       clc
AF14: 2A       rol a
AF15: 2A       rol a
AF16: 2A       rol a
AF17: 2A       rol a
AF18: 85 17    sta $17
AF1A: A9 00    lda #$00
AF1C: 69 00    adc #$00
AF1E: 0A       asl a
AF1F: 26 17    rol $17
AF21: 69 04    adc #$04
AF23: 85 18    sta $18
AF25: A9 1F    lda #$1f
AF27: 38       sec
AF28: E5 1A    sbc $1a
AF2A: 18       clc
AF2B: 65 17    adc $17
AF2D: 85 17    sta $17
AF2F: A9 71    lda #$71
AF31: 85 19    sta $19
AF33: A9 AF    lda #$af
AF35: 85 1A    sta $1a
AF37: A5 3D    lda $3d
AF39: 0A       asl a
AF3A: A8       tay
AF3B: B1 19    lda ($19), y
AF3D: 85 1B    sta $1b
AF3F: C8       iny
AF40: B1 19    lda ($19), y
AF42: 85 1C    sta $1c
AF44: A2 02    ldx #$02
AF46: A0 02    ldy #$02
AF48: B1 1B    lda ($1b), y
AF4A: 91 17    sta ($17), y   ; [video_address]
AF4C: 88       dey
AF4D: 10 F9    bpl $af48
AF4F: A9 03    lda #$03
AF51: 18       clc
AF52: 65 1B    adc $1b
AF54: 85 1B    sta $1b
AF56: A5 1C    lda $1c
AF58: 69 00    adc #$00
AF5A: 85 1C    sta $1c
AF5C: A9 20    lda #$20
AF5E: 18       clc
AF5F: 65 17    adc $17
AF61: 85 17    sta $17
AF63: A5 18    lda $18
AF65: 69 00    adc #$00
AF67: 85 18    sta $18
AF69: CA       dex
AF6A: 10 DA    bpl $af46
AF6C: A9 00    lda #$00
AF6E: 85 5A    sta $5a
AF70: 60       rts
