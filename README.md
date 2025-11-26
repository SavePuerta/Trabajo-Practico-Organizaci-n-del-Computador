# Trabajo-Practico-Organizaci-n-del-Computador

### Guia compilacion

```bash
    make start
```

### Explicacion Codificación

```c
void codificar(const unsigned char* input, int input_size, char* output);
```  

input      -> RDI  
inputSize  -> RSI  
output     -> RDX  

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

---

### Explicacion Decodificación

```c
void decodificar(const char* input, int input_size, unsigned char* output);
```
--- 

La tabla de decodificacion es:
- Un array de 256 bytes, uno por cada posible valor ASCII.
- Cada posición corresponde al valor ASCII de un carácter.
- Si el carácter es válido en Base64, la posición contiene su valor (0–63).
- Si el carácter no es válido, está el 255 para ignorarlo.
- El carácter de padding '=' tiene el valor 254 para identificarlo aparte.

input      -> RDI  
inputSize  -> RSI  
output     -> RDX  

La función decodificar toma una cadena en base64 y la convierte en datos binarios.  
Primero, cada carácter base64 se traduce a su valor numérico usando la tabla.  
Luego, cada grupo de 4 caracteres base64 se transforma en 3 bytes originales, rearmando los bits según la especificación base64.  
```asm 
movzx ebx, byte [tablaDecodificada + rax]
```  

Usa un loop parecido al codificador:

```asm 
loop_decodificar:
    cmp r11, r9
    jae finalizar_decodificacion

    movzx eax, byte [r8 + r11]
    cmp al, '='
    je padding

    movzx ebx, byte [tablaDecodificada + rax]
    cmp bl, 255
    je saltear_invalido

    mov [rsp + r12], bl
    inc r12

```


---

Para cada grupo de 4 caracteres realiza:

- Traducción de cada carácter base64 a su valor numérico con la tabla `tablaDecodificada`.
- Se agrupan los valores en bloques de 4 para reconstruir los 3 bytes originales.
- Para cada grupo:
  - El primer byte se arma con los 6 bits altos del primer valor y los 2 bits altos del segundo.
  - El segundo byte se arma con los 4 bits bajos del segundo valor y los 4 bits altos del tercero.
  - El tercer byte se arma con los 2 bits bajos del tercer valor y los 6 bits del cuarto valor.

Si el grupo contiene caracteres de padding `=`, se ajusta el proceso para reconstruir correctamente los últimos bytes, ignorando los valores extra.

---

Por ejemplo, para un grupo de 4 caracteres base64:

```
C0 C1 C2 C3
```
Se decodifican a valores V0, V1, V2, V3 y se reconstruyen así:

- Byte1: (V0 << 2) | (V1 >> 4)
- Byte2: ((V1 & 0x0F) << 4) | (V2 >> 2)
- Byte3: ((V2 & 0x03) << 6) | V3

---

El método ignora caracteres inválidos y termina el procesamiento al encontrar el padding.
