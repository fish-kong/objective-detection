%Matlab��HOG����
function F = HOG(img, cellpw, cellph, nblockw, nblockh,nthet, overlap,issigned, normmethod)
% normmethod���ص����е�������׼�������ķ���
%       eΪһ���趨�ĺ�С����ʹ��ĸ��Ϊ0
%       vΪ��׼��ǰ����������
%       'none', which means non-normalization;
%       'l1', which means L1-norm normalization; V=V/(V+e)
%       'l2', which means L2-norm normalization; V=V/����(Vƽ��+eƽ��)
%       'l1sqrt',V=����(V/(V+e))
%       'l2hys',l2��ʡ����ʽ����V���ֵ����Ϊ0.2

if nargin < 2
    cellpw = 8;
    cellph = 8;
    nblockw = 2;
    nblockh = 2;
    nthet = 9;
    overlap = 0.5;
    issigned = 'unsigned';
    normmethod = 'l2hys';
else
    if 1<nargin &&  nargin< 9
        error('�����������.');
    end
end

[M, N, K] = size(img);  %MΪ������NΪ������KΪά��---��DALAL������ָ������rows:128*columns:64��������HOG���ֵ===M=128 N=64 K=3
if mod(M,cellph*nblockh) ~= 0   %��������Ϊ��ĸ߶ȵ�������
    error('ͼƬ��������Ϊ��ĸ߶ȵ�������.');
end
if mod(N,cellpw*nblockw) ~= 0   %��������Ϊ��Ŀ�ȵ�������
    error('ͼƬ��������Ϊ��Ŀ�ȵ�������.');
end                             
if mod((1-overlap)*cellpw*nblockw, cellpw) ~= 0 ||...  %Ҫʹ���������������
        mod((1-overlap)*cellph*nblockh, cellph) ~= 0
    error('���������ظ�������Ϊϸ����Ԫ�ߴ��������');
end

%���ø�˹�ռ�Ȩֵ���ڵķ���
delta = cellpw*nblockw * 0.5;

%% ����ͼ��ÿ�����ص��ݶȣ�������С�ͷ��򣩣���Ҫ��Ϊ�˲���������Ϣ��ͬʱ��һ���������յĸ��š�
%�����ݶȾ���  �ݶȵļ��㡾-1��0��1��Ч���Ǻܺõģ���3*3��sobel���ӻ���2*2�ĶԽǾ��󷴶���ϵͳ�Ľ���Ч��
hx = [-1,0,1];
hy = -hx';   %ת��
gradscalx = imfilter(double(img),hx);  %imfilter���˲�����hx��ʾ�˲���Ĥ
gradscaly = imfilter(double(img),hy);

if K > 1
    gradscalx = max(max(gradscalx(:,:,1),gradscalx(:,:,2)), gradscalx(:,:,3));  %ȡRGB�����ֵ
    gradscaly = max(max(gradscaly(:,:,1),gradscaly(:,:,2)), gradscaly(:,:,3));
end

gradscal = sqrt(double(gradscalx.*gradscalx + gradscaly.*gradscaly));  %�ݶȾ��� gradscal

% �����ݶȷ������
gradscalxplus = gradscalx+ones(size(gradscalx))*0.0001;  %��ֹΪ0������gradscalx����0.0001
gradorient = zeros(M,N);                                 %��ʼ���ݶȷ������
% unsigned situation: orientation region is 0 to pi.
if strcmp(issigned, 'unsigned') == 1                     %��������
    gradorient =...
        atan(gradscaly./gradscalxplus) + pi/2;           %��pi/2��Ϊatan������ȡֵ��-pi/2��ʼ
    or = 1;
else
    % signed situation: orientation region is 0 to 2*pi. %��������
    if strcmp(issigned, 'signed') == 1
        idx = find(gradscalx >= 0 & gradscaly >= 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx));
        idx = find(gradscalx < 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx)) + pi;
        idx = find(gradscalx >= 0 & gradscaly < 0);
        gradorient(idx) = atan(gradscaly(idx)./gradscalxplus(idx)) + 2*pi;
        or = 2;
    else
     %  error('Incorrect ISSIGNED parameter.');
        error('����ISSIGNED��������');
    end
end
%% 4 �ֿ�
% �����Ļ���
xbstride = cellpw*nblockw*(1-overlap);   %x����Ļ���
ybstride = cellph*nblockh*(1-overlap);
xbstridend = N - cellpw*nblockw + 1;     %x���������ܴﵽ�����ֵ
ybstridend = M - cellph*nblockh + 1;

% ������=ntotalbh*ntotalbw
ntotalbh = ((M-cellph*nblockh)/ybstride)+1; %���˵�һ��������ÿ������ֻ��Ҫybstride�Ϳ��Լ�һ��
ntotalbw = ((N-cellpw*nblockw)/xbstride)+1;

% hist3dbig�洢��άֱ��ͼ�������������һ������Է������
      hist3dbig = zeros(nblockh+2, nblockw+2, nthet+2);
        F = zeros(1, ntotalbh*ntotalbw*nblockw*nblockh*nthet);
        glbalinter = 0;
   
% ���ɴ洢һ���������ֵ������
sF = zeros(1, nblockw*nblockh*nthet);

% ���ɸ�˹Ȩֵ��ģ��
[gaussx, gaussy] = meshgrid(0:(cellpw*nblockw-1), 0:(cellph*nblockh-1));   %����һ���������
weight = exp(-((gaussx-(cellpw*nblockw-1)/2)...
    .*(gaussx-(cellpw*nblockw-1)/2)+(gaussy-(cellph*nblockh-1)/2)...
    .*(gaussy-(cellph*nblockh-1)/2))/(delta*delta));

% ȨֵͶƱ�����߲�ֵ
for btly = 1:ybstride:ybstridend
    for btlx = 1:xbstride:xbstridend
        for bi = 1:(cellph*nblockh)
            for bj = 1:(cellpw*nblockw)
                
                i = btly + bi - 1;       %����������ϵ�е�����
                j = btlx + bj - 1;
                gaussweight = weight(bi,bj);
                
                gs = gradscal(i,j);   %�ݶ�ֵ
                go = gradorient(i,j); %�ݶȷ���
                          
                % calculate bin index of hist3dbig
                % ����˸�ͳ���������ĵ������
                binx1 = floor((bj-1+cellpw/2)/cellpw) + 1;
                biny1 = floor((bi-1+cellph/2)/cellph) + 1;
                binz1 = floor((go+(or*pi/nthet)/2)/(or*pi/nthet)) + 1;
                
                if gs == 0
                    continue;
                end
                
                binx2 = binx1 + 1;
                biny2 = biny1 + 1;
                binz2 = binz1 + 1;
                
                x1 = (binx1-1.5)*cellpw + 0.5;
                y1 = (biny1-1.5)*cellph + 0.5;
                z1 = (binz1-1.5)*(or*pi/nthet);
                
                % trilinear interpolation.���߲�ֵ
                hist3dbig(biny1,binx1,binz1) =...
                    hist3dbig(biny1,binx1,binz1) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny1,binx1,binz2) =...
                    hist3dbig(biny1,binx1,binz2) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx1,binz1) =...
                    hist3dbig(biny2,binx1,binz1) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx1,binz2) =...
                    hist3dbig(biny2,binx1,binz2) + gs*gaussweight...
                    * (1-(bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
                hist3dbig(biny1,binx2,binz1) =...
                    hist3dbig(biny1,binx2,binz1) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny1,binx2,binz2) =...
                    hist3dbig(biny1,binx2,binz2) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*(1-(bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx2,binz1) =...
                    hist3dbig(biny2,binx2,binz1) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *(1-(go-z1)/(or*pi/nthet));
                hist3dbig(biny2,binx2,binz2) =...
                    hist3dbig(biny2,binx2,binz2) + gs*gaussweight...
                    * ((bj-x1)/cellpw)*((bi-y1)/cellph)...
                    *((go-z1)/(or*pi/nthet));
            end
        end
       
        %F����
            if or == 2   %�����ʱ��BINZ=nthet+2Ҫ���ظ�BINZ=2��BINZ=1Ҫ����BINZ=nthet+1
                         %��Ϊ����һ����β��ӵĻ�
                hist3dbig(:,:,2) = hist3dbig(:,:,2)...
                    + hist3dbig(:,:,nthet+2);
                hist3dbig(:,:,(nthet+1)) =...
                    hist3dbig(:,:,(nthet+1)) + hist3dbig(:,:,1);
            end
            hist3d = hist3dbig(2:(nblockh+1), 2:(nblockw+1), 2:(nthet+1));
            
        
            for ibin = 1:nblockh     %�Կ���ÿ��ϸ����Ԫ
                for jbin = 1:nblockw
                    idsF = nthet*((ibin-1)*nblockw+jbin-1)+1;
                    idsF = idsF:(idsF+nthet-1);
                    sF(idsF) = hist3d(ibin,jbin,:);  %ÿ��ϸ����Ԫ��nthet��BIN
                end
            end
            iblock = ((btly-1)/ybstride)*ntotalbw +...
                ((btlx-1)/xbstride) + 1;
            idF = (iblock-1)*nblockw*nblockh*nthet+1;
            idF = idF:(idF+nblockw*nblockh*nthet-1);
            F(idF) = sF;
            hist3dbig(:,:,:) = 0;
        
    end
end

F(F<0) = 0;   %��ֵ��0

%% ��һ������
e = 0.001;  %Ϊ�˷�ֹ��ĸ����0���趨һ����С��ֵe
l2hysthreshold = 0.2;
fslidestep = nblockw*nblockh*nthet;
switch normmethod
    case 'none'
    case 'l1'        %l1-norm
        for fi = 1:fslidestep:size(F,2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/(div+e);
        end
    case 'l1sqrt'    %l1-sqrt
        for fi = 1:fslidestep:size(F,2)
            div = sum(F(fi:(fi+fslidestep-1)));
            F(fi:(fi+fslidestep-1)) = sqrt(F(fi:(fi+fslidestep-1))/(div+e));
        end
    case 'l2'        %l2-norm
        for fi = 1:fslidestep:size(F,2)
            sF = F(fi:(fi+fslidestep-1)).*F(fi:(fi+fslidestep-1));
            div = sqrt(sum(sF)+e*e);
            F(fi:(fi+fslidestep-1)) = F(fi:(fi+fslidestep-1))/div;
        end
    case 'l2hys'     %l2-Hys �޶���󲻳���0.2
        for fi = 1:fslidestep:size(F,2)
            sF = F(fi:(fi+fslidestep-1)).*F(fi:(fi+fslidestep-1));
            div = sqrt(sum(sF)+e*e);
            sF = F(fi:(fi+fslidestep-1))/div;
            sF(sF>l2hysthreshold) = l2hysthreshold;
            div = sqrt(sum(sF.*sF)+e*e);
            F(fi:(fi+fslidestep-1)) = sF/div;
        end
    otherwise
        error('����NORMMETHOD���벻��ȷ');
end



