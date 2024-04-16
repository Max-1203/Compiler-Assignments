%option noyywrap
%{
    #include <bits/stdc++.h>
    using namespace std;
    void yyerror(char *);

    vector<string> terminals;
    vector<string> non_terminals;

    unordered_map <string,vector<string>> productions, first_list, follow_list;

    int flag = 0;
    string startSymbol;
    string temp;
    string temp_prod;
%}

%x DEF_TERMINALS DEF_NON_TERMINALS DEF_PROD_LHS DEF_PROD_RHS

t_nt [A-Za-z()*+-]
space [\t ]

%%

^{space}*"TERMINALS"{space}+            {BEGIN DEF_TERMINALS;}
<DEF_TERMINALS>{t_nt}                   {temp = yytext; terminals.push_back(temp);}
<DEF_TERMINALS>{space}+                 {;}
<DEF_TERMINALS>[\n]                     {BEGIN 0;}

^{space}*"NONTERMINALS"{space}+         {BEGIN DEF_NON_TERMINALS;}
<DEF_NON_TERMINALS>{t_nt}               {temp = yytext; non_terminals.push_back(temp);}
<DEF_NON_TERMINALS>{space}+             {;}
<DEF_NON_TERMINALS>[\n]                 {BEGIN 0;}

{t_nt}                                  {
                                            temp = yytext; BEGIN DEF_PROD_LHS;
                                            if(flag == 0)
                                            {
                                                startSymbol = yytext;
                                                flag = 1;
                                            }
                                        }
<DEF_PROD_LHS>{space}+                  {;}
<DEF_PROD_LHS>"->"                      {BEGIN DEF_PROD_RHS;}
<DEF_PROD_RHS>{space}+                  {;}
<DEF_PROD_RHS>"EPS"                     {temp_prod += "^";}
<DEF_PROD_RHS>{t_nt}                    {temp_prod += yytext;}
<DEF_PROD_RHS>"|"                       {productions[temp].push_back(temp_prod); temp_prod.clear();}
<DEF_PROD_RHS>\n                        {productions[temp].push_back(temp_prod); temp_prod.clear(); BEGIN 0;}

.                                       {;}
%%

typedef struct lr1_item
{
    string prod_lhs;
    string prod_rhs;
    string look_ahead;
    int dot_position;
    int prod_size;
}
lr1_item;

struct next_state;

typedef struct state
{
    int state_num;
    set<lr1_item> set_items;
    set<struct next_state> set_next;
}
state;

typedef struct next_state
{
    string signal;
    state* next;
}
next_state;

bool isTerm(string s)
{
    if(find(terminals.begin(), terminals.end(), s) != terminals.end())
    {
        return true;
    }
    return false;
}

bool isNonTerm(string s)
{
    if(find(non_terminals.begin(), non_terminals.end(), s) != non_terminals.end())
    {
        return true;
    }
    return false;
}

bool isThere(vector<string> q,string z)
{
    if(find(q.begin(), q.end(), z) != q.end())
    {
        return true;
    }
	return false;
}

void printFirst() 
{
	cout<<"---------------------------------\n";
	cout<<"Symbol \t\tFIRST Set\n";
	cout<<"---------------------------------\n";
	for(auto it : first_list)
    {
		cout<<it.first<<" \t\t\t{ ";
		bool flag = 0;
		for(auto it1 : it.second) 
        {
			if(flag) cout<<" , ";
			flag = 1;
			cout<<it1;
		}
		cout<<" }\n";
	}
	cout<<"---------------------------------\n\n\n";
}

void printFollow() 
{
	cout<<"---------------------------------\n";
	cout<<"Symbol \t\tFOLLOW Set\n";
	cout<<"---------------------------------\n";
	for(auto it : follow_list)
    {
		cout<<it.first<<" \t\t\t{ ";
		bool flag = 0;
		for(auto it1 : it.second) 
        {
			if(flag) cout<<" , ";
			flag = 1;
			cout<<it1;
		}
		cout<<" }\n";
	}
	cout<<"---------------------------------\n\n\n";
}

void printProductions()
{
    cout<<"---------------------------------\n";
	cout<<"Symbol \t\tProductions\n";
	cout<<"---------------------------------\n";
	for(auto it : productions)
    {
		cout<<it.first<<" \t\t\t{ ";
		bool flag = 0;
		for(auto it1 : it.second) 
        {
			if(flag) cout<<" , ";
			flag = 1;
			cout<<it1;
		}
		cout<<" }\n";
	}
	cout<<"---------------------------------\n\n\n";
}

void findFirst()
{
    bool changing = true;

    while(changing)
    {
        changing = false;
        for(auto p_t : productions)
        {
            string lhs = p_t.first;
            for(string rhs : p_t.second)
            {
                int idx = 0;
                bool found = false;
                while(!found && idx < rhs.length())
                {
                    if(isTerm(string(1, rhs[idx])))
                    {
                        if(!isThere(first_list[lhs], string(1, rhs[idx])))
                        {
                            first_list[lhs].push_back(string(1, rhs[idx]));
                            changing = true;
                        }
                        found = true;
                    }
                    else
                    {
                        for(auto st : first_list[string(1, rhs[idx])])
                        {
                            if(!isThere(first_list[lhs], st) && st != "^")
                            {
                                first_list[lhs].push_back(st);
                                changing = true;
                            }
                        }
                        if(!isThere(productions[string(1, rhs[idx])], "^"))
                        {
                            found = true;
                        }
                        else
                        {
                            idx++;
                        }
                    }
                }
                if(!found && !isThere(first_list[lhs], "^"))
                {
                    first_list[lhs].push_back("^");
                    changing = true;
                }                
            }
        }
    }
}

void findFollow()
{
    follow_list[startSymbol].push_back("$");
    bool changing = true;

    while(changing)
    {
        changing = false;
        for(auto pt : productions)
        {
            for(string st : pt.second)
            {
                if(st == "^")
                {
                    continue;
                }
                if(isNonTerm(string(1, st[st.size()-1])))
                {
                    for(auto st_ : follow_list[pt.first])
                    {
                        if(!isThere(follow_list[string(1, st[st.size()-1])], st_))
                        {
                            follow_list[string(1, st[st.size()-1])].push_back(st_);
                            changing = true;
                        }
                    }
                }
                for(int i = st.size()-2; i >= 0; i--)
                {
                    if(i < 0)
                    {
                        break;
                    }
                    if(isTerm(string(1, st[i])))
                    {
                        continue;
                    }
                    else
                    {
                        bool done = false;
                        int d = 1;
                        while(!done && i+d < st.size())
                        {
                            if(isTerm(string(1, st[i+d])))
                            {
                                if(!isThere(follow_list[string(1, st[i])], string(1, st[i+d])))
                                {
                                    follow_list[string(1, st[i])].push_back(string(1, st[i+d]));
                                    changing = true;
                                }
                                done = true;
                                break;
                            }
                            else
                            {
                                for(auto tk : first_list[string(1, st[i+d])])
                                {
                                    if(!isThere(follow_list[string(1, st[i])], tk) && tk != "^")
                                    {
                                        follow_list[string(1, st[i])].push_back(tk);
                                        changing = true;
                                    }
                                }
                                if(!isThere(first_list[string(1, st[i+d])], "^"))
                                {
                                    done = true;
                                }
                            }
                            d++;
                        }
                        if(!done)
                        {
                            for(auto s : follow_list[pt.first])
                            {
                                if(!isThere(follow_list[string(1, st[i])], s))
                                {
                                    follow_list[string(1, st[i])].push_back(s);
                                    changing = true;
                                }
                            }
                            done = true;
                        }
                    }
                }
            }
        }
    }
}


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

    yyin = input_file;
    yylex();
    terminals.push_back("^");
    terminals.push_back("$");

    fclose(input_file);

    findFirst();
    findFollow();

                                    /*Start Debugging, using output file*/
    ofstream output_file;
    output_file.open("output.txt");
    if (!output_file) 
    {
        perror("Error opening file");
        return 1;
    }

    cout.rdbuf(output_file.rdbuf());

    printFirst();
    printFollow();
    

    output_file.close();
                                    /*End Debugging, using output file*/
    

    return 0;
}
