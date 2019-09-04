function [testvector, xwindownum, ywindownum, isbigenough, imglist]=readimg2(img,xbstride,ybstride,windoww,windowh)  %������ľ��󷵻�һ��testvector
% input��
% img;%�������ͼƬ
% xbstride;  %x���򻬲�
% ybstride;  %y���򻬲�
% windoww;   %��ⴰ�ڿ��
% windowh;  %��ⴰ�ڸ߶�

%%
[M, N, K] = size(img);  %MΪ������Ҳ���Ǹ߶ȡ�NΪ������Ҳ���ǿ��

if M<128 | N<64
    fprintf ('the size of this photo is too small we need its hight>128 & width>64\n')
    error;
    isbigenough=0;
else
    isbigenough=1;
    xbstrideend=1;%x�������ܵ�����󴰿ڵ����Ͻ�x����,��ʼ��Ϊ1
    ybstrideend=1;%y�������ܵ�����󴰿ڵ����Ͻ�x����,��ʼ��Ϊ1
    
    while xbstrideend<N-windoww-xbstride
        xbstrideend=xbstrideend+xbstride;
    end
    % xbstrideend;   %x�������ܵ�����󴰿ڵ����Ͻ�x����
    
    while ybstrideend<M-windowh-ybstride
        ybstrideend=ybstrideend+ybstride;
    end
    % ybstrideend;  %y�������ܵ�����󴰿ڵ����Ͻ�x����
    
    tempind=0;
    imglist=cell(0);  %��ʼ��һ��cell�������testvector
    
    xwindownum=(xbstrideend-1)/xbstride+1;  %x���򴰿ڵĸ���
    ywindownum=(ybstrideend-1)/ybstride+1;  %y���򴰿ڵĸ���
    
    testvector=zeros(xwindownum*ywindownum,3780); %���鲢����Ҫ��ʼ������ɾȥ����һ��
    
    
    for j=1:ybstride:ybstrideend           %�������ң����ϵ��£�ɨ�����д���
        for i=1:xbstride:xbstrideend
            tempind=tempind+1;
            imglist{tempind}=img(j:j+windowh-1,i:i+windoww-1,:);  %�����ڵ����ش浽imglist��
%             testvector(tempind,:)=(imglist{tempind});
        end
    end
end

