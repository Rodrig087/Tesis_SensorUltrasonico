%Numero de muestras
num_m=100;

%Inicializa el puerto
delete(instrfind({'Port'},{'COM3'}));
puerto_serial=serial('COM3');
puerto_serial.BaudRate=9600;
warning('off','MATLAB:serial:fscanf:unsuccessfulRead');

%Abrir el puerto serial
fopen(puerto_serial);

%Declaracion del contador de numero de muestras
cont_m=1;

while cont_m<num_m
    valor=fscanf(puerto_serial,'MEASUREMENT:IMMED:TYPE PK2PK')
    cont_m=cont_m+1;
end

%Cerrar conexion puerto 
fclose(puerto_serial);
delete(puerto_serial);
clear all;

