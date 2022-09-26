function print_spinner(INTERVAL		,icount,progress,pcount) { #Cycles through spinner 
   icount++;
   if (INTERVAL) {
        progress[1]="◐";
        progress[2]="◓";
        progress[3]="◑";
        progress[4]="◒";

        pcount++;
        if (pcount > 4)
            pcount=1;

        if (icount >= INTERVAL) {
            if (spinner_print)
                printf "\033["length(spinner_print)"D\033[K";

            spinner_print=progress[pcount];
            printf spinner_print;
        }
    } else {
        printf "\033["length(spinner_print)"D\033[K";
        spinner_print="";
        icount=0;
    }
}

function print_status (STATUSMSG) { #Erase last status message and print a new one
    if(STATUSMSG) {
        status_print=STATUSMSG;
        printf status_print;
    } else {
        CURSOR_LEFT(length(status_print));
        CLEARLINE();
    }
}

function CURSOR_CLS() {printf "\033[2J"} #Clear full screen and move cursor to 0,0
function CURSOR_ERASE() {printf  "\033[K"} #Clear current line
function CURSOR_SAVE() {printf "\033[s"} #Save cursor position
function CURSOR_RESTORE() {printf "\033[u"} #Restore cursor position back to last save
function CURSOR_SET(LINE,COLUMN) {printf "\033["LINE";"COLUMN"H"} #Set cursor to row,column position
function CURSOR_UP(NUM) {printf "\033["NUM"A"} #Move cursor up x rows
function CURSOR_DOWN(NUM) {printf "\033["NUM"B"} #Move cursor downn x rows
function CURSOR_RIGHT(NUM) {printf "\033["NUM"C"} #Move cursor right x columns
function CURSOR_LEFT(NUM) {printf "\033["NUM"D"} #Move cursor left x columns

function bytes2human(B,F		,U,N) { #Takes bytes and gives human readable
	U[0]="b "; U[1]="KB"; U[2]="MB"; U[3]="GB"; U[4]="TB"; U[5]="PB"; N=0
	while(B >= 1024 && N < length(U) ) { N++; B=B/1024; }
	return sprintf("%\047."F"f "U[N],B)
}

function sec2human (secs,sep) { #Takes seconds give days hrs mmins secs
	return sprintf("%dd"sep"%dh"sep"%dm"sep"%ds",((secs/86400)),((secs%86400/3600)),((secs%3600/60)),((secs%60)))
}

function num2human(NUM) { #Takes number, returns 1,000
	return sprintf("%\047d",NUM)
}

function dec2pct(NUM) { #Takes decimal, returns x,xxx.xx%
	return sprintf("%\047.2f%%",NUM*100)
}

function num2dec(NUM,PLACES) { #Takes number,place-count returns 1,000.x
	return sprintf("%\047."PLACES"f",NUM)
}

function mysql_query(QUERY,MYSQLOPTS		,X,MYSQL) { #Takes query returns array _MYSQL_RESULTS
	MYSQL="/usr/bin/mysql --defaults-file=/root/.my.cnf -NB "MYSQLTOPS" "
    X=MYSQL" -e \047" QUERY "\047" " 2>&1"
    split("",_MYSQL_RESULTS,"")
    while(X|getline) { _MYSQL_RESULTS[length(_MYSQL_RESULTS)+1]=$0; }
    close(X)
	return length(_MYSQL_RESULTS);
}

function mysql_load_variables(SCOPE,MYSQLOPTS) { #Returns _MYSQL_VARS as associative array
	mysql_query("SHOW "SCOPE" VARIABLES;",MYSQLOPTS)
	for (e in _MYSQL_RESULTS) {
		split(_MYSQL_RESULTS[e],VARIABLE)
		if (VARIABLE[1]) { _MYSQL_VARIABLES[VARIABLE[1]]=VARIABLE[2] }
	}
}

function mysql_load_status(SCOPE,MYSQLOPTS) { #Returns _MYSQL_STATUS as associative array
	mysql_query("SHOW "SCOPE" STATUS;",MYSQLOPTS)
	for (e in _MYSQL_RESULTS) {
		split(_MYSQL_RESULTS[e],STATUS)
		if (STATUS[1]) { _MYSQL_STATUS[STATUS[1]]=STATUS[2] }
	}
}

function cprint(color,string) { print COLOR[color] string  NoColor } #Color print cprint(color,string)
function cprintf(format,color,string) {	printf COLOR[color] format NoColor,string } #Color printf cprintf(format,color,string) 
function tprint(width,string		,void1,void2) { 
	void1=void2=sprintf("%d",(width-length(string))/2)
	if (void1+length(string)+void2 > width) { void2-- }
	printf "%-"void1"s %s %"void2"s\n",_BULLET,string,_BULLET
}

function core_alert(msg,color) { #Print dynamic alert header
    "tput cols"|getline cols
    if (!color) {color=BRed}
    if (msg) {
        if (msg=="--line") {
            msg=""
            line=1
        } else {
            msg="----[ "msg" ]"
        }
    }
    width=(cols-length(msg))
    i=length(msg)
    while (i < cols) {
   		msg=msg"-"
        i++
    }
    print color msg
}

function basename(file,    a) { return a[split(file, a, "/")] } #Get file name
function dirname(file) { return gensub("/[^/]+$", "", "g", file) } #Get dir name

//grepper awk function get real path
function realpath(file) { #Get ABS Path
	EXE="readlink -f " file
    EXE | getline x
    close(EXE)
	return x
}
//grepper

function mkdir(dir) { #Create dir
	system("mkdir -p "dir)
	close("mkdir -p "dir)
}

function isdir(path) { #Check if dir
	EXE="test -d "path" && echo 1 || echo 0"
	EXE|getline x
	return x
}

BEGIN {
	_BULLET="•"

	_WEEKDAYS[0]="Sun"; _WEEKDAYS[1]="Mon"; _WEEKDAYS[2]="Tue"; _WEEKDAYS[3]="Wed";
	_WEEKDAYS[4]="Thu"; _WEEKDAYS[5]="Fri"; _WEEKDAYS[6]="Sat";

	_WEEKDAYS["sun"]=0; _WEEKDAYS["mon"]=1; _WEEKDAYS["tue"]=2; _WEEKDAYS["wed"]=3;
	_WEEKDAYS["thu"]=4; _WEEKDAYS["fri"]=5; _WEEKDAYS["sat"]=6;

	_MONTHS[1]="Jan"; _MONTHS[2]="Feb";  _MONTHS[3]="Mar";  _MONTHS[4]="Apr";
	_MONTHS[5]="May"; _MONTHS[6]="Jun";  _MONTHS[7]="Jul";  _MONTHS[8]="Aug";
	_MONTHS[9]="Sep"; _MONTHS[10]="Oct"; _MONTHS[11]="Nov"; _MONTHS[12]="Dec"

	_MONTHS["jan"]=1; _MONTHS["feb"]=2;  _MONTHS["mar"]=3;  _MONTHS["apr"]=4; 
	_MONTHS["may"]=5; _MONTHS["jun"]=6;  _MONTHS["jul"]=7;  _MONTHS["aug"]=8; 
	_MONTHS["sep"]=9; _MONTHS["oct"]=10; _MONTHS["nov"]=11; _MONTHS["dec"]=12; 

    split("",_MYSQL_RESULTS,"")
}


