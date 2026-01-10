* Encoding: UTF-8.
GET 
  STATA FILE='/Users/chrissoria/Documents/Research/CADAS_1066/1066_Baseline data.dta'.  
DATASET NAME DataSet2 WINDOW=FRONT.

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

* Encoding: UTF-8.
SORT CASES BY
  houseid (A) particid (A) .

* CSI-D RELSCORE

RECODE
  MENTAL ACTIV MEMORY PUT KEPT FRDNAME FAMNAME CONVERS WORDFIND WORDWRG PAST LASTSEE 
LASTDAY ORIENT LOSTOUT LOSTIN CHORES HOBBY MONEY CHANGE REASON FEED DRESS toilet   (MISSING=9)  .
EXECUTE .

COUNT
  Miss1 = MENTAL activ MEMORY PUT KEPT FRDNAME FAMNAME CONVERS WORDFIND WORDWRG PAST LASTSEE 
LASTDAY ORIENT LOSTOUT LOSTIN CHORES HOBBY MONEY CHANGE REASON (9) .
EXECUTE .
COUNT
  Miss3 = FEED DRESS toilet (9) .
EXECUTE .
COMPUTE misstot = (miss3*3) + miss1 .
EXECUTE .
RECODE
 PUT KEPT FRDNAME FAMNAME CONVERS WORDFIND WORDWRG PAST LASTSEE LASTDAY ORIENT 
LOSTOUT LOSTIN CHORES CHANGE money  (1=0.5) (2=1)  .
EXECUTE .
compute dress_original=dress.
execute.
DO IF (dressdis = 1) .
RECODE
  dress  (ELSE=0)  .
END IF .
EXECUTE .
compute chores_original=chores.
execute.
DO IF (choredis = 1) .
RECODE
  chores  (ELSE=0)  .
END IF .
EXECUTE .
compute feed_original=feed.
execute.
DO IF (feeddis = 1) .
RECODE
  Feed (ELSE=0)  .
END IF .
EXECUTE .
compute toilet_original=toilet.
execute.
DO IF (toildis = 1) .
RECODE
  toilet (ELSE=0)  .
END IF .
EXECUTE .

SET MXWARNS 100.

*this is how it was in the SPSS script
COMPUTE relscore_duplicate = (30/(30-misstot))*(( activ + MENTAL + MEMORY + PUT + KEPT + FRDNAME + FAMNAME 
+ CONVERS + WORDFIND + WORDWRG + PAST + LASTSEE + LASTDAY + ORIENT + LOSTOUT 
+ LOSTIN + CHORES + HOBBY + MONEY + CHANGE + REASON + FEED + DRESS + toilet)-((miss1+miss3)*9)) .

IF (30 - misstot = 0) relscore_duplicate = SYSMIS().
IF (30 - misstot > 0) relscore_duplicate = (30 / (30 - misstot)) * 
    ((activ + MENTAL + MEMORY + PUT + KEPT + FRDNAME + FAMNAME + CONVERS + 
    WORDFIND + WORDWRG + PAST + LASTSEE + LASTDAY + ORIENT + LOSTOUT + LOSTIN + 
    CHORES + HOBBY + MONEY + CHANGE + REASON + FEED + DRESS + toilet) - 
    ((miss1 + miss3) * 9)).
EXECUTE.

RECODE
 PUT KEPT FRDNAME FAMNAME CONVERS WORDFIND WORDWRG PAST LASTSEE LASTDAY ORIENT 
LOSTOUT LOSTIN CHORES CHANGE money  (1=2)  (0.5=1) .
EXECUTE .

RECODE
  ACTIV MENTAL MEMORY PUT KEPT FRDNAME FAMNAME CONVERS WORDFIND WORDWRG PAST
  LASTSEE LASTDAY ORIENT LOSTOUT LOSTIN CHORES CHOREDIS HOBBY MONEY CHANGE
  REASON FEED FEEDDIS DRESS DRESSDIS TOILET TOILDIS MISTAKE DECIDE MUDDLED
  (9=SYSMIS)  .
EXECUTE .

** THIS CORRECTS A GLITCH WHEREBY IF THE WHOLE CSI'D' INFORMANT INTERVIEW WAS MISSING A RELSCORE OF 0 WAS RETURNED

DO IF (misstot >= 29) .
RECODE
  relscore  (ELSE=SYSMIS)  .
END IF .
EXECUTE .




* SRQ-20 SCORE AND CASENESS (COMMON MENTAL DISORDER)

COUNT
  srqtot = srq1 srq2 srq3 srq4 srq5 srq6 srq7 srq8 srq9 srq10 srq11 srq12
  srq13 srq14 srq15 srq16 srq17 srq18 srq19 srq20  (1)  .
VARIABLE LABELS srqtot 'total srq score' .
EXECUTE .
RECODE
  srqtot
  (0 thru 7=0)  (8 thru Highest=1)  INTO  srqcase .
EXECUTE .

RECODE
  SRQ1 SRQ2 SRQ3 SRQ4 SRQ5 SRQ6 SRQ7 SRQ8 SRQ9 SRQ10 SRQ11 SRQ12
  SRQ13 SRQ14 SRQ15 SRQ16 SRQ17 SRQ18 SRQ19 SRQ20  (9=SYSMIS) .
EXECUTE.

COUNT
  srqmiss = SRQ1 SRQ2 SRQ3 SRQ4 SRQ5 SRQ6 SRQ7 SRQ8 SRQ9 SRQ10 SRQ11 SRQ12
  SRQ13 SRQ14 SRQ15 SRQ16 SRQ17 SRQ18 SRQ19 SRQ20  (9)  SRQ1 SRQ2 SRQ3 SRQ4
  SRQ5 SRQ6 SRQ7 SRQ8 SRQ9 SRQ10 SRQ11 SRQ12 SRQ13 SRQ14 SRQ15 SRQ16 SRQ17
  SRQ18 SRQ19 SRQ20  (MISSING)  .
VARIABLE LABELS srqmiss 'srq missing values' .
EXECUTE .

DO IF (srqmiss >= 11) .
RECODE
  srqtot  (ELSE=SYSMIS)  .
END IF .
EXECUTE .

DO IF (srqmiss >= 11) .
RECODE
  srqcase (ELSE=SYSMIS)  .
END IF .
EXECUTE .


* ZARIT CAREGIVER BURDEN

COUNT
zbmiss  =  zb1 zb2 zb3 zb4 zb5 zb6 zb7 zb8 zb9 zb10 zb11 zb12 zb13 zb14 zb15 zb16 zb17 zb18 zb19 zb20 zb21 zb22 (9) .
execute.
COMPUTE zbtot  = (22/(22-zbmiss))*((zb1 + zb2 + zb3 + zb4 + zb5 + zb6 + zb7 + zb8 + zb9 + zb10 + zb11 + zb12 + zb13 + 
zb14 + zb15 + zb16 + zb17 + zb18 + zb19 + zb20 + zb21 + zb22)-(zbmiss*9)) .
EXECUTE .
recode
zb1 zb2 zb3 zb4 zb5 zb6 zb7 zb8 zb9 zb10 zb11 zb12 zb13 zb14 zb15 zb16 zb17 zb18 zb19 zb20 zb21 zb22 (9=SYSMIS)  .

* CAREGIVER INCOME

RECODE
  cBEN1 cBEN2 cBEN3 cBEN4  (MISSING=0)  (999999=0)  .
EXECUTE .

compute c_family1=0.
execute.
compute c_family2=0.
execute.
compute c_family3=0.
execute.
compute c_family4=0.
execute.
compute c_gov1=0.
execute.
compute c_gov2=0.
execute.
compute c_gov3=0.
execute.
compute c_gov4=0.
execute.
compute c_occup1=0.
execute.
compute c_occup2=0.
execute.
compute c_occup3=0.
execute.
compute c_occup4=0.
execute.
compute c_disab1=0.
execute.
compute c_disab2=0.
execute.
compute c_disab3=0.
execute.
compute c_disab4=0.
execute.
compute c_rent1=0.
execute.
compute c_rent2=0.
execute.
compute c_rent3=0.
execute.
compute c_rent4=0.
execute.
compute c_work1=0.
execute.
compute c_work2=0.
execute.
compute c_work3=0.
execute.
compute c_work4=0.
execute.
compute c_care1=0.
execute.
compute c_care2=0.
execute.
compute c_care3=0.
execute.
compute c_care4=0.
execute.
compute c_oth1=0.
execute.
compute c_oth2=0.
execute.
compute c_oth3=0.
execute.
compute c_oth4=0.
execute.


IF (cbntype1 = 4) c_family1 = cben1 .
EXECUTE .
IF (cbntype2 = 4) c_family2 = cben2 .
EXECUTE .
IF (cbntype3 = 4) c_family3 = cben3 .
EXECUTE .
IF (cbntype4 = 4) c_family4 = cben4 .
EXECUTE .
IF (cbntype1 = 1) c_gov1 = cben1 .
EXECUTE .
IF (cbntype2 = 1) c_gov2 = cben2 .
EXECUTE .
IF (cbntype3 = 1) c_gov3 = cben3 .
EXECUTE .
IF (cbntype4 = 1) c_gov4 = cben4 .
EXECUTE .
IF (cbntype1 = 2) c_occup1 = cben1 .
EXECUTE .
IF (cbntype2 = 2) c_occup2 = cben2 .
EXECUTE .
IF (cbntype3 = 2) c_occup3 = cben3 .
EXECUTE .
IF (cbntype4 = 2) c_occup4 = cben4 .
EXECUTE .
IF (cbntype1 = 3) c_disab1 = cben1 .
EXECUTE .
IF (cbntype2 = 3) c_disab2 = cben2 .
EXECUTE .
IF (cbntype3 = 3) c_disab3 = cben3 .
EXECUTE .
IF (cbntype4 = 3) c_disab4 = cben4 .
EXECUTE .
IF (cbntype1 = 5) c_rent1 = cben1 .
EXECUTE .
IF (cbntype2 = 5) c_rent2 = cben2 .
EXECUTE .
IF (cbntype3 = 5) c_rent3 = cben3 .
EXECUTE .
IF (cbntype4 = 5) c_rent4 = cben4 .
EXECUTE .
IF (cbntype1 = 6) c_work1 = cben1 .
EXECUTE .
IF (cbntype2 = 6) c_work2 = cben2 .
EXECUTE .
IF (cbntype3 = 6) c_work3 = cben3 .
EXECUTE .
IF (cbntype4 = 6) c_work4 = cben4 .
EXECUTE .
IF (cbntype1 = 7) c_care1 = cben1 .
EXECUTE .
IF (cbntype2 = 7) c_care2 = cben2 .
EXECUTE .
IF (cbntype3 = 7) c_care3 = cben3 .
EXECUTE .
IF (cbntype4 = 7) c_care4 = cben4 .
EXECUTE .
IF (cbntype1 = 8) c_oth1 = cben1 .
EXECUTE .
IF (cbntype2 = 8) c_oth2 = cben2 .
EXECUTE .
IF (cbntype3 = 8) c_oth3 = cben3 .
EXECUTE .
IF (cbntype4 = 8) c_oth4 = cben4 .
EXECUTE .


RECODE
  CBNTYPE1 CBNTYPE2 CBNTYPE3 CBNTYPE4  (0=SYSMIS)  .
EXECUTE .

RECODE
  CBEN1 CBEN2 CBEN3 CBEN4  (0=SYSMIS)  .
EXECUTE .



compute c_family= c_family1 + c_family2 + c_family3 + c_family4.
execute.
compute c_gov= c_gov1 + c_gov2 + c_gov3 + c_gov4.
execute.
compute c_occup= c_occup1 + c_occup2 + c_occup3 + c_occup4.
execute.
compute c_disab= c_disab1 + c_disab2 + c_disab3 + c_disab4.
execute.
compute c_rent= c_rent1 + c_rent2 + c_rent3 + c_rent4.
execute.
compute c_work= c_work1 + c_work2 + c_work3 + c_work4.
execute.
compute c_care= c_care1 + c_care2 + c_care3 + c_care4.
execute.
compute c_oth= c_oth1 + c_oth2 + c_oth3 + c_oth4.
execute.

RECODE
  c_family c_gov c_occup
  c_disab c_rent c_work c_care c_oth  (SYSMIS=0)  .
EXECUTE .
COMPUTE cnof_tot = c_gov + c_occup + c_disab + c_rent + c_work + c_care +
  c_oth .
EXECUTE .
COMPUTE c_tot = cnof_tot + c_family .
EXECUTE .


COUNT
  twdepmiss = AM1 PM1 EVE1 NITE1 AM2 PM2 EVE2 NITE2  (MISSING)  AM1 PM1 EVE1
  NITE1 AM2 PM2 EVE2 NITE2  (9)  .
EXECUTE .
COMPUTE tw_dep = 1.5*(am1 + pm1 + eve1 + nite1 + am2 + pm2 + eve2 + nite2) .
EXECUTE .
RECODE
  cashrs2 cashrs3 cashrs4 cashrs5
  cashrs7 cashrs8 (SYSMIS=0)  (9=0)   .
EXECUTE .
RECODE
  cashrs1 cashrs6 (SYSMIS=0)  (99=0)   .
EXECUTE .
compute tadl = cashrs2 +  cashrs3 +  cashrs4 +  cashrs5 +  cashrs7 +  cashrs8.
execute.

RECODE
  caremar  (0=SYSMIS)  .
EXECUTE .
RECODE
  caremar  (5 thru highest=SYSMIS)  .
EXECUTE .

RECODE
  carerage  (Lowest thru 10=SYSMIS)  .
EXECUTE .
RECODE
  carerage  (99=SYSMIS)  .
EXECUTE .

RECODE
  carerrel  (9=SYSMIS)  .
EXECUTE .

RECODE
  carerrel  (9=SYSMIS)  .
EXECUTE .

RECODE
  CAREEDUC  (6=SYSMIS)  (9=SYSMIS)  .
EXECUTE .

RECODE
  cjob  (9=SYSMIS)  .
EXECUTE .

RECODE
  cjobcat  (0=SYSMIS) (10 thru highest=sysmis)  .
EXECUTE .

RECODE
  CAREHELP  NTPAID ( 9=SYSMIS)  .
EXECUTE .

RECODE
  CARELIVE  (2 thru 9=SYSMIS)  .
EXECUTE .

RECODE
  CUTBACK  (9=SYSMIS)  .
EXECUTE .

RECODE
  CUTBACK  (3=0)  .
EXECUTE .

RECODE
CUTWHEN (999=SYSMIS) .
EXECUTE.

recode
am1 am2 pm1 pm2 eve1 eve2 nite1 nite2 (9=sysmis) .
execute. 

RECODE
  CAREHELP HELPHOUR  (99=SYSMIS) .
EXECUTE .

RECODE
  CAREHELP  (9=SYSMIS) .
EXECUTE .

RECODE
  HELPWEEK  (13 thru Highest=SYSMIS)  .
EXECUTE .

RECODE
  HELPJOB DAYPAID NTPAID  (0=SYSMIS) (9=sysmis)  .
EXECUTE .

RECODE
  CASHRS2 CASHRS3 CASHRS4 CASHRS5 CASHRS7 CASHRS8   (4 thru Highest=SYSMIS)  .
EXECUTE .

RECODE
  cutwhen  (999=SYSMIS)  .
EXECUTE .


** THIS CORRECTS A GLITCH WHEREBY PARTICIPANTS WERE CODED AS NEEDING NO CARE, BUT CARE SECTION WAS NOT SKIPPED AND CARE NEEDS WERE EVIDENT

COUNT
  zbcare = ZB1 ZB2 ZB3 ZB4 ZB5 ZB6 ZB7 ZB8 ZB9 ZB10 ZB11 ZB12 ZB13 ZB14 ZB15
  ZB16 ZB17 ZB18 ZB19 ZB20 ZB21 ZB22  (1 thru Highest)  .
EXECUTE .
COUNT
  othcare = CASHRS1 CASHRS2 CASHRS3 CASHRS4 CASHRS5 CASHRS6 CASHRS7 CUTBACK
  CAREHELP  (1 thru Highest)  .
EXECUTE .
compute carerev = zbcare + othcare.
execute.
recode
carerev (1 thru highest=1).
execute.
DO IF (carerev = 1) .
RECODE
  CARENEED  (3=2)  .
END IF .
EXECUTE .

** THIS THEN RECODES CARE SECTION VARIABLES TO SYSMIS WHEN NO NEEDS FOR CARE WERE IDENTIFIED

DO IF (careneed= 3) .
RECODE
  CAREWHO1 CAREWHO2 CUTBACK CUTWHEN CUTHOUR CAREHELP HELPHOUR HELPWEEK
  HELPJOB DAYPAID NTPAID CASHRS1 CASHRS2 CASHRS3 CASHRS4 CASHRS5 CASHRS6
  CASHRS7 CASHRS8 ZB1 ZB2 ZB3 ZB4 ZB5 ZB6 ZB7 ZB8 ZB9 ZB10 ZB11 ZB12 ZB13 ZB14
  ZB15 ZB16 ZB17 ZB18 ZB19 ZB20 ZB21 ZB22  (ELSE=SYSMIS)  .
END IF .
EXECUTE .

* NPI-Q DISTRESS AND SEVERITY SCORES

DO IF (npi1 = 0) .
RECODE
  npi1sev npi1d  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi2 = 0) .
RECODE
  npi2sev npi2dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi3 = 0) .
RECODE
  npi3sev npi3dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi4 = 0) .
RECODE
  npi4sev npi4dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi5 = 0) .
RECODE
  npi5sev npi5dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi6 = 0) .
RECODE
  npi6sev npi6dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi7 = 0) .
RECODE
  npi7sev npi7dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi8 = 0) .
RECODE
  npi8sev npi8dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi9 = 0) .
RECODE
  npi9sev npi9dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi10 = 0) .
RECODE
  npi10sev npi10dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi11 = 0) .
RECODE
  npi11sev npi11dis  (SYSMIS=0)  .
END IF .
EXECUTE .
DO IF (npi12 = 0) .
RECODE
  npi12sev npi12dis  (SYSMIS=0)  .
END IF .
EXECUTE .

RECODE
  NPI1 NPI1SEV NPI1D NPI2 NPI2SEV NPI2DIS NPI3 NPI3SEV NPI3DIS NPI4 NPI4SEV
  NPI4DIS NPI5 NPI5SEV NPI5DIS NPI6 NPI6SEV NPI6DIS NPI7 NPI7SEV NPI7DIS NPI8
  NPI8SEV NPI8DIS NPI9 NPI9SEV NPI9DIS NPI10 NPI10SEV NPI10DIS NPI11 NPI11SEV
  NPI11DIS NPI12 NPI12SEV NPI12DIS  (9=SYSMIS)  .
EXECUTE .

DO IF (npi1sev >= 1) .
RECODE
  NPI1  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi2sev >= 1) .
RECODE
  NPI2  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi3sev >= 1) .
RECODE
  NPI3  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi4sev >= 1) .
RECODE
  NPI4  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi5sev >= 1) .
RECODE
  NPI5  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi6sev >= 1) .
RECODE
  NPI6  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi7sev >= 1) .
RECODE
  NPI7  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi8sev >= 1) .
RECODE
  NPI8  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi9sev >= 1) .
RECODE
  NPI9  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi10sev >= 1) .
RECODE
  NPI10  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi11sev >= 1) .
RECODE
  NPI11  (2 thru Highest=1)  .
END IF .
EXECUTE .
DO IF (npi12sev >= 1) .
RECODE
  NPI12  (2 thru Highest=1)  .
END IF .
EXECUTE .

RECODE
  NPI1 NPI2 NPI3 NPI4 NPI5 NPI6 NPI7 NPI8 NPI9 NPI10 NPI11 NPI12  (2 thru
  Highest=SYSMIS)  .
EXECUTE .

compute npisev= npi1sev+npi2sev+npi3sev+npi4sev+npi5sev+npi6sev+
npi7sev+npi8sev+npi9sev+npi10sev+npi11sev+npi12sev.
execute.

compute npidis= npi1d+ npi2dis+ npi3dis + npi4dis+ npi5dis + npi6dis
+ npi7dis + npi8dis + npi8dis + npi9dis + npi10dis + npi11dis + npi12dis.
execute.

RECODE
  TIMEONS  (999=SYSMIS)  .
EXECUTE .

RECODE
  TYPEONS  (0=SYSMIS)  .
EXECUTE .

RECODE
  TYPEONS ONS1 ONS2 ONS3 ONS4 ONS5 ONS6 ONS7 ONS8 ONS9 ONS10 ONS11 ONS12
  ONS13 ONS14 ONS15 ONS16 ONS17 ONS18 ONS19 ONS20 ONS21 ONS221 FLUCT FLUCTCOG
  FLUCTOFT GRADDEC STEPWISE STEPPRE1 STEPPRE3 STEPPRE2 STEPPRE4 STEPREC1
  STEPREC3 STEPREC2 STEPREC4 CLOUDING CONFNITE CONFDAY NOCTURN BCHANGE BSUSPIC
  BIRRIT BACCUSE BUPSET BFIRST BVIS BAUD BDELUDE DEPRESS DEPDUR CRY CRYDUR
  WISHDIE INTEREST ANHED SLEEP EAT BEREAVE BERWHEN DEPIMP TOLDBP TREATBP
  CVEVENT CVTYPE1 CVTYPE2 CVTYPE3 CVTYPE4 AFFINCON ANGINA INTCLAUD MIDIAG PARK
  TREMOR INITIATE SLOW MICROG HEAVYALC ALCTREAT ALCPROB HYPOTHY HYPERTHY HI
  HILL LOC BEHCHANG FITSEVER LONGFITS EARLYCHG NPI1 NPI1SEV NPI1D NPI2 NPI2SEV
  NPI2DIS NPI3 NPI3SEV NPI3DIS NPI4 NPI4SEV NPI4DIS NPI5 NPI5SEV NPI5DIS NPI6
  NPI6SEV NPI6DIS NPI7 NPI7SEV NPI7DIS NPI8 NPI8SEV NPI8DIS NPI9 NPI9SEV
  NPI9DIS NPI10 NPI10SEV NPI10DIS NPI11 NPI11SEV NPI11DIS NPI12 NPI12SEV
  NPI12DIS HASCONF  (9=SYSMIS)  .
EXECUTE .

RECODE
  ONS221 DEPDUR CVTYPE1 CVTYPE2 CVTYPE3 CVTYPE4 LOC berwhen  (0=SYSMIS)  .
EXECUTE .

RECODE
  FLUCTOFT  (5 thru Highest=SYSMIS)  .
EXECUTE .

RECODE
  CVTYPE1 CVTYPE2 CVTYPE3 CVTYPE4 LOC  (3 thru Highest=SYSMIS)  .
EXECUTE .
RECODE
  AFFINCON EARLYCHG  (2 thru Highest=SYSMIS)  .
EXECUTE .
RECODE
  STEP1 STEP3 STEP2 STEP4 FALLSNO  (99=SYSMIS)  .
EXECUTE .
RECODE
  CVDATE1 CVDATE2 CVDATE3 CVDATE4 ALCPAST ALCNOW  (999=SYSMIS)  .
EXECUTE .

MEANS TABLES=relscore_duplicate relscore_original
  /CELLS MEAN COUNT STDDEV.


COMPUTE pred_relscore= 0.004 + (0.072*whodas12) + (0.338*npisev).
execute.

RECODE
  pred_relscore  (Lowest thru 0=0)  (30 thru Highest=10)  .
EXECUTE .

*this is how it was before
    RECODE
  relscore  (MISSING=999)
  IF (relscore=999) relscore = pred_relscore 
  RECODE
  relscore  (999=MISSING)
  EXECUTE .

IF (MISSING(relscore_duplicate)) relscore_duplicate = pred_relscore.
EXECUTE.

MEANS TABLES=relscore_duplicate relscore
  /CELLS MEAN COUNT STDDEV.

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

DATASET COPY newDataset.
DATASET ACTIVATE newDataset.
ADD FILES /FILE=* /KEEP=relscore_original relscore_duplicate relscore MENTAL ACTIV MEMORY PUT KEPT FRDNAME FAMNAME CONVERS WORDFIND WORDWRG PAST LASTSEE 
LASTDAY ORIENT LOSTOUT LOSTIN CHORES HOBBY MONEY CHANGE REASON FEED DRESS toilet.
EXECUTE.
DATASET ACTIVATE newDataset.

MEANS TABLES=relscore_duplicate relscore
  /CELLS MEAN COUNT STDDEV.

MEANS TABLES=relscore_duplicate relscore_original
  /CELLS MEAN COUNT STDDEV.

SAVE OUTFILE='/Users/chrissoria/Documents/Research/CADAS_1066/data/1066_Baseline data.sav'/ COMPRESSED.
