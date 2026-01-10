SORT CASES BY
  houseid (A) particid (A) .
IF (name > 0) nametot = 1 .
execute.
IF (nrecall > 0) nametot = 1 .
execute.
IF (name + nrecall = 0) nametot = 0 .
EXECUTE .
COUNT
  count = pencil watch chair shoes knuckle elbow should bridge hammer pray
  chemist repeat town chief street store address longmem month day year season
  nod point circle pentag  (1)  .
EXECUTE .
RECODE
  animals wordimm worddel paper story  (SYSMIS=0)  .
EXECUTE .
RECODE
  animals (99=0)  .
EXECUTE .
RECODE
  wordimm worddel paper story  (9=0)  .
EXECUTE .
RECODE
  learn1 learn2 learn3 recall  (SYSMIS=0)  .
EXECUTE .
RECODE
  learn1 learn2 learn3 recall  (99=0)  .
EXECUTE .
RECODE
  pencil watch chair shoes knuckle elbow should bridge hammer pray
  chemist repeat town chief street store address longmem month day year season
  nod point circle pentag nametot nrecall  (SYSMIS=0)  .
EXECUTE .

RECODE
  learn1 learn2 learn3 recall  (11=1)  (20 thru 21=2)  (30 thru 31=3)  (40 thru 41=4)  (50 thru 51=5) 
(60 thru 61=6)  (70 thru 71=7)  (80 thru 81=8)  (90 thru 91=9) (99=sysmis)  .
EXECUTE .

RECODE
  name pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address
  longmem month day year season nod point circle pentag  (2 thru 9=SYSMIS)  .
EXECUTE .
RECODE
  animals  (46 thru Highest=SYSMIS)  .
EXECUTE.
RECODE
 wordimm worddel paper  (4 thru Highest=SYSMIS)  .
EXECUTE .
RECODE
  story  (7 thru Highest=SYSMIS)  .
EXECUTE .

RECODE
  recall  (11 thru Highest=SYSMIS)  .
EXECUTE .
RECODE
  immed  (30 thru Highest=SYSMIS)  .
EXECUTE .
RECODE
  nrecall  (2 thru Highest=SYSMIS)  .
EXECUTE .

COMPUTE animtot = animals / 23 .
EXECUTE .
COMPUTE wordtot1 = wordimm/3 .
EXECUTE .
COMPUTE wordtot2 = worddel/3 .
EXECUTE .
COMPUTE papertot = paper/3 .
EXECUTE .
COMPUTE storytot = story/6 .
EXECUTE .
compute cogscore = 1.03125*(nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot).
execute.
COMPUTE immed = learn1+learn2+learn3 .
EXECUTE .
COMPUTE langexpr = bridge + hammer + pray + chemist .
EXECUTE .
COMPUTE langcomp = nod + point .
EXECUTE .
COMPUTE orientti = month + day + year + season .
EXECUTE .
COMPUTE orientsp = town + street + store + address .
EXECUTE .
COMPUTE objname = pencil + watch + chair + shoes + knuckle + elbow + should .
EXECUTE .
COMPUTE mem = worddel + wordimm + nrecall + story .
EXECUTE .
COMPUTE language = langexpr + langcomp .
EXECUTE .
COMPUTE orientat = orientti+orientsp+chief .
EXECUTE .

**IMPUTING MISSING 10 WORD LIST RECALL FROM IMMEDIATE RECALL

compute pred_recall = (0.344*immed)-0.339.
execute.

RECODE
  pred_recall  (Lowest thru 0=0)  (10 thru Highest=10)  .
EXECUTE .


**THIS COMMAND SAVES THE ORIGINAL RECALL VARIABLE BEFORE IMPUTATION OF THE MV

compute recall_original= recall.
execute.

RECODE
  RECALL  (MISSING=999).
EXECUTE .

IF (recall=999) recall = pred_recall .
EXECUTE .

RECODE
  recall  (11 thru Highest=SYSMIS)  .
EXECUTE .


SAVE OUTFILE='C:\data\stage1_output\csidsubj_processed.sav'/ COMPRESSED.