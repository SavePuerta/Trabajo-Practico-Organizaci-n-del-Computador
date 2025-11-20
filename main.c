#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>


void openFile(char* nombreArchivo){
    FILE* archivo = fopen(nombreArchivo,"r");

    fclose(archivo);

}


void closeFile(){
    FILE* archivo = fopen("outputTexto.txt","w");

    fclose(archivo);
}


int main(int argc, const char* argv[]){

    openFile(argv[2]);

    closeFile();
    return 0;
}
























