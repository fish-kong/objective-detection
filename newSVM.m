function predictedY=newSVM(testvector)
%%
load pos.mat;
load neg.mat;
[num1,a]=size(posvector);
[num2,b]=size(negvector);
x=posvector';
y=negvector';
y1=ones(1,num1);
y2=-ones(1,num2);
% �����������������
X=[x,y]';
Y=[y1,y2]';
%% SVM��������
C=10;
ker='linear';%ker='rbf';
global p1 p2
p1=10;% �˲���
p2=1;% ��Щ�˺������������˲���
%% ѵ��ģ�� 
[nsv alpha bias] = svc(X,Y,ker,C);  %ģ�ͳ����󣬱������  �´�ֱ�ӵ���
% save alpha.mat alpha
% save nsv.mat nsv
% save bias.mat bias

%% ����
predictedY = svcoutput(X,Y,testvector,ker,alpha,bias);




 
 
 
 