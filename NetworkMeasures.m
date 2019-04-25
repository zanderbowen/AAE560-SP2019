function node_table = ClusteringCoefficient(G)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%number of nodes
nnodes=numnodes(G);

%pull out the adjacency matrix
A=full(adjacency(G));

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

%add the clustering coefficient calculation to the graph node table
G.Nodes.ClusteringCoeff=CC';

%betweeness centrality
B=centrality(G,'betweenness');
B=B*(2/((nnodes-1)*(nnodes-2)));

% add the betweeness centrality calculation to the graph node table
G.Nodes.BCentrality=B;

node_table=G.Nodes;

end

