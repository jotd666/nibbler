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
;	map(0x2400, 0x2400).w("snk6502", FUNC(fantasy_sound_device::speech_w));  // speech
;	map(0x3000, 0x3fff).rom().region("maincpu", 0x3000);
;	map(0x4000, 0xffff).rw(FUNC(fantasy_state::highmem_r), FUNC(fantasy_state::highmem_w));

; high memory:     
;	 FFE0  FF FF FF FF FF FF F3 42 A4 0C 3C 64 1B E2 B7 48   
;    FFF0  FF FF 5C DA AE EF 44 30 FF FF 00 30 04 30 09 30  

flipscreen_2103 = $2103
scroll_x_2200 = $2200
scroll_y_2300 = $2300

nmi_3000:    ; [global]
3000: 78       sei
3001: 4C 0E 32 jmp $320e
reset_3004:  ; [global]
3004: 78       sei
3005: 4C 00 78 jmp $7800

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

; cpu wait loop
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
3087: 2D 05 21 and $2105
308A: D0 F9    bne $3085
308C: A0 00    ldy #$00
308E: 88       dey
308F: D0 FD    bne $308e
3091: A9 08    lda #$08
3093: 2D 05 21 and $2105
3096: F0 03    beq $309b
3098: 20 02 4D jsr $4d02
309B: A9 02    lda #$02
309D: 2D 05 21 and $2105
30A0: D0 0A    bne $30ac
30A2: A9 01    lda #$01
30A4: 2D 05 21 and $2105
30A7: F0 E3    beq $308c
30A9: 4C C1 30 jmp $30c1
30AC: A9 00    lda #$00
30AE: 85 FD    sta $fd
30B0: 4C C1 30 jmp $30c1
30B3: A9 01    lda #$01
30B5: 2D 05 21 and $2105
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
30D9: 8D 00 21 sta $2100
30DC: A5 4F    lda $4f
30DE: F0 0D    beq $30ed
30E0: C6 4F    dec $4f
30E2: D0 09    bne $30ed
30E4: A5 A6    lda $a6
30E6: 29 F0    and #$f0
30E8: 85 A6    sta $a6
30EA: 8D 01 21 sta $2101
30ED: A5 BE    lda $be
30EF: C9 10    cmp #$10
30F1: B0 3F    bcs $3132
30F3: A5 BD    lda $bd
30F5: D0 3B    bne $3132
30F7: A9 80    lda #$80
30F9: 2D 07 21 and $2107
30FC: F0 14    beq $3112
30FE: A9 20    lda #$20
3100: 2D 06 21 and $2106
3103: D0 06    bne $310b
3105: A5 F5    lda $f5
3107: F0 29    beq $3132
3109: 30 27    bmi $3132
310B: A9 10    lda #$10
310D: 85 BE    sta $be
310F: 4C 2A 31 jmp $312a
3112: A9 40    lda #$40
3114: 2D 07 21 and $2107
3117: F0 19    beq $3132
3119: A9 20    lda #$20
311B: 2D 06 21 and $2106
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
3144: 2D 04 21 and $2104
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
315D: 2D 04 21 and $2104
3160: F0 03    beq $3165
3162: 20 C6 4D jsr $4dc6
3165: A9 08    lda #$08
3167: 2D 04 21 and $2104
316A: F0 03    beq $316f
316C: 20 26 4E jsr $4e26
316F: A9 04    lda #$04
3171: 2D 05 21 and $2105
3174: F0 03    beq $3179
3176: 4C DE 59 jmp $59de
3179: A5 4D    lda $4d
317B: F0 0D    beq $318a
317D: C6 4D    dec $4d
317F: D0 09    bne $318a
3181: A5 A5    lda $a5
3183: 29 F0    and #$f0
3185: 85 A5    sta $a5
3187: 8D 00 21 sta $2100
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
31B6: 2D 06 21 and $2106
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
31EB: 2D 05 21 and $2105
31EE: F0 03    beq $31f3
31F0: 20 02 4D jsr $4d02
31F3: A9 08    lda #$08
31F5: 2D 05 21 and $2105
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
3233: 2D 06 21 and $2106
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
3265: 8D 00 21 sta $2100
3268: 09 10    ora #$10
326A: 85 A5    sta $a5
326C: 8D 00 21 sta $2100
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
329D: 8D 00 21 sta $2100
32A0: 85 A6    sta $a6
32A2: 8D 01 21 sta $2101
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
32D0: 91 17    sta ($17), y
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
32F7: 2D 06 21 and $2106
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
3360: 2D 06 21 and $2106
3363: F0 0B    beq $3370
3365: A9 10    lda #$10
3367: 2D 04 21 and $2104
336A: D0 04    bne $3370
336C: A9 00    lda #$00
336E: 85 BA    sta $ba
3370: 60       rts

3423: 08       php
3424: 85 BB    sta $bb
3426: A0 00    ldy #$00
3428: A9 30    lda #$30
342A: 91 2D    sta ($2d), y
342C: A5 BE    lda $be
342E: C9 10    cmp #$10
3430: B0 01    bcs $3433
3432: 60       rts
3433: A9 01    lda #$01
3435: 8D 01 21 sta $2101
3438: A9 09    lda #$09
343A: 8D 01 21 sta $2101
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
3587: 20 6E 4B jsr $4b6e
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
35EA: 20 6E 4B jsr $4b6e
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
3633: 91 17    sta ($17), y
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
367D: 91 17    sta ($17), y
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
36A0: 91 17    sta ($17), y
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
36C3: 91 17    sta ($17), y
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
36E6: 91 17    sta ($17), y
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
372D: 91 17    sta ($17), y
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
3743: 91 17    sta ($17), y
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
3766: 91 17    sta ($17), y
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
3789: 91 17    sta ($17), y
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
3808: 20 6E 4B jsr $4b6e
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
383F: B9 C6 38 lda $38c6, y
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
388E: 20 6E 4B jsr $4b6e
3891: A9 1F    lda #$1f
3893: 85 17    sta $17
3895: A9 0C    lda #$0c
3897: 85 18    sta $18
3899: A0 00    ldy #$00
389B: A9 03    lda #$03
389D: 91 17    sta ($17), y
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
3950: 8D 01 21 sta $2101
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
396A: 8D 01 21 sta $2101
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
39A4: 4C 6E 4B jmp $4b6e
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
39D6: 2D 06 21 and $2106
39D9: F0 0C    beq $39e7
39DB: A5 BE    lda $be
39DD: C9 30    cmp #$30
39DF: 90 06    bcc $39e7
39E1: AD 05 21 lda $2105
39E4: 4C EA 39 jmp $39ea
39E7: AD 04 21 lda $2104
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
39FC: 8D 01 21 sta $2101
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
3B1A: 8D 00 21 sta $2100
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
3B35: 8D 01 21 sta $2101
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
3C1F: 8D 01 21 sta $2101
3C22: A9 0B    lda #$0b
3C24: 8D 01 21 sta $2101
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
3D9A: 91 17    sta ($17), y
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
3FA9: 2D 07 21 and $2107
3FAC: F0 F1    beq $3f9f
3FAE: 4C 06 59 jmp $5906

