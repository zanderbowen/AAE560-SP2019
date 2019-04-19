clear;
clc;
close all;

%instantiate customer object
cust=Customer(0,0);

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
% figure;
% h=plot(js_sch.master_schedule,'EdgeLabel',js_sch.master_schedule.Edges.EdgeLabel);
% %try to layout the graph a little more like a Gantt Chart
% layout(h,'layered','Direction','right','Sources',1);
% %layout(h,'force','WeightEffect','direct'); - won't work with 0 edge weights
% [HideNodeNames{1:numnodes(js_sch.master_schedule)}]=deal('');
%needs some work... labelnode(h,unique([source target]),HideNodeNames);

%instantiate a an empty object array of class Supervisor
sup=Supervisor.empty;

%add a supervisor object to the array - A
sup=[sup; Supervisor('A')];

%have the supervisors get the job queues from the master schedule
sup=getWork(sup,js_sch.master_schedule.Edges);