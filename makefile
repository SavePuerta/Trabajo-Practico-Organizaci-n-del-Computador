start:
	cd ./src && gcc main.c -o main && ./main

codificador:
	cd src && \
	nasm -f elf64 -g -F dwarf -o codificador.o codificador.asm && \
	gcc -c main.c -o main.o && \
	gcc -no-pie -z noexecstack -o codificador main.o codificador.o && \
	./codificador