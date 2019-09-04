function [imglist]=readneg(rootpath)
if nargin<1
    disp('Not enough parameters!');
    return;
end

filelist=dir(rootpath);%get the filelist from rootpath
[filenum,~]=size(filelist);%get the filelist's count

num=filenum;

for i=1:filenum
if strcmp(filelist(i).name,'Thumbs.db')
    num=filenum-1;
end
end

negvector=zeros(num-2,3780);
tempind=0;
imglist=cell(0);%define the var of imagedata list
for i=1:filenum
    %ignore two special files: current catalog and father catalog
    if strcmp(filelist(i).name,'.')|| strcmp(filelist(i).name,'..')||strcmp(filelist(i).name,'Thumbs.db')
        %do nothing
    else
        tempind=tempind+1;%count for picture
        temp=imread(strcat(rootpath,'\',filelist(i).name));
        temp=imresize(temp,[128 64]);
        imglist{tempind}=temp;
        negvector(tempind,:)=HOG(imglist{tempind});  
    end
end

save neg.mat negvector;
