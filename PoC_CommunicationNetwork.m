clear all


%instantiate customer object
cust=Customer.empty;

%add a customer to the object array - A

cust=[cust; Customer(1,0)];

%instantiate director object
dir=Director();

%instantiate a an empty object array of class Supervisor
sup=Supervisor.empty;

%add a supervisor object to the array - A
sup=[sup; Supervisor('A',{sup.functional_group})];
%add a supervisor object to the array - B
sup=[sup; Supervisor('B',{sup.functional_group})];
%add a supervisor object to the array - C
sup=[sup; Supervisor('C',{sup.functional_group})];

%instantiate an empty object array for machines
m_arr=Machine.empty;

%add a machine object A.1 to the machine array
m_arr=[m_arr; Machine('A',{sup.functional_group},1,[m_arr.full_name],8)];
%add a machine object B.1 to the machine array
m_arr=[m_arr; Machine('B',{sup.functional_group},1,[m_arr.full_name],8)];
%add a machine object C.1 to the machine array
m_arr=[m_arr; Machine('C',{sup.functional_group},1,[m_arr.full_name],8)];

% %create an empty object array of Class Receiving
rec=Receiving.empty;
% 
% %instantiate Receiving - #1
rec=[rec; Receiving];

%create an empty object array of Class Vendor
ven=Vendor.empty;

%instantiate vendor - #1
ven=[ven; Vendor(1,[ven.unique_id],2,5,'n')];

%comm_net=CommunicationNetwork(dir,cust,sup,m_arr,rec,ven);
%comm_net=CommunicationNetwork2(dir,cust,sup,m_arr,rec,ven);
%comm_net=CommunicationNetwork3(dir,cust,sup,m_arr,rec,ven);
comm_net=CommunicationNetwork6(dir,cust,sup,m_arr,rec,ven);

%plot(comm_net,'EdgeLabel',comm_net.Edges.Weight)
