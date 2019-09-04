%% 基于lbp与svm的二分类
clc
close all
clear
format compact
%% 加载训练样本
%%
%% 对数据进行批量处理
mapping=getmapping(8,'u2');%先计算Lbp算子的映射表
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
    c=imresize(rgb2gray(c),[row col]);%读入图片，并对图片进行分块，采用4*4分块，每块进行LBP
    
    B=mat2cell(c,[row/4 row/4 row/4 row/4],[col/4 col/4 col/4 col/4]);
    %对每个子块进行Lbp
    for k=1:16
        H1=lbp(B{k},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
        H.hist{k}=H1;
    end
    hist=[H.hist{1},H.hist{2},H.hist{3},H.hist{4},H.hist{5},H.hist{6},H.hist{7},H.hist{8},H.hist{9},H.hist{10},H.hist{11},H.hist{12},H.hist{13},H.hist{14},H.hist{15},H.hist{16}];
    MappedData = mapminmax(hist, 0, 0.5);%将输入数据归一化到[0,0.5]
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
    %读入图片，并对图片进行分块，采用4*4分块，每块进行LBP
    
    B=mat2cell(c,[row/4 row/4 row/4 row/4],[col/4 col/4 col/4 col/4]);
    %对每个子块进行Lbp
    for k=1:16
        H1=lbp(B{k},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
        H.hist{k}=H1;
    end
    hist=[H.hist{1},H.hist{2},H.hist{3},H.hist{4},H.hist{5},H.hist{6},H.hist{7},H.hist{8},H.hist{9},H.hist{10},H.hist{11},H.hist{12},H.hist{13},H.hist{14},H.hist{15},H.hist{16}];
    MappedData = mapminmax(hist, 0, 0.5);%将输入数据归一化到[0,0.5]
    posvector=[posvector;MappedData];
end

%%
num1=size(posvector,1);
num2=size(negvector,1);

% 输入样本与输出样本
X=[posvector;negvector];
Y=[ones(1,num1) -ones(1,num2)]';
% 划分数据集
rand('state',0)
[~,n]=sort(rand(1,size(X,1)));
m=round(0.7*size(X,1));% 70%为训练集 剩下30%为测试集
X_train=X(n(1:m),:);
Y_train=Y(n(1:m),:);
X_test=X(n(m+1:end),:);
Y_test=Y(n(m+1:end),:);

%% SVM参数设置
C=10;%朗格朗日乘数的范围为[0 C]-可能是惩罚参数
ker='linear';%ker='linear';


global p1 p2
p1=10;% 核参数
p2=1;% 有些核函数具有两个核参数
%% 训练模型
[nsv,alpha,bias] = svc(X_train,Y_train,ker,C);  %模型出来后，保存参数  下次直接调用

label_train= svcoutput(X_train,Y_train,X_train,ker,alpha,bias);

% 训练集精度
acc_train=sum(label_train==Y_train)/size(Y_train,1)
%% 测试
label_test= svcoutput(X_train,Y_train,X_test,ker,alpha,bias);
% 训练集精度
acc_test=sum(label_test==Y_test)/size(Y_test,1)
%% 对未知的数据进行分类
c=imread('test1.jpg');
xbstride=32;  %x方向滑步
ybstride=32;  %y方向滑步
windoww=col;   %检测窗口宽度
windowh=row;  %检测窗口高度
[~, ~, ~, ~, imglist]=readimg2(c,xbstride,ybstride,windoww,windowh);  %将待测图片分块
testvector=[];
for i=1:size(imglist,2)
    c=imglist{i};
    B=mat2cell(c,[row/4 row/4 row/4 row/4],[col/4 col/4 col/4 col/4]);
    %对每个子块进行Lbp
    for k=1:16
        H1=lbp(B{k},1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood %using uniform patterns
        H.hist{k}=H1;
    end
    hist=[H.hist{1},H.hist{2},H.hist{3},H.hist{4},H.hist{5},H.hist{6},H.hist{7},H.hist{8},H.hist{9},H.hist{10},H.hist{11},H.hist{12},H.hist{13},H.hist{14},H.hist{15},H.hist{16}];
    MappedData = mapminmax(hist, 0, 0.5);%将输入数据归一化到[0,0.5]
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



