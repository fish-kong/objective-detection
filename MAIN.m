clc;clear;close all
%%

imgpath = 'test1.jpg';% 待检测目标图像
t=imread(imgpath);
[ysize,xsize,~]=size(t); %ysize为高，xsize为宽

if ysize>1000 | xsize>1000
    t=imresize(t,[240 360]);    %读取图片,转换大小
end

[ysize,xsize,~]=size(t); %ysize为高，xsize为宽
mapping=getmapping(8,'u2');%先计算Lbp算子的映射表
row=128;
col=64;
%% HOG 将待测图片划分为多个小块，然后对每个小块提取HOG特征
xbstride=32;  %x方向滑步
ybstride=32;  %y方向滑步
windoww=64;   %检测窗口宽度
windowh=128;  %检测窗口高度

[testvector ,xwindownum ,ywindownum ,isbigenough,imglist]=readimg2(t,xbstride,ybstride,windoww,windowh); %待测图片产生HOG特征-结果保存在testvector.mat中

testvector=[];
for i=1:size(imglist,2)
    c=rgb2gray(imglist{i});
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





%% 最后并对每个小块进行分类
predictedY=newSVM(testvector);  %进行预测,产生predictedY

% figure
% for i=1:40
%  subplot(5,8,i)
%  imshow(imglist{i});
%  title(num2str(predictedY(i)));
% end
% suptitle('原始图划分为多个子图')

%%
%下面针对提取出来的predictedY(k),当值为1时,判断其属于哪个缩小后的图像，求出k对应的当下所属
%图片的坐标，并且还原到原来的图中后的坐标。然后在原图中放大检测窗口画出
I=zeros(240,360);

figure
imshow(t);
title('待测图像')
hold on;


j=1;
[windownum,~]=size(predictedY);
[rawvectornum,k1]=size(testvector);
narrowarray(1,:)=[rawvectornum 1 xwindownum ywindownum];

for k=1:windownum                     %要判断属于哪个缩放后的图
    if predictedY(k)==1
        if k-rawvectornum<=0 %属于原图
            amplification=1; 
        end
        % k
        kx=mod(k-1,narrowarray(j,3))*xbstride+1;  %计算在所属图中的坐标并换算成原图中的坐标后画框
        ky=mod(k-1,narrowarray(j,4))*ybstride+1;
        rawkx=(kx-1)*narrowarray(j,2)+1;
        rawky=(ky-1)*narrowarray(j,2)+1;
        %rawkx=kx/narrowarray(j,2);
        %rawky=ky*narrowarray(j,2);
        myplot(rawkx,rawky,ceil(windoww/narrowarray(j,2)),ceil(windowh/narrowarray(j,2)));
        I=my_add(I,rawkx,rawky,ceil(windoww/narrowarray(j,2)),ceil(windowh/narrowarray(j,2)));%将框框添加进矩阵里面，以便于最后画个大框，将所有小框框住

        %  w=floor(windoww/narrowarray(j,2))
        %  h=floor(windowh/narrowarray(j,2))
    end
end

figure
imshow(I);
title('感兴趣区域')
%% 找出这些小框的最小外切框框
% I=bwareaopen(I,10000);%去掉聚团灰度值小于10000的部位
% figure, imshow(I), title('删除干扰物体');
pictureRe = regionprops(I, 'area', 'boundingbox');
rects = cat(1, pictureRe.BoundingBox);%将面积对象的边界条件链接并保存到rects，顺序为[起始点x坐标, 起始点y坐标, 面积对象长度(x), 面积对象宽度(y)]
figure, imshow(t), title('精准人体目标定位');
rectangle('position', rects(1, :), 'EdgeColor', 'r'); %定位区域，并用红色的框标记
% pictureOut = imcrop(t, rects(1, :));                               %按照红线框切割人的区域
% figure, imshow(pictureOut), title('裁剪完之后的图像');


