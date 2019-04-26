clear;
clc;
close all;

%flag to plot the schedule or not
plot_master=1;

%add a variable to simulate the timer
current_time=0;

%instantiate customer object
cust=Customer(1,0);

%instantiate director object
dir=Director();

%setting properties in customer to tell WO to generate more WOs
cust.new_wo=1;
cust.new_wo_due_date=10;

%instantiate a job shop work order object array
js_wos=WorkOrder.empty;

%add a job shop work order to the array - #1
js_wos=genWO(js_wos,cust.new_wo,cust.new_wo_due_date,[js_wos.unique_id]);

%setting properties in customer to tell WO to generate more WOs
cust.new_wo=1;
cust.new_wo_due_date=20;

%add a job shop work order to the array - #2
js_wos=genWO(js_wos,cust.new_wo,cust.new_wo_due_date,[js_wos.unique_id]);

%generate routing for new WOs, for planned WOs calcuated the critical path
for i=1:length(js_wos)
    if strcmp(js_wos(i).status,'new')
        [js_wos(i).routing,js_wos(i).status]=generateRouting(dir);
    end
    
    if strcmp(js_wos(i).status,'planned') && js_wos(i).master_schedule==0
        [js_wos(i).start_date js_wos(i).cp_duration]=calculateStartDate(js_wos(i));
    end
end

%instantiate Job Shop Schedule object
js_sch=JobShopSchedule(0);

%add WOs to master schedule
[js_sch.master_schedule revised_wo_dates]=addWoToMasterSchedule(js_sch,js_wos(masterSchedule(dir, js_wos)));
%update start and end dates and master_schedule flag
js_wos=updateDates(js_wos,revised_wo_dates);

%setting properties in customer to tell WO to generate more WOs
cust.new_wo=1;
cust.new_wo_due_date=20;

%add a job shop work order to the array - #3
js_wos=genWO(js_wos,cust.new_wo,cust.new_wo_due_date,[js_wos.unique_id]);

for i=1:length(js_wos)
    if strcmp(js_wos(i).status,'new')
        [js_wos(i).routing,js_wos(i).status]=generateRouting(dir);
    end
    
    if strcmp(js_wos(i).status,'planned') && js_wos(i).master_schedule==0
        [js_wos(i).start_date,js_wos(i).cp_duration]=calculateStartDate(js_wos(i));
    end
end

%add new WO to master schedule
[js_sch.master_schedule revised_wo_dates]=addWoToMasterSchedule(js_sch,js_wos(masterSchedule(dir, js_wos)));
%update start and end dates and master_schedule flag
js_wos=updateDates(js_wos,revised_wo_dates);

%plotting the graph of the network schedule
    if plot_master==1
    figure;
    h=plot(js_sch.master_schedule,'EdgeLabel',js_sch.master_schedule.Edges.EdgeLabel);
    %try to layout the graph a little more like a Gantt Chart
    layout(h,'layered','Direction','right','Sources',1);
    %layout(h,'force','WeightEffect','direct'); - won't work with 0 edge weights
    % [HideNodeNames{1:numnodes(js_sch.master_schedule)}]=deal('');
    %needs some work... labelnode(h,unique([source target]),HideNodeNames);
end

%instantiate a an empty object array of class Supervisor
sup=Supervisor.empty;

%add a supervisor object to the array - A
sup=[sup; Supervisor('A',{sup.functional_group})];

%add a supervisor object to the array - B
sup=[sup; Supervisor('B',{sup.functional_group})];

%have the supervisors get the job queues from the master schedule
sup=getWork(sup,js_sch.master_schedule.Edges);

%instantiate an empty object array for machines
m_arr=Machine.empty;

%add a machine object A.1 to the machine array
m_arr=[m_arr; Machine('A',{sup.functional_group},1,[m_arr.full_name],8)];

%add a machine object B.1 to the machine array
m_arr=[m_arr; Machine('B',{sup.functional_group},1,[m_arr.full_name],8)];

%!!! supervisor should check for completed work before assigning new work !!!
%??? need to think about order of operations for functions that run inside
%of the wrapper ???

%??? hoping findoj updates machines accordingly ???
%run_machines=performWork(findobj(m_arr,'status','running'),js_wos);

%update work order

%testing out assignWork and processPO supervisor and vendor methods
%js_wos(1).routing.Edges.VendorPart(1)=1;
js_wos(1).routing.Edges.VendorPart(2)=1;
js_wos(2).routing.Edges.VendorPart(1)=1;

%supervisor to assign work to a machine and update WOs to released
for i=1:length(sup)
    %find all machines in a particular functional group that are idle
    f_grp_idle_machines=findobj(m_arr,'functional_group',sup(i).functional_group,'-and','status','idle');
    %passing f_grp_machines back from the assign work function should update the m_arr object array accordingly
    [f_grp_idle_machines sup js_wos]=assignWork(sup,f_grp_idle_machines,js_wos,i,current_time);
    clear f_grp_machines
end

%create an empty object array of Class Vendor
ven=Vendor.empty;

%instantiate vendor - #1
ven=[ven; Vendor(1,[ven.unique_id],2)];

%for testing purposes after a supervisor has assigned work since I don't
%have the timer wrapper right now
for i=1:max(js_sch.master_schedule.Edges.LF)
    [run_machines js_wos]=performWork(findobj(m_arr,'status','running'),js_wos);
end
clear run_machines

%testing the Vendor Class processPO method
ven=processPO(ven,js_wos,js_sch); 

%testing the Vendor Class deliverPart method
for i=1:max(js_sch.master_schedule.Edges.LF)+1
    [ven js_wos]=deliverPart(ven,js_wos,i-1);
end

% **** stuff in work right now ***
%search for work orders with status in-work
wos_in_work=findobj(js_wos,'status','in-work');
%search for work orders with status planned
wos_planned=findobj(js_wos,'status','planned');

%update the master schedule before closing WOs to avoid the code havint to loop thru closed ones
%update master schedule
js_sch.master_schedule=updateMasterSchedule(js_sch,wos_in_work,wos_planned);

%plotting the graph of the network schedule - flag to plot is at top of code
if plot_master==1
    figure;
    h1=plot(js_sch.master_schedule,'EdgeLabel',js_sch.master_schedule.Edges.EdgeLabel);
    %try to layout the graph a little more like a Gantt Chart
    layout(h1,'layered','Direction','right','Sources',1);
    %layout(h,'force','WeightEffect','direct'); - won't work with 0 edge weights
    % % [HideNodeNames{1:numnodes(js_sch.master_schedule)}]=deal('');
    % %needs some work... labelnode(h,unique([source target]),HideNodeNames);
end

%search for open work order (i.e. not closed or cancelled)
open_wos=findobj(js_wos,'status','new','-or','status','planned','-or','status','in-work');
%call closeWO method to check to see if the WO status should be set to closed
open_wos=closeWO(open_wos);
