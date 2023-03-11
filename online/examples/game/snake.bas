0 reset
10 SYNCH =20 : VOL = 0.5: DISPLAY 200
15 CLS RESET :IMMEDIATE  1:VOLUME VOL : chvolume 0,1 : chvolume 1,.5
20 SW =COLS ():SH =ROWS ():TAW =80:TAH =32:SBH = 4 : gameover = 0
22 if SW < TAW+2 OR SH < TAH + 2 THEN RESET:  COLOR 1,0,2 : CLS: PRINT: PRINT " TOO LOW RESOLUTION!! " : END
30 DIM LIV$ ( 3) : DIM WALLH(3)
40 DIM SCL ( 2):SCL ( 0)= 5:SCL ( 1)=11
45 DIM LVLC(14): DIM LVFCH(14) : DIM LVLWC(14) : DIM LVLWCC(14) : DIM LVLSTGNAME$(14)
50 COLOR  1, 0, 0:CLS
60 TAX0 =INT ((SW / 2)-(TAW / 2)):TAY0 =INT ((SH / 2)-(TAH / 2))
70 IF TAX0 < 0OR TAY0 < 0THEN COLOR  2, 0, 2:CLS RESET :PRINT "SCREEN TO SMALL!"
80 TEXTAREA TAW ,TAH ,TAX0 ,TAY0
91 WALLH(0) = 532:WALLH(1) = 532:WALLH(2) = 532
92 read stagecount
95 FOR I = 0 TO stagecount-1:
96 READ D : LVLC(I) = D : READ D : LVFCH(I) = D
97 READ D : LVLWC(I) = D
98 READ D: LVLWCC( I ) = D
99 NEXT
100 FOR I = 0 TO stagecount-1: READ D$ : LVLSTGNAME$(  I ) = D$ : NEXT
200 CXWIDTH = width() / cols(): CXHEIGHT = height() / rows():
210 def fn XPOS(x) = CXWIDTH * x
220 def fn YPOS(y) = CXHEIGHT * y
310 drU = 8 : drD = 4 : drL = 2 : drR = 1
311 iuR  = drU + (16 * drR)
312 iuL  = drU + (16 * drL)
313 irD  = drR + (16 * drD)
314 irU  = drR + (16 * drU)
315 ilD  = drL + (16 * drD)
316 ilU  = drL + (16 * drU)
317 idL  = drD + (16 * drL)
318 idR  = drD + (16 * drR)
320 DIM SCHR(256) : FOR T = 0 TO 255 : SCHR( T ) = 65+T: NEXT
321 SCHR( iuR ) = 410
322 SCHR( iuL ) = 411
323 SCHR( irD ) = 411
324 SCHR( irU ) = 413
325 SCHR( ilD ) = 410
326 SCHR( ilU ) = 412
327 SCHR( idL ) = 413
328 SCHR( idR ) = 412

1000 SUB MAINLOOP
1010 GOSUB TITLE
1020 gameover = 0 : GOSUB GAME
1030 GOTO MAINLOOP

2000 SUB TITLE
2001 textarea cols(), rows(), 0 , 0
2002 color 5,0: cls
2003 TEXTAREA TAW+2 ,TAH+2 ,TAX0-1 ,TAY0-1
2004 color 5,2: cls
2005 TEXTAREA TAW ,TAH ,TAX0 ,TAY0
2020 color 1,0: CLS
2024 restore: read stagecount
2025 FOR i = 0 TO stagecount-1: READ dummy0: READ dummy1:  READ dummy2: READ dummy3: NEXT
2026 FOR i = 0 TO stagecount-1: READ dummy$ : NEXT
2027 read tpw: read tph : tpxo = tax0+15: tpyo = tay0 + 1
2028 for tpy=0 to tph-1: for tpx=0 to tpw-1
2029 read tpch: read tpcol: read tpbg
2030 pokeccl tpx+tpxo,tpy+tpyo,tpch,tpcol,tpbg
2031 next: next
2050 LOCATE INT ( 14 ), 0
2051 color 5,0: CENTER "Snake B3":PRINT
2052 if gameover = 1 then  COLOR  2,0 : CENTER "Game Over": PRINT
2053 if gameover = 1 then  COLOR  1,0 : CENTER "Your Score: " ; int( SC ) :PRINT
2054 if gameover = 1 then  COLOR  1,0 : CENTER "Level: " ; int( Level ) :PRINT
2055 if gameover = 1 then gosub sndgameover
2056 COLOR  1,0
2060 LOCATE 27,0: CENTER "Press any key to start"
2070 LOCATE 29,0:  CENTER "Use 'WASD' or CursorKeys" : locate 0,0
2100 GOSUB WAITKEY
2120 RETURN

3000 SUB GAME
3010 WALL =528:HRTH =9829:CLOVER =9827: STARCH0 = 608: STARCH1 =  609:  GOALCH0=9654 : GOALCHA0=9664 : goalch = 296
3011 KEY0 = 373: KEY1 = 294: KEY2=352
3015 SNAKE = 9608
3016 textarea cols(), rows(), 0 , 0
3017 color 5,0,0: cls
3020 GOSUB DRAWLEVEL
3030 TEXTAREA TAW ,SBH ,TAX0 ,TAY0 :COLOR  1, 0:CLS
3035 GOSUB UPDATELEVELINDICATOR
3040 SC = 0:FLIP0=0:FLIP = 0:DC = 0 : Level = 0
3060 LIVES = 3
3070 LIV$ ( 3)=UC$ (HRTH );UC$ (HRTH );UC$ (HRTH )
3080 LIV$ ( 2)=UC$ (HRTH );UC$ (HRTH );" "
3090 LIV$ ( 1)=UC$ (HRTH );"  "
3100 REM RESUME NEXT LEVEL OR NEXT LIVE
3101 GOSUB LIVESTATUS
3102 X =INT (TAW / 2):Y =INT (TAH / 2):XD = 0:YD = 1
3103 XI =INT (X ):YI =INT (Y ):LXI =XI :LYI =YI : YF=.6: XF=1 :SPF = .5: SPC = 0: SPCI = .01
3104 XSP =  1 * SPF :YSP =YF * SPF
3105 CD = 10: CDS = .01
3106 GOSUB DRAWTIMER
3107 IF gameover = 1 then Level = 0 :RETURN
3110 GOSUB CALCULATESTAGE
3111 REM  -- -- -- CLEAR RECTANGLE AROUND PLAYER FROM WALLS -- -- -- --
3112 for cly = yi-4 to yi+4
3113 for clx = xi-5 to xi+5
3114  CH = PEEKC( TAX0 +clx, TAY0 +cly )
3115  IF CH <> STARCH0 AND CH <> STARCH1 THEN POKECCL TAX0 +clx ,TAY0 +cly ,LVFCHR,0,LVLC(STAGEIX)
3116 next:next
3120 OLDXI = -999: OLDYI = -999: LASTSC = -1
3130 REM -- -- -- -- -- -- -- -- -- -- -- --  GAMELOOP -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
3135 SPC = SPC + SPCI: IF SPC > 1 THEN SPC = 0 : GOSUB GOFASTER
3145 IF OLDXI <> XI OR OLDYI <> YI THEN POKECCL TAX0 +XI ,TAY0 +YI ,SNAKE ,SCL (FLIP ),0 : OLDXI = XI: OLDYI = YI
3150 GETKEY KEY$
3160 if key$ <> "" then gosub HANDLEKEYS
3200 GOSUB MOVEPLAYER
3205 if nextlev = 1 then gosub NEXTLEVEL : SC = SC + 100: GOSUB REDRAWINGAME : goto 3100
3210 IF die then goto 3100
3300 waitms 20
3310 SC =SC + .1: IF INT(SC) <> LASTSC THEN COLOR 1:LOCATE  0, 1:PRINT "Score: "; pad$( str$( int( sc ), 10, 0), "0", 6 ): LASTSC = int(SC)
3315 CD=CD-CDS
3316 GOSUB DRAWTIMER
3320 GOTO 3130
3330 END

3400 SUB HANDLEKEYS
3401 pXD = XD : pYD = YD
3402 IF KEY$ ="w" OR KEY$ = "ArrowUp" AND YD=0 THEN YD =- 1:XD = 0 :  gosub CHANGEDIRECTION
3403 IF KEY$ ="s" OR KEY$ = "ArrowDown" AND YD=0 THEN YD = 1:XD = 0 :  gosub CHANGEDIRECTION
3404 IF KEY$ ="a" OR KEY$ = "ArrowLeft" AND XD=0 THEN XD =- 1:YD = 0 :  gosub CHANGEDIRECTION
3405 IF KEY$ ="d" OR KEY$ = "ArrowRight" AND XD=0 THEN XD = 1:YD = 0 :  gosub CHANGEDIRECTION
3440 RETURN

3450 SUB CHANGEDIRECTION
3451 six = 0: gosub sound
3452 tmpLastDir = 0 : tmpCurDir = 0
3453 IF pXD = 1 THEN tmpLastDir = drR
3454 IF pXD = -1 THEN tmpLastDir = drL
3455 IF pYD = 1 THEN tmpLastDir = drD
3456 IF pYD = -1 THEN tmpLastDir = drU
3457 IF XD = 1 THEN tmpCurDir = drR
3458 IF XD = -1 THEN tmpCurDir = drL
3459 IF YD = 1 THEN tmpCurDir = drD
3460 IF YD = -1 THEN tmpCurDir = drU
3465 CDIX = tmpLastDir + (16 * tmpCurDir)
3466 SNKCHR = SCHR( CDIX )
3467 OLDC = PEEKCL( TAX0 +XI ,TAY0 +YI, 0 )
3470 POKECCL TAX0 +XI ,TAY0 +YI , SNKCHR, OLDC, LVLC(STAGEIX)
3471 RETURN

3500 SUB MOVEPLAYER
3510 X =X +(XD *XSP )
3520 Y =Y +(YD *YSP )
3525 LXI =XI :LYI =YI :XI =INT (X ):YI =INT (Y )
3530 IF LXI <>XI OR LYI <>YI THEN FLIP0 = 1-FLIP0: IF FLIP0 = 0 then FLIP = 1 - FLIP
3540 GOSUB TESTPLAYER
3550 IF DIE = 1THEN GOSUB PLAYERDIE
3580 if nextlev = 1 then POKECCL TAX0 +XI ,TAY0 +YI ,SNAKE ,SCL (FLIP ),0
3582 if nextlev = 1 then xi=xi + XD : flip = 1-flip : POKECCL TAX0 +XI ,TAY0 +YI ,SNAKE ,SCL (FLIP ),0
3583 if nextlev = 1 then RETURN
3595 X =RANGE (X , 0,TAW - 1):Y =RANGE (Y , 0,TAH - 1)
3599 RETURN

3600 SUB CALCULATESTAGE
3610 STAGEIX = INT(Level / 3) % stagecount
3620 RETURN

3700 SUB GOFASTER
3710 SPF = SPF + .1
3711 SPF = RANGE( SPF, 0, 1)
3715 XSP =  1 * SPF :YSP =YF * SPF
3716 PSPF = INT(SPF*10)
3725 IF PSPF = LSPF THEN RETURN
3740 LSPF = PSPF
3745 SIX=1 : GOSUB SOUND
3750 RETURN

3800 SUB UPDATELEVELINDICATOR
3820 LVL$ = "   Level: " + Level
3821 STG$ = "   Stage: " + LVLSTGNAME$( STAGEIX )
3830 TEXTAREA TAW ,TAH ,TAX0 ,TAY0
3840 LOCATE  0,0: COLOR  5, 0 : CENTER LVL$
3841 LOCATE  1,0: COLOR  5, 0 : CENTER STG$
3850 RETURN

3900 SUB DRAWTIMER
3910 LIW = INT((TAW-2) * (CD/10)) : LIW2 = TAW-LIW
3920 FOR T=1 TO TAW-2
3930 TCH = 9675 : TCC = 14
3940 if LIW >T then TCH = 9679
3945 IF T<15 then tcc = 5
3946 IF T<10 then tcc = 11
3947 IF T<5 then tcc = 2
3950 pokeccl t+TAX0,2+TAY0,tch, TCC,0
3960 next
3970 RETURN

4000 SUB DRAWLEVEL
4001 TEXTAREA TAW ,TAH ,TAX0 ,TAY0  : HH = TAH-SBH: WW = TAW
4005 GOSUB CALCULATESTAGE : LVFCHR = LVFCH( STAGEIX )
4010 COLOR  LVLWC(STAGEIX), LVLC(STAGEIX):CLS
4015 FOR X=TAX0 TO TAX0+TAW-1: FOR Y=TAY0 TO TAY0+TAH-1
4016  POKECCL X,Y, LVFCHR,0,LVLC(STAGEIX)
4017 NEXT: NEXT
4020 REM  -- -- -- -- -- -- OUTER WALLS -- -- --  -- -- -- --
4021 SPW =WIDTH ():SPH =HEIGHT ()
4060 FOR TX = 0TO TAW - 1
4065  CH = WALLH( TX % 3)
4070  POKECCL TAX0 +TX ,TAY0 +SBH ,CH,LVLWC(STAGEIX),LVLWCC(STAGEIX) :POKECCL TAX0 +TX ,TAY0 +TAH - 1, CH,LVLWC(STAGEIX),LVLWCC(STAGEIX)
4080 NEXT
4090 FOR TY =SBH TO TAH - 1
4095  CH = WALLH( TY % 3)
4100  POKECCL TAX0 ,TAY0 +TY ,CH,LVLWC(STAGEIX),LVLWCC(STAGEIX) :POKECCL TAX0 +TAW - 1,TAY0 +TY ,CH,LVLWC(STAGEIX),LVLWCC(STAGEIX)
4110 NEXT
4115 REM  -- -- -- -- -- -- DOOR (DOOR POSTS) -- -- --  -- -- -- --
4120 LHEIGHT = TAH-2-7 : Y = INT(RND(0)*LHEIGHT) + TAY0 + 3
4125 X=TAX0 +TAW - 2 : X2 = X+1 : GC0 = GOALCH0: GC1 = GOALCH
4126 if Level % 2 = 0 then x = TAX0: x2 = x+1 : GC0 = GOALCH: GC1 = GOALCHA0
4130 POKECCL X2, Y, WALL, LVLWC(STAGEIX), LVLWCC(STAGEIX): POKECCL X, Y, WALL, LVLWC(STAGEIX),LVLWCC(STAGEIX)
4135 POKECCL X2, Y+5, WALL, LVLWC(STAGEIX), LVLWCC(STAGEIX) : POKECCL X, Y+5, WALL, LVLWC(STAGEIX),LVLWCC(STAGEIX)
4140 Y=Y+1
4145 REM  -- -- -- -- -- -- DOOR (GOAL CHARS) -- -- --  -- -- -- --
4150 FOR TY=0 TO 3
4155  POKECCL X2,Y+TY,GC0,14,LVLC(STAGEIX): POKECCL X,Y+TY,GC1,14,LVLC(STAGEIX)
4160 NEXT
4190 REM  -- -- -- -- -- -- OBSTACLE WALLS -- -- --  -- -- -- --
4200 Y=Y-2
4205 X = TAW - 10
4210 FOR YY=0 to 6 : POKECCL X, YY + Y, WALL, LVLWC(STAGEIX),LVLWCC(STAGEIX) : NEXT
4300 WL = 7: LHEIGHT = TAH-2-(2*WL) : LWIDTH = TAW-2-(2*WL)
4305 FOR T = 0 TO LEVEL
4310  Y = INT(RND(0)*LHEIGHT) + TAY0 + WL
4315  X = INT(RND(0)*LWIDTH) + TAX0 + WL
4320  IF T % 2 = 1 THEN FOR YY=0 to WL-1 : POKECCL X,    YY + Y, WALL, LVLWCC(STAGEIX), LVLWC(STAGEIX) : NEXT
4325  IF T % 2 = 0 THEN FOR XX=0 to WL-1 : POKECCL XX+X, Y,      WALL, LVLWCC(STAGEIX), LVLWC(STAGEIX) : NEXT
4330 NEXT
4414 REM  -- -- -- -- -- -- STARS -- -- --  -- -- -- --
4415 for t = 0 to Level
4416 sxx = INT(rnd(0)*(WW-3))+TAX0+1: syy= INT(rnd(0)*(HH-2))+TAY0 + SBH + 1
4420 CH0 = PEEKC( sxx, syy ): CH1 = PEEKC( sxx+1, syy )
4430 IF CH0 = LVFCHR AND CH1 = LVFCHR THEN pokeccl sxx, syy, STARCH0, 5
4431 IF CH0 = LVFCHR AND CH1 = LVFCHR THEN pokeccl sxx+1, syy, STARCH1, 5
4449 next
4500 RETURN

5000 SUB TESTPLAYER
5010 DIE = 0 : NEXTLEV = 0
5015 IF CD <= 0 then DIE = 1: RETURN
5020 IF (LXI =XI AND LYI =YI )THEN RETURN
5025 PCHAR = PEEKC (XI +TAX0 ,YI +TAY0 )
5026 IF PCHAR = LVFCHR THEN  RETURN
5030 IF PCHAR = GOALCH THEN NEXTLEV = 1 : RETURN
5035 IF PCHAR = STARCH0 THEN SC=SC+200 :  GOSUB sndstar : POKECCL XI +TAX0 + 1 ,YI +TAY0, LVFCHR, 0,LVLC(STAGEIX): RETURN
5036 IF PCHAR = STARCH1 THEN SC=SC+200 :  GOSUB sndstar : POKECCL XI +TAX0 - 1 ,YI +TAY0, LVFCHR, 0,LVLC(STAGEIX): RETURN
5040 IF PCHAR<>LVFCHR THEN DIE = 1 : RETURN
5090 return

5100 SUB REDRAWINGAME
5110 TEXTAREA TAW ,TAH ,TAX0 ,TAY0 : gosub DRAWLEVEL
5120 TEXTAREA TAW ,SBH ,TAX0 ,TAY0 :COLOR  1, 0:CLS : gosub LIVESTATUS
5130 GOSUB UPDATELEVELINDICATOR
5140 RETURN

5500 SUB NEXTLEVEL
5505 Level = Level + 1
5510 TEXTAREA TAW ,TAH ,TAX0 ,TAY0
5515 COLOR  1, 3
5520 LOCATE INT (ROWS ()/ 2)- 5, 0:CENTER "  Enter Level " + ( Level + 1)
5525 CENTER "Your Score: ";int( SC )
5527 OLVI = STAGEIX: GOSUB CALCULATESTAGE : NLVI = STAGEIX
5531 IF OLVI = NLVI THEN GOSUB sndnextlevel
5532 IF OLVI <> NLVI THEN GOSUB sndnextstage
5535 GOSUB WAITKEY
5540 RETURN

6000 SUB PLAYERDIE
6005 LIVES =LIVES - 1: IF LIVES = 0 THEN gameover = 1
6010 TEXTAREA TAW ,TAH ,TAX0 ,TAY0
6020 COLOR  1, 2
6030 LOCATE INT (ROWS ()/ 2)- 5, 0:CENTER "  1 Live Lost  "
6040 CENTER "Your Score: ";int( SC )
6050 GOSUB snddie
6055 FOR t = 0 TO 25: border t: waitms 20: next : border 0
6060 GOSUB WAITKEY
6065 GOSUB REDRAWINGAME
6070 RETURN

7000 SUB WAITKEY
7010 GET K$
7020 IF K$ <>" "THEN GOTO 7010
7030 RETURN

8000 SUB LIVESTATUS
8010 LOCATE  0,TAW - 4:COLOR  2, 0:PRINT LIV$ (LIVES );
8020 RETURN

9500 SUB WAIT
9510 waitms 5 : rem SYNCH
9530 RETURN

10000 sub sound
10010 if six = 0 then chvolume 0,.5: BEEP  1,50,70 : return
10020 if six = 1 then chvolume 0,.5: BEEP  0,930,70 : return
10900 reset : cls : print "unknown sound " ; six : end

15000 sub sndnextlevel
15001 ch = 2
15010 volume .5: chvolume ch,1: clearfx ch : f = 30: sh = 18
15100 for r = 0 to 25
15110 ADDFX  ch,11,r*1000, r*f
15120 ADDFX  ch,21, 1, r*f
15130 ADDFX  ch,10,r*50 ,r*f + sh
15150 next
15160 ADDFX  ch,21, 0,(r+1)*f
15200 playfx ch
15300 return

16000 sub sndnextstage
16001 ch = 2
16010 volume .5: chvolume ch,1: clearfx ch : f = 100: sh = 80
16100 for r = 0 to 50 step 1: r2=50-r
16110 ADDFX  ch,11,r2*11, r*f
16120 ADDFX  ch,21, 1, r*f
16130 ADDFX  ch,10,r*10 ,r*f + sh
16150 next
16160 ADDFX  ch,21, 0,(r)*f + (sh*2)
16200 playfx ch
16300 return

17000 sub snddie
17001 ch = 3
17010 volume .5: chvolume ch,1: clearfx ch : f = 10: sh = 8
17100 for r = 0 to 50 step 1: r2=50-r
17110 ADDFX  ch,11,r2*31, r*f
17120 ADDFX  ch,21, 1, r*f
17130 ADDFX  ch,10,r2*5 ,r*f + sh
17150 next
17160 ADDFX  ch,21, 0,(r)*f + (sh*2)
17200 playfx ch
17201 return

18000 sub sndgameover
18001 ch = 2
18010 volume .5: chvolume ch,1: clearfx ch : f = 30: sh = 18
18100 for r = 0 to 50
18110 ADDFX  ch,11,int(rnd()*1000), r*f
18120 ADDFX  ch,21, 1, r*f
18130 ADDFX  ch,10,int(rnd()*1000),r*f + sh
18150 next
18160 ADDFX  ch,21, 0,(r+1)*f
18200 playfx ch
18201 return

19000 sub sndstar
19001 ch = 2
19010 volume .5: chvolume ch,1: clearfx ch : f = 3: sh = 8
19100 for r = 10 to 60 step 10: r2=50-r
19110 ADDFX  ch,11,r*61, r*f
19120 ADDFX  ch,21, 1, r*f
19130 ADDFX  ch,10,r*20 ,r*f + sh
19150 next
19160 ADDFX  ch,21, 0,(r)*f + (sh*2)
19200 playfx ch
19201 return

50000 sub data
50049 data 14  : REM stages   levelcolor, levelbgchar,  wallcolor, wallbgcolor
50050 data 20,536,6,26,  23,524,7,8,   0,32,1,8,   4,460,6,9,   10,534,11,8,   0,405,4,10  ,   12,420,13,8
50051 data 20,358,6,26,  23,527,7,8,   0,32,7,8,   20,364,4,0,   10,460,10,8,   20,534,4,10  ,   12,405,12,11
50052 data "Beginners Luck", "Purple Room", "Dark Room",  "Bathroom", "Orange Room", "Shady", "Solid Wood"
50053 data "Halfway Point",  "Neon City", "Neon Glow", "Blue Moon", "Industrial", "Blues", "Oak"
51000 data 48, 26
51010 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51020 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 490, 1, 0, 491, 1, 0, 492, 1, 1, 492, 1, 0, 493, 1, 0, 32, 1, 0, 32, 1, 0, 490, 1, 0, 491, 1, 0, 492, 1, 1, 492, 1, 0, 493, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51030 data  32, 1, 0, 32, 1, 0, 32, 2, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 491, 1, 1, 491, 1, 1, 388, 0, 1, 491, 1, 1, 32, 1, 1, 32, 1, 0, 32, 1, 0, 32, 1, 1, 32, 1, 1, 388, 0, 1, 32, 1, 1, 32, 1, 1, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51040 data  32, 1, 0, 32, 1, 0, 32, 2, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 491, 1, 1, 491, 1, 1, 32, 1, 0, 491, 1, 1, 32, 1, 1, 344, 0, 11, 344, 0, 11, 32, 1, 1, 32, 1, 1, 32, 0, 0, 32, 1, 1, 32, 1, 1, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51050 data  32, 1, 0, 32, 1, 0, 32, 2, 0, 391, 11, 0, 392, 11, 0, 32, 0, 11, 491, 1, 1, 491, 1, 1, 404, 0, 1, 491, 1, 1, 32, 1, 1, 32, 0, 11, 32, 0, 11, 32, 1, 1, 32, 1, 1, 404, 0, 1, 32, 1, 1, 32, 1, 1, 32, 0, 11, 393, 11, 0, 394, 11, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51060 data  32, 1, 0, 32, 2, 0, 383, 11, 0, 286, 5, 11, 32, 0, 11, 32, 0, 11, 412, 1, 11, 32, 0, 1, 32, 0, 1, 32, 0, 1, 413, 1, 11, 32, 0, 11, 32, 0, 11, 412, 1, 11, 32, 1, 1, 32, 1, 1, 32, 1, 1, 413, 1, 11, 32, 0, 11, 32, 0, 11, 286, 5, 11, 382, 11, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51070 data  32, 2, 0, 384, 11, 0, 32, 0, 11, 286, 5, 11, 286, 5, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 336, 1, 11, 32, 1, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 336, 1, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 286, 5, 11, 286, 5, 11, 32, 0, 11, 385, 11, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51080 data  32, 2, 0, 400, 11, 0, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 32, 0, 11, 401, 11, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51090 data  32, 2, 0, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 516, 5, 11, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51100 data  32, 1, 0, 383, 5, 5, 383, 5, 5, 383, 5, 5, 383, 5, 5, 383, 5, 5, 548, 0, 5, 312, 0, 5, 313, 0, 5, 549, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 548, 0, 5, 312, 0, 5, 313, 0, 5, 549, 0, 5, 32, 0, 5, 32, 5, 5, 32, 5, 5, 32, 5, 5, 32, 5, 5, 32, 5, 5, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51110 data  32, 1, 0, 382, 0, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 382, 5, 5, 383, 0, 5, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51120 data  32, 2, 0, 32, 11, 0, 32, 5, 0, 382, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 32, 0, 5, 383, 0, 5, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51130 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 386, 8, 0, 387, 8, 0, 32, 18, 0, 32, 18, 0, 32, 18, 0, 32, 18, 0, 32, 18, 0, 32, 18, 0, 32, 18, 0, 386, 8, 0, 387, 8, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51140 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 402, 1, 0, 403, 1, 0, 369, 27, 0, 515, 0, 27, 515, 0, 27, 515, 0, 27, 515, 0, 27, 515, 0, 27, 515, 0, 27, 402, 1, 0, 403, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 5, 0, 32, 1, 0, 32, 1, 0, 32, 5, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 383, 27, 0, 32, 1, 0
51150 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 447, 21, 0, 286, 5, 21, 286, 5, 21, 32, 0, 21, 32, 0, 21, 32, 0, 21, 414, 0, 21, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 552, 11, 27, 32, 1, 0
51160 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 286, 5, 21, 286, 5, 21, 286, 5, 21, 32, 0, 21, 32, 0, 21, 414, 0, 21, 32, 27, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 383, 27, 0, 32, 0, 27, 32, 1, 0
51170 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 383, 27, 0, 286, 11, 27, 286, 11, 27, 32, 5, 27, 32, 0, 27, 32, 0, 27, 32, 27, 0, 32, 27, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 383, 21, 0, 286, 5, 21, 384, 0, 21, 32, 21, 0
51180 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 286, 11, 27, 286, 11, 27, 32, 0, 27, 32, 5, 27, 32, 0, 27, 32, 0, 27, 32, 27, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 286, 11, 27, 32, 0, 27, 400, 0, 27, 32, 1, 0
51190 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 382, 0, 27, 552, 11, 27, 32, 0, 27, 32, 5, 27, 32, 0, 27, 32, 0, 27, 382, 27, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 383, 27, 0, 286, 11, 27, 32, 0, 27, 32, 1, 0, 32, 1, 0
51200 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 27, 0, 382, 0, 21, 286, 5, 21, 286, 5, 21, 286, 5, 21, 552, 5, 21, 286, 21, 21, 382, 21, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 27, 0, 383, 21, 0, 286, 5, 21, 32, 0, 21, 384, 0, 21, 32, 1, 0, 32, 1, 0
51210 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 27, 0, 286, 5, 21, 286, 5, 21, 552, 5, 21, 552, 5, 21, 32, 5, 21, 32, 0, 21, 32, 21, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 391, 27, 0, 392, 27, 0, 286, 11, 27, 286, 5, 21, 286, 5, 21, 286, 5, 21, 286, 11, 27, 32, 0, 27, 286, 11, 27, 393, 27, 0, 394, 21, 0, 32, 21, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 18, 0, 383, 27, 0, 286, 11, 27, 32, 0, 27, 552, 28, 27, 400, 0, 27, 32, 1, 0, 32, 1, 0
51220 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 27, 0, 382, 0, 27, 286, 11, 27, 32, 0, 27, 32, 0, 27, 286, 11, 27, 286, 11, 27, 382, 27, 0, 32, 1, 0, 391, 21, 0, 392, 21, 0, 286, 5, 21, 286, 11, 27, 32, 0, 27, 286, 11, 27, 32, 0, 27, 32, 0, 21, 552, 5, 21, 286, 5, 21, 32, 0, 27, 32, 0, 27, 32, 0, 27, 286, 11, 27, 286, 5, 21, 286, 5, 21, 286, 11, 27, 393, 27, 0, 394, 27, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 21, 0, 383, 27, 0, 286, 11, 27, 32, 0, 27, 553, 28, 27, 392, 0, 27, 32, 1, 0, 32, 1, 0, 32, 1, 0
51230 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 286, 11, 27, 32, 5, 27, 32, 5, 27, 32, 0, 27, 286, 11, 27, 286, 11, 27, 286, 5, 21, 286, 5, 21, 286, 5, 21, 552, 5, 21, 32, 5, 27, 32, 5, 27, 32, 0, 27, 32, 0, 27, 32, 0, 21, 32, 5, 21, 32, 5, 21, 32, 28, 27, 32, 28, 27, 32, 28, 27, 32, 28, 27, 32, 28, 21, 32, 28, 21, 32, 28, 27, 552, 11, 27, 32, 28, 27, 32, 28, 27, 32, 28, 27, 32, 28, 21, 552, 5, 21, 32, 28, 27, 286, 28, 27, 286, 28, 27, 383, 0, 27, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51240 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 382, 0, 27, 286, 11, 27, 32, 0, 27, 32, 0, 27, 32, 0, 27, 32, 0, 27, 32, 5, 21, 32, 0, 21, 32, 0, 21, 32, 0, 21, 32, 0, 27, 32, 0, 27, 32, 0, 27, 286, 28, 27, 32, 0, 21, 552, 19, 21, 32, 5, 21, 286, 28, 27, 553, 28, 27, 286, 28, 27, 32, 0, 27, 32, 0, 21, 32, 0, 21, 32, 0, 27, 32, 28, 27, 32, 0, 27, 32, 0, 27, 32, 0, 27, 286, 5, 21, 32, 0, 21, 286, 28, 27, 286, 28, 27, 286, 28, 27, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51250 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 415, 0, 27, 286, 28, 27, 286, 28, 27, 553, 28, 27, 32, 0, 27, 552, 19, 21, 286, 19, 21, 552, 19, 21, 552, 19, 21, 552, 28, 27, 286, 28, 27, 553, 28, 27, 391, 0, 27, 392, 0, 21, 32, 1, 0, 32, 1, 0, 32, 1, 0, 393, 0, 27, 394, 0, 27, 286, 28, 27, 552, 19, 21, 286, 19, 21, 286, 28, 27, 552, 28, 27, 286, 28, 27, 553, 28, 27, 286, 28, 27, 552, 19, 21, 286, 19, 21, 286, 28, 27, 391, 0, 27, 392, 0, 27, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0
51260 data  32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 393, 0, 27, 354, 0, 27, 346, 27, 0, 347, 27, 0, 346, 21, 0, 345, 21, 0, 344, 21, 0, 340, 21, 0, 339, 27, 0, 337, 27, 0, 32, 18, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 27, 0, 337, 21, 0, 338, 21, 0, 339, 27, 0, 339, 27, 0, 340, 27, 0, 339, 27, 0, 339, 27, 0, 338, 21, 0, 337, 21, 0, 336, 27, 0, 32, 27, 0, 32, 27, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0, 32, 1, 0