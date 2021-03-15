%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h> 
#include <stdlib.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
struct parametru{
     char id[20];
     char tip[20];
};

struct variables{
     int dimensiune;
     int constante;
     int curs;
     char id[20];
     char tip[20];
     char value[20];
     char scope[20];
     float valori[100]; //valorile din vector
}main_v[100],global_v[100],local_v[100];
struct functie{
     char id[20];
     char tip[20];
     struct parametru parametri[20];
     struct variables variabile[100];
     int nr_params;
     int nr_vars;
     int return_i;
     float return_f;

}functii[100];
struct tipuri{
     int constante;
     char tip[20];
     struct variables variabile[100];
     int nr_vars;
}tip_lista[100];
struct apeluri{
     char id[20];
     int nr_p;
}apel[100];
struct w{
     char conditie[4];
     char id1c[20];
     char id2c[20];
     char id1ass[20];
     char id2[20];
     char id3[20];
     char op[20];
     char opc[20];
     int linii;
     char operator[100];
     char valori[300];
}wh[100];
FILE* fptr;
int apel_c=0;
int g_c=0;
int l_c=0;
int m_c=0;
int s_c=0;
int f_c=0;
int nr=0;
char apelata[20];
int valoare_de_adevar;
int linie_c=0;
void clear_table(){
     fptr=fopen("symbol_table.txt","w");
}

void valoare_neinit(char s[]){
     printf("Error - linia %d: Variabila %s este neinitializata\n",yylineno,s);
     exit(2);
}

void vars_diff(char s1[],char s2[]){
     printf("Error - linia %d: Variabilele %s si %s nu au acelasi tip\n",yylineno,s1,s2);
     exit(3);
}
void var_nedecl(char s[]){

     printf("Error - linia %d: Variabila %s este nedeclarata\n",yylineno,s);
     exit(0);
}
void var_decl(char s[]){
     printf("Error - linia %d: Variabila %s este deja declarata\n",yylineno,s);
     exit(1);
}
void var_const(char s[]){
     printf("Error - linia %d: Variabila %s este deja constanta\n",yylineno,s);
     exit(2);
}
void diferite(char s[]){
     printf("Error - linia %d: Variabila %s nu are acelasi tip\n",yylineno,s);
     exit(3);
}
void func_dec(char s[]){
     printf("Error - linia %d: Functia %s a fost declarata anterior \n",yylineno,s);
     exit(4);
}
void func_nedec(char s[]){
     printf("Error - linia %d: Functia %s nu a fost declarata anterior \n",yylineno,s);
     exit(5);
}
void func_param_dif(char s[]){
     printf("Error - linia %d: Functia %s a nu are aceeasi parametrii \n",yylineno,s);
     exit(6);
}
void acelasi_return(){
     printf("Error - linia %d: Functia nu are aceeasi valoare de return \n",yylineno);
     exit(7);
}
void pune_vector(char id[20],char tip[20],char value[20],char scope[20], int constanta, int dim){
     
         if(strcmp(scope,"global")==0){
          strcpy(global_v[g_c].id,id);
          strcpy(global_v[g_c].tip,tip);
          strcpy(global_v[g_c].value,value);
          strcpy(global_v[g_c].scope,scope);
          global_v[g_c].constante=constanta;
          global_v[g_c].dimensiune=dim;
          global_v[g_c].curs=0;
          g_c++;
          
     }else if(strcmp(scope,"main")==0){
          strcpy(main_v[m_c].id,id);
          strcpy(main_v[m_c].tip,tip);
          strcpy(main_v[m_c].value,value);
          strcpy(main_v[m_c].scope,scope);
          main_v[m_c].constante=constanta;
          main_v[m_c].dimensiune=dim;
           main_v[m_c].curs=0;
          m_c++;
          
     }else if(strcmp(scope,"local")==0){
          strcpy(local_v[l_c].id,id);
          strcpy(local_v[l_c].tip,tip);
          strcpy(local_v[l_c].value,value);
          strcpy(local_v[l_c].scope,scope);
          local_v[l_c].constante=constanta;
          local_v[l_c].dimensiune=dim;
          local_v[l_c].curs=0;
          l_c++;
          
     }else if(strcmp(scope,"create")==0){
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].id,id);
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].tip,tip);
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].value,value);
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].scope,scope);
          tip_lista[s_c].nr_vars++;
          
     }else if(strcmp(scope,"func")==0){
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].id,id);
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].tip,tip);
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].value,value);
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].scope,scope);
          functii[f_c].variabile[functii[f_c].nr_vars].constante=constanta;
          functii[f_c].variabile[functii[f_c].nr_vars].dimensiune=dim;
          functii[f_c].variabile[functii[f_c].nr_vars].curs=dim;
          functii[f_c].nr_vars++;
          
     }
     
    
     
}
bool aceeasi_parametri(char id[]){
     int g=0;
     for(int i=0;i<f_c;i++){
          if(strcmp(functii[i].id,id)==0){
                    g=0;
                    if(functii[i].nr_params==apel_c){
                    for(int j=0;j<functii[i].nr_params;j++){
                         for(int k=0; k<g_c;k++){
                          if(strcmp(global_v[k].id,apel[j].id)==0){
                                 if(strcmp(global_v[k].tip,functii[i].parametri[j].tip)==0)
                                        g++;
                                     }
                         }
                         for(int k=0; k<m_c;k++){
                          if(strcmp(main_v[k].id,apel[j].id)==0){
                                 if(strcmp(main_v[k].tip,functii[i].parametri[j].tip)==0)
                                        g++;
                                     }
                               }
                         for(int k=0; k<l_c;k++){
                          if(strcmp(local_v[k].id,apel[j].id)==0){
                                 if(strcmp(local_v[k].tip,functii[i].parametri[j].tip)==0)
                                        g++;
                                     }
                               }
                         for(int k=0; k<f_c;k++){
                          if(strcmp(functii[k].id,apel[j].id)==0){
                                 if(strcmp(functii[k].tip,functii[i].parametri[j].tip)==0)
                                        g++;
                                     }
                               }
                    }
                    if(g==apel_c){
                         return true;
                    }
          }}
     }
     return false;
}
bool deja_declarat(char id[],char scope[]){
     
     if(strcmp(scope,"global")==0){
          for(int i=0; i<g_c;i++){
               if(strcmp(global_v[i].id,id)==0){
                    
                    return true;
               }
          }
     }else if(strcmp(scope,"main")==0){
          for(int i=0; i<=m_c; i++){
               
               if(strcmp(main_v[i].id,id)==0){
                    return true;
               }
          }
     }else if(strcmp(scope,"local")==0){
          for(int i=0; i<l_c; i++){
               if(strcmp(local_v[i].id,id)==0){
                    return true;
               }
          }
     }else if(strcmp(scope,"func")==0){
          for(int i=0; i<=f_c; i++){
               for(int j=0; j<functii[i].nr_vars; j++){                    //cautam in variabile
                   
                    if(strcmp(functii[i].variabile[j].id,id)==0){
                         
                         return true;
                    }
               }
               for(int j=0; j<functii[i].nr_params; j++){                    //cautam si in parametri
                    if(strcmp(functii[i].parametri[j].id,id)==0){
                         return true;
                    }
               }
               
          }
     }else if(strcmp(scope,"create")==0){
               for(int i=0; i<=s_c; i++){
               
               for(int j=0; j<tip_lista[i].nr_vars; j++){
                    if(strcmp(tip_lista[i].variabile[j].id,id)==0){
                         return true;
                    }
               }
          }         
     }
     return false;
     
}

bool variabila_init(char id[],char scope[]){
     if(strcmp(scope,"global")==0){
          for(int i =0; i<g_c;i++){
               if(strcmp(global_v[i].id,id)==0){
                    if(strcmp(global_v[i].value,"NULL")==0){
                         return false;
                    }
               }
          }
     }
     if(strcmp(scope,"main")==0){
          for(int i =0; i<m_c;i++){
               if(strcmp(main_v[i].id,id)==0){
                    if(strcmp(main_v[i].value,"NULL")==0){
                         return false;
                    }
               }
          }
     }
     if(strcmp(scope,"local")==0){
          for(int i =0; i<l_c;i++){
               if(strcmp(local_v[i].id,id)==0){
                    if(strcmp(local_v[i].value,"NULL")==0){
                         return false;
                    }
               }
          }
     }
     return true;
     
}

void creeaza_parametri(char id[20],char parametri[100]){
     bzero(parametri,100);
     for(int i=0;i<f_c;i++){
          if(strcmp(functii[i].id,id)==0){
              
               
               for(int j=0;j<functii[i].nr_params;j++){
                    
                    strcat(parametri,functii[i].parametri[j].tip);
                    strcat(parametri," ");
                    strcat(parametri,functii[i].parametri[j].id);
                    strcat(parametri,", ");
               }
          }
     }
}

void creeaza_variabile(char id[20],char variabile[100]){
     bzero(variabile,100);
      for(int i=0;i<f_c;i++){
          if(strcmp(functii[i].id,id)==0){
               for(int j=0;j<functii[i].nr_vars;j++){
                    strcat(variabile,functii[i].variabile[j].tip);
                    strcat(variabile," ");
                    strcat(variabile,functii[i].variabile[j].id);
                    strcat(variabile,", ");
               }
          }
     }
}

void creeaza_variabile_create(char id[20],char variabile[100]){
     bzero(variabile,100);
      for(int i=0;i<s_c;i++){
          if(strcmp(tip_lista[i].tip,id)==0){
               for(int j=0;j<tip_lista[i].nr_vars;j++){
                    strcat(variabile,tip_lista[i].variabile[j].tip);
                    strcat(variabile," ");
                    strcat(variabile,tip_lista[i].variabile[j].id);
                    strcat(variabile,", ");
               }
          }
     }
}

void pune_in_fisier(char id[],char tip[],char value[],int constanta,char scope[]){
     fptr= fopen("symbol_table.txt","a");
     fprintf(fptr,"<%s> <%s> <%s> <const:%d> <%s>\n",id,tip,value,constanta,scope);
}

void pune_functie_in_fisier(char id[],char tip[],char parametri[],char variabile[]){
     fptr= fopen("symbol_table.txt","a");
     fprintf(fptr,"<%s> <%s> <param:%s> <vars:%s> <functie> <global>\n",id,tip,parametri,variabile);
}

void pune_create_in_fisier(char id[],char variabile[]){
     fptr= fopen("symbol_table.txt","a");
     fprintf(fptr,"<%s> <vars:%s> <CREATE> <global>\n",id,variabile);

}

void fill_symbol_table(){
     for(int i= 0;i<g_c;i++){                                                                                        // punem variabilele globale
          pune_in_fisier(global_v[i].id,global_v[i].tip,global_v[i].value,global_v[i].constante,global_v[i].scope);
     }    
     for(int i= 0;i<m_c;i++){                                                                                        // punem variabilele din main
          pune_in_fisier(main_v[i].id,main_v[i].tip,main_v[i].value,main_v[i].constante,main_v[i].scope);
     }
     for(int i= 0;i<l_c;i++){                                                                                        // punem variabilele din local
          pune_in_fisier(local_v[i].id,local_v[i].tip,local_v[i].value,local_v[i].constante,local_v[i].scope);
     }

     char variabile[100];
     for(int i =0;i<s_c;i++){                                                                                        // punem variabilele din create
          for(int j=0;j<tip_lista[i].nr_vars;j++){
               pune_in_fisier(tip_lista[i].variabile[j].id,tip_lista[i].variabile[j].tip,tip_lista[i].variabile[j].value,tip_lista[i].variabile[j].constante,tip_lista[i].variabile[j].scope);
          }
          creeaza_variabile_create(tip_lista[i].tip,variabile);
          pune_create_in_fisier(tip_lista[i].tip,variabile);
     }
     char parametri[100];
     bzero(variabile,100);
     for(int i =0;i<f_c;i++){                                                                                        
          for(int j =0;j<functii[i].nr_vars;j++){
               pune_in_fisier(functii[i].variabile[j].id,functii[i].variabile[j].tip,functii[i].variabile[j].value,functii[i].variabile[j].constante,functii[i].variabile[j].scope);// punem variabilele din functii
          }
          creeaza_parametri(functii[i].id,parametri);
          creeaza_variabile(functii[i].id,variabile);
          
          pune_functie_in_fisier(functii[i].id,functii[i].tip,parametri,variabile);
          
     }
     

     
}

void pune_variabila(char id[20],char tip[20],char value[20],char scope[20], int constanta){
     
         if(strcmp(scope,"global")==0){
          strcpy(global_v[g_c].id,id);
          strcpy(global_v[g_c].tip,tip);
          strcpy(global_v[g_c].value,value);
          strcpy(global_v[g_c].scope,scope);
          global_v[g_c].constante=constanta;
          g_c++;
         
          
     }else if(strcmp(scope,"main")==0){
          strcpy(main_v[m_c].id,id);
          strcpy(main_v[m_c].tip,tip);
          strcpy(main_v[m_c].value,value);
          strcpy(main_v[m_c].scope,scope);
          main_v[m_c].constante=constanta;
          m_c++;
          
     }else if(strcmp(scope,"local")==0){
          strcpy(local_v[l_c].id,id);
          strcpy(local_v[l_c].tip,tip);
          strcpy(local_v[l_c].value,value);
          strcpy(local_v[l_c].scope,scope);
          local_v[l_c].constante=constanta;
          l_c++;
          
     }else if(strcmp(scope,"create")==0){
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].id,id);
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].tip,tip);
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].value,value);
          strcpy(tip_lista[s_c].variabile[tip_lista[s_c].nr_vars].scope,scope);
          tip_lista[s_c].nr_vars++;
          
     }else if(strcmp(scope,"func")==0){
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].id,id);
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].tip,tip);
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].value,value);
          strcpy(functii[f_c].variabile[functii[f_c].nr_vars].scope,scope);
          functii[f_c].variabile[functii[f_c].nr_vars].constante=constanta;
          functii[f_c].nr_vars++;
          
     }
     
    
     
}

void pune_in_functie(char id[],char tip[]){
     strcpy(functii[f_c].id,id);
     strcpy(functii[f_c].tip,tip);
     
     f_c++;
     functii[f_c].nr_params=0;
     functii[f_c].nr_vars=0;
     functii[f_c].return_i=0;
     functii[f_c].return_f=0;
}

void pune_parametri(char id[],char tip[]){
     strcpy(functii[f_c].parametri[functii[f_c].nr_params].id,id);
     strcpy(functii[f_c].parametri[functii[f_c].nr_params].tip,tip);
     functii[f_c].nr_params++;
}
bool exista_functie(char id[], char tip[],struct parametru param[100]){
     int g=0;
     for(int i=0;i<f_c;i++){
          if(strcmp(functii[i].id,id)==0){
               if(strcmp(functii[i].tip,tip)==0){
                    for(int j=0;j<functii[i].nr_params;j++){
                         for(int k=j;k<functii[i].nr_params;k++){
                              if(strcmp(param[j].id,functii[i].parametri[k].id)==0){
                                   if(strcmp(param[j].tip,functii[i].parametri[k].tip)==0){
                                        g++;
                                   }
                              }
                         }
                         
                    }
               }
          }
              
          
     }
     
     if(g==2){
          
          return true;
     }
          
     else{
          return false;
     }
         
}
bool este_declarata(char id[]){
     int g=0;
     for(int i=0;i<f_c;i++){
          if(strcmp(functii[i].id,id)==0){
                    g=1;
                    break;
          }
     }
     if(g==1){
          return true;
     }
     else{
          return false;
     }
}

void pune_tip_in_create(char tip[]){
    
     strcpy(tip_lista[s_c].tip,tip);
     s_c++;
     tip_lista[s_c].nr_vars=0;
    
}

bool exista_tip(char tip[]){
     for(int i =0;i<s_c;i++){
          if(strcmp(tip_lista[i].tip,tip) == 0){
               
               return true;
          }
          
     }
     return false;
}
int ia_pozitie_tip(char tip[]){
     for(int i =0;i<s_c;i++){
          if(strcmp(tip_lista[i].tip,tip) == 0){
               return i;
          }
     }
}
void ia_tip(char id[],char tip[],char scope[]){
     if(strcmp(scope,"main")==0){
          for(int i=0;i<m_c;i++){
               if(strcmp(main_v[i].id,id)==0){
                    strcpy(tip,main_v[i].tip);
                    return;
               }
          }
     }
     if(strcmp(scope,"global")==0){
          for(int i=0;i<g_c;i++){
               if(strcmp(global_v[i].id,id)==0){
                    strcpy(tip,global_v[i].tip);
                    return;
               }
          }
     }
     if(strcmp(scope,"local")==0){
          for(int i=0;i<l_c;i++){
               if(strcmp(local_v[i].id,id)==0){
                    strcpy(tip,local_v[i].tip);
                    return;
               }
          }
     }
     
}


void ia_scope(char id[],char scope[],char scope_apel[]){

     int ok=0;
     if(strcmp(scope_apel,"global")==0){
          for(int i=0;i<g_c;i++){                      //cautam global
                    if(strcmp(global_v[i].id,id)==0){
                         strcpy(scope,global_v[i].scope);
                        
                    }
               }
     }
     if(strcmp(scope_apel,"main")==0){
          for(int i=0;i<m_c;i++){                      //cautam in main
               if(strcmp(main_v[i].id,id)==0){
                    strcpy(scope,main_v[i].scope);
                    ok=1;
               }
          }
          if(ok==0){
               for(int i=0;i<g_c;i++){                      //cautam si global
                    if(strcmp(global_v[i].id,id)==0){
                         strcpy(scope,global_v[i].scope);
                         ok=1;
                    }
               }
          }
     }
     ok=0;
     if(strcmp(scope_apel,"local")==0){
          for(int i=0;i<l_c;i++){                                //cautam local
               if(strcmp(local_v[i].id,id)==0){
                    strcpy(scope,local_v[i].scope);
                    ok=1;
               }
          }
          if(ok==0){                                   //cautam si in main
               for(int i=0;i<m_c;i++){
                    if(strcmp(main_v[i].id,id)==0){
                         strcpy(scope,main_v[i].scope);
                         ok=1;
                    }
               }
          }
          if(ok==0){
               for(int i=0;i<g_c;i++){                           //cautam si global
                    if(strcmp(global_v[i].id,id)==0){
                         strcpy(scope,global_v[i].scope);
                         ok=1;
                    }
               }
          }
     }
     ok=0;
     if(strcmp(scope_apel,"func")==0){
               for(int i=0;i<f_c;i++){
                    for(int j=0;j<functii[i].nr_vars;j++){
                         if(strcmp(functii[i].variabile[j].id,id)==0){
                              strcpy(scope,functii[i].variabile[j].scope);
                              ok=1;
                         }
                    }
          
               }
               if(ok==0){
                    for(int i =0;i<g_c;i++){
                         if(strcmp(global_v[i].id,id)==0){
                              strcpy(scope,global_v[i].scope);
                         }
                    }
               }
               

     }
     ok=0;
     if(strcmp(scope,"struct")==0){
          for(int i =0;i<s_c;i++){
               for(int j=0;j<tip_lista[i].nr_vars;j++){
                    if(strcmp(id,tip_lista[i].variabile[j].id)==0){
                         strcpy(scope,tip_lista[i].variabile[j].scope);
                    }
               }
               
          } 

     }

}
void ia_valoare(char id[],char valoare[],char scope[]){       //luam valoarea cu id-ul respectiv din scope-ul cerut inafara de create
     if(strcmp(scope,"global")==0){
          for(int i=0;i<g_c;i++){                                //cautam global
               if(strcmp(global_v[i].id,id)==0){ 
                         strcpy(valoare,global_v[i].value);
               }
          }

     }else if(strcmp(scope,"main")==0){
               
               for(int i=0;i<m_c;i++){                                //cautam in main
                    if(strcmp(main_v[i].id,id)==0){
                              strcpy(valoare,main_v[i].value);
                         
                    }
               }
               
     }else if(strcmp(scope,"local")==0){
          
               for(int i=0;i<l_c;i++){                                //cautam in local
                    if(strcmp(local_v[i].id,id)==0){
                              strcpy(valoare,local_v[i].value);
                         
                    }
               }
     }
}
bool exista_variabila_create_in_variabila(char variabila_create[],char variabila[],char apel_scope[]){           //Verificam daca variabila de tip create are o anumita variabila
     if(strcmp(apel_scope,"main")==0){
          for(int i=0;i<m_c;i++){
               if(strcmp(main_v[i].id,variabila)==0){
                    for(int j =0; j<s_c;j++){
                         if(strcmp(tip_lista[j].tip,main_v[i].tip)==0){
                              for(int k=0;k<tip_lista[j].nr_vars;k++){
                                   if(strcmp(tip_lista[j].variabile[k].id,variabila_create)==0){
                                        return true;
                                   }
                              }
                         }    
                    }
                    
               }
          }
     }
     
     
          return false;
}

bool exista_variabila(char var[],char scope[]){             //Verificam daca variabila a fost declarata anterior

     if(strcmp(scope,"global")==0){
          
          for(int i=0;i<g_c;i++){
              if(strcmp(global_v[i].id,var)==0){
                    
                    return true;
               }
          }
     }else if(strcmp(scope,"main")==0){
               for(int i=0;i<m_c;i++){
                    if(strcmp(main_v[i].id,var)==0){
                         
                         return true;
                    }
               }
               for(int i =0;i<g_c;i++){
                    if(strcmp(global_v[i].id,var)==0){
                         return true;
                    }
               }
     }else if(strcmp(scope,"local")==0){
               
               for(int i=0;i<l_c;i++){
                    if(strcmp(local_v[i].id,var)==0){
                         return true;
                    }
               }
               for(int i=0;i<m_c;i++){
                    if(strcmp(main_v[i].id,var)==0){
                         return true;
                    }
               }
               for(int i =0;i<g_c;i++){
                    if(strcmp(global_v[i].id,var)==0){
                         return true;
                    }
               }
     }else if(strcmp(scope,"func")==0){
               for(int i=0;i<f_c;i++){
                    for(int j=0;j<functii[i].nr_vars;j++){
                         if(strcmp(functii[i].variabile[j].id,var)==0){
                              return true;
                         }
                    }
          
     }
               for(int i =0;i<g_c;i++){
                    if(strcmp(global_v[i].id,var)==0){
                         return true;
                    }
               }

     }
     
     return false;
}

void assign(char id[],char valoare[],char scope[]){
     
     if(strcmp(scope,"global")==0){
          for(int i=0;i<g_c;i++){
               if(strcmp(global_v[i].id,id)==0){
                    if(global_v[i].constante==1 && strcmp(global_v[i].value,"NULL")!=0){
                         var_const(id);
                    }
                    else{
                    strcpy(global_v[i].value,valoare);
                    }
               }
          }
     }else if(strcmp(scope,"main")==0){
               for(int i=0;i<m_c;i++){
                    if(strcmp(main_v[i].id,id)==0){
                         if(main_v[i].constante==1 && strcmp(main_v[i].value,"NULL")!=0){
                         var_const(id);
                    }
                    else{
                         strcpy(main_v[i].value,valoare);
                    }
                    }
               }
     }else if(strcmp(scope,"local")==0){
               for(int i=0;i<l_c;i++){
                    if(strcmp(local_v[i].id,id)==0){
                         if(local_v[i].constante==1 && strcmp(local_v[i].value,"NULL")!=0){
                         var_const(id);
                    }
                    else{
                         strcpy(local_v[i].value,valoare);
                         
                    }
                    }
               }
          }    
}

void assign_val_to_create(char id_create[],char id_var[],char valoare[]){
     for(int i =0; i< s_c;i++){
          if(strcmp(tip_lista[i].tip,id_create)==0){
               for(int j =0; j< tip_lista[i].nr_vars;j++){
                    if(strcmp(tip_lista[i].variabile[j].id,id_var)==0 ){
                          if(tip_lista[i].variabile[j].constante==1  && strcmp(tip_lista[i].variabile[j].value,"NULL")!=0){
                                var_const(id_var);
                                strcpy(tip_lista[i].variabile[j].value,valoare);
                           }
                         else{
                              strcpy(tip_lista[i].variabile[j].value,valoare);
                         }
                    }
               }
          }
     }
}
void ia_valoare_create(char id_create[],char id_var[],char valoare[]){
     for(int i =0; i< s_c;i++){
          if(strcmp(tip_lista[i].tip,id_create)==0){
               for(int j =0; j< tip_lista[i].nr_vars;j++){
                    if(strcmp(tip_lista[i].variabile[j].id,id_var)==0){
                         strcpy(valoare,tip_lista[i].variabile[j].value);
                    }
               }
          }
     }
}
void itoa(int nr,char string[]){
     sprintf(string, "%d", nr);
}

bool au_acelasi_tip(char id1[],char scope1[],char id2[],char scope2[]){
     char tip1[20];
     char tip2[20];
     if(strcmp(scope1,"main")==0){                          //pentru primul id
          for(int i =0;i<m_c;i++){
               if(strcmp(id1,main_v[i].id)==0){
                    strcpy(tip1,main_v[i].tip);
               }
          }   
     }else if(strcmp(scope1,"global")==0){
          for(int i =0;i<g_c;i++){
               if(strcmp(id1,global_v[i].id)==0){
                    strcpy(tip1,global_v[i].tip);
               }
          } 

     }else if(strcmp(scope1,"local")==0){
          for(int i =0;i<l_c;i++){
               if(strcmp(id1,local_v[i].id)==0){
                    strcpy(tip1,local_v[i].tip);
               }
          } 

     }else if(strcmp(scope1,"func")==0){
          int ok=0;
          for(int i=0;i<f_c;i++){
               for(int j=0;j<functii[i].nr_vars;j++){                      //in variabile
                    if(strcmp(id1,functii[i].variabile[j].id)==0){
                         strcpy(tip1,functii[i].variabile[j].tip);
                         ok=1;
                    }
               }
               if(ok==0){
                    for(int j=0;j<functii[i].nr_params;j++){                      //in parametri
                         if(strcmp(id1,functii[i].parametri[j].id)==0){
                              strcpy(tip1,functii[i].parametri[i].tip);
                         }
                    }
               }

               
          } 

     }else if(strcmp(scope1,"struct")==0){
          for(int i =0;i<s_c;i++){
               for(int j=0;j<tip_lista[i].nr_vars;j++){
                    if(strcmp(id1,tip_lista[i].variabile[j].id)==0){
                         strcpy(tip1,tip_lista[i].variabile[j].tip);
                    }
               }
               
          } 

     }                                  

     if(strcmp(scope2,"main")==0){                                             //pentru al doilea id
          for(int i =0;i<m_c;i++){
               if(strcmp(id2,main_v[i].id)==0){
                    strcpy(tip2,main_v[i].tip);
               }
          }   
     }else if(strcmp(scope2,"global")==0){
          for(int i =0;i<g_c;i++){
               if(strcmp(id2,global_v[i].id)==0){
                    strcpy(tip2,global_v[i].tip);
               }
          } 

     }else if(strcmp(scope2,"local")==0){
          for(int i =0;i<l_c;i++){
               if(strcmp(id2,local_v[i].id)==0){
                    strcpy(tip2,local_v[i].tip);
               }
          } 

     }else if(strcmp(scope2,"func")==0){
          int ok=0;
          for(int i =0;i<f_c;i++){
               for(int j=0;j<functii[i].nr_vars;j++){                      //in variabile
                    if(strcmp(id2,functii[i].variabile[j].id)==0){
                         strcpy(tip2,functii[i].variabile[j].tip);
                         ok=1;
                    }
               }
               if(ok==0){
                    for(int j=0;j<functii[i].nr_params;j++){                      //in parametri
                         if(strcmp(id2,functii[i].parametri[j].id)==0){
                              strcpy(tip2,functii[i].parametri[i].tip);
                         }
                    }
               }

               
          } 

     }else if(strcmp(scope2,"struct")==0){
          for(int i =0;i<s_c;i++){
               for(int j=0;j<tip_lista[i].nr_vars;j++){
                    if(strcmp(id2,tip_lista[i].variabile[j].id)==0){
                         strcpy(tip2,tip_lista[i].variabile[j].tip);
                    }
               }
               
          } 

     }

     if(strcmp(tip1,tip2)==0){
          return true;
     }else{
          return false;
     }

}

bool id_acelasi_tip_cu_tip(char id1[],char scope1[],char tip[]){
     char tip1[20];
     if(strcmp(scope1,"main")==0){                          //pentru primul id
          for(int i =0;i<m_c;i++){
               if(strcmp(id1,main_v[i].id)==0){
                    strcpy(tip1,main_v[i].tip);
               }
          }   
     }else if(strcmp(scope1,"global")==0){
          for(int i =0;i<g_c;i++){
               if(strcmp(id1,global_v[i].id)==0){
                    strcpy(tip1,global_v[i].tip);
               }
          } 

     }else if(strcmp(scope1,"local")==0){
          for(int i =0;i<l_c;i++){
               if(strcmp(id1,local_v[i].id)==0){
                    strcpy(tip1,local_v[i].tip);
               }
          } 

     }else if(strcmp(scope1,"func")==0){
          int ok=0;
          for(int i =0;i<f_c;i++){
               for(int j=0;j<functii[i].nr_vars;j++){                      //in variabile
                    if(strcmp(id1,functii[i].variabile[j].id)==0){
                         strcpy(tip1,functii[i].variabile[j].tip);
                         ok=1;
                    }
               }
               if(ok==0){
                    for(int j=0;j<functii[i].nr_params;j++){                      //in parametri
                         if(strcmp(id1,functii[i].parametri[j].id)==0){
                              strcpy(tip1,functii[i].parametri[i].tip);
                         }
                    }
               }

               
          } 

     }else if(strcmp(scope1,"struct")==0){
          for(int i =0;i<s_c;i++){
               for(int j=0;j<tip_lista[i].nr_vars;j++){
                    if(strcmp(id1,tip_lista[i].variabile[j].id)==0){
                         strcpy(tip1,tip_lista[i].variabile[j].tip);
                    }
               }
               
          } 

     }     

     if(strcmp(tip1,tip)==0){
          return true;
     }
     return false;

}

void ia_parametri(char id[],char tip[],struct parametru param[100]){
     for(int i=0;i<f_c;i++){
          if(strcmp(functii[i].id,id)==0){
               if(strcmp(functii[i].tip,tip)==0){
                    for(int k=0;k<functii[i].nr_params;k++){
                         strcpy(param[k].id,functii[i].parametri[k].id);
                         strcpy(param[k].tip,functii[i].parametri[k].tip);
                    }
               }
          }
     }
}
void cauta(char id[]){
     for(int i=0;i<f_c;i++){
          if(strcmp(id, functii[i].id)==0){
               if(strcmp(functii[i].tip, "int")==0){
                    nr=functii[i].return_i;
               }
               else{
                    printf("Nu poti pune la Eval() valori float;");
                    exit(8);
               }
          }
     }
}
void fa_while(){
     while(valoare_de_adevar){
          printf("intra");
          for(int i=1;i<=linie_c;i++){
               char valoare1[10], valoare2[10];
               ia_valoare(wh[linie_c].id2,valoare1,"main");
               ia_valoare(wh[linie_c].id3,valoare2,"main");
               int val1, val2;
               val1=atoi(valoare1);
               val2=atoi(valoare2);
               printf("op %s",wh[linie_c].operator);
               printf("\nop %s",wh[linie_c].id2);
               printf("\nop %s",wh[linie_c].id3);
               if(strcmp(wh[linie_c].operator, "+")==0){
                    int val3=val1+val2;
                    printf("\n valoare %d", val3);
                     char val[20];
                      itoa(val3,val); 
                     assign(wh[linie_c].id1ass,val,"main");
               }
               if(strcmp(wh[linie_c].operator, "-")==0){
                    int val3=val1-val2;
                     char val[20];
                      itoa(val3,val); 
                     assign(wh[linie_c].id1ass,val,"main");
               }
               if(strcmp(wh[linie_c].operator, "%")==0){
                    int val3=val1%val2;
                     char val[20];
                      itoa(val3,val); 
                     assign(wh[linie_c].id1ass,val,"main");
               }
               if(strcmp(wh[linie_c].operator, "*")==0){
                    int val3=val1*val2;
                     char val[20];
                      itoa(val3,val); 
                     assign(wh[linie_c].id1ass,val,"main");
               }
          }
          char valoare1[10], valoare2[10];
          printf("\n com %s", wh[0].id1c);
          printf("\n com %s", wh[0].id2c);
               ia_valoare(wh[0].id1c,valoare1,"main");
               ia_valoare(wh[0].id2c,valoare2,"main");
               int val1, val2;
               val1=atoi(valoare1);
               val2=atoi(valoare2);
               if(strcmp(wh[0].opc, "<")==0){ 
                    printf("\n val 1 : %d", val1);
                    printf("\n val 2 : %d", val2);
                    valoare_de_adevar=val1<val2;
               }
               if(strcmp(wh[linie_c].opc, ">=")==0){
                    valoare_de_adevar=val1>=val2;
               }
               if(strcmp(wh[linie_c].opc, "<=")==0){
                    valoare_de_adevar=val1<=val2;
               }
               if(strcmp(wh[linie_c].opc, "==")==0){
                    valoare_de_adevar=val1==val2;
               }
     }
}
%}

%token ASSIGN MAIN CREATE CONST IF ELSE WHILE FOR EQ NEQ GEQ LEQ RETURN
%union
     {
          int number;
          char *string;
          float f_value;
          char *str;
          char dim[100];
          int boolval;
     }    
%token <string> ID EVAL TIP
%token <dim> DIMENSIUNE
%token <boolval> FALSE
%token <boolval> TRUE 
%token <number> NR
%token <f_value> NR_R
%token <str> SIR

%type <number> operatie_ID_g
%type <number> operatie_ID_f
%type <number> operatie_ID_m
%type <number> operatie_ID_l
%type <number> operatie_ID_wh
%type <number> operatii_i
%type <f_value> operatii_f
%type <boolval> operatie_b
%type <boolval> comparare_i
%type <boolval> comparare_f
%type <boolval> comparare_w

%token COMPARE CONCAT
%left COMPARARI
%left '|' '&' '!'
%left '+' '-' '%' '*' '/' 
%start progr
%%
progr     :    globale main {printf("program corect sintactic\n"); YYACCEPT;}
          ;

globale   :    declaratie_globala                   
          |    globale declaratie_globala      
          |    functie
          |    globale functie 
          |    create  
          |    globale create 
          |    globale statement   
          |    statement           
          ;

declaratie_globala  :    TIP ID ';'               
                              {
                                   int constanta=0;
                                   if(!deja_declarat($2,"global")){
                                        pune_variabila($2,$1,"NULL","global", constanta);
                                   }else{
                                        var_decl($2);
                                   }
                                   
                              }
                    |    TIP ID DIMENSIUNE ASSIGN {int constanta=0;
                                                   if(!deja_declarat($2,"global")){
                                                   pune_vector($2,$1,"NULL","global", constanta, DIMENSIUNE);
                                                   }
                                                        else{
                                                     var_decl($2);
                                                        } 
                         ;}'@' lista_vector '@' ';'
                    |    TIP ID DIMENSIUNE ';' {int constanta=0;
                                               if(!deja_declarat($2,"global")){
                                                   pune_vector($2,$1,"NULL","global", constanta, DIMENSIUNE);
                                                        }else{
                                                     var_decl($2);
                                                        } 
                         ;}
                    |    CONST TIP ID ASSIGN NR ';'
                                   {
                                        if(strcmp($2, "int")!=0){
                                             diferite($3);
                                        }
                                        else{
                                        int constanta=1;
                                        if(!deja_declarat($3,"global")){
                                             char val[20];
                                             itoa($5,val);
                                             pune_variabila($3,$2,val,"global", constanta);
                                        }else{
                                             var_decl($3);
                                        }
                                        }
                                   }
                    |    TIP ID ASSIGN NR ';'     
                                   {    
                                        if(strcmp($1, "int")!=0){
                                             diferite($2);
                                        }
                                        else{
                                        int constanta=0;
                                         if(!deja_declarat($2,"global")){
                                             char val[20];
                                             itoa($4,val);
                                             pune_variabila($2,$1,val,"global", constanta);
                                        }else{
                                             var_decl($2);
                                        }
                                        }
                                   }
                    |    CONST TIP ID ASSIGN NR_R ';'
                                   {
                                        if(strcmp($2, "float")!=0){
                                             diferite($3);
                                        }
                                        else{
                                        int constanta=1;
                                        if(!deja_declarat($3,"global")){
                                             char val[20];
                                             itoa($5,val);
                                             pune_variabila($3,$2,val,"global", constanta);
                                        }else{
                                             var_decl($3);
                                        }
                                        }
                                   }
                    |    TIP ID ASSIGN NR_R ';'     
                                   {    
                                        if(strcmp($1, "float")!=0){
                                             diferite($2);
                                        }
                                        else{
                                        int constanta=0;
                                         if(!deja_declarat($2,"global")){
                                             char val[20];
                                             itoa($4,val);
                                             pune_variabila($2,$1,val,"global", constanta);
                                        }else{
                                             var_decl($2);
                                        }
                                        }
                                   }
                    ;
lista_vector   :    operatii_i    {if(strcmp(global_v[g_c-1].tip, "int")!=0){diferite(global_v[g_c-1].id);}; global_v[g_c-1].valori[global_v[g_c-1].curs]=$1;global_v[g_c-1].curs++;}
               |    lista_vector ','    operatii_i     {if(strcmp(global_v[g_c-1].tip, "int")!=0){diferite(global_v[g_c-1].id);};global_v[g_c-1].valori[global_v[g_c-1].curs]=$3;global_v[g_c-1].curs++;}
               | operatii_f    {if(strcmp(global_v[g_c-1].tip, "float")!=0){diferite(global_v[g_c-1].id);}; global_v[g_c-1].valori[global_v[g_c-1].curs]=$1;global_v[g_c-1].curs++;}
               |    lista_vector ','    operatii_f     {if(strcmp(global_v[g_c-1].tip, "float")!=0){diferite(global_v[g_c-1].id);};global_v[g_c-1].valori[global_v[g_c-1].curs]=$3;global_v[g_c-1].curs++;}
create    :    CREATE ID create_bloc ';'     {pune_tip_in_create($2); }
          ;
create_bloc    :    '{' create_list '}'
               ;
create_list    :    declaratie_create                {}
               |    create_list declaratie_create 
               ;
declaratie_create   :    TIP ID ';'   
                              {    
                                   int constanta=0;
                                   if(!deja_declarat($2,"create")){
                                        pune_variabila($2,$1,"NULL","create", constanta);
                                   }else{
                                        var_decl($2);
                                   }
                                   
                              }
                    ;
create_statement     :    ID ASSIGN ID '.' ID      
                                   {
                                        if(exista_variabila($1,"main")){
                                             if(exista_variabila($3,"main")){
                                                  if(exista_variabila_create_in_variabila($5,$3,"main")){
                                                       char scope[20],valoare[20];
                                                       ia_scope($1,scope,"main");              //luam scope-ul variabilei $1
                                                       ia_valoare_create($3,$5,valoare);
                                                       assign($1,valoare,scope);
                                                       
                                                  }else{
                                                       var_nedecl($5);
                                                  }
                                             }else{
                                                  var_nedecl($3);
                                             }
                                        }else{
                                                  var_nedecl($1);
                                             }
                                        
                                        
                              

                                   }
                    |    ID '.' ID ASSIGN NR 
                                   {
                                        if(exista_variabila($1,"main")){
                                             if(exista_variabila_create_in_variabila($3,$1,"main")){
                                                  char val[20];
                                                  itoa($5,val); 
                                                  assign_val_to_create($1,$3,val); 
                                             }else{
                                                  var_nedecl($3);
                                             }
                                        }else {
                                             var_nedecl($1);
                                        }
                                        
                                   }               
                    ;
vector    :    ID '[' NR ']'
          ;
functie   :    TIP ID '(' lista_param ')' {    
                                                  struct parametru param[100];
                                                  ia_parametri($2,$1,param);
                                                   if(exista_functie($2, $1,param)){ 
                                                       func_dec($2);
                                                  }
                                                  
                                                  pune_in_functie($2,$1);
                                                  
                                                  
                                                 
                                             }bloc_functie           
          |    TIP ID '(' ')' {
                                                  struct parametru param[100];
                                                  ia_parametri($2,$1,param);
                                                  if(exista_functie($2, $1,param)){
                                                       func_dec($2);
                                                  }
                                                  
                                                  pune_in_functie($2,$1);
                                                  
                                                  
                                             } bloc_functie                       
          ;
bloc_functie   :    '{' func_list RETURN operatii_i ';' '}' {   printf("tip %s",functii[f_c-1].tip);
                                                             if(strcmp(functii[f_c-1].tip, "int")==0){

                                                                 functii[f_c-1].return_i=$4;}
                                                                 
                                                            else{
                                                                 acelasi_return();
                                                            }
                                                                 }
               | '{' func_list RETURN operatii_f ';' '}' {    if(strcmp(functii[f_c-1].tip, "float")==0){
                                                                 functii[f_c-1].return_f=$4;
                                                                 functii[f_c-1].return_i=0;
                                                                 }
                                                            else{
                                                                 acelasi_return();
                                                            }
                                                                 }
               ;

func_list :    func_decl ';'
          |    func_list func_decl ';'            
          |    func_list func_statement
          |    func_statement ';'
          ;
func_decl :    TIP ID                   
                         {    
                              int constanta=0;
                              if(!deja_declarat($2,"func")){
                                        
                                        pune_variabila($2,$1,"NULL","func", constanta);
                              }else{
                                        var_decl($2);
                              }
                              
                         }
          |    CREATE ID ID             
                         {    
                              int constanta=0;
                              if(!deja_declarat($3,"func")){
                                        pune_variabila($3,$2,"NULL","func", constanta);
                              }else{
                                        var_decl($2);
                              }
                              
                         }         
          |    TIP vector            
          |    TIP ID ASSIGN NR        
                              {    
                                   if(strcmp($1, "int")!=0){
                                             diferite($2);
                                        }
                                   else{
                                   int constanta=0;
                                   if(!deja_declarat($2,"func")){
                                        char val[20];
                                        itoa($4,val);
                                        pune_variabila($2,$1,val,"func", constanta);
                                   }else{
                                        var_decl($2);
                                   }
                                   }
                              } 
     /*  |    TIP ID DIMENSIUNE ASSIGN {int constanta=0;
                                               if(!deja_declarat($2,"func")){
                                                   pune_vector($2,$1,"NULL","func", constanta, DIMENSIUNE);
                                                        }else{
                                                     var_decl($2);
                                                        } 
                         ;}'@' lista_vector1 '@' ';'*/
                  /*  |    TIP ID DIMENSIUNE ';' {int constanta=0;
                                               if(!deja_declarat($2,"func")){
                                                   pune_vector($2,$1,"NULL","func", constanta, DIMENSIUNE);
                                                        }else{
                                                     var_decl($2);
                                                        } 
                         ;}*/
          |    CONST TIP ID ASSIGN NR {
                                   if(strcmp($2, "int")!=0){
                                             diferite($3);
                                        }
                                   else{
                                   int constanta=1;
                                   if(!deja_declarat($3,"func")){
                                        char val[20];
                                        itoa($5,val);
                                        pune_variabila($3,$2,val,"func",constanta);
                                   }
                                   else{
                                        var_decl($3);
                                   }
                                   }
                               }
          |    TIP ID ASSIGN NR_R       
                              {    
                                   if(strcmp($1, "float")!=0){
                                             diferite($2);
                                        }
                                   else{
                                   int constanta=0;
                                   if(!deja_declarat($2,"func")){
                                        char val[20];
                                        itoa($4,val);
                                        pune_variabila($2,$1,val,"func", constanta);
                                   }else{
                                        var_decl($2);
                                   }
                                   }
                              } 
          |    CONST TIP ID ASSIGN NR_R {
                                   if(strcmp($2, "float")!=0){
                                             diferite($3);
                                        }
                                   else{
                                   int constanta=1;
                                   if(!deja_declarat($3,"func")){
                                        char val[20];
                                        itoa($5,val);
                                        pune_variabila($3,$2,val,"func",constanta);
                                   }
                                   else{
                                        var_decl($3);
                                   }
                                   }
                                   }
          ; 
func_statement :    ID ASSIGN ID ';'    
                              { 
                                   char valoare[20],scope1[20],scope2[20]; 
                                    
                                   
                                   if(exista_variabila($1,"func")){
                                        ia_scope($1,scope1,"func");  
                                        
                                        if(exista_variabila($3,scope2)){
                                             ia_scope($3,scope2,"func");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2)){
                                                       ia_valoare($3,valoare,scope2);
                                                       assign($1,valoare,scope1);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              } 
               |    assign_ID_f ';' 

               |    ID ASSIGN NR  ';'	
                    {
                         char valoare[20],scope[20];
                         
                         if(exista_variabila($1,"func")){
                              ia_scope($1,scope,"func");
                              if(id_acelasi_tip_cu_tip($1,scope,"int")){
                                   itoa($3,valoare);
                                   assign($1,valoare,scope);
                              }else{
                                   diferite($1);
                              }
                              
                         }else{
                              var_nedecl($1);
                         }
                         
                    }  
               |    create_statement ';'
               |    apel_functii ';'
               |    functii_control
               |    operatie_string_f ';'
               |    EVAL '(' operatii_i ')' ';'                  {printf("Eval:%d\n",$3);}
               ;    

lista_param    :    param   
               |    lista_param ','  param 
               ;
            
param     :    TIP ID                   {pune_parametri($2,$1);}
          ; 
      
apel_functii   :    ID '(' ')'               {if(!este_declarata($1)){
                                                       func_nedec($1);
                                                       }
                                                       else{
                                                            strcpy(apelata, $1);
                                                       };}
               |    ID '(' param_apel ')'    {if(!este_declarata($1)){
                                                       func_nedec($1);
                                                       };
                                                       if(!aceeasi_parametri($1)){
                                                                 func_param_dif($1);
                                                       }
                                                       else{
                                                            strcpy(apelata, $1);
                                                       }
                                                       apel_c=0;
                                                       }
               ;
param_apel     :    ID                       {strcpy(apel[apel_c].id, $1);
                                                            apel[apel_c].nr_p=apel_c;
                                                             apel_c++;}
               |    apel_functie_return             
               |    param_apel ',' ID              {strcpy(apel[apel_c].id, $3); 
                                                       apel[apel_c].nr_p=apel_c;
                                                       apel_c++;}
               |    param_apel ',' apel_functie_return
               ;
apel_functie_return :    ID '(' ')'          {if(!este_declarata($1)){
                                                       func_nedec($1);
                                                       }
                                                  strcpy(apel[apel_c].id, $1);
                                                            apel[apel_c].nr_p=apel_c;
                                                             apel_c++;}
                    | ID '(' param_apel ')'  {if(!este_declarata($1)){
                                                       func_nedec($1);
                                                       }
                                                    strcpy(apel[apel_c].id, $1);
                                                            apel[apel_c].nr_p=apel_c;
                                                             apel_c++;}
main :    TIP MAIN '(' ')' main_bloc 
     ;

main_bloc :    '{' main_list '}'
          ;
main_list :    main_statement
          |    main_list main_statement
          |    declaratie_main                    
          |    main_list declaratie_main        
          ;
declaratie_main     :    TIP ID ';'               
                                   {    
                                        int constanta=0;
                                        if(!deja_declarat($2,"main")){
                                             pune_variabila($2,$1,"NULL","main", constanta);
                                        }else{
                                             var_decl($2);
                                        }
                                        
                                   }
                    |    CREATE ID ID ';'         
                                   {    
                                        int constanta=0;
                                        if(!deja_declarat($3,"main")){
                                             pune_variabila($3,$2,"NULL","main", constanta);
                                        }else{
                                             var_decl($3);
                                        }
                                        
                                   }    
                    |    TIP vector ';'
                    |    TIP ID ASSIGN NR ';'     
                                   {
                                        if(strcmp($1, "int")!=0){
                                             diferite($2);
                                        }
                                        int constanta=0;
                                        if(!deja_declarat($2,"main")){
                                             char val[20];
                                             itoa($4,val);
                                             pune_variabila($2,$1,val,"main", constanta);
                                        }else{
                                             var_decl($2);
                                        }
                                        
                                   } 
                    ;
               
     
main_statement :    ID ASSIGN ID ';'    
                              { 
                                   char valoare[20],scope1[20],scope2[20]; 
                                   
                                    
                                   
                                   if(exista_variabila($1,"main")){
                                        
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2)){
                                                       ia_valoare($3,valoare,scope2);
                                                       assign($1,valoare,scope1);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              } 
               |    assign_ID_m ';'
               |    operatie_string_m ';'
               //|    ID ASSIGN operatie_b ';'
               |    ID ASSIGN SIR ';'
                              {
                                   char scope[20];
                                  
                                   if(exista_variabila($1,"main")){
                                        
                                        ia_scope($1,scope,"main");
                                        
                                        if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                             
                                             assign($1,$3,scope);
                                        }else{
                                             diferite($1);
                                        }

                                   }else{
                                        var_nedecl($1);
                                   }
                              }
               |    ID ASSIGN operatii_i  ';'	
                    {
                         char valoare[20],scope[20];
                         
                         if(exista_variabila($1,"main")){
                              ia_scope($1,scope,"main");
                              if(id_acelasi_tip_cu_tip($1,scope,"int")){
                                   itoa($3,valoare);
                                   assign($1,valoare,scope);
                              }else{
                                   diferite($1);
                              }
                              
                         }else{
                              var_nedecl($1);
                         }
                    } 
               |    TIP ID DIMENSIUNE ASSIGN {int constanta=0;
                                               if(!deja_declarat($2,"main")){
                                                   pune_vector($2,$1,"NULL","main", constanta, DIMENSIUNE);
                                                        }else{
                                                     var_decl($2);
                                                        } 
                         ;}'@' lista_vector1 '@' ';'
                    |    TIP ID DIMENSIUNE ';' {int constanta=0;
                                               if(!deja_declarat($2,"main")){
                                                   pune_vector($2,$1,"NULL","main", constanta, DIMENSIUNE);
                                                        }else{
                                                     var_decl($2);
                                                        } 
                         ;}
               |    CONST TIP ID ASSIGN operatii_i ';'
                               {
                                    if(strcmp($2, "int")!=0){
                                             diferite($3);
                                        }
                                        int constanta=1;
                                        if(!deja_declarat($3,"main")){
                                             char val[20];
                                             itoa($5,val);
                                             pune_variabila($3,$2,val,"main",constanta);
                                        }else{
                                             var_decl($3);
                                        }
                                        
                                   } 
               |    ID ASSIGN operatii_f';'	
                    {
                         char valoare[20],scope[20];
                         
                         if(exista_variabila($1,"main")){
                              ia_scope($1,scope,"main");
                              if(id_acelasi_tip_cu_tip($1,scope,"float")){
                                   itoa($3,valoare);
                                   assign($1,valoare,scope);
                              }else{
                                   diferite($1);
                              }
                              
                         }else{
                              var_decl($1);
                         }
                    }  
               |    CONST TIP ID ASSIGN operatii_f ';'
                               {   
                                    if(strcmp($2, "float")!=0){
                                             diferite($3);
                                        }
                                        int constanta=1;
                                        if(!deja_declarat($3,"main")){
                                             char val[20];
                                             itoa($5,val);
                                             pune_variabila($3,$2,val,"main",constanta);
                                        }else{
                                             var_decl($3);
                                        }
                                        
                                   } 
               |    EVAL '(' operatii_i ')' ';'                  {printf("Eval:%d\n",$3);}
               |    create_statement ';'
               |    apel_functii ';'
               |    functii_control
               ;
lista_vector1 :operatii_i    {if(strcmp(main_v[m_c-1].tip, "int")!=0){diferite(main_v[m_c-1].id);}; main_v[m_c-1].valori[main_v[m_c-1].curs]=$1;}
               |    lista_vector1 ','    operatii_i     {if(strcmp(main_v[m_c-1].tip, "int")!=0){diferite(main_v[m_c-1].id);};main_v[m_c-1].valori[main_v[m_c-1].curs]=$3;main_v[m_c-1].curs++;}
               | operatii_f    {if(strcmp(main_v[m_c-1].tip, "float")!=0){diferite(main_v[m_c-1].id);}; main_v[m_c-1].valori[main_v[m_c-1].curs]=$1;main_v[m_c-1].curs++;}
               |    lista_vector1 ','    operatii_f     {if(strcmp(main_v[m_c-1].tip, "float")!=0){diferite(main_v[m_c-1].id);};main_v[m_c-1].valori[main_v[m_c-1].curs]=$3;main_v[m_c-1].curs++;}
if_list   :    if_statement        
          |    if_list if_statement
          |    if_declaratie             
          |    if_list if_declaratie  
          ;
if_statement :   ID ASSIGN ID ';'       
                              {    if(valoare_de_adevar){
                                        char valoare[20],scope1[20],scope2[20];      
                                   if(exista_variabila($1,"local")){
                                        
                                        if(exista_variabila($3,"local")){
                                             ia_scope($1,scope1,"local");  
                                             ia_scope($3,scope2,"local");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2)){
                                                       ia_valoare($3,valoare,scope2);
                                                       assign($1,valoare,scope1);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
                                   
                              } 
               |    ID ASSIGN operatii_i ';'             
                                        {
                                             if(valoare_de_adevar){
                                                  char valoare[20],scope[20];
                                               if(exista_variabila($1,"main")){
                                                    ia_scope($1,scope,"main");
                                                         if(id_acelasi_tip_cu_tip($1,scope,"int")){
                                                              itoa($3,valoare);
                                                                  assign($1,valoare,scope);
                                                         }else{
                                                               diferite($1);
                                                               }
                                                        }else{
                                                            var_nedecl($1);
                                                         }
                                             }
                                              
                                        }
               |    ID ASSIGN operatii_f ';'{
                                                  if(valoare_de_adevar){
                                                       char valoare[20],scope[20];
                                                  if(exista_variabila($1,"local")){
                                                        ia_scope($1,scope,"local");
                                                        if(id_acelasi_tip_cu_tip($1,scope,"float")){
                                                               itoa($3,valoare);
                                                              assign($1,valoare,scope);
                                                                  }else{
                                                                   diferite($1);
                                                                        }
                              
                                                             }else{
                                                                var_decl($1);
                                                              } 
                                                  }
                                                 
               }
               //|    ID ASSIGN operatie_b ';'
               |    ID ASSIGN SIR ';'
                              {
                                   if(valoare_de_adevar){
                                        char scope[20];
                                  
                                   if(exista_variabila($1,"local")){
                                        
                                        ia_scope($1,scope,"local");
                                        
                                        if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                             
                                             assign($1,$3,scope);
                                        }else{
                                             diferite($1);
                                        }

                                   }else{
                                        var_nedecl($1);
                                   }
                                   }
                                   
                              }
               |     ID ASSIGN ID '.' ID      
                                   {
                                        if(valoare_de_adevar){
                                             if(exista_variabila($1,"main")){
                                             if(exista_variabila($3,"main")){
                                                  if(exista_variabila_create_in_variabila($5,$3,"main")){
                                                       char scope[20],valoare[20];
                                                       ia_scope($1,scope,"main");              //luam scope-ul variabilei $1
                                                       ia_valoare_create($3,$5,valoare);
                                                       assign($1,valoare,scope);
                                                      
                                                  }else{
                                                       var_nedecl($5);
                                                  }
                                             }else{
                                                  var_nedecl($3);
                                             }
                                        }else{
                                                  var_nedecl($1);
                                             }
                                        
                                        
                              
                                        }
                                        

                                   }
                    |    ID '.' ID ASSIGN NR 
                                   {
                                        if(valoare_de_adevar){
                                             if(exista_variabila($1,"main")){
                                             if(exista_variabila_create_in_variabila($3,$1,"main")){
                                                  char val[20];
                                                  itoa($5,val); 
                                                  assign_val_to_create($1,$3,val); 
                                             }else{
                                                  var_nedecl($3);
                                             }
                                        }else {
                                             var_nedecl($1);
                                        }
                                        
                                        }
                                        
                                   }
               |    assign_ID_l ';'     
               |    EVAL '(' operatii_i ')' ';'                                      {printf("Eval:%d\n",$3);}
               |    ID '(' ')' ';'                
               |    ID '(' param_apel ')' ';'
               |    operatie_string_l ';'
               ;
if_declaratie     :    TIP ID ';'               
                              {    if(valoare_de_adevar){
                                        int constanta=0;
                                        pune_variabila($2,$1,"NULL","local", constanta);
                              }
                                   
                              }          
               | TIP ID ASSIGN operatii_i ';'
                                   {     
                                        if(valoare_de_adevar){
                                             if(strcmp($1, "int")!=0){
                                             diferite($2);
                                        }
                                        int constanta=0;
                                        char val[20];
                                        itoa($4,val);pune_variabila($2,$1,val,"local", constanta);

                                        }
                                        
                                   }
               | TIP ID ASSIGN operatii_f ';' 
                                   {    
                                        if(valoare_de_adevar){
                                             if(strcmp($1, "float")!=0){
                                                  diferite($2);
                                        }
                                             int constanta=0;
                                             char val[20];
                                             itoa($4,val);
                                             pune_variabila($2,$1,val,"local", constanta);

                                        }
                                        
                                   }
               
               | CONST TIP ID ASSIGN operatii_i ';' 
                                   {
                                        if(valoare_de_adevar){
                                             if(strcmp($2, "int")!=0){
                                                  diferite($3);
                                             }
                                              int constanta=1;char val[20];itoa($5,val);pune_variabila($3,$2,val,"local", constanta);
                                        }
                                        
                                   } 
               | CONST TIP ID ASSIGN operatii_f ';' 
                                   {
                                        if(valoare_de_adevar){
                                             if(strcmp($2, "float")!=0){
                                                  diferite($3);
                                             }
                                              int constanta=1;char val[20];itoa($5,val);pune_variabila($3,$2,val,"local", constanta);
                                        }
                                        
                                   }
              ;

else_list :    else_statement        
          |    else_list else_statement
          |    else_declaratie             
          |    else_list else_declaratie  
          ;
else_statement :   ID ASSIGN ID ';'       
                              {    if(!valoare_de_adevar){
                                        char valoare[20],scope1[20],scope2[20];      
                                   if(exista_variabila($1,"local")){
                                        
                                        if(exista_variabila($3,"local")){
                                             ia_scope($1,scope1,"local");  
                                             ia_scope($3,scope2,"local");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2)){
                                                       ia_valoare($3,valoare,scope2);
                                                       assign($1,valoare,scope1);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
                                   
                              } 
               |    ID ASSIGN operatii_i ';'             
                                        {
                                             if(!valoare_de_adevar){
                                                  char valoare[20],scope[20];
                                               if(exista_variabila($1,"local")){
                                                    ia_scope($1,scope,"local");
                                                         if(id_acelasi_tip_cu_tip($1,scope,"int")){
                                                              itoa($3,valoare);
                                                                  assign($1,valoare,scope);
                                                         }else{
                                                               diferite($1);
                                                               }
                                                        }else{
                                                            var_nedecl($1);
                                                         }
                                             }
                                              
                                        }
               |    ID ASSIGN operatii_f ';'{
                                                  if(!valoare_de_adevar){
                                                       char valoare[20],scope[20];
                                                  if(exista_variabila($1,"local")){
                                                        ia_scope($1,scope,"local");
                                                        if(id_acelasi_tip_cu_tip($1,scope,"float")){
                                                               itoa($3,valoare);
                                                              assign($1,valoare,scope);
                                                                  }else{
                                                                   diferite($1);
                                                                        }
                              
                                                             }else{
                                                                var_decl($1);
                                                              } 
                                                  }
                                                 
               }
               //|    ID ASSIGN operatie_b ';'
               |    ID ASSIGN SIR ';'
                              {
                                   if(!valoare_de_adevar){
                                        char scope[20];
                                  
                                   if(exista_variabila($1,"local")){
                                        
                                        ia_scope($1,scope,"local");
                                        
                                        if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                             
                                             assign($1,$3,scope);
                                        }else{
                                             diferite($1);
                                        }

                                   }else{
                                        var_nedecl($1);
                                   }
                                   }
                                   
                              }
               |     ID ASSIGN ID '.' ID      
                                   {
                                        if(!valoare_de_adevar){
                                             if(exista_variabila($1,"local")){
                                             if(exista_variabila($3,"local")){
                                                  if(exista_variabila_create_in_variabila($5,$3,"local")){
                                                       char scope[20],valoare[20];
                                                       ia_scope($1,scope,"local");              //luam scope-ul variabilei $1
                                                       ia_valoare_create($3,$5,valoare);
                                                       assign($1,valoare,scope);
                                                       
                                                  }else{
                                                       var_nedecl($5);
                                                  }
                                             }else{
                                                  var_nedecl($3);
                                             }
                                        }else{
                                                  var_nedecl($1);
                                             }
                                        
                                        
                              
                                        }
                                        

                                   }
                    |    ID '.' ID ASSIGN NR 
                                   {
                                        if(!valoare_de_adevar){
                                             if(exista_variabila($1,"local")){
                                             if(exista_variabila_create_in_variabila($3,$1,"local")){
                                                  char val[20];
                                                  itoa($5,val); 
                                                  assign_val_to_create($1,$3,val); 
                                             }else{
                                                  var_nedecl($3);
                                             }
                                        }else {
                                             var_nedecl($1);
                                        }
                                        
                                        }
                                        
                                   }     
               |    ID '(' ')' ';'                
               |    ID '(' param_apel ')' ';'
               |    EVAL '(' operatii_i ')' ';'                                                {printf("Eval:%d\n",$3);}
               |    operatie_string_l ';'
               
               ;
else_declaratie     :    TIP ID ';'               
                              {    if(!valoare_de_adevar){
                                        int constanta=0;
                                        pune_variabila($2,$1,"NULL","local", constanta);
                              }
                                   
                              }          
               | TIP ID ASSIGN operatii_i ';'
                                   {     
                                        if(!valoare_de_adevar){
                                             if(strcmp($1, "int")!=0){
                                             diferite($2);
                                        }
                                        int constanta=0;
                                        char val[20];
                                        itoa($4,val);pune_variabila($2,$1,val,"local", constanta);

                                        }
                                        
                                   }
               | TIP ID ASSIGN operatii_f ';' 
                                   {    
                                        if(!valoare_de_adevar){
                                             if(strcmp($1, "float")!=0){
                                                  diferite($2);
                                        }
                                             int constanta=0;
                                             char val[20];
                                             itoa($4,val);
                                             pune_variabila($2,$1,val,"local", constanta);

                                        }
                                        
                                   }
               | CONST TIP ID ASSIGN operatii_i ';' 
                                   {
                                        if(!valoare_de_adevar){
                                             if(strcmp($2, "int")!=0){
                                                  diferite($3);
                                             }
                                              int constanta=1;char val[20];itoa($5,val);pune_variabila($3,$2,val,"local", constanta);
                                        }
                                        
                                   } 
               | CONST TIP ID ASSIGN operatii_f ';' 
                                   {
                                        if(!valoare_de_adevar){
                                             if(strcmp($2, "float")!=0){
                                                  diferite($3);
                                             }
                                              int constanta=1;char val[20];itoa($5,val);pune_variabila($3,$2,val,"local", constanta);
                                        }
                                        
                                   }
              ;


statement :    ID ASSIGN ID ';'              
                              {    
                                   char valoare[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"global")){
                                        
                                        if(exista_variabila($3,"global")){
                                             ia_scope($1,scope1,"global");  
                                             ia_scope($3,scope2,"global");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2)){
                                                       ia_valoare($3,valoare,scope2);
                                                       assign($1,valoare,scope1);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
          |    ID ASSIGN operatii_i ';'
                              {
                                   char valoare[20],scope[20];
                                  
                                   if(exista_variabila($1,"global")){
                                        
                                        ia_scope($1,scope,"global");
                                        
                                        if(id_acelasi_tip_cu_tip($1,scope,"int")){
                                             itoa($3,valoare);
                                             assign($1,valoare,scope);
                                        }else{
                                             diferite($1);
                                        }

                                   }else{
                                        var_nedecl($1);
                                   }
                              }
          |    ID ASSIGN operatii_f ';'
                              {
                                   char valoare[20],scope[20];
                                  
                                   if(exista_variabila($1,"global")){
                                        
                                        ia_scope($1,scope,"global");
                                        
                                        if(id_acelasi_tip_cu_tip($1,scope,"float")){
                                             itoa($3,valoare);
                                             assign($1,valoare,scope);
                                        }else{
                                             diferite($1);
                                        }

                                   }else{
                                        var_nedecl($1);
                                   }

                              }
          |    ID ASSIGN SIR ';'
                              {
                                   char scope[20];
                                  
                                   if(exista_variabila($1,"global")){
                                        
                                        ia_scope($1,scope,"global");
                                        
                                        if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                             
                                             assign($1,$3,scope);
                                        }else{
                                             diferite($1);
                                        }

                                   }else{
                                        var_nedecl($1);
                                   }
                              }
          |    operatii_i ';'
          |    operatii_f ';'
         
          |    operatie_string_g ';'
          |    EVAL '(' operatii_i ')' ';'                                                     {printf("Eval:%d\n",$3);}
          |    assign_ID_g ';'
          ;
operatie_string_l    :    ID ASSIGN CONCAT '(' SIR ',' SIR ')'     
                                             {
                                                  char scope[20];
                                                  char concat[100];
                                                  if(exista_variabila($1,"local")){

                                                       ia_scope($1,scope,"local");

                                                       if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                                            strcpy(concat,strcat($5,$7));
                                                            
                                                            assign($1,concat,scope);
                                                       }else{
                                                            diferite($1);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                                  
                                             }
                  //  |    COMPARE'(' SIR ',' SIR ')' 
                    ;
operatie_string_m     :    ID ASSIGN CONCAT '(' SIR ',' SIR ')'     
                                             {
                                                  char scope[20];
                                                  char concat[100];
                                                  
                                                  if(exista_variabila($1,"main")){

                                                       ia_scope($1,scope,"main");

                                                       if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                                            strcpy(concat,strcat($5,$7));
                                                            
                                                            assign($1,concat,scope);
                                                       }else{
                                                            diferite($1);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                                  
                                             }
                  //  |    COMPARE'(' SIR ',' SIR ')' 
                    ;
operatie_string_f     :    ID ASSIGN CONCAT '(' SIR ',' SIR ')'     
                                             {
                                                  char scope[20];
                                                  char concat[100];
                                                  
                                                  if(exista_variabila($1,"func")){

                                                       ia_scope($1,scope,"func");

                                                       if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                                            strcpy(concat,strcat($5,$7));
                                                            
                                                            assign($1,concat,scope);
                                                       }else{
                                                            diferite($1);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                                  
                                             }
                  //  |    COMPARE'(' SIR ',' SIR ')' 
                    ;
operatie_string_g     :    ID ASSIGN CONCAT '(' SIR ',' SIR ')'     
                                             {
                                                  char scope[20];
                                                  char concat[100];
                                                 
                                                  if(exista_variabila($1,"global")){

                                                       ia_scope($1,scope,"global");

                                                       if(id_acelasi_tip_cu_tip($1,scope,"string")){
                                                            strcpy(concat,strcat($5,$7));
                                                            
                                                            assign($1,concat,scope);
                                                       }else{
                                                            diferite($1);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                                  
                                             }
                  //  |    COMPARE'(' SIR ',' SIR ')' 
                    ;

comparare_i :   NR '<' NR   { $$= $1 < $3;if($1<$3)
                                                  valoare_de_adevar=1;
                                                        else
                                                  valoare_de_adevar=0;}
               |     NR '>' NR   { $$= $1 > $3;if($1>$3)
                                                  valoare_de_adevar=1;
                                                        else
                                                  valoare_de_adevar=0;}
               |     NR LEQ NR   { $$= $1 <= $3;if($1<=$3)
                                                  valoare_de_adevar=1;
                                                        else
                                                  valoare_de_adevar=0;}
               |     NR GEQ NR   { $$= $1 >= $3;if($1>=$3)
                                                  valoare_de_adevar=1;
                                                        else
                                                  valoare_de_adevar=0;}
               |     NR EQ NR   { $$= $1 == $3;if($1==$3)
                                                  valoare_de_adevar=1;
                                                        else
                                                  valoare_de_adevar=0;}
               |     NR NEQ NR   { $$= $1 != $3;if($1!=$3)
                                                  valoare_de_adevar=1;
                                                        else
                                                  valoare_de_adevar=0;}
               ;
comparare_f     :     NR_R '<' NR_R  { $$= $1 < $3;}
               |     NR_R '>' NR_R   { $$= $1 > $3;}
               |     NR_R LEQ NR_R  { $$= $1 <= $3;}
               |     NR_R GEQ NR_R   { $$= $1 >= $3;}
               |     NR_R EQ NR_R   { $$= $1 == $3;}
               |     NR_R NEQ NR_R   { $$= $1 != $3;}
               ;
comparare_w :    ID'<' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"main")){
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                        strcpy(wh[0].id1c, $1);
                                                        strcpy(wh[0].id2c, $3);
                                                        strcpy(wh[0].opc, "<");
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       valoare_de_adevar = atoi(valoare1)<atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |  ID'>' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"main")){
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                        strcpy(wh[0].id1c, $1);
                                                        strcpy(wh[0].id2c, $3);
                                                        strcpy(wh[0].opc, ">");
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       valoare_de_adevar = atoi(valoare1)<atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
                                                

;
operatii_i     :    operatii_i '+' operatii_i           {$<number>$=$1+$3;}
               |    operatii_i '-' operatii_i           {$<number>$=$1-$3;}
               |    operatii_i '%' operatii_i           {$<number>$=$1%$3;}
               |    operatii_i '/' operatii_i           {$<number>$=$1/$3;}
               |    operatii_i '*' operatii_i           {$<number>$=$1*$3;}
               |    '(' operatii_i ')'                  {$<number>$=$2;}
               |    NR                  {$$+$1;}
               | operatii_i '+' apel_functii           {cauta(apelata);$<number>$=$1+nr;}
               
               ; 


operatii_f     :    NR_R '+' NR_R       {$$=$1+$3;}
               |    NR_R '-' NR_R       {$$=$1-$3;}
               |    NR_R '%' NR_R       {$$=$1+$3;}
               |    NR_R '/' NR_R       {$$=$1/$3;}
               |    NR_R '*' NR_R       {$$=$1*$3;}
               |    '(' operatii_f ')'  {$$=$2;}
               |    NR_R                {$$=$1;}
               ; 
operatie_b     :    TRUE {    $$=$1;    valoare_de_adevar=1;}
               |    FALSE {$$=$1;       valoare_de_adevar=0;}
               |    '!' operatie_b 
                              {
                                   $$=1-$2; 
                                   if(1-$2==0)
                                        valoare_de_adevar=0;
                                   else
                                        valoare_de_adevar=1;
                              }
               |    operatie_b '&' operatie_b 
                                        {
                                             $$=$1 && $3;
                                             if($1==1 && $3==1)
                                                  valoare_de_adevar=1;
                                             else
                                                  valoare_de_adevar=0;
                                        }
               |    operatie_b '|' operatie_b  
                                        {
                                             $$=$1 || $3;
                                             if($1==1 || $3==1)
                                                  valoare_de_adevar=1;
                                             else
                                                  valoare_de_adevar=0;
                                        }
               |    comparare_i         {$$=$1;}
               |    comparare_f         {$$=$1;}
               ;
  

functii_control     :    IF '(' conditie ')' '{' if_list '}'                                                
                    |    IF '(' conditie ')' '{' if_list '}' ELSE '{' else_list '}'          
                    |    WHILE '(' comparare_w ')' '{' while_list  '}'  {fa_while();linie_c=0;}
                    |    FOR '(' statement ';' conditie ';' ID ASSIGN operatii_i ')' '{' if_list '}' 
                    ;
conditie  :    operatie_b
          ;
while_list:    while_statement        
          |    while_list while_statement 
          ;
while_statement:   assign_ID_wh ';'
               ;
assign_ID_wh   :    ID ASSIGN operatie_ID_wh    
                                        {    
                                             char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                             if(exista_variabila($1,"main")){
                                                       ia_scope($1,scope1,"main");  
                                                       strcpy(wh[linie_c].id1ass, $1);
                                                       if(id_acelasi_tip_cu_tip($1,scope1,"int")){
                                                            itoa($3,valoare1);
                                                            assign($1,valoare1,scope1);
                                                       }else {
                                                            itoa($3,valoare2);
                                                            vars_diff($1,valoare2);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                        }
               ;       
operatie_ID_wh:     ID'+' ID
                              {if(valoare_de_adevar){

                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"main")){
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                        linie_c++;
                                                        strcpy(wh[linie_c].id2, $1);
                                                        strcpy(wh[linie_c].id3, $3);
                                                        printf("1 %d", linie_c);
                                                      strcpy(wh[linie_c].operator, "+");
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }}
               |    ID '-' ID {if(valoare_de_adevar){
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"main")){
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                        linie_c++;
                                                        strcpy(wh[linie_c].id2, $1);
                                                        strcpy(wh[linie_c].id3, $3);
                                                      strcpy(wh[linie_c].operator, "-");
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }}
                              
               |    ID '*' ID{if(valoare_de_adevar){
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"main")){
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       linie_c++;
                                                        strcpy(wh[linie_c].id2, $1);
                                                        strcpy(wh[linie_c].id3, $3);
                                                      strcpy(wh[linie_c].operator, "*");
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }}
                             
               |    ID '/' ID {if(valoare_de_adevar){
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"main")){
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                        linie_c++;
                                                        strcpy(wh[linie_c].id2, $1);
                                                        strcpy(wh[linie_c].id3, $3);
                                                      strcpy(wh[linie_c].operator, "*");
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }}
                              
               |    ID '%' ID          {if(valoare_de_adevar){
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"main")){
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                        linie_c++;
                                                        strcpy(wh[linie_c].id2, $1);
                                                        strcpy(wh[linie_c].id3, $3);
                                                      strcpy(wh[linie_c].operator, "%");
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }}  
;
assign_ID_g      :    ID ASSIGN operatie_ID_g    
                                        {    
                                             char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                             if(exista_variabila($1,"global")){
                                                       ia_scope($1,scope1,"global");  
                                                       
                                                       if(id_acelasi_tip_cu_tip($1,scope1,"int")){
                                                            itoa($3,valoare1);
                                                            assign($1,valoare1,scope1);
                                                       }else {
                                                            itoa($3,valoare2);
                                                            vars_diff($1,valoare2);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                        }
               ;         

operatie_ID_g    :    ID'+' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20];  
                                   if(exista_variabila($1,"global")){
                                        
                                        if(exista_variabila($3,"global")){
                                             ia_scope($1,scope1,"global");  
                                             ia_scope($3,scope2,"global");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '-' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"global")){
                                        
                                        if(exista_variabila($3,"global")){
                                             ia_scope($1,scope1,"global");  
                                             ia_scope($3,scope2,"global");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)-atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    } 
                              }
               |    ID '*' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"global")){
                                        
                                        if(exista_variabila($3,"global")){
                                             ia_scope($1,scope1,"global");  
                                             ia_scope($3,scope2,"global");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)*atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '/' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"global")){
                                        
                                        if(exista_variabila($3,"global")){
                                             ia_scope($1,scope1,"global");  
                                             ia_scope($3,scope2,"global");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)/atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '%' ID            
                                   {char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"global")){
                                        
                                        if(exista_variabila($3,"global")){
                                             ia_scope($1,scope1,"global");  
                                             ia_scope($3,scope2,"global");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)%atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                                   }


assign_ID_m      :    ID ASSIGN operatie_ID_m    
                                        {    
                                             char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                             if(exista_variabila($1,"main")){
                                                       ia_scope($1,scope1,"main");  
                                                       
                                                       if(id_acelasi_tip_cu_tip($1,scope1,"int")){
                                                            itoa($3,valoare1);
                                                            assign($1,valoare1,scope1);
                                                       }else {
                                                            itoa($3,valoare2);
                                                            vars_diff($1,valoare2);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                        }
               ;         

operatie_ID_m    :    ID'+' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                   if(exista_variabila($1,"main")){
                                        
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '-' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"main")){
                                        
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)-atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    } 
                              }
               |    ID '*' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"main")){
                                        
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)*atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '/' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"main")){
                                        
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)/atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '%' ID            
                                   {char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"main")){
                                        
                                        if(exista_variabila($3,"main")){
                                             ia_scope($1,scope1,"main");  
                                             ia_scope($3,scope2,"main");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)%atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                                   }

assign_ID_f      :    ID ASSIGN operatie_ID_f    
                                        {    
                                             char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                             if(exista_variabila($1,"func")){
                                                       ia_scope($1,scope1,"func");  
                                                       
                                                       if(id_acelasi_tip_cu_tip($1,scope1,"int")){
                                                            itoa($3,valoare1);
                                                            assign($1,valoare1,scope1);
                                                       }else {
                                                            itoa($3,valoare2);
                                                            vars_diff($1,valoare2);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                        }
               ;         

operatie_ID_f    :    ID'+' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"func")){
                                        
                                        if(exista_variabila($3,"func")){
                                             ia_scope($1,scope1,"func");  
                                             ia_scope($3,scope2,"func");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '-' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"func")){
                                        
                                        if(exista_variabila($3,"func")){
                                             ia_scope($1,scope1,"func");  
                                             ia_scope($3,scope2,"func");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)-atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    } 
                              }
               |    ID '*' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"func")){
                                        
                                        if(exista_variabila($3,"func")){
                                             ia_scope($1,scope1,"func");  
                                             ia_scope($3,scope2,"func");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)*atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '/' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"func")){
                                        
                                        if(exista_variabila($3,"func")){
                                             ia_scope($1,scope1,"func");  
                                             ia_scope($3,scope2,"func");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)/atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '%' ID            
                                   {char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"func")){
                                        
                                        if(exista_variabila($3,"func")){
                                             ia_scope($1,scope1,"func");  
                                             ia_scope($3,scope2,"func");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)%atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                                   }
assign_ID_l      :    ID ASSIGN operatie_ID_l    
                                        {    
                                             char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                             if(exista_variabila($1,"local")){
                                                       ia_scope($1,scope1,"local");  
                                                       
                                                       if(id_acelasi_tip_cu_tip($1,scope1,"int")){
                                                            itoa($3,valoare1);
                                                            assign($1,valoare1,scope1);
                                                       }else {
                                                            itoa($3,valoare2);
                                                            vars_diff($1,valoare2);
                                                       }

                                                  }else{
                                                       var_nedecl($1);
                                                  }
                                        }
               ;         

operatie_ID_l    :    ID'+' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"local")){
                                        
                                        if(exista_variabila($3,"local")){
                                             ia_scope($1,scope1,"local");  
                                             ia_scope($3,scope2,"local");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)+atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '-' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"local")){
                                        
                                        if(exista_variabila($3,"local")){
                                             ia_scope($1,scope1,"local");  
                                             ia_scope($3,scope2,"local");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)-atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    } 
                              }
               |    ID '*' ID
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"local")){
                                        
                                        if(exista_variabila($3,"local")){
                                             ia_scope($1,scope1,"local");  
                                             ia_scope($3,scope2,"local");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)*atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '/' ID 
                              {
                                   char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"local")){
                                        
                                        if(exista_variabila($3,"local")){
                                             ia_scope($1,scope1,"local");  
                                             ia_scope($3,scope2,"local");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)/atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                              }
               |    ID '%' ID            
                                   {char valoare1[20],valoare2[20],scope1[20],scope2[20]; 
                                  
                                    
                                   
                                   if(exista_variabila($1,"local")){
                                        
                                        if(exista_variabila($3,"local")){
                                             ia_scope($1,scope1,"local");  
                                             ia_scope($3,scope2,"local");
                                             if(au_acelasi_tip($1,scope1,$3,scope2)){
                                                  if(variabila_init($3,scope2) && variabila_init($1,scope1)){
                                                       
                                                       ia_valoare($1,valoare1,scope1);
                                                       ia_valoare($3,valoare2,scope2);
                                                       $$ = atoi(valoare1)%atoi(valoare2);
                                                  }else{
                                                       valoare_neinit($3);
                                                  }
                                             }else {
                                                 vars_diff($1,$3);
                                             }
                                                  
                                             
                                        }else{
                                             var_nedecl($3);
                                        }
                                    }else{
                                         var_nedecl($1);
                                    }
                                   }



%%
void yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");

clear_table();
yyparse();
fill_symbol_table();


} 