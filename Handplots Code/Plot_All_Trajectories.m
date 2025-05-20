% Plot_All_Trajectories
% RAS
% 08/06/2021

close all
clear

cd 'Block_A'
figure; hold on
Plot_Targets('A');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'


cd 'Block_B1'
figure; hold on
Plot_Targets('B');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'


cd 'Block_C1'
figure; hold on
Plot_Targets('C1');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'

cd 'Block_C2'
figure; hold on
Plot_Targets('C2');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'

cd 'Block_C3'
figure; hold on
Plot_Targets('C3');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'

cd 'Block_C4'
figure; hold on
Plot_Targets('C4');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'

cd 'Block_C5'
figure; hold on
Plot_Targets('C5');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'

cd 'Block_B2'
figure; hold on
Plot_Targets('B2');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'

cd 'Block_E'
figure; hold on
Plot_Targets('E');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end
axis equal
cd '..'

cd 'Block_F'
figure; hold on
Plot_Targets('F');
DirContents = dir;
DirContents(1:2)=[];
DirLength = length(DirContents)
for rasi=1:DirLength
    load(DirContents(rasi).name)
    DataIndices=find(TargetData(:,4));
    
    X=TargetData(DataIndices,3); 
    Y=TargetData(DataIndices,4);
    plot(X,Y,'k.')
    plot(X(end),Y(end),'r.','MarkerSize',12)
%     
%     whos
%     pause

end

axis equal
cd '..'



function Plot_Targets(PlotTitle)

hold on
title(PlotTitle);
for rasj=0:4
    for rask = 0:4
        plot((-0.29+(.02*rasj)),(0.56+(.02*rask)),'bo','MarkerSize',8)
    end
end
axis([-0.45 -0.10 0.53 0.8])
end