%master production schedule where node 1 is time now
%node 2 is time at the end of currently known work

%source node - node 1 is the start of the schedule
source=[1 1 3 4 5 6];
%target node - node 3 is the finish node
target=[3 5 4 2 6 2];
%weights - duration of the activity
%0 weight is possible!!!
weight=[0 1 2 1 2 0];
%Activity (Edge) Name
activity={'S1'; 'S2'; '1.A'; 'E1'; '2.A'; 'E1'};

for i=1:length(weight)
    EdgeLabel{i}=[char(activity(i)),'=',num2str(weight(i))];
end

G=digraph(source,target,weight);

%adding activities names to the graph edge table
G.Edges.Activity=activity;

%adding EdgeLabel to the graph edge table
G.Edges.EdgeLabel=EdgeLabel';

%plotting the graph of the network schedule
figure;
h=plot(G,'EdgeLabel',G.Edges.EdgeLabel);
%try to layout the graph a little more like a Gantt Chart
layout(h,'layered','Direction','right','Sources',1);
%layout(h,'force','WeightEffect','direct'); - won't work with 0 edge weights
[HideNodeNames{1:numnodes(G)}]=deal('');
highlight(h,2,'Marker','hexagram','MarkerSize',10);
highlight(h,[3 4],'Marker','s','MarkerSize',7);
highlight(h,[5 6],'Marker','^','MarkerSize',7);
highlight(h,1,'MarkerSize',7);
labelnode(h,unique([source target]),HideNodeNames);