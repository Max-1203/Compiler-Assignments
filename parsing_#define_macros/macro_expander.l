%option noyywrap
%{
#include <bits/stdc++.h>
using namespace std;
void yyerror(char *);

unordered_map<string, string> macro_def;
string temp;
unordered_map<string, string> macro_params;

FILE* output_file;
%}

%x DEF_NAME DEF_BODY DEF_BODY_START DEF_NAME_PARAN PROCESS_PARAM

id [A-Z][A-Z0-9_]*
tp \([^()]*\)|[a-z]
paran \({space}*{tp}[^()a-z ]*{space}*{tp}\)|\({space}*{tp}{space}*\)
space [\t ]

%%      

^{space}*"#define"{space}+      {fprintf(output_file, yytext); BEGIN DEF_NAME;}

<DEF_NAME>{id}/{space}+         {fprintf(output_file, yytext); temp = yytext; BEGIN DEF_BODY;}

<DEF_NAME>{id}/{paran}          {fprintf(output_file, yytext); temp = yytext; BEGIN DEF_NAME_PARAN;}

<DEF_NAME_PARAN>{paran}         {fprintf(output_file, yytext); macro_params[temp] = yytext; BEGIN DEF_BODY_START;}

<DEF_BODY_START>{space}+        {fprintf(output_file, yytext); BEGIN DEF_BODY;}

<DEF_BODY>[^\n]*                {   fprintf(output_file, yytext);  
                                    while(yytext[0] == ' ')
                                    {
                                        yytext++;
                                    }
                                    macro_def[temp] = yytext;
                                }

<DEF_BODY>[\n]                  {fprintf(output_file, yytext); BEGIN 0;}

{id}/[^"("]                     {   
                                    if(macro_def.find(yytext) == macro_def.end())
                                    {
                                        fprintf(output_file, yytext);      
                                    }
                                    else
                                    {
                                        string ans = macro_def[yytext];
                                        for(int i = ans.length()-1; i >= 0; i--)
                                        {
                                            unput(ans[i]);
                                        }
                                    }
                                }

{id}/{paran}                    {   
                                    if(macro_def.find(yytext) == macro_def.end())
                                    {
                                        fprintf(output_file, yytext);
                                    }
                                    else
                                    {
                                        temp = yytext;
                                        BEGIN PROCESS_PARAM;
                                    }
                                }

<PROCESS_PARAM>{paran}          {   
                                    string prams_compare = macro_params[temp];
                                    unordered_map<char, string> mp;

                                    vector<char> parameters;
                                    vector<string> replacements;
                                    string t;
                                    for(int i = 1; i < prams_compare.length()-1; i++)
                                    {
                                        if(prams_compare[i] != ' ' && prams_compare[i] != ',')
                                        {
                                            parameters.push_back(prams_compare[i]);
                                        }
                                    }
                                    for(int i = 1; i < strlen(yytext)-1; i++)
                                    {
                                        if(yytext[i] != ' ' && yytext[i] != ',')
                                        {
                                            t += yytext[i];
                                        }
                                        else
                                        {
                                            if(!t.empty())
                                            {
                                                replacements.push_back(t);
                                                t.clear();
                                            }
                                        }
                                    }
                                    if(!t.empty())
                                    {
                                        replacements.push_back(t);
                                        t.clear();
                                    }
                                    for(int i = 0; i < parameters.size(); i++)
                                    {
                                        mp[parameters[i]] = replacements[i];
                                    }
                                    string def = macro_def[temp]; 
                                    string ans;
                                    for(int i = 0; i < def.length(); i++)
                                    {
                                        if(mp.find(def[i]) != mp.end())
                                        {
                                            ans += mp[def[i]];
                                        }
                                        else
                                        {
                                            ans += def[i];
                                        }
                                    }
                                    for(int i = ans.length()-1; i >= 0; i--)
                                    {
                                        unput(ans[i]);
                                    }
                                    BEGIN 0;
                                }

"%"                             {fprintf(output_file, "%s", yytext);}

.|\n                            {fprintf(output_file, yytext);}


%%

int main(int argc, char *argv[])
{
    if(argc < 2)
    {
        printf("Usage: %s <input_file>\n", argv[0]);
        return 1;
    }

    FILE* input_file = fopen(argv[1], "r");
    if (!input_file) 
    {
        perror("Error opening file");
        return 1;
    }
    output_file = fopen("output.c", "w");
    if (!output_file) 
    {
        perror("Error opening file");
        return 1;
    }

    yyin = input_file;
    yylex();
    

    fclose(input_file);
    fclose(output_file);
    
    return 0;
}
