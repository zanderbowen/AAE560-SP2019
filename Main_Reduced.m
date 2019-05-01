clear all;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%                                MAIN.m                                   %
%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   This script acts as the integrating wrapper for the SoS simulation,   %
%   instantiating the necessary objects and functions to analyze the SoS  %
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
[dir, sup, mach, rec] = createJobShop(1,3,3,1);
%   In this case, a Job Shop was created with 1 Director, 3 Supervisors, 3
%   Machines, and 1 Receiving focal.
%
%   Create Vendor Base:
[ven] = createVendor(1,2,5,'n');
%   In this case, one Vendor is used.  This Vendor is an abstract
%   representation of a larger Vendor base, and has an early delivery
%   requirement of 2.
%
%   Create Customer Base:
[cust] = createCustomer(1);
%   In this case, one Customer is being used.  This Customer is an abstract
%   representation of a larger Customer base.

%-------------------------------------------------------------------------%
%   1.B Create Communication Network                                      %
%-------------------------------------------------------------------------%

%   Map the network via the CommunicationNetwork function:
comm_net = CommunicationNetwork(dir, cust, sup, mach, rec, ven);
%
%   Plot the network and determine network characteristics:
NetworkMeasures(comm_net);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%                       2. GENERATE WORK ORDER(S)                         %
%-------------------------------------------------------------------------%
%                                                                         %
%   Once the various objects are created, a number of work orders is      %
%   generated via a specialized function 'createWO'                       %                                                                  
%                                                                         %
%-------------------------------------------------------------------------%
%   2.A Create Work Order(s)                                              %
%-------------------------------------------------------------------------%

%   Instantiate an empty work order object js_wos
js_wos=WorkOrder.empty;

%   Now populate work order with desired number and due dates
[ js_wos, cust ] = createWO(300, 20, cust, js_wos);
[ js_wos, cust ] = createWO(150, 10, cust, js_wos);
[ js_wos, cust ] = createWO(50, 30, cust, js_wos);
%   In this case, a total of 500 orders will be produced; 300 with a 20 hr
%   duration (representing typical orders), 150 with a 10 hr duration
%   (representing easier, fill-in orders), and 50 with a 30 hr duration
%   (representing tougher, less-frequent orders).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------%
%                       3. ROUTING WORK ORDER(S)                          %
%-------------------------------------------------------------------------%
%                                                                         %
%   Once the work orders are generated, they are routed through the job   %
%   shop via the director.  This step also requires the work orders to    %
%   be routed to external entities (vendor); finally, the director        %
%   object assignes scheduling data to each work order, which the job     %
%   shop is tasked with meeting.                                          %
%                                                                         %
%-------------------------------------------------------------------------%
%   3.A Route through Director                                            %
%-------------------------------------------------------------------------%
%Director sets up routing
[js_wos] = routing( js_wos, dir );

%                           !! WARNING !!
%POPULATING THE SCHEDULE IS A TIME INTENSIVE TASK.  IF YOU INTEND TO ONLY
%VIEW NETWORK PROPERTIES VIEW SIMPLIFIED SCHEDULE VARIANCE DATA, BYPASS 
%THIS SECTION BY SETTING "runScheduling" TO ZERO

%   Switch to Bypass Scheduling
runScheduling = 1;

if runScheduling == 1
    
    %   Instantiate Job Shop Schedule object
    js_sch=JobShopSchedule(2);
    %   the value passed into the function is the buffer time the director 
    %   would set between work orders/
    
    %   Add WOs to master schedule
    [js_sch.master_schedule,revised_wo_dates,wo_ef_initial]=...
        addWoToMasterSchedule(js_sch,js_wos(masterSchedule(dir, js_wos)));
    
    for i=1:length(wo_ef_initial.id)
        js_wos(wo_ef_initial.id(i)).initial_start_edge_EF=wo_ef_initial.ef(i);
    end
    clear wo_ef_initial
    
    %   Update start and end dates
    js_wos=updateDates(js_wos,revised_wo_dates);

    %   Display the master_schedule 
    js_sch.master_schedule.Edges;
    
    %   Switch to display network schedule plot
    plot_master=1;

    %   Plotting the graph of the network schedule
    if plot_master==1
        figure;
        h=plot(js_sch.master_schedule,'EdgeLabel',js_sch.master_schedule.Edges.EdgeLabel);
        %try to layout the graph a little more like a Gantt Chart
        layout(h,'layered','Direction','right','Sources',1);
        %layout(h,'force','WeightEffect','direct'); - won't work with 0 edge weights
    end
end

%-------------------------------------------------------------------------%
%   3.B Route Vendor and Job Shop                                         %
%-------------------------------------------------------------------------%

%	Running work orders down to machine level and executing.  We first loop
%   for each work order, and nest a loop for each operation within a given 
%   work order.  Each work order object is then updated.
for i = 1:length(js_wos)
    for j = 1:length(mach)
        [js_wos(i)] = scheduleVariance(comm_net, js_wos(i), ...
            js_wos(i).routing.Edges.Weight(j), ...
            js_wos(i).routing.Edges.Operation(j),j);
    end
end
