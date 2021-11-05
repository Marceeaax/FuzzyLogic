%------------DETECCION DE BORDES------------

%1- LEE LA IMAGEN UTILIZANDO LA SUBRUTINA imread, ESPECIFICADO POR SU
%NOMBRE DE ARCHIVO
Irgb = imread('picture5.png'); 
%MUESTRA TODA LA IMAGEN CON LA AMPLIACION ESPECIFICADA .imshow
imshow(Irgb, 'InitialMagnification', 100)

%2- CONVIERTE LA IMAGEN DEL COLOR VERDADERO RBG(Irgb) A LA IMAGEN EN ESCALA DE
%GRISES (Igray)
Igray = rgb2gray(Irgb);

%MUESTRA LA IMAGEN EN ESCALA DE GRISES
figure
image(Igray,'CDataMapping','scaled')
colormap('gray')
title('Imagen de Entrada en Escala de Grises')

%CONVIERTE LA IMAGEN I A DOBLE PRECISION:
% ->CAMBIA LA ESCALA DE LA SALIDA DE LOS TIPOS DE DATOS ENTEROS AL RANGO
%   [0,1]
I = im2double(Igray);
%SE CREA LOS FILTROS DE GRADIENTES SIMPLE
Gx =[-1 1];
Gy = Gx(:); %CALCULA LA TRANSPUESTA

%3-CONVOLUCIONA I con Gx, USANDO LA FUNCION conv2, PARA OBTENER LA MATRIZ QUE
%  CONTIENE LOS GRADIENTES DEL eje x DE I
Ix = conv2(I,Gx,'same');
%CONVOLUCIONA I con Gy, USANDO LA FUNCION conv2, PARA OBTENER LA MATRIZ QUE
% CONTIENE LOS GRADIENTES DEL eje y DE I
Iy = conv2(I,Gy,'same');

%MUESTRA LA IMAGEN LUEGO DE LA CONVOLUCION 
figure; image(Ix,'CDataMapping','scaled'); colormap('gray'); title('Ix');
figure; image(Iy,'CDataMapping','scaled'); colormap('gray'); title('Iy');


%4-UTILIZA UN OBJETO mamfis PARA REPRESENTAR UN SISTEMA DE INTERFERENCIA
%DIFUSA MAMDANI DE TIPO 1 (FIS) METODO MAX-MIN
%->mamfis ESPECIFICA LA INFORMACION DE CONFIGURACION DEL FIS O ESTABLECE LAS
%PROPIEDADES DEL OBJETO UTILIZANDO ARGUMENTOS DE PAR NOMBRE-VALOR
edgeFIS = mamfis('Name','edgeDetection');

%5-AGREGA LA VARIABLE DE ENTRADA AL SISTEMA DE INTEREFERENCIA DIFUSA
% addInput CONFIGURA LA VARIABLE DE ENTRADA UTILIZANDO UNO O MAS ARGUMENTOS DE
% PAR NOMBRE-VALOR
%->SE ESPECIFICA LOS DEGRADADOS Ix e Iy COMO VARIABLES DE ENTRADA DE edgeFIS
edgeFIS = addInput(edgeFIS,[-1 1],'Name','Ix');
edgeFIS = addInput(edgeFIS,[-1 1],'Name','Iy');



%6- SE AGREGA FUNCION DE MEMBRESIA A LA VARIABLE DIFUSA con addMF
% -> SE ESPECIFICA UNA FUNCION DE MEMEBRESIA GAUSSIANA DE MEDIA CERO PARA
% CADA ENTRADA. 
sx = 0.1; sy = 0.1; %ES LA DESVIACION ESTANDAR DE LA FUNCION DE MEMBRESIA CERO
edgeFIS = addMF(edgeFIS,'Ix','gaussmf',[sx 0],'Name','zero');
edgeFIS = addMF(edgeFIS,'Iy','gaussmf',[sy 0],'Name','zero');

%addOuput AGREGA LA VARIABLE DE SALIDA PARA EL FIS Iout
%-> SE ESPECIFICA LA INTENSIDAD DE LA IMAGEN DEL BORDE DETECTADO COMO
%SALIDA DE edgeFIS
edgeFIS = addOutput(edgeFIS,[0 1],'Name','Iout');


%7-SE ESPECIFICA LAS FUNCIONES DE PERTENENCIA TRIANGULAR (BLACK Y WHITE) PARA
%LA VARIABLE DE SALIDA Iout

%->LOS TRIPLETES QUE INDICA EL INICIO, PICO Y FINAL DE LAS FUNCIONES DE
%MEMBRESIA
wa = 0.1; wb = 1; wc = 1; %TRIPLETES DE WHITE
ba = 0; bb = 0; bc = 0.7;%TRIPLETES DE BLACK

%addMF AGREGA UNA FUNCION DE MEMBRESIA A LA VARIABLE DE SALIDA EN EL
%SISTEMA DE INTERFERENCIA DIFUSA Iout Y DEVUELVE EL SISTEMA DIFUSA
%RESULTANTE EN edgeFIS
edgeFIS = addMF(edgeFIS,'Iout','trimf',[wa wb wc],'Name','white');
edgeFIS = addMF(edgeFIS,'Iout','trimf',[ba bb bc],'Name','black');

%->MUESTRA LA FUNCION DE MEMBRESIA GAUSSIANA (PERTENENCIA A REGION UNIFORME)
%->MUESTRA LA FUNCIONES DE MEMBRESIA TRIANGULARES
figure
subplot(2,2,1)
plotmf(edgeFIS,'input',1)
title('Ix')
subplot(2,2,2)
plotmf(edgeFIS,'input',2)
title('Iy')
subplot(2,2,[3 4])
plotmf(edgeFIS,'output',1)
title('Iout')

%8-REGLAS DIFUSAS
%OBS: if expression , statements. UNA EXPRESION ES VERDADERA CUANDO SU
%RESULTADO NO ESTA VACIO Y SOLO CONTIENE RESULTADOS DISTINTOS DE CERO.


%REGLA 1: SI Ix es zero y Iy es zero
%Obtiene el grado de membresia de Ix en zero
%Obtiene el grado de membresia de Iy en zero
%Ya que estamos utilizando el operador 'and' entonces el resultado es el
%grado de membresia mas bajo de ambas expresiones, en caso que el resultado sea distinto de
%cero entonces la expresion sale verdadera
% Y se ejecuta el consecuente
% El grado de membresia resultante es evaluado en la funcion de membresia
% white y se obtiene el resultado
r1 = 'If Ix is zero and Iy is zero then Iout is white';

%REGLA 2: 
%Si (Complemento de Ix es cero) o (Complemento de Iy es cero) 
%Ya que estmos utilizando el operador 'or' entonces el resultado es el 
%grado de membresia mas alta de ambas expresiones , en caso que el
%resultado sea distinto cero se ejecuta la expresion .
%El grado de membresia es evaluado en black y se obtiene el resultado
r2 = 'If Ix is not zero or Iy is not zero then Iout is black';




%char(r1,r2) CONVIERTE LOS VECTORES r1,r2 EN UNA SOLA MATRIZ
%DE UN SOLO CARACTER. DESPUES DE LA CONVERSION DE CARACTERES, LOS VECTORES
%DE ENTRADAS SE CONVIERTEN EN FILAS EN r
r = char(r1,r2);

%REETORNA UN SISTEMA DE INTEREFENCIA QUE ES EQUIVALENTE AL SISTEMA DE
%INTERFERENCIA DE ENTRADA PERO CON LAS REGLAS DIFUSAS REEMPLAZADAS POR LAS
%REGLAS ESPECIFICADAS EN r
edgeFIS = parsrule(edgeFIS,r);

%MUESTRA LAS REGLAS EN EL SISTEMA DE INTERFERENCIA DIFUSA
showrule(edgeFIS)

%CREA UNA MATRIZ DE CEROS CON EL TAMANO DE LA IMAGEN
Ieval = zeros(size(I));
for ii = 1:size(I,1)
Ieval(ii,:) = evalfis([(Ix(ii,:));(Iy(ii,:));]',edgeFIS); %RETORNA LAS VARIABLES DE SALIDA
end

%MUESTRA EL RESULTADO
figure; image(Ieval,'CDataMapping','scaled'); colormap('gray');
title('Deteccion de Bordes utilizando Logica Difusa');