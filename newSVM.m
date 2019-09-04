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
% 输入样本与输出样本
X=[x,y]';
Y=[y1,y2]';
%% SVM参数设置
C=10;
ker='linear';%ker='rbf';
global p1 p2
p1=10;% 核参数
p2=1;% 有些核函数具有两个核参数
%% 训练模型 
[nsv alpha bias] = svc(X,Y,ker,C);  %模型出来后，保存参数  下次直接调用
% save alpha.mat alpha
% save nsv.mat nsv
% save bias.mat bias

%% 测试
predictedY = svcoutput(X,Y,testvector,ker,alpha,bias);




 
 
 
 