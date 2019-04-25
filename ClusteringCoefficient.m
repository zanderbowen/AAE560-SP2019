function CC = ClusteringCoefficient(G)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

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

end

