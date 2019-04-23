clear all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%                                MAIN.m                                   %
%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   This script acts as the integrating wrapper for the SoS simulation...   
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%                       1. CREATE SoS ARCHITECTURE                        %
%-------------------------------------------------------------------------%
%                                                                         %
%   This simulation will include a Job Shop (consisting of director(s),   %
%   supervisor(s), machine(s), and receiving), a defined number of        %
%   customers, and a defined number of vendors. This section instantiates % 
%   these systems, then developes the network that these systems use to   %
%   communicate (externally and internally)                               %
%                                                                         %
%   RESTRICTIONS:                                                         %
%   1. Number of machines must be divisible by number of supervisors      %
%                                                                         %
%-------------------------------------------------------------------------%
%   1.A Create Systems                                                    %
%-------------------------------------------------------------------------%

%   Create Job Shop (Director(s), Supervisor(s), Machine(s), & Receiving):
[dir, sup, mach, rec] = createJobShop(1,2,4,1);
%   In this case, a Job Shop was created with 1 Director, 2 Supervisors, 4
%   Machines, and 1 Receiving focal.

%   Create Vendor Base:
[ven] = createVendor(1,2);
%   In this case, one Vendor is used.  This Vendor is an abstract
%   representation of a larger Vendor base, and has an early delivery
%   requirement of 2.

%   Create Customer Base:
[cust] = createCustomer(1);
%   In this case, one Customer is being used.  This Customer is an abstract
%   representation of a larger Customer base.
%
%
%-------------------------------------------------------------------------%
%   1.B Create Communication Network                                      %
%-------------------------------------------------------------------------%

%   Map the network via the CommunicationNetwork function:
comm_net = CommunicationNetwork(dir, cust, sup, mach, rec, ven);

%   Plot the network:
plot(comm_net)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%                       2. GENERATE WORK ORDER(S)                         %
%-------------------------------------------------------------------------%
%                                                                         %
%   This simulation ...                                                   %
%                                                                         %
%   RESTRICTIONS:                                                         %
%   1.                                                                    %
%                                                                         %
%-------------------------------------------------------------------------%
%   2.A Create Work Order(s)                                              %
%-------------------------------------------------------------------------%

%Instantiate an empty work order object js_wos
js_wos=WorkOrder.empty;

%Now populate work order with desired number and due dates
[ js_wos, cust ] = createWO(1, 10, cust, js_wos);
[ js_wos, cust ] = createWO(1, 20, cust, js_wos);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%                       3. ROUTING WORK ORDER(S)                          %
%-------------------------------------------------------------------------%
%                                                                         %
%   This simulation ...                                                   %
%                                                                         %
%   RESTRICTIONS:                                                         %
%   1.                                                                    %
%                                                                         %
%-------------------------------------------------------------------------%
%   3.A Route through Director                                            %
%-------------------------------------------------------------------------%
%Director sets up routing
[js_wos] = routing( js_wos, dir );

%instantiate Job Shop Schedule object
js_sch=JobShopSchedule(0);

%add WOs to master schedule
[js_sch.master_schedule, revised_wo_dates]=addWoToMasterSchedule(js_sch,js_wos(masterSchedule(dir, js_wos)));
%update start and end dates and master_schedule flag
js_wos=updateDates(js_wos,revised_wo_dates);

%add a job shop work order to the array - #3
[ js_wos, cust ] = createWO(1, 20, cust, js_wos);
[js_wos] = routing( js_wos, dir );

%add new WO to master schedule
[js_sch.master_schedule, revised_wo_dates]=addWoToMasterSchedule(js_sch,js_wos(masterSchedule(dir, js_wos)));
%update start and end dates and master_schedule flag
js_wos=updateDates(js_wos,revised_wo_dates);

%plotting the graph of the network schedule
figure;
h=plot(js_sch.master_schedule,'EdgeLabel',js_sch.master_schedule.Edges.EdgeLabel);
%try to layout the graph a little more like a Gantt Chart
layout(h,'layered','Direction','right','Sources',1);
%layout(h,'force','WeightEffect','direct'); - won't work with 0 edge weights
% [HideNodeNames{1:numnodes(js_sch.master_schedule)}]=deal('');
%needs some work... labelnode(h,unique([source target]),HideNodeNames);

%-------------------------------------------------------------------------%
%   3.B Route through Vendor                                              %
%-------------------------------------------------------------------------%

%Vendor Class processPO method
ven=processPO(ven,js_wos,js_sch); 

%Vendor Class deliverPart method
for i=1:max(js_sch.master_schedule.Edges.LF)+1
    [ven, js_wos]=deliverPart(ven,js_wos,i-1);
end

%-------------------------------------------------------------------------%
%   3.C Route through Supervisors & Machines                              %
%-------------------------------------------------------------------------%

%have the supervisors get the job queues from the master schedule
sup=getWork(sup,js_sch.master_schedule.Edges);

%!!! supervisor should check for completed work before assigning new work !!!
%??? need to think about order of operations for functions that run inside
%of the wrapper ???

%??? hoping findoj updates machines accordingly ???
run_machines=performWork(findobj(mach,'status','running'),js_wos);

%update work order

current_time = 3;
%supervisor to assign work to a machine and update WOs to released
for i=1:length(sup)
    %find all machines in a particular functional group that are idle
    f_grp_idle_machines=findobj(mach,'functional_group',sup(i).functional_group,'-and','status','idle');
    %passing f_grp_machines back from the assign work function should update the m_arr object array accordingly
    [f_grp_idle_machines, sup, js_wos]=assignWork(sup,f_grp_idle_machines,js_wos,i,current_time);
    clear f_grp_machines
end
clear i