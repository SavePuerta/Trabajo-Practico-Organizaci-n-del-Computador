start:
	make codificador

codificador:
	cd src && \
	nasm -f elf64 -g -F dwarf -o codificador.o codificador.asm && \
	nasm -f elf64 -g -F dwarf -o decodificador.o decodificador.asm && \
	gcc -c main.c -o main.o && \
	gcc -no-pie -z noexecstack -o programa main.o codificador.o decodificador.o && \
	./programa 
