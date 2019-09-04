clc;clear;close all
%%

imgpath = 'test1.jpg';% �����Ŀ��ͼ��
t=imread(imgpath);
[ysize,xsize,~]=size(t); %ysizeΪ�ߣ�xsizeΪ��

if ysize>1000 | xsize>1000
    t=imresize(t,[240 360]);    %��ȡͼƬ,ת����С
end

[ysize,xsize,~]=size(t); %ysizeΪ�ߣ�xsizeΪ��
mapping=getmapping(8,'u2');%�ȼ���Lbp���ӵ�ӳ���
row=128;
col=64;
%% HOG ������ͼƬ����Ϊ���С�飬Ȼ���ÿ��С����ȡHOG����
xbstride=32;  %x���򻬲�
ybstride=32;  %y���򻬲�
windoww=64;   %��ⴰ�ڿ��
windowh=128;  %��ⴰ�ڸ߶�

[testvector ,xwindownum ,ywindownum ,isbigenough,imglist]=readimg2(t,xbstride,ybstride,windoww,windowh); %����ͼƬ����HOG����-���������testvector.mat��

testvector=[];
for i=1:size(imglist,2)
    c=rgb2gray(imglist{i});
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





%% ��󲢶�ÿ��С����з���
predictedY=newSVM(testvector);  %����Ԥ��,����predictedY

% figure
% for i=1:40
%  subplot(5,8,i)
%  imshow(imglist{i});
%  title(num2str(predictedY(i)));
% end
% suptitle('ԭʼͼ����Ϊ�����ͼ')

%%
%���������ȡ������predictedY(k),��ֵΪ1ʱ,�ж��������ĸ���С���ͼ�����k��Ӧ�ĵ�������
%ͼƬ�����꣬���һ�ԭ��ԭ����ͼ�к�����ꡣȻ����ԭͼ�зŴ��ⴰ�ڻ���
I=zeros(240,360);

figure
imshow(t);
title('����ͼ��')
hold on;


j=1;
[windownum,~]=size(predictedY);
[rawvectornum,k1]=size(testvector);
narrowarray(1,:)=[rawvectornum 1 xwindownum ywindownum];

for k=1:windownum                     %Ҫ�ж������ĸ����ź��ͼ
    if predictedY(k)==1
        if k-rawvectornum<=0 %����ԭͼ
            amplification=1; 
        end
        % k
        kx=mod(k-1,narrowarray(j,3))*xbstride+1;  %����������ͼ�е����겢�����ԭͼ�е�����󻭿�
        ky=mod(k-1,narrowarray(j,4))*ybstride+1;
        rawkx=(kx-1)*narrowarray(j,2)+1;
        rawky=(ky-1)*narrowarray(j,2)+1;
        %rawkx=kx/narrowarray(j,2);
        %rawky=ky*narrowarray(j,2);
        myplot(rawkx,rawky,ceil(windoww/narrowarray(j,2)),ceil(windowh/narrowarray(j,2)));
        I=my_add(I,rawkx,rawky,ceil(windoww/narrowarray(j,2)),ceil(windowh/narrowarray(j,2)));%�������ӽ��������棬�Ա�����󻭸���򣬽�����С���ס

        %  w=floor(windoww/narrowarray(j,2))
        %  h=floor(windowh/narrowarray(j,2))
    end
end

figure
imshow(I);
title('����Ȥ����')
%% �ҳ���ЩС�����С���п��
% I=bwareaopen(I,10000);%ȥ�����ŻҶ�ֵС��10000�Ĳ�λ
% figure, imshow(I), title('ɾ����������');
pictureRe = regionprops(I, 'area', 'boundingbox');
rects = cat(1, pictureRe.BoundingBox);%���������ı߽��������Ӳ����浽rects��˳��Ϊ[��ʼ��x����, ��ʼ��y����, ������󳤶�(x), ���������(y)]
figure, imshow(t), title('��׼����Ŀ�궨λ');
rectangle('position', rects(1, :), 'EdgeColor', 'r'); %��λ���򣬲��ú�ɫ�Ŀ���
% pictureOut = imcrop(t, rects(1, :));                               %���պ��߿��и��˵�����
% figure, imshow(pictureOut), title('�ü���֮���ͼ��');


