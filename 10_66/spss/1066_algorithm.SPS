* Encoding: US-ASCII.
* JOIN FILES

MATCH FILES /FILE=*
 /FILE='C:\data\stage1_output\csidsubj_processed.sav'
 /RENAME (interid = d0)
 /BY houseid particid
 /DROP= d0.
EXECUTE.
MATCH FILES /FILE=*
 /FILE='C:\data\stage1_output\background_processed.sav'
 /RENAME (date interid = d0 d1)
 /BY houseid particid
 /DROP= d0 d1.
EXECUTE.
MATCH FILES /FILE=*
 /FILE='C:\data\stage1_output\neuroex_processed.sav'
 /RENAME (date interid = d0 d1)
 /BY houseid particid
 /DROP= d0 d1.
EXECUTE.
MATCH FILES /FILE=*
 /FILE='C:\data\stage1_output\household_processed.sav'
 /RENAME (date interid toilet = d0 d1 d2)
 /BY houseid particid
 /DROP= d0 d1 d2.
EXECUTE.

**IMPUTING RELSCORE - THE FIRST COMMAND SAVES THE ORIGINAL RELSCORE VARIABLE BEFORE IMPUTATION OF THE MV

compute relscore_original= relscore.
execute.

COMPUTE pred_relscore= 0.004 + (0.072*whodas12) + (0.338*npisev).
execute.

RECODE
  pred_relscore  (Lowest thru 0=0)  (30 thru Highest=10)  .
EXECUTE .

RECODE
  relscore  (MISSING=999).
EXECUTE .

IF (relscore=999) relscore = pred_relscore .
EXECUTE .

RECODE
  relscore  (999=MISSING).
EXECUTE .

COMPUTE dfscore = 0.452322  - (0.01669918*COGSCORE) + (0.03033851*RELSCORE).
EXECUTE .
RECODE
  dfscore
  (Lowest thru 0.119999999=1)  (0.12 thru 0.18399999999=2)  (0.184 thru Highest=3)  (ELSE=Copy)  INTO
  dfcase .
EXECUTE .
RECODE
  cogscore
  (Lowest thru 28.5=3)  (28.50001 thru 29.5=2)  (29.50001 thru Highest=1)  (ELSE=Copy)  INTO
  cogcase .
EXECUTE .

APPLY DICTIONARY
  FROM='c:\data\dict\dict_csid.sav'.

SAVE OUTFILE='C:\data\stage2_output\csid_processed.sav'/ drop nametot count animtot wordtot1 wordtot2 papertot storytot/ COMPRESSED.
MATCH FILES /FILE=*
 /FILE='C:\data\stage1_output\gms_processed.sav'
 /RENAME (date interid = d0 d1)
 /BY houseid particid
 /DROP= d0 d1.
EXECUTE.
RECODE
  cogscore
  (Lowest thru 23.699=1)  (23.70 thru 28.619=2)  (28.62 thru 30.619=3)  (30.62
  thru 31.839=4)  (31.84 thru Highest=5)  INTO  ncogscor .
EXECUTE .
RECODE
  relscore
  (0=1)  (0.01 thru 1.99=2)  (2.0 thru 5.0=3)  (5.01 thru 12.0=4)  (12.01
  thru Highest=5)  INTO  nrelscor .
EXECUTE .
RECODE
  recall
  (0=1)  (4=3)  (1 thru 3=2)  (5 thru 6=4)  (7 thru Highest=5)  INTO  ndelay .
EXECUTE .
RECODE
  nrelscor
  (1=0)  (2=1.908)  (3=2.311)  (4=4.171)  (5=5.680)  INTO  brelscor .
EXECUTE .
RECODE
  ncogscor
  (1=2.801)  (2=1.377)  (3=0.866)  (4=-0.231)  (5=0)  INTO  bcogscor .
EXECUTE .
RECODE
  ndelay
  (5=0)  (4=2.176)  (3=2.575)  (2=3.349)  (1=3.822)  INTO  bdelay .
EXECUTE .
RECODE
  gmsdiag
  (6=0)  (1=1.566)  (2=1.545)  (3=-0.635)  (4=-0.674)  (5=0.34)  INTO
  bgmsdiag .
EXECUTE .
COMPUTE logodds = -9.53+brelscor+bcogscor+bdelay+bgmsdiag .
EXECUTE .
COMPUTE odds = EXP(logodds) .
EXECUTE .
COMPUTE prob = odds/(1+odds) .
EXECUTE .
RECODE
  prob
  (Lowest thru 0.25591=0)  (0.25592 thru Highest=1)  INTO  dem1066 .
EXECUTE .

SAVE OUTFILE='C:\data\stage2_output\algorithm_processed.sav'/ COMPRESSED.
