#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[])
{
    FILE *entrada = NULL;
    FILE *saida = NULL;
    int tc; // tempo de chegada
    int id_trans ; // id de transacção
    char oper,atr; //operação e o atributo a ser lido

    while(fscanf(stdin, "%d %d %c %c ",&tc,&id_trans,&oper,&atr) !=EOF)
    {
        
    }
    saida = freopen(argv[2], "w", stdout );
}