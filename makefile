interprete: interprete.o
	gcc -m32 -o interprete interprete.o

interprete.o: interprete.asm
	nasm -f elf -g -F stabs -o interprete.o interprete.asm -l interprete.lst
