;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;esto es para hacer el codigo mas legible
sys_exit equ 1
sys_read equ 3
sys_write equ 4
sys_open equ 5
stdin equ 0
stdout equ 1

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
section .data

; mensajes de errores 
msgPrueba: db "Entro a mostrar",10,0
msgError1: db "Comando invalido",10,0
msgError2: db "Falta el nombre del archivo",10,0
msgError3: db "Se introdujo un tercer parametro inválido",10,0
msgError4: db "Solo puede digitar 1 o 2",10,0
msgError5: db "Opcion invalida",10,0
msgError6: db "Falta un tercer parametro el nuevo nombre del archivo",10,0
msgError7: db "Falta un tercer párametro el nombre del segundo archivo a ser comparado",10,0
msgError8: db "Error al abrir no existe el archivo ",0
msgError9: db "Digite solo salir sin ningun otro caracter o espacio",10,0
msgDiferencia: db "Diferencia en la línea %d",10,0
msgIguales: db "Los archivos son iguales",10,0
enter: db 10,0
lenEnter: equ $-enter
promp: db "cli> "
lenPromp: equ $-promp
;mensajes de pregunta al usuario si esta seguro de ejecutar el comando
msgBorrarNormal: db "Esta seguro de que desea borrar el archivo",10,"1:Si                   2:No",10,0
msgRenombrarNormal: db "Esta seguro de que desea renombrar el archivo",10,"1:Si                   2:No",10,0
;mensajes de ayuda de cada comando donde aparece la descripcion del mismo
msgAyudaBorrar: db "Este comando recibe como parametro el nombre del archivo que se desea borrar",10,"Este lanzara una pregunta para verificar que el usuario estÃ¡ seguro ",10, "de que desea eliminar el archivo por completo si la respuesta es afirmativa",10,"procede con la eliminaciÃ³n y en caso contrario finaliza su ejecuciÃ³n.",10,"El argumento opcional --forzado tiene como objetivo omitir la pregunta de",10,"verificaciÃ³n,en otras palabras elimina el archivo sin solicitar la confirmacion.",10,0
msgAyudaMostrar: db "Este programa recibe como parámetro el nombre de un archivo",10,"(nombre-archivo), cuyo contenido será mostrado en la pantalla (salida estándar)",10,0
msgAyudaRenombrar: db "Los argumentos del programa son los nombres de los archivos involucrados,",10,"el archivo que debe existir en la ruta disponible al prompt será nombre-archivo-original",10,"y se le asignará por nombre el que se haya ingresado como argumento nombre-archivo-nuevo.",10,"cada vez que se utilice este comando, para omitirlo se puede utilizar el argumento --forzado",10,0
msgAyudaCopiar: db "Los argumentos del programa son, el nombre del archivo que será",10,"copiado nombre-archivo-original y el nombre que tendrá el","nuevo archivo por crear nombre-archivo-nuevo.",10,0
msgAyudaComparar: db "Dados dos nombres de archivo existentes, los compara línea",10," por línea mostrando como salida los números de línea donde los archivos son diferentes,",10,"en caso de ser idénticos (por ejemplo cuando se usa el mismo archivo)",10,"no deberia de imprimirse nada pues son identicos",10,0


section .bss ;datos no inicializados
lenComando equ 100
comando resb lenComando
lenNombreArchivo equ 50
nombreArchivo1 resb lenNombreArchivo
nombreArchivo2 resb lenNombreArchivo
lenContenidoArchivo equ 15000
contenidoArchivo1 resb lenContenidoArchivo
contenidoArchivo2 resb lenContenidoArchivo
lenArchivo1 resb 1
lenArchivo2 resb 1
respuesta resb 1
lenNumero equ 4
numeroLineas resb lenNumero

section .text

extern printf
global main:


main:

nop; mantiene el gdb feliz


; labores de "mantenimiento" - previas
push ebp			
mov	ebp, esp

introduccionComando: ;promp
mov ecx,promp ;se despliega el "cli>" para introducir comandos
mov edx,lenPromp
call DisplayText

mov ecx,comando ;leer comando
mov edx,lenComando
call ReadText

xor eax,eax;se limpia el registro eax para eliminar basura
mov al,byte[comando];se mueve el primer byte del comando introducido para identificar cual se introdujo
cmp al,"b"
je verificarBorrar
cmp al,"m"
je verificarMostrar
cmp al,"r"
je verificarRenombrar
cmp al,"c"
je verificarComandosC
cmp al,"s"
je verificarSalir
jne introduccionComando;si la primera inicial del comando introducido no es ninguno de los anteriores significa que se no se introdujo un comando valido y vuelve al comiezo 

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

verificarBorrar:
;se verifica byte por byte del buffer donde esta el comando para comprobar que se introdujo correctamente borrar de no ser asi saltara a error 
mov al,byte[comando + 1]
cmp al,"o"
jne error
mov al,byte[comando + 2]
cmp al,"r"
jne error
mov al,byte[comando + 3]
cmp al,"r"
jne error
mov al,byte[comando + 4]
cmp al,"a"
jne error
mov al,byte[comando + 5]
cmp al,"r"
jne error
mov al,byte[comando + 6]
cmp al,10;se compara con un enter para saber si solo se introdujo el comando y luego presionaron enter esto quiere decir que no se introdujo el nombre del archivo
je error2 ;despliegara un error 
cmp al," "
jne error
mov al,byte[comando + 7]
cmp al,"-"
mov ebx,7;ebx tiene la posicion actual del buffer
je verificarAyuda1
cmp al,10
je error2
mov ecx,0;contador

cicloNombreArchivo1:
;se introduce el nombre del archivo en el buffer correspondiente
mov al,byte[comando +  ebx];al tendra el byte de la posicion donde quedo anteriormente
cmp al,10
je borrarNormal
cmp al," ";si existe un espacio se debe verificar la existencia de un forzado
je verificarForzado1
mov byte[nombreArchivo1 + ecx],al;se va introduciendo byte por byte el nombre del archivo en el buffer
inc ecx;se incrementa el contador
inc ebx; se incrementan los espacios en el buffer del comando
jmp cicloNombreArchivo1


borrarNormal:
mov byte[nombreArchivo1 + ecx],0; al final del nombre del archivo se introduce un 0 para que sirva

respuestaBorrar:
;se despliega un mensaje donde se le pregunta al usuario si esta seguro de que desea borrar el archivo indicado por medio del printf
push msgBorrarNormal;se imprime el mensaje
call printf
add esp,4;se elimina basura de la pila
mov ecx,respuesta
mov edx,100
call ReadText;se lee la respuesta
cmp eax,2 ;si se digitaron mas de dos caracteres(numero de la opcion y el enter) despliega un error
jne digitoMas1


; se compara el primer byte del buffer respuesta con un 1 o un 2 y sino dara un mensaje de respuesta incorrecta
xor eax,eax;se limpia para eliminar basura
mov al,byte[respuesta]
cmp al,"1"
je borrar;si la respuesta fue 1 ira a borrar 
cmp al,"2"
je introduccionComando;si fue 2 significa que digito 'no' e ira a introduccion de comando
jmp respuestaIncorrecta1


borrar:
;se borra del sistema un archivo .txt indicado por el usuario
mov eax,10 ;eax tendra la interrupcion 10 unlink
mov ebx,nombreArchivo1;ebx tendra el nombre del archivo1
xor ecx,ecx ;se limpian registros para evitar errores
xor edx,edx
int 80h ;interrupcion del sistema

test eax,eax
js errorAbrir1
call LimpiarArchivos
jmp introduccionComando ;vuelve a introducir un nuevo comando

verificarForzado1:
;se verifica la introduccion del parametro --forzado byte por byte , de ser introducido mal indicara un mensaje de error en pantalla
mov byte[nombreArchivo1 + ecx],0; al final del nombre del archivo se introduce un 0 para que sirva
inc ebx;se incrementa la posicion en el buffer comando
mov al,byte[comando + ebx]
cmp al,"-"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"f"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"o"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"r"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"z"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"d"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"o"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,10
jne error
jmp borrar ;si se introdujo el parametro correctamente ira a borrar el archivo del sistema

verificarAyuda1:
;se verifica byte por byte por medio de comparaciones la introduccion del parametro  --ayuda ,de ser introducido mal indicara un mensaje de error al usuario
inc ebx;se incrementa la posicion del buffer comando para seguir con las comparaciones
mov al,byte[comando + ebx]
cmp al,"-"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"y"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"u"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"d"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error

borrarAyuda:
;si el parametro --ayuda fue introducido se despliega un mensaje en pantalla con una especificacion del funcionamiento de dicho comando
push msgAyudaBorrar ;se imprime el mensaje
call printf
add esp,4;se elimina basura de la pila
jmp introduccionComando;vuelve a la introduccion de un nuevo comando

digitoMas1:
;se imprime un mensaje de error de que solo se puede digitar un '1' o un '2'
push msgError4;se imprime el mensaje
call printf
add esp,4;se elimina basura de la pila
jmp respuestaBorrar;vuelve a que se imprima el mensaje de si esta seguro de ejecutar el comando

respuestaIncorrecta1:
;mensaje de error de "respuesta invalida"
push msgError5;se imprime el mensaje
call printf
add esp,4;se elimina basura de la pila
jmp respuestaBorrar ;regresa a respuestaBorrar

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


verificarMostrar:
;se verifica byte por byte del buffer donde esta el comando para comprobar que se introdujo correctamente mostrar de no ser asi saltara a error
mov al,byte[comando + 1]
cmp al,"o"
jne error
mov al,byte[comando + 2]
cmp al,"s"
jne error
mov al,byte[comando + 3]
cmp al,"t"
jne error
mov al,byte[comando + 4]
cmp al,"r"
jne error
mov al,byte[comando + 5]
cmp al,"a"
jne error
mov al,byte[comando + 6]
cmp al,"r"
jne error
mov al,byte[comando + 7]
cmp al,10;se compara con un enter para saber si solo se introdujo el comando y luego presiono enter esto quiere decir que no se introdujo el nombre del archivo y se le indica al usuario por medio de un error
je error2
cmp al," "
jne error
mov al,byte[comando + 8]
cmp al,"-"
mov ebx,8;ebx tiene la posicion actual del buffer
je verificarAyuda2;si hay un '-' se verifica la existencia del parametro --ayuda
cmp al,10
je error2
mov ecx,0;contador

cicloNombreArchivo2:
;se introduce el nombre del archivo byte por byte en el buffer correspondiente
mov al,byte[comando +  ebx];al tendra el byte de la posicion donde quedo anteriormente
cmp al,10
je mostrar;se compara con un enter para saber si termino el nombre del archivo y va a mostrar
cmp al," ";si hay un espacio ira a un error
je error3
mov byte[nombreArchivo1 + ecx],al;se introduce byte por byte el nombre del archivo en su buffer 
inc ecx;se incrementa el contador
inc ebx;se incrementa la posicion del buffer del comando
jmp cicloNombreArchivo2



MostrarNormal:
mov byte[nombreArchivo1 + ecx],0; al final del nombre del archivo se introduce un 0 para que sirva

mostrar:
;muestra el contenido de un archivo plano .txt indicado por el usuario en consola

;se abre el archivo
mov eax,5;eax tendra la interrupcion open
mov ebx,nombreArchivo1;ebx tiene el nombre del archivo a abrir
xor ecx,ecx;se limpian registros para evitar errores
xor edx,edx
int 80h;interrupcion del sistema

test eax,eax
js errorAbrir1
push eax ;se guarda el FD

mov ebx,eax
;se lee el archivo 
mov eax,3;eax tendra la interrupcion read
mov ecx,contenidoArchivo1
mov edx,lenContenidoArchivo
int 80h
push eax;se guarda la cantidad leida

;se escribe el contenido del archivo en pantalla
mov eax,4 ;eax tendra la interrupcion write
mov ebx,1 ;salida estandar
mov ecx,contenidoArchivo1
pop edx
int 80h

;se cierra el archivo 
mov eax,6 ;eax tendra la interrupcion close
pop ebx ;se saca el FD
xor ecx,ecx
xor edx,edx
int 80h
call LimpiarArchivos
call LimpiarContenidoArchivos
jmp introduccionComando;vuelve a la introduccion de comandos nuevos

verificarAyuda2:
;se verifica byte por byte por medio de comparaciones la introduccion del parametro --ayuda ,de ser introducido mal indicara un mensaje de error al usuario
inc ebx
mov al,byte[comando + ebx]
cmp al,"-"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"y"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"u"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"d"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error

mostrarAyuda2:
;se muestra un mensaje con una especificacion del funcionamiento del comando mostrar 
push msgAyudaMostrar
call printf
add esp,4; se limpia basura de la pila
jmp introduccionComando

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

verificarRenombrar:
;se verifica byte por byte del buffer donde esta el comando para comprobar que se introdujo correctamente renombrar de no ser asi saltara a error
mov al,byte[comando + 1]
cmp al,"e"
jne error
mov al,byte[comando + 2]
cmp al,"n"
jne error
mov al,byte[comando + 3]
cmp al,"o"
jne error
mov al,byte[comando + 4]
cmp al,"m"
jne error
mov al,byte[comando + 5]
cmp al,"b"
jne error
mov al,byte[comando + 6]
cmp al,"r"
jne error
mov al,byte[comando + 7]
cmp al,"a"
jne error
mov al,byte[comando + 8]
cmp al,"r"
jne error
mov al,byte[comando + 9]
cmp al,10
je error2
cmp al," "
jne error
mov al,byte[comando + 10]
cmp al,"-"
mov ebx,10
je verificarAyuda3
cmp al,10
je error2
mov ecx,0;contador

cicloNombreArchivo3:
;se introduce el nombre anterior del archivo en el buffer correspondiente 
mov al,byte[comando +  ebx];al tendra el byte de la posicion donde quedo anteriormente
cmp al,10;se compara con un enter para saber si termino el nombre del primer archivo y va a error indicando que falto el segundo nombre si fuera el caso
je errorRenombrar
cmp al," " ;si hay un espacio se ira a verificar que se ingresara el nuevo nombre que se desea para el archivo
je verificarSegundoArchivo
mov byte[nombreArchivo1 + ecx],al ;si no ira ingresando el nombre anterior del archivo byte por byte
inc ecx
inc ebx
jmp cicloNombreArchivo3


verificarSegundoArchivo:
mov byte[nombreArchivo1 + ecx],0;se coloca un 0 al final del nombre anterior del archivo para que funcione
inc ebx;se incrementa la posicion en el buffer 
xor ecx,ecx
mov ecx,0;contador

cicloNombreArchivo4:
;se introduce el nuevo nombre del archivo en el buffer correspondiente 
mov al,byte[comando +  ebx];al tendra el byte de la posicion donde quedo anteriormente
cmp al,10;se compara con un enter para saber si termino de ingresar dicho nombre
je renombrarNormal
cmp al," " ;si hay un espacio se verifica la existencia del parametro --forzado
je verificarForzado2
mov byte[nombreArchivo2 + ecx],al;se ingresa byte por byte el nombre del archivo
inc ecx
inc ebx
jmp cicloNombreArchivo4

renombrarNormal:
mov byte[nombreArchivo2 + ecx],0;se coloca un 0 al final del nuevo nombre para que funcione

respuestaRenombrar:
;se despliega un mensaje donde se le pregunta al usuario si esta seguro de renombrar el archivo
push msgRenombrarNormal
call printf
add esp,4;se elimina basura de la pila
mov ecx,respuesta
mov edx,100
call ReadText; se lee la respuesta
cmp eax,2;si digito mas de 2 digitos ira a un error
jne digitoMas2
; se compara el primer byte del buffer respuesta con un 1 o un 2 y sino dara un mensaje de respuesta incorrecta
xor eax,eax
mov al,byte[respuesta]
cmp al,"1"
je renombrar
cmp al,"2"
je introduccionComando
jmp respuestaIncorrecta2

renombrar:
;se cambia el nombre de un archivo .txt indicado por el usuario por uno nuevo indicado por el mismo tambien
mov eax,38 ;eax tendra la interrupcion rename
mov ebx,nombreArchivo1
mov ecx,nombreArchivo2
xor edx,edx
int 80h

test eax,eax
js errorAbrir1
call LimpiarArchivos
jmp introduccionComando;vuelve a la introduccion de un nuevo comando

verificarForzado2:
;se verifica la introduccion del parametro --forzado byte por byte , de ser introducido mal indicara un mensaje de error en pantalla
mov byte[nombreArchivo1 + ecx],0
inc ebx
mov al,byte[comando + ebx]
cmp al,"-"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"-"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"f"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"o"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"r"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"z"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"d"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,"o"
jne error3
inc ebx
mov al,byte[comando + ebx]
cmp al,10
jne error
jmp renombrar;si se introdujo bien el parametro ira a renombrar el archivo

verificarAyuda3:
;se verifica byte por byte por medio de comparaciones la introduccion del parametro --ayuda ,de ser introducido mal indicara un mensaje de error al usuario
inc ebx;se incrementa la posicion del buffer comando para seguir con las comparaciones
mov al,byte[comando + ebx]
cmp al,"-"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"y"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"u"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"d"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error

RenombrarAyuda:
;si el parametro --ayuda fue introducido se despliega un mensaje en pantalla con una especificacion del funcionamiento de dicho comando
push msgAyudaRenombrar
call printf
add esp,4;se elimina basura de la pila
jmp introduccionComando

digitoMas2:
;se imprime un mensaje de error de que solo se puede digitar un '1' o un '2'
push msgError4
call printf
add esp,4
jmp respuestaRenombrar;vuelve a preguntar al usuario si esta seguro de renombrar el archivo

respuestaIncorrecta2:
;mensaje de error de "respuesta invalida"
push msgError5
call printf
add esp,4
jmp respuestaRenombrar

errorRenombrar:
;mensaje de error donde se indica que falta el nuevo nombre del archivo
push msgError6
call printf
add esp,4
call LimpiarArchivos
jmp introduccionComando

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
verificarComandosC:;Esto verifca cual de los 2 comandos que empiezan con la letra c es (copiar o comparar)

mov al,byte[comando + 1]
cmp al,"o"
jne error
mov al,byte[comando + 2]
cmp al,"p"
je verificarCopiar
jne error

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

verificarCopiar:
;se verifica byte por byte del buffer donde esta el comando para comprobar que se introdujo correctamente copiar de no ser asi saltara a error 
mov al,byte[comando + 3]
cmp al,"i"
jne error
mov al,byte[comando + 4]
cmp al,"a"
jne error
mov al,byte[comando + 5]
cmp al,"r"
jne error
mov al,byte[comando + 6]
cmp al,10;se compara con un enter para saber si solo se introdujo el comando y luego presionaron enter esto quiere decir que no se introdujo el nombre del archivo
je error2 ;despliegara un error 
cmp al," "
jne error
mov al,byte[comando + 7]
cmp al,"-"
mov ebx,7;ebx tiene la posicion actual del buffer
je verificarAyuda4;si hay un '-' se verificara si se ingreso el parametro --ayuda
cmp al,10
je error2
mov ecx,0;contador

cicloNombreArchivo5:
;se introduce el nombre del archivo en el buffer correspondiente 
mov al,byte[comando +  ebx];al tendra el byte de la posicion donde quedo anteriormente
cmp al,10;se compara con un enter para saber si termino el nombre del archivo e ira a un error donde se indica que falta el nombre del nuevo archivo
je errorCopiar
cmp al," ";si hay un espacio se verifica el segundo nombre
je verificarSegundoArchivoCopiar
mov byte[nombreArchivo1 + ecx],al;se introduce byte por byte el nombre del archivo original en el buffer
inc ecx
inc ebx
jmp cicloNombreArchivo5


verificarSegundoArchivoCopiar:
mov byte[nombreArchivo1 + ecx],0; al final del nombre del archivo se introduce un 0 para que sirva
inc ebx
xor ecx,ecx
mov ecx,0

cicloNombreArchivo6:
;se introduce el nombre del archivo nuevo en el buffer correspondiente
mov al,byte[comando +  ebx]
cmp al,10;si hay un enter ira a copiar el archivo
je copiarNormal
mov byte[nombreArchivo2 + ecx],al;si no se ira introduciendo el nombre del nuevo archivo byte por byte
inc ecx
inc ebx
jmp cicloNombreArchivo6

copiarNormal:
mov byte[nombreArchivo2 + ecx],0; al final del nombre del archivo se introduce un 0 para que sirva

copiar:
;se copia un archivo .txt indicado por el usuario
;se abre el archivo
mov eax,5 ;eax tendra la interrupcion open
mov ebx,nombreArchivo1
xor ecx,ecx
xor edx,edx
int 80h

test eax,eax
js errorAbrir1
push eax;se guarda el FD

mov eax,8;eax tendra la interrupcion creat (crea un archivo)
mov ebx,nombreArchivo2;con el nombre del nuevo archivo
mov ecx,511;esto es para obtener permisos para leer y escribir en el archivo
xor edx,edx
int 80h
mov ebx,eax;se copia el file descriptor a ebx
pop eax; se saca el file descriptor del archivo abierto
push eax
push ebx


mov ebx,eax
;se lee el contenido del archivo
mov eax,3 ;eax tendra la interrupcion read
mov ecx,contenidoArchivo1
mov edx,lenContenidoArchivo
int 80h
push eax;se guarda la cantidad de caracteres leidos

mov eax,4;eax tendra la interrupcion write 
pop edx;se saca la cantidad de caracteres leidos para escibirlos en el archivo
pop ebx
push ebx
mov ecx,contenidoArchivo1
int 80h

;se cierra el archivo
mov eax,6;eax tendra la interrupcion close
pop ebx
xor ecx,ecx
xor edx,edx
int 80h

mov eax,6;eax tendra la interrupcion close
pop ebx
int 80h
call LimpiarArchivos
call LimpiarContenidoArchivos
jmp introduccionComando

verificarAyuda4:
;se verifica byte por byte por medio de comparaciones la introduccion del parametro --ayuda ,de ser introducido mal indicara un mensaje de error al usuario
inc ebx
mov al,byte[comando + ebx]
cmp al,"-"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"y"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"u"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"d"
jne error
inc ebx
mov al,byte[comando + ebx]
cmp al,"a"
jne error

CopiarAyuda:
;se muestra un mensaje con una especificacion del funcionamiento del comando copiar
push msgAyudaRenombrar
call printf
add esp,4
jmp introduccionComando

errorCopiar:
;se imprime un mensaje donde se indica que falta el nombre del segundo archivo
push msgError6
call printf
add esp,4
jmp introduccionComando

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
verificarSalir:
;se verifica byte por byte del buffer donde esta el comando para comprobar que se introdujo correctamente salir de no ser asi saltara a error 
mov al,byte[comando + 1]
cmp al,"a"
jne error
mov al,byte[comando + 2]
cmp al,"l"
jne error
mov al,byte[comando + 3]
cmp al,"i"
jne error
mov al,byte[comando + 4]
cmp al,"r"
jne error
mov al,byte[comando + 5]
cmp al,10; se compara el ultimo caracter con un enter
jne error4; si es distinto salta a decir que introdujo un caracter ditinto demás

fin:
mov	esp, ebp;Finaliza la ejecución del interprete
pop	ebp
ret

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
error:
;impresion del mensaje de error de comando invalido
push msgError1
call printf
add esp,4
call LimpiarArchivos
jmp introduccionComando

error2:
;impresion del mensaje error donde se indica que falta el nombre del archivo
push msgError2
call printf
add esp,4
jmp introduccionComando

error3:
;impresion donde se indica que Se introdujo un tercer parametro invalido
push msgError3
call printf
add esp,4
jmp introduccionComando

error4:
;imprime mensaje especial en caso de error de comansdo salir
push msgError9
call printf
add esp,4
jmp introduccionComando

errorAbrir1:;imprime un mensaje error al abrir el primer archivo
push msgError8
call printf
push nombreArchivo1
call printf
push enter
call printf
add esp,12
call LimpiarArchivos
jmp introduccionComando

errorAbrir2:;imprime un mensaje error al abrir el segundo archivo
push msgError8
call printf
push nombreArchivo2
call printf
push enter
call printf
add esp,12
call LimpiarArchivos
jmp introduccionComando

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;Subrutinas

;subrutina de impresion, imprime mensajes en pantalla
DisplayText: 
mov eax,sys_write
mov ebx,stdout
int 80h
ret

LimpiarRegistros:
xor eax,eax
xor ebx,ebx
xor ecx,ecx
xor edx,edx
ret

;Limpia los buffer con el nombre de los archivos con 0 que son iguales a null
LimpiarArchivos:
mov ecx,lenNombreArchivo
mov eax,0
cicloLimpiarArchivo:
mov byte[nombreArchivo1 + eax],0
mov byte[nombreArchivo2 + eax],0
inc eax
loop cicloLimpiarArchivo
ret

;limpia los buffers que contienen el contenido de un archivo con 0 que son iguales a null
LimpiarContenidoArchivos:
mov ecx,lenContenidoArchivo
mov eax,0
cicloLimpiarContenidos:
mov byte[contenidoArchivo1 + eax],0
mov byte[contenidoArchivo2 + eax],0
inc eax
loop cicloLimpiarContenidos
ret

;subrutina de lectura, lee lo que el usuario digita
ReadText: 
mov eax,sys_read
mov ebx,stdin
int 80h
ret
