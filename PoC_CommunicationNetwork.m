
%instantiate customer object
cust=Customer.empty;

%add a customer to the object array - A
cust = [cust; Customer(0,0,1)];

%instantiate director object
dir=Director();

%instantiate a an empty object array of class Supervisor
sup=Supervisor.empty;

%add a supervisor object to the array - A
sup=[sup; Supervisor('A',{sup.functional_group})];

%instantiate an empty object array for machines
m_arr=Machine.empty;

%add a machine object A.1 to the machine array
m_arr=[m_arr; Machine('A',{sup.functional_group},1,[m_arr.full_name],8)];

% %create an empty object array of Class Receiving
rec=Receiving.empty;
% 
% %instantiate Receiving - #1
rec=[rec; Receiving];

%create an empty object array of Class Vendor
ven=Vendor.empty;

%instantiate vendor - #1
ven=[ven; Vendor(1,[ven.unique_id],2)];

comm_net=CommunicationNetwork(dir,cust,sup,m_arr,rec,ven);

plot(comm_net)
