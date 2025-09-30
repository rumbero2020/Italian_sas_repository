/* Mirti Valerio 01/02/2023


cerca se esiste la directory nel path indicato
se non la trova la crea

dir=/percorso/percorso/percorso
*/

%macro CheckandCreateDir(dir);
/*OS Indipendent*/
%let slash = %sysfunc(ifc(&sysscp=WIN,\,/));

%local rc fileref ;
%let rc =%sysfunc(filename(fileref,&dir)) ;

%if %sysfunc(fexist(&fileref))%then %do;

	%put The directory "&dir" already exists ;
	%return;

%end;

%else %do; 
	/*gestione ultimo slash qualora ci fosse:
		nella countc successiva non combacerebbe il percorso
		con l'ultima directory perciò viene eliminato*/
	%if "%substr(%sysfunc(trim(&dir)),%length(%sysfunc(trim(&dir))), 
										%length(%sysfunc(trim(&dir))))"
		eq "&slash"
	%then 
	%let dir= %substr(&dir,1,%length(&dir)-1);

	data _null_;
	dir="&dir";
   	whereisslash=0;
	n=0;
	/*OS Indipendent*/
	c=ifn("&sysscp."="WIN",
		countw(dir,"&slash")-1,
		countw(dir,"&slash"));
   	do until(whereisslash=0);
      whereisslash=findc(dir, "&slash", whereisslash+1);
	  n+1;
      output;

		if n=c then do;	  
  		name=scan(dir,-1,"&slash");
  		path=substr(dir,1,whereisslash);
		rc=dcreate(name,path);	
		end;

   	end;
	run;

	
%end ;

	%if &sysrc eq 0 %then 
		%put The directory &dir has been created. ;
	%else
		%put There was a problem while creating the directory &dir;
		
%mend;

/*%CheckandCreateDir(/sas/sasdata/Mensilizzazione_CE/Collaudo/Test_Val_Poll/Old2);*/
