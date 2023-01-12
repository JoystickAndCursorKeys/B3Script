0 reset: volume 0.5 : chvolume 1,1
1 color 1,0,26: cls
2 print "Use the keyboard to play piano!"
3 print "Press Escape to exit!"
4 print "Press Tab to record"
5 print "Press Shift to play / stops"
7 kb$="qwertyuiopasdfghjklzxcvbnm"
8 dim replay(100) : repptr = 0 : rec = 0
10 getkey a$: if a$ = "" then goto 10
11 if a$ = "Tab" then rec = 1 - rec : border 26 + rec
12 if a$ = "Tab" and rec = 1 then repptr = 0: goto 10
13 if a$ = "Shift" then rec = 0: gosub playsong: border 26 + rec: goto 10
15 print a$
21 gosub lookup
22 note = 100 + (rv * 10)
23 color 3: print uc$("266a") ;: color 1: print " f=" ; note
24 beep 1, note , 100
25 if rec = 1 then replay( repptr ) = note: repptr = repptr  + 1
26 w=ti + 50
27 if ti < w then goto 27
30 goto 10

100 sub lookup
101 rv=0:for t = 1 to len( kb$ )
110 if mid$(kb$,t,1) = a$ then rv = t
140 next
150 return
200 getkey a$ : if a$ = "" then goto 200
210 print a$

300 sub playsong
305 border 3
310 for t=0 to repptr-1
320 w=ti+110
325 if ti<w then goto 325
330 beep 1,replay( t ), 100
340 next
400 return
