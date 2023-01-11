proc import datafile=
    "/home/u59966405/sasuser.v94/Visit1.xls"
    dbms=xls out=visit1 replace;
    run;

data new;
   set work.visit1;
run;

ods rtf file="/home/u59966405/sasuser.v94/SASProject.rtf";
ods noproctitle;

data trans;
   set new;
   id3=put(idpatient,format.);
   id1=put(birthdt_yy,format.);
   id2= substr(id1,11,2);
   id4= 'PT';
   if sex=0 then sex1='M';
   else sex1='F';
   ID= cat(id4,id3,id2,sex1);
   ID= compress(ID);
   drop id1 id2 id3 id4;
   where weight is not missing and height is not missing;
   BMI = weight/(height)**2;
   format BMI 6.2;
   if BMI<18.5 then BMICLASS= 1;
   else if BMI>= 18.5 and BMI<25 then BMICLASS=2;
   else if BMI>= 25 and BMI<30 then BMICLASS=3;
   else BMICLASS=4;
   BIRTHDT = mdy( birthdt_mm ,birthdt_dd, birthdt_yy);
   format BIRTHDT ddmmyy8. ;
   VISITDT = mdy(  v1dt_mm, v1dt_dd,  v1dt_yy);
   format VISITDT ddmmyy8. ; 
   if age<=30 then AGECLASS= 1;
   else if age> 30 and age<=40 then AGECLASS=2;
   else if age> 40 and age <=50 then AGECLASS=3;
   else AGECLASS=4;
run;

title "Table of transformed data";
proc print data=work.trans;
    var ID weight height sex BMI BMICLASS 
    BIRTHDT VISITDT age AGECLASS;
run;
title;

title "Main statistics of the variable BMI for AGECLASS and sex ";
proc means data= work.trans mean std median q1 q3 MAXDEC=2 ;
    var BMI;
    class AGECLASS sex;
run;
title;


proc freq data = work.trans;
    tables AGECLASS*sex;
run;


proc means data= work.trans mean max min MAXDEC=2 nonobs noprint;
    output out = work.stats(drop= _freq_ _type_) mean=Media min= Minimo max=Massimo;
    var BMI;
    class AGECLASS sex;
    WHERE AGECLASS = 1 or AGECLASS = 2; 
run;


proc sort data=work.stats;
   by AGECLASS sex;
run;

proc transpose data=work.stats name=Stat out=work.stats2(rename=(col1=BMI));
	by AGECLASS sex;
	var Media Minimo Massimo;
	where AGECLASS is not missing and sex is not missing;
run;

proc format;
    value genfmt  1 = 'Female'
                   0 = 'Male';
run;

proc format;
    value acc      1 = 'AGE<=30'
                   2 = 'AGE 31-40';
run;


proc means data= work.stats2 mean MAXDEC=2 nonobs;
    var BMI;
    class AGECLASS sex Stat; 
    format sex genfmt. AGECLASS acc.;
    label Stat = 'STATS';
run;

proc means data=work.trans mean;
    var BMI;
    where sex=0;
run;


title "Population at risk of cardiovascular disease";
proc print data=work.trans ;
     var ID weight height BMI BMICLASS BIRTHDT VISITDT age AGECLASS;
     where age>=60 and sex=0 and BMI>=25.60;
run;
title;

proc freq data=work.trans order=formatted;
   tables BMICLASS*AGECLASS / expected cellchi2 norow nocol chisq;
   output out=ChiSqData n lrchi pchi;
   title 'Chi-Square Tests for 4 by 4 table of Age class and BMI class';
run;

ods proctitle;
ods rtf close;















    
    