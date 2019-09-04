function [testvector, xwindownum, ywindownum, isbigenough, imglist]=readimg2(img,xbstride,ybstride,windoww,windowh)  %对输入的矩阵返回一个testvector
% input：
% img;%输入待测图片
% xbstride;  %x方向滑步
% ybstride;  %y方向滑步
% windoww;   %检测窗口宽度
% windowh;  %检测窗口高度

%%
[M, N, K] = size(img);  %M为行数，也就是高度。N为列数，也就是宽度

if M<128 | N<64
    fprintf ('the size of this photo is too small we need its hight>128 & width>64\n')
    error;
    isbigenough=0;
else
    isbigenough=1;
    xbstrideend=1;%x方向所能到的最后窗口的左上角x坐标,初始化为1
    ybstrideend=1;%y方向所能到的最后窗口的左上角x坐标,初始化为1
    
    while xbstrideend<N-windoww-xbstride
        xbstrideend=xbstrideend+xbstride;
    end
    % xbstrideend;   %x方向所能到的最后窗口的左上角x坐标
    
    while ybstrideend<M-windowh-ybstride
        ybstrideend=ybstrideend+ybstride;
    end
    % ybstrideend;  %y方向所能到的最后窗口的左上角x坐标
    
    tempind=0;
    imglist=cell(0);  %初始化一个cell用来存放testvector
    
    xwindownum=(xbstrideend-1)/xbstride+1;  %x方向窗口的个数
    ywindownum=(ybstrideend-1)/ybstride+1;  %y方向窗口的个数
    
    testvector=zeros(xwindownum*ywindownum,3780); %数组并不需要初始化，就删去了这一句
    
    
    for j=1:ybstride:ybstrideend           %从左往右，从上到下，扫描所有窗口
        for i=1:xbstride:xbstrideend
            tempind=tempind+1;
            imglist{tempind}=img(j:j+windowh-1,i:i+windoww-1,:);  %窗口内的像素存到imglist中
%             testvector(tempind,:)=(imglist{tempind});
        end
    end
end

