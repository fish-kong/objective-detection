%% ����lbp��svm�Ķ�����
clc
close all
clear
format compact
%% ����ѵ������
%%
%% �����ݽ�����������
mapping=getmapping(8,'u2');%�ȼ���Lbp���ӵ�ӳ���
row=128;
col=64;
rootpath='neg\';
filelist=dir(rootpath);%get the filelist from rootpath
[filenum,~]=size(filelist);%get the filelist's count
tempind=0;
negvector=[];
for i=3:filenum
    tempind=tempind+1;%count for picture
    c=imread(strcat(rootpath,'\',filelist(i).name));
    c=imresize(rgb2gray(c),[row col]);%����ͼƬ������ͼƬ���зֿ飬����4*4�ֿ飬ÿ�����LBP
    
    B=mat2cell(c,[row/4 row/4 row/4 row/4],[col/4 col/4 col/4 col/4]);
    %��ÿ���ӿ����Lbp
    for k=1:16
        H1=lbp(B{k},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
        H.hist{k}=H1;
    end
    hist=[H.hist{1},H.hist{2},H.hist{3},H.hist{4},H.hist{5},H.hist{6},H.hist{7},H.hist{8},H.hist{9},H.hist{10},H.hist{11},H.hist{12},H.hist{13},H.hist{14},H.hist{15},H.hist{16}];
    MappedData = mapminmax(hist, 0, 0.5);%���������ݹ�һ����[0,0.5]
    negvector=[negvector;MappedData];
end


rootpath='pos\';
filelist=dir(rootpath);%get the filelist from rootpath
[filenum,~]=size(filelist);%get the filelist's count
tempind=0;
posvector=[];
for i=3:filenum
    tempind=tempind+1;%count for picture
    c=imread(strcat(rootpath,'\',filelist(i).name));
    c=imresize(rgb2gray(c),[row col]);
    %����ͼƬ������ͼƬ���зֿ飬����4*4�ֿ飬ÿ�����LBP
    
    B=mat2cell(c,[row/4 row/4 row/4 row/4],[col/4 col/4 col/4 col/4]);
    %��ÿ���ӿ����Lbp
    for k=1:16
        H1=lbp(B{k},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
        H.hist{k}=H1;
    end
    hist=[H.hist{1},H.hist{2},H.hist{3},H.hist{4},H.hist{5},H.hist{6},H.hist{7},H.hist{8},H.hist{9},H.hist{10},H.hist{11},H.hist{12},H.hist{13},H.hist{14},H.hist{15},H.hist{16}];
    MappedData = mapminmax(hist, 0, 0.5);%���������ݹ�һ����[0,0.5]
    posvector=[posvector;MappedData];
end

%%
num1=size(posvector,1);
num2=size(negvector,1);

% �����������������
X=[posvector;negvector];
Y=[ones(1,num1) -ones(1,num2)]';
% �������ݼ�
rand('state',0)
[~,n]=sort(rand(1,size(X,1)));
m=round(0.7*size(X,1));% 70%Ϊѵ���� ʣ��30%Ϊ���Լ�
X_train=X(n(1:m),:);
Y_train=Y(n(1:m),:);
X_test=X(n(m+1:end),:);
Y_test=Y(n(m+1:end),:);

%% SVM��������
C=10;%�ʸ����ճ����ķ�ΧΪ[0 C]-�����ǳͷ�����
ker='linear';%ker='linear';


global p1 p2
p1=10;% �˲���
p2=1;% ��Щ�˺������������˲���
%% ѵ��ģ��
[nsv,alpha,bias] = svc(X_train,Y_train,ker,C);  %ģ�ͳ����󣬱������  �´�ֱ�ӵ���

label_train= svcoutput(X_train,Y_train,X_train,ker,alpha,bias);

% ѵ��������
acc_train=sum(label_train==Y_train)/size(Y_train,1)
%% ����
label_test= svcoutput(X_train,Y_train,X_test,ker,alpha,bias);
% ѵ��������
acc_test=sum(label_test==Y_test)/size(Y_test,1)
%% ��δ֪�����ݽ��з���
c=imread('test1.jpg');
xbstride=32;  %x���򻬲�
ybstride=32;  %y���򻬲�
windoww=col;   %��ⴰ�ڿ��
windowh=row;  %��ⴰ�ڸ߶�
[~, ~, ~, ~, imglist]=readimg2(c,xbstride,ybstride,windoww,windowh);  %������ͼƬ�ֿ�
testvector=[];
for i=1:size(imglist,2)
    c=imglist{i};
    B=mat2cell(c,[row/4 row/4 row/4 row/4],[col/4 col/4 col/4 col/4]);
    %��ÿ���ӿ����Lbp
    for k=1:16
        H1=lbp(B{k},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
        H.hist{k}=H1;
    end
    hist=[H.hist{1},H.hist{2},H.hist{3},H.hist{4},H.hist{5},H.hist{6},H.hist{7},H.hist{8},H.hist{9},H.hist{10},H.hist{11},H.hist{12},H.hist{13},H.hist{14},H.hist{15},H.hist{16}];
    MappedData = mapminmax(hist, 0, 0.5);%���������ݹ�һ����[0,0.5]
    testvector=[testvector;MappedData];
end

predictedY = svcoutput(X_train,Y_train,testvector,ker,alpha,bias);


% save pos posvector
% save neg negvector
% save testvector testvector


%
% figure
% for i=1:size(imglist,2)
%  subplot(5,8,i)
%  imshow(imglist{i});
%  t=predictedY(i);
%  title(num2str(t))
% end



