function f=myplot(x,y,xlength,ylength)  %»­ËÄÌõÏß
y1=y*ones(xlength+1);
x1=x*ones(ylength+1);  

i=x:x+xlength;
    plot(i,y1,'y');
    hold on;
    
i=x:x+xlength;
    plot(i,y1+ylength,'y');

 i=y:y+ylength;
    plot(x1,i,'y');

 i=y:y+ylength;
    plot(x1+xlength,i,'y');