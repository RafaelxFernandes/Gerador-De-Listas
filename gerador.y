%{
    #include <string>
    #include <stdio.h>
    #include <stdlib.h>
    #include <iostream>

    using namespace std;

    extern "C" int yylex();

    #define YYSTYPE Atributos

    int linha = 1;
    int coluna = 1;
    int numeroNos = 0;

    struct Atributos{
        string head;
        string codigo;
    };

    struct Lista{
        bool sublista;
        string valorString;
        Lista* valorSublista;
        Lista* proximo;
    };

    int yylex();
    int yyparse();
    void yyerror(const char *);

    Atributos gera_codigo_atomo(Atributos s1);
    Atributos gera_ultimo_elemento(Atributos s1);
    Atributos gera_lista_vazia();
    Atributos gera_novo_elemento(Atributos s1, Atributos s3);
    Atributos gera_subLista(Atributos s1);

    void imprime_saida(Atributos s1);
%}

%start S

%token ATOMO

%%

S   : L             {imprime_saida($1);}
    | N             {imprime_saida($1);}
    ;

N   : F ',' LE      {$$ = gera_novo_elemento($1, $3);}
    | F
    ;

L   : '(' LE ')'    {$$ = $2;}
    | '(' ')'       {$$ = gera_lista_vazia();}
    ;

LE  : E ',' LE      {$$ = gera_novo_elemento($1, $3);}
    | E             {$$ = gera_ultimo_elemento($1);}
    ;

E   : L             {$$ = gera_subLista($1);}
    | F
    ;

F   : ATOMO         {$$ = gera_codigo_atomo($1);}
    ;

%%

#include "lex.yy.c"

Atributos gera_subLista(Atributos s1){
    Atributos ss;

    ss.head = "l" + to_string(numeroNos++);

    ss.codigo = s1.codigo + "\n"
                + ss.head + "->sublista = true;\n"
                + ss.head + "->valorString = \"\";\n"
                + ss.head + "->valorSublista = " 
                + s1.head + ";\n";
            
    return ss;
}

Atributos gera_novo_elemento(Atributos s1, Atributos s3){
    Atributos ss;

    ss.codigo = s1.codigo
                + s1.head + "->proximo = " 
                + s3.head + ";\n\n"
                + s3.codigo;
    ss.head = s1.head;

    return ss;
}

Atributos gera_ultimo_elemento(Atributos s1){
    Atributos ss;

    ss.codigo = s1.codigo
                + s1.head + "->proximo = nullptr;\n";
    
    ss.head = s1.head;

    return ss;
}

Atributos gera_lista_vazia(){
    Atributos ss {"nullptr", ""};

    return ss;
}

Atributos gera_codigo_atomo(Atributos s1){
    Atributos ss;

    ss.head = " l" + to_string(numeroNos++);

    ss.codigo = ss.head + "->sublista = false;\n"
                + ss.head + "->valorString = \"" 
                + s1.head + "\";\n"
                + ss.head + "->valorSublista = nullptr;\n";
    
    return ss;
}

void imprime_saida(Atributos s1){
    cout << "#include <string>" << endl
         << endl
         << "using namespace std;" << endl
         << endl
         << "struct Lista {" << endl
         << "  bool sublista;" << endl
         << "  string valorString;" << endl
         << "  Lista *valorSublista;" << endl
         << "  Lista *proximo;" << endl
         << "};\n" 
         << endl
         << "Lista* geraLista() {"
         << endl;

    for(int i = 0; i < numeroNos; i++){
        cout << " Lista* l" << i << " = new Lista();\n";
    }

    cout << "\n" + s1.codigo << endl;
    cout << " return " << s1.head << ";" << endl << "}" << endl;
}

void yyerror(const char* mensagem){
    puts(mensagem);

    cout << "Linha " << linha
         << " , coluna " << coluna - yyleng
         << " , proximo a " << yytext << endl;
    exit(0);
}

// >>> REMOVER <<<
int main( int argc, char* argv[] ) {
    yyparse();
}