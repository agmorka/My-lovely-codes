proc fcmp outlib=work.myfuncs.funcs;
	deletefunc get_bdate_from_cpr;
run;

proc fcmp outlib=work.myfuncs.funcs;
	function get_bdate_from_cpr(cpr $);
	/* Calculates birthdate from CPR number. 
	Validates the input string by checking the string length and CPR checksum.
	Checks if calculated date is a valid date.
	Returns a date value (which needs a format).
	Example usage: 
	format bdate date9.;
	bdate=get_bdate_from_cpr(cpr);
	*/
		outval='';

		if length(cpr)=10 then do;

			array coef[10] (4 3 2 7 6 5 4 3 2 1);
			checksum=0;
			do i=1 to length(cpr);
				checksum=checksum+coef[i]*substr(cpr,i,1);
			end;
			
			if mod(checksum,11)=0 then do;
				dd=input(substr(cpr,1,2),best.);
				mm=input(substr(cpr,3,2),best.);
				yy=input(substr(cpr,5,2),best.);
				d7=input(substr(cpr,7,1),best.);

				if d7<=3 then yyyy=1900+yy;
				else if (d7=4 or d7=9) and yy>36 then yyyy=1900+yy;
				else if (d7=4 or d7=9) and yy<=36 then yyyy=2000+yy;
				else if (d7=5 or d7=6 or d7=7 or d7=8) and yy<=57 then yyyy=2000+yy;
				else if (d7=5 or d7=6 or d7=7 or d7=8) and yy>57 then yyyy=1800+yy;

				is_leapyear=(mod(yyyy,4)=0) and ((mod(yyyy,100) ne 0) or (mod(yyyy,400)=0 and mod(yyyy,4000) ne 0));

				if mm in (1,3,5,7,8,10,12) and 1<=dd<=31 then is_valid_date=1;
				else if mm in (4,6,9,11) and 1<=dd<=30 then is_valid_date=1;
				else if is_leapyear=0 and mm=2 and 1<=dd<=28 then is_valid_date=1;
				else if is_leapyear=1 and mm=2 and 1<=dd<=29 then is_valid_date=1;
				else is_valid_date=0;

				if is_valid_date=1 then outval=cat(yyyy,put(mm,z2.),put(dd,z2.));
			end;
		end;

		return(input(outval,yymmdd8.));
	endsub;
run;
