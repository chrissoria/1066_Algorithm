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
COMPUTE relscore = (30/(30-misstot))*(( activ + MENTAL + MEMORY + PUT + KEPT + FRDNAME + FAMNAME 
+ CONVERS + WORDFIND + WORDWRG + PAST + LASTSEE + LASTDAY + ORIENT + LOSTOUT 
+ LOSTIN + CHORES + HOBBY + MONEY + CHANGE + REASON + FEED + DRESS + toilet)-((miss1+miss3)*9)) .
EXECUTE .

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
APPLY DICTIONARY
  FROM='c:\data\dict\dict_informant.sav'.
SAVE OUTFILE='C:\data\stage1_output\informant_processed (open this).sav'.
execute.



