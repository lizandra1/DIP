

%im1 = imread('images/Automovil023.png');
im1 = imread('Automovil002.png');

im1=imadjust(im1)
% im1 = rgb2gray(im1);
% im1 = imadjust(im1);

%im1 = imread('images/Automovil032.png');
%im1 = imread('images/Automovil006.png');

im1 = double(im1)/255;
figure(1), imshow(im1), title('Imagen Original')
%%%%%%%%%%%%%%%%%
% Para ello previamente seleccionamos las coordenadas (x,y) de la placa en 
% vista lateral de la Imagen Original
% Imagen automovil001
% y = [181,179,212,217]';
% x = [291,349,349,290]';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Imagen2 automovil002
y = [211,211,244,246]';
x = [287,343,343,287]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Imagen3
% y = [148,159,196,176]';
% x = [271,310,299,259]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Imagen4
% y = [222,231,280,264]';
% x = [103,174,169,98]';

yp = [1,1,160,160]'; %Asignamos un tamano para la imagen final
xp = [1,330,330,1]';

M = [ones(4,1),x,y,x.*y]; % Creamos la matriz para transformacion Bilineal
a = M^(-1)*xp;
b = M^(-1)*yp;
Mp = [ones(4,1),xp,yp,xp.*yp];
ap = Mp^(-1)*x;
bp = Mp^(-1)*y;
% Ahora recalculamos el valor para cada punto y lo redondeamos al mas
% cercano; como es una transformada lineal, un pixel dentro de la nueva
% transformada puede quedar con un valor que no es entero por eso el round
for m=1:160, 
    for n=1:330, 
        im3(m,n)=im1(round(bp'*[1;n;m;n*m]), round(ap'*[1;n;m;n*m]));
    end; 
end;

%binaria imagen
%%%%Auto1
for m=1:160, 
    for n=1:330, 
        if(im3(m,n)>0.1)&&(im3(m,n)<0.3)||(im3(m,n)==0.8167)||(im3(m,n)==0.7833)||(im3(m,n)==0.675)||(im3(m,n)==0.7833)
            im11(m,n)=1;
        elseif (im3(m,n)==0.35)
            im11(m,n)=1;
        elseif (im3(m,n)==0.325)
            im11(m,n)=1;
        else
            im11(m,n)=0;
        end
    end; 
end;
%%%Auto 2
for m=1:160, 
    for n=1:330, 
        if(im3(m,n)>0)&&(im3(m,n)<0.6)
            im11(m,n)=1;
        else
            im11(m,n)=0;
        end
    end; 
end;
% figure, imshow(im11),title('imagen 11');
% figure(3), imshow(imadjust(im3)); title('Transformacion Vista Frontal')
a1=160;
b1=330;
H=imerode(im11,strel('line',3,90));
final=bwareaopen(H,floor((160/9.5)*(330/9.5)));
final(1:floor(.9*a1),1:2)=1;
final(a1:-1:(a1-20),b1:-1:(b1-2))=1;
figure, imshow(final); title('sin borde Frontal')
Iprops=regionprops(final,'BoundingBox');
hold on
for n=1:size(Iprops,1)
    rectangle('Position',Iprops(n).BoundingBox,'EdgeColor','r','LineWidth',1); 
end
hold off
NR=cat(1,Iprops.BoundingBox);   %%Data storage section
[r ttb]=connn(NR);

if ~isempty(r)
    
    
    xlow=floor(min(reshape(ttb(:,1),1,[])));
    xhigh=ceil(max(reshape(ttb(:,1),1,[])));
    xadd=ceil(ttb(size(ttb,1),3));
    ylow=floor(min(reshape(ttb(:,2),1,[])));    %%%%%area selection
    yadd=ceil(max(reshape(ttb(:,4),1,[])));
    final1=H(ylow:(ylow+yadd+(floor(max(reshape(ttb(:,2),1,[])))-ylow)),xlow:(xhigh+xadd));
    [a2 b2]=size(final1);
    final1=bwareaopen(final1,floor((a2/20)*(b2/20)));
    figure(6)
    imshow(final1)
    
   
    Iprops1=regionprops(final1,'BoundingBox','Image');
    NR3=cat(1,Iprops1.BoundingBox);
    I1={Iprops1.Image};
    
    %%
    carnum=[];
    if (size(NR3,1)>size(ttb,1))
        [r2 to]=connn2(NR3);
        
        for i=1:size(Iprops1,1)
            
            ff=find(i==r2);
            if ~isempty(ff)
                N1=I1{1,i};
                letter=readLetter(N1,2);
            else
                N1=I1{1,i};
                letter=readLetter(N1,1);
            end
            if ~isempty(letter)
                carnum=[carnum letter];
            end
        end
    else
        for i=1:size(Iprops1,1)
            N1=I1{1,i};
            letter=readLetter(N1,1);
            carnum=[carnum letter];
        end
    end
    %%
    
    fid1 = fopen('carnum.txt', 'wt');
    fprintf(fid1,'%s',carnum);
    fclose(fid1);
    winopen('carnum.txt')
   


else
    fprintf('reconocimiento de la placa fall�\n');
    fprintf('letras no son claras \n');
end

%%%%%%%%%%%%% Para la deteccion de bordes %%%%%%%%%%%%%%%%%%%%%%%%
% im4 = edge(im3,'sobel');
% figure(4), subplot(1,3,1), imshow([im3;im4]); title('Deteccion de bordes usando el comando EDGE')
% % Defino dos matrices (horizontal y vertical)
% s1 = [-1 0 1; -2 0 2; -1 0 1];
% s2 = [-1 -2 -1; 0 0 0; 1 2 1];
% im5 = filter2(s1,im3); %filter2 es la convolucion entre la imagen y la matriz
% im6 = filter2(s2,im3); %derivada vertical
% % Con la derivada lo que se busca es encontrar las variaciones
% subplot(1,3,2), imshow([im5;im6],[]), title('Derivada Horizontal y Vertical')
% im7 = abs(im5)  + abs(im6); % Gradiente
% subplot(1,3,3), imshow([im3,[];im7,[]]), title('Convolucion entre la imagen y la matriz')