close all;
clear;
clc;

%network schedule starting and ending nodes
SchStartNode=1;
SchEndNode=2;

%source node - node 1 is the start of the schedule
source=[1 1 1 3 4 5 6];
%target node - node 3 is the finish node
target=[3 4 5 5 5 6 2];
%weights - duration of the activity
weight=[5 3 7 8 7 4 5];
%Activity (Edge) Name
activity={'A'; 'B'; 'E'; 'C'; 'D'; 'F'; 'G'};

G=digraph(source,target,weight);

%adding edge names to the graph edge table
G.Edges.Activity=activity;

%pre-populate early start and early finish
G.Edges.ES=NaN([length(weight) 1]);
G.Edges.EF=NaN([length(weight) 1]);

%pre-populate late start and late finish
G.Edges.LS=NaN([length(weight) 1]);
G.Edges.LF=NaN([length(weight) 1]);

if ~isdag(G)
    error('Graph of schedule must not have any cycles.');
end

%compute the negative weight
NegWeight=-1*weight;

%since the starting and ending nodes are known, use negative weights
%to actually find the longest path - which is the critical path
GNeg=digraph(source,target,NegWeight);

[CriticalPath temp CPEdgeIndex]=shortestpath(GNeg,SchStartNode,SchEndNode);

%plotting the graph of the network schedule
h=plot(G,'EdgeLabel',G.Edges.Activity);
%highlighting the critical path
highlight(h,'Edges',CPEdgeIndex,'EdgeColor','r');
highlight(h,SchStartNode,'NodeColor','g');
highlight(h,SchEndNode,'NodeColor','r');

%using pathbetweennodes function to find all paths between the start and finish
%nodes
paths=pathbetweennodes(adjacency(G), SchStartNode, SchEndNode);

%convert the paths to activity sequences
ActSeq={};
ct=1;
for i=1:length(paths)
    temp=cell2mat(paths(i));
    temp2={};
    for j=1:length(temp)-1
        temp2=[temp2, G.Edges.Activity(find(ismember(G.Edges.EndNodes,[temp(j) temp(j+1)],'rows')))];
        EdgeTally{ct}=cell2mat(G.Edges.Activity(find(ismember(G.Edges.EndNodes,[temp(j) temp(j+1)],'rows'))));
        ct=ct+1;
    end
    ActSeq=[ActSeq; {temp2}];
end

%error checking for the appropriate ending and starting nodes
    if length(unique(EdgeTally))~=numedges(G)
        error(['All paths through the schedule shall start at node ',num2str(SchStartNode),' and end at node ',num2str(SchEndNode),'.']);
    end

%perform forward and backward scheduling to determine early start/finish and late
%start/finishes

%early start and finish
%start with edges connected to SchStartNode
S=successors(G,SchStartNode);
for i=1:length(S)
    EdgeIndex=find(ismember(G.Edges.EndNodes,[SchStartNode S(i)],'rows'));
    G.Edges.ES(EdgeIndex)=0;
    G.Edges.EF(EdgeIndex)=G.Edges.Weight(EdgeIndex);
end

%brute force loop through remaining edges to calculate ES and EF
ct=1;
while any(isnan(G.Edges.ES)) || any(isnan(G.Edges.EF))
    if isnan(G.Edges.ES(ct)) || isnan(G.Edges.EF(ct))
        %check preceeding edges have EF calculated
        Node=G.Edges.EndNodes(ct,1);
        P=predecessors(G,Node);
        for i=1:length(P)
            EF(i)=G.Edges.EF(find(ismember(G.Edges.EndNodes,[P(i) Node],'rows')));
        end
        
        %check to ensure that ES and EF can be calculated then calculate
        if ~any(isnan(EF))
            G.Edges.ES(ct)=max(EF);
            G.Edges.EF(ct)=max(EF)+G.Edges.Weight(ct);
        end
    end
    
    %increment counter or reset it
    if ct>=length(G.Edges.ES)
        ct=1;
    else
        ct=ct+1;
    end
    
    %clear EF variable
    clear EF;
end

%late start and finish
%start with edges connected to SchEndNode
P=predecessors(G,SchEndNode);
for i=1:length(P)
    EdgeIndex=find(ismember(G.Edges.EndNodes,[P(i) SchEndNode],'rows'));
    G.Edges.LF(EdgeIndex)=max(G.Edges.EF);
    G.Edges.LS(EdgeIndex)=G.Edges.LF(EdgeIndex)-G.Edges.Weight(EdgeIndex);
end

%brute force loop through remaining edges to calculate LS and LF

ct=1;
while any(isnan(G.Edges.LS)) || any(isnan(G.Edges.LF))
    if isnan(G.Edges.LS(ct)) || isnan(G.Edges.LF(ct))
        %check preceeding edges have EF calculated
        Node=G.Edges.EndNodes(ct,2);
        S=successors(G,Node);
        for i=1:length(S)
            LS(i)=G.Edges.LS(find(ismember(G.Edges.EndNodes,[Node S(i)],'rows')));
        end
        
        %check to ensure that ES and EF can be calculated then calculate
        if ~any(isnan(LS))
            G.Edges.LF(ct)=min(LS);
            G.Edges.LS(ct)=min(LS)-G.Edges.Weight(ct);
        end
        
        %clear LS variable
        clear LS;
    end
    
    %increment counter or reset it
    if ct>=length(G.Edges.ES)
        ct=1;
    else
        ct=ct+1;
    end
end

%calculate the total slack
G.Edges.TS=G.Edges.LS-G.Edges.ES;