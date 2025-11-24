# Trabajo-Practico-Organizaci-n-del-Computador

### Guia compilacion

```bash
    make codificador
```


### Explicacion Codificación


```c
void codificar(const unsigned char* input, int input_size, char* output);
```  

input      → RDI  
inputSize  → RSI  
output     → RDX  

después se pasan a los registros r8, r9 y rcx.

```asm
mov rax, rcx
    mov rbx, 3
    xor rdx, rdx
    div rbx
```
este bloque calcula la division entera por 3  
`div rbx` divide el entero formado por rdx:rax  
rax es el inputsize en este caso y rbx 3  
`xor rdx, rdx` hace que rdx valga 0 y la division solo sea a rax.

---
`procesar_bloques` es un bloque que se encarga de cargar los btes y armar los grupos de 6 bits, aparte delega el tratamiento del resto a `procesar_resto`  

se dividen los 3 bytes en: 
- g0 = bits 7..2 del primer byte
- g1 = (2 bits del primer byte) y (4 bits altos del segundo byte)
- g2 = (4 bits bajos del segundo byte) y (2 bits altos del tercero)
- g3 = últimos 6 bits del tercer byte

```
B0:(aaaaaabb)
B1:(bbbbcccc)
B2:(ccdddddd)

g0 = aaaaaa
g1 = bbbb bb
g2 = cc cccc
g3 = dddddd
```
con `mov dl, [tablaCodificada + rdx]` se carga en dl el caracter que corresponde  

en cada grupo de 6 bits se acomodan los bits para que queden en las posiciones correctas  

al final se avanzan los punteros para poder repetir el bucle.

--- 

`procesar_resto` decide como seguir segun el caso.

---

`caso_un_byte` y `caso_dos_bytes` son el mismo proceso que antes solo que se reemplaza con un "=" segun corresponda

esto es para tratar los casos en los que se necesita un padding para cumplir con la regla de base64 de generar siempre 4 caracteres.