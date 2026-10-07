/* Modifications made to accept includes much in the same way bind does.
   Any real lex/bison hacker is welcome to fix the obviously cheesy bits.
   in particular, it seems hacky to make the include token be the keyword
   'include' plus the rest of the file path making it necessary to parse 
   out the identifier.  I did this becase the regex for 'string' is
   relatively greedy and comes up with a longer match string than the 
   include token.  What i really need is some sort of 'break' syntax for 
   lex that would read the first definition matching an include line and 
   STOP processing any other tokens.  By default it returns the 
   matching expression with the largest number of matched characters.
*/
%{
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>
#include	"getltscfg.h"
#include	"parser.tab.h"

void trim(char *);
int validateinclude(char *);
static char *open_quote_value(const char *);
%}

	/*
	 * Every character must be matched by a rule below. A character none of
	 * them matches falls through to flex's default rule, which copies it to
	 * stdout - into the middle of the output a shell is about to evaluate,
	 * which is how a single quote ended in a kernel panic. With nodefault,
	 * flex warns at build time that "default rule can be matched" if any
	 * character is left uncovered, and a scanner built anyway stops with an
	 * error on such a character instead of copying it. This one builds
	 * without that warning.
	 */
%option nodefault

lb		\[
rb		\]

inc		^[ \t]*include[ \t]+((\"[^\n]*\")|([^=\n\[\]"'#]*))[ \t]*
qstring		\"[^\n]*\"
sqstring	\'[^\n]*\'
oqstring	\"[^\n"]*
osqstring	\'[^\n']*
string		[^=\n\r\[\]"'#]*

equal		\=

whitespace	[ \t\r]+
comment		#[^\n]*


%%

{equal}		{	return(EQUAL);		}
{lb}		{	return(LB);		}
{rb}		{	return(RB);		}
{inc}		{	
			if(validateinclude(yytext)) {
				// the file is valid and readable
				return(INC);
			}
			else {
				// simply returning a string type makes the whole syntax invalid.
				// a real lex hacker is welcome to make this (and any of the other cheesy bits) better
				return(STRING);
			}
		}

{whitespace}	{	/* do nothing */ }


{string}	{
			yylval.string = (char *)malloc(strlen(yytext)+1);
			strcpy(yylval.string,yytext);
			trim(yylval.string);
			return(STRING);
		}

{qstring}	{
                        int len = strlen(yytext);

			//
			// result is 2 bytes smaller than qstring, but don't
			// forget room for the trailing NULL.
			//
			yylval.string = (char *)malloc( len - 1 );

			//
			// Copy string, Skipping leading and trailing quote
			//
                        memcpy(yylval.string,yytext+1,len-2);
                        yylval.string[len-2] = '\0';	// Terminate that string
			return(STRING);
		}

	/*
	 * Single quotes, which a shell user writes without thinking. They were
	 * not part of any rule, so flex did with the quote what it does with
	 * every character no rule matches: it copied it to stdout. That stray
	 * quote then sat at the front of getltscfg -a's output, and the eval in
	 * ltsp_config.d/01-getltscfg died of it - during boot, as PID 1.
	 */
{sqstring}	{
			int len = strlen(yytext);

			yylval.string = (char *)malloc( len - 1 );
			memcpy(yylval.string,yytext+1,len-2);
			yylval.string[len-2] = '\0';
			return(STRING);
		}

	/*
	 * A quote that is never closed. Same stray quote on stdout as above, and
	 * the same kernel panic - from one forgotten character. The value is
	 * taken to the end of the line, which is what was meant every time, and
	 * the line is named on stderr so it gets fixed.
	 */
{oqstring}	|
{osqstring}	{
			yylval.string = open_quote_value(yytext);
			return(STRING);
		}

	/* The newline after a comment is counted by the rule below; a comment
	 * on the last line needs none, and is no error without one. */
{comment}	{	/* do nothing */	}
\n		{	lineno++;		}

%%

static char *open_quote_value(const char *text)
{
	char *value = strdup(text + 1);

	trim(value);
	(void)fprintf(stderr,
		"\nmissing closing quote in %s, line=%d; "
		"the value runs to the end of the line\n\n",
		curConfigFile, lineno);
	return value;
}

void trim(char *str)
{
    char *p;

    // Trim leading spaces

    while( isspace(*str) ){
        p = str;
        while(*p){
            *p = *(p+1);
            p++;
        }
    }

    // Look for hash '#' characters to denote comments
    // If we find one, and it is NOT inside of a quoted string
    // then replace it with a NULL to terminate the string.

    p = str;
    while(*p)
            p++;

    // Coming out of the loop, p points to the terminating NULL

    // Trim trailing spaces

    p--;                    // Get off of the trailing NULL

    while( p >= str && isspace(*p) ){
        *p = '\0';          // Replace the space with a NULL
        p--;
    }
}
// this function takes a line that appears to be for an include
// and parses the string to retrieve only the full path to the file and
// attempts to open the file.  if a failure occurs, zero is returned.
int validateinclude(char *fPath) 
{
	int len;
	char *tmp;
	FILE *incFile;
	
	tmp = (char *)malloc(strlen(fPath)+1);
	strcpy(tmp,fPath);
	trim(tmp);		

	sscanf(tmp,"include %n",&len);
	if(len > 0) {
		// fix fPath by removing the leading include tag
    		while(*tmp && len > 0) {
            		tmp++;
			len--;
		}
		trim(tmp);
		// if there are quotes, remove them
		len = strlen(tmp);
		if(len > 0) {
			if(tmp[0] == '"' && tmp[len - 1] == '"') {
				tmp[len-1] = '\0';
				tmp++;
				trim(tmp);
			}
			// try and validate this is indeed a file
			incFile = fopen (tmp,"r");
			if(incFile == NULL) {
				fclose(incFile);
				return 0;
			}
			else {
				fclose(incFile);
				// setup the filename in the yyval string
				yylval.string = (char *)malloc(strlen(tmp)+1);
				strcpy(yylval.string,tmp);
				return 1;
			}
		}
	}
	return 0;
}
