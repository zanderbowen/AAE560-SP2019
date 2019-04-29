function [comm_net] = CommunicationNetwork2(dir_vec,cust_vec,sup_vec, mach_vec, rec_vec, ven_vec)

%*** Small World-ish Network Where Machines Connects to Directos and Receiving Directly ***

%Input director, supervisor, machine, vendor, customer, and receiving
%object vectors/arrays. Generate the network topology used to communicate within
%the JS SoS.

%the node names will correspond to the objects created with similar
%notation

%Director
%Customer.unique_id
%Supervisor.functional_group
%Machine.functional_group.machine_number

% Assume there is only one director, this is the "seed" of the graph

%Initialize an empty undirected graph from which to build the network.
comm_net=graph({},{});

%add the director node
source={'Director'};
comm_net=addnode(comm_net,source);

%build the director-customer links
for i=1:length(cust_vec)
    target={['Customer.',num2str(cust_vec(i).unique_id)]};
    weight= 4;
    comm_net=addedge(comm_net,source,target,weight);
end

%build the director-supervisor links
%assume there is only one supervisor per machine group
for i=1:length(sup_vec)
    target={['Supervisor.',sup_vec(i).functional_group]};
    weight = 3;
    comm_net=addedge(comm_net,source,target,weight);
end

%build the director-machine links
for i=1:length(mach_vec)
    target=['Machine.',mach_vec(i).functional_group,num2str(mach_vec(i).machine_number)];
    weight = 3;
    comm_net=addedge(comm_net,source,target,weight);
end

%build the supervisor-machine links
%assume there is only one supervisor per machine group
for i=1:length(mach_vec)
    source={['Supervisor.',mach_vec(i).functional_group]};
    target={['Machine.',mach_vec(i).functional_group,num2str(mach_vec(i).machine_number)]};
    weight = 2;
    comm_net=addedge(comm_net,source,target,weight);
end

%build the supervisor-receiving links
%assume there is only a single receiving node
target={'Receiving'};
for i=1:length(sup_vec)
    source={['Supervisor.',sup_vec(i).functional_group]};
    weight = 3;
    comm_net=addedge(comm_net,source,target,weight);
end

%build the machine-receiving links
target={'Receiving'};
for i=1:length(mach_vec)
    source={['Machine.',mach_vec(i).functional_group,num2str(mach_vec(i).machine_number)]};
    weight = 3;
    comm_net=addedge(comm_net,source,target,weight);
end

%build the receiving-vendor links
%assume there is only a single receiving node
target={'Receiving'};
for i=1:length(ven_vec)
    source={['Vendor.',num2str(ven_vec(i).unique_id)]};
    weight = 4;
    comm_net=addedge(comm_net,source,target,weight);
end