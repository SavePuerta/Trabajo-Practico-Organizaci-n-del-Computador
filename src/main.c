#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void codificar(const unsigned char* input, int input_size, char* output);

unsigned char* leer_archivo(const char* nombre, size_t* file_size) {
    FILE* file = fopen(nombre, "rb");
    if (!file) {
        printf("Error: No se pudo abrir %s\n", nombre);
        return NULL;
    }
    
    fseek(file, 0, SEEK_END);
    *file_size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    unsigned char* buffer = (unsigned char*)malloc(*file_size);
    if (!buffer) {
        fclose(file);
        return NULL;
    }
    
    size_t read_bytes = fread(buffer, 1, *file_size, file);
    if (read_bytes != *file_size) {
        free(buffer);
        fclose(file);
        return NULL;
    }
    
    return buffer;
    // buffer es el texto binario del archivo
}

int escribir_archivo_de_texto(const char* nombre, const char* data) {
    FILE* file = fopen(nombre, "w");
    if (!file) {
        printf("Error: No se pudo crear %s\n", nombre);
        return 0;
    }
    
    fprintf(file, "%s", data);
    fclose(file);
    return 1;
}

void codificar_archivo() {
    size_t input_size;
    unsigned char* input_data = leer_archivo("codificacion.bin", &input_size);
    
    if (!input_data) {
        printf("Error: No se pudo leer inputBinario.bin\n");
        return;
    }
    
    // sumo dos a el tamaño para redondear hacia arriba porque la division binaria no redondea
    // al dividir entre 3 da el número de grupos de 3 bytes que hay en el archivo
    //(1-3 bytes -> 1 grupo, 4-6 bytes -> 2 grupos, 7-9 bytes -> 3 grupos, etc)
    // la multiplicación por 4 es porque cada grupo de 3 bytes se convierte en 4 caracteres base64
    // el +1 es para el carácter nulo al final de la cadena
    size_t output_size = ((input_size + 2) / 3) * 4 + 1;
    char* output_data = (char*)malloc(output_size);
    
    if (!output_data) {
        free(input_data);
        printf("Error: Memoria insuficiente\n");
        return;
    }
    
    //input_data, input_size, output_data
    codificar(input_data, input_size, output_data);
    
    // if (write_text_file("outputTexto.txt", output_data)) {
    //     printf("Archivo codificado exitosamente: outputTexto.txt\n");
    // }
    
    free(input_data);
    free(output_data);
}


int main() {
    
    printf("=== Codificador/Decodificador ===\n");
    printf("1. Codificar\n");
    printf("2. Decodificar\n");
    printf("Seleccione opcion: ");
    
    int opcion = scanf("%d", &opcion);
        
    
    switch (opcion) {
        case 1:
            codificar_archivo();
            break;
        case 2:
            //decodificar_archivo();
            break;
        default:
            printf("Opcion invalida\n");
            break;
    }
    
    return 0;
}