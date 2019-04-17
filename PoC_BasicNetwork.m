close all;
clear;
clc;

%source node
source=[1 2 3 3 4 4 5 5 5 6 6 6];
%target node
target=[3 4 5 6 5 6 7 8 9 10 11 12];

G=graph(source,target);

%adding names after the fact
nodenames={'Customer' 'Vendor' 'Director' 'Receiving' 'Supervisor A'...
    'Supervisor B' 'A1' 'A2' 'A3' 'B1' 'B2' 'B3'}';

%find the adjacency matrix - shortcut instead of manually entering weights
A=full(adjacency(G));

G=graph(A,nodenames);

figure;
h=plot(G);
highlight(h,1,'NodeColor','g');
highlight(h,2,'NodeColor','r');
highlight(h,[7 8 9 10 11 12],'NodeColor','m');
highlight(h,[3 5 6],'NodeColor','k');
h.MarkerSize=7;
h.EdgeColor='k';
set(gca,'xtick',[]);
set(gca,'ytick',[]);

%number of nodes
nnodes=numnodes(G);

%calculate number of triangles
triangles=diag(A^3)./2;

for i=1:nnodes
    if degree(G,i)<2
        triples(i)=0;
    else
        triples(i)=nchoosek(degree(G,i),2);
    end
end

%clustering coefficient
CC=triangles'./triples;

%betweeness centrality
B=centrality(G,'betweenness');
B=B*(2/((nnodes-1)*(nnodes-2)));

%distance matrix
D=distances(G);

%eccentricty of the graph
eccentricity=max(D,[],2);

%diameter of the graph
diameter=max(eccentricity);

%degree distribution
temp=tabulate(degree(G));
indicies=find(temp(:,2)~=0);
uniquedeg=temp(indicies,1);
degdist=temp(indicies,3)./100;

%calculate degree cummulative distribution
for i=length(degdist):-1:1
    if i==length(degdist)
        cummdist(i)=degdist(i);
    else
        cummdist(i)=degdist(i)+cummdist(i+1);
    end
end
%plot
figure;
subplot(1,2,2)
plot(uniquedeg,cummdist,'-o');
ylim([0 1]);
xlabel('Degree');
ylabel('Cummulative Distribution');
subplot(1,2,1)
histogram(degree(G),'Normalization','probability');
xlabel('Degree');
ylabel('Probability');

%degree correlation
for i=1:nnodes
    ki=0;
    N=neighbors(G,i);
    %calculate the summation of degrees of nodes with a degree to the
    %node of interest
    sum_kj=0;
    for j=1:length(N)
        ki=G.Edges.Weight(findedge(G,N(j),i))+ki;
        N2=neighbors(G,N(j));
        %for jj=1:length(N2)
            %sum_kj=G.Edges.Weight(findedge(G,N2(jj),N(j)))+sum_kj;
        %end
        sum_kj=G.Edges.Weight(findedge(G,N(j),i))*degree(G,N(j))+sum_kj;
    end
    
    
    %calculate the degree correlation
    knn(i)=sum_kj/degree(G,i);
    
end

deg=degree(G);

%plot degree correlation and nodal degree
[temp index]=sort(deg);


if any(logical(isnan(knn)))
    warning('The knn_in_in vector contains a NaN value, curve fitting will not work.');
end
figure;
scatter(deg(index),knn(index));
hold on;
p=polyfit(deg(index)',knn(index),1);
plot(deg(index),polyval(p,deg(index)));
hold off;
grid on;
xlabel('Degree');
ylabel('Degree Correlation');

%ploting cummulative degree distribution to determine the network type
figure;
subplot (2,2,1)
plot(uniquedeg,cummdist,'-o');
grid on;
xlabel('Degree');
ylabel('p(k)');

subplot(2,2,2)
loglog(uniquedeg,cummdist,'-o');
grid on;
xlabel('Degree');
ylabel('p(k)');

subplot(2,2,3)
semilogx(uniquedeg,cummdist,'-o');
grid on;
xlabel('Degree');
ylabel('p(k)');

subplot(2,2,4)
semilogy(uniquedeg,cummdist,'-o');
grid on;
xlabel('Degree');
ylabel('p(k)');