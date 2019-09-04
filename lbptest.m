clear
clc
close all
%%

I=imread('test1.jpg');
I=rgb2gray(I);
I=imresize(I,[128 64]);
row=size(I,1);
col=size(I,2);
B=mat2cell(I,[row/2 row/2],[col/2 col/2]);
figure
subplot(2,2,1),imshow(B{1,1});
subplot(2,2,2),imshow(B{1,2});
subplot(2,2,3),imshow(B{2,1});
subplot(2,2,4),imshow(B{2,2});

mapping=getmapping(8,'u2');
H.a=0;
for i=1:4
    H1=lbp(B{i},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
    H.hist{i}=H1;
end
figure
subplot(2,2,1),stem(H.hist{1});
subplot(2,2,2),stem(H.hist{2});
subplot(2,2,3),stem(H.hist{3});
subplot(2,2,4),stem(H.hist{4});
%%
c=I;
row=size(c,1);%读入图片，并对图片进行分块，采用4*4分块，每块进行LBP
col=size(c,2);
B=mat2cell(c,[row/4 row/4 row/4 row/4],[col/4 col/4 col/4 col/4]);
%对每个子块进行Lbp
for k=1:16
    H1=lbp(B{k},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
    H.hist{k}=H1;
end
figure
for i=1:16
subplot(4,4,i),stem(H.hist{i});
end

