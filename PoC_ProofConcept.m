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

%instantiate a job shop work orders variable
js_wos=WorkOrder.empty;

%instantiate job shop work order
js_wos=genWO(js_wos,cust.new_wo,cust.new_wo_due_date,[js_wos.unique_id]);

%setting properties in customer to tell WO to generate more WOs
cust.new_wo=1;
cust.new_wo_due_date=20;

%make this an array of WorkOrder objects
js_wos=genWO(js_wos,cust.new_wo,cust.new_wo_due_date,[js_wos.unique_id]);

%change due date to the second WO
js_wos(2).due_date=30;

%access the second work order due date - as a check
js_wos(2).due_date

for i=1:length(js_wos)
    if strcmp(js_wos(i).status,'new')
        [js_wos(i).routing,js_wos(i).status]=generateRouting(dir);
    end
    
    if strcmp(js_wos(i).status,'planned')
        [js_wos(i).start_date js_wos(i).cp_duration]=calculateStartDate(js_wos(i));
    end
end

%instantiate Job Shop schedule object
js_sch=JobShopSchedule;

%add WOs to master schedule
[js_sch.master_schedule revised_wo_dates]=addWoToMasterSchedule(js_sch,js_wos(masterSchedule(dir, js_wos)));

%cludge to set js_wos.master_schedule to 1
temp=findobj(js_wos,'master_schedule',0);
for i=1:length(temp)
    js_wos(temp(i).unique_id).master_schedule=1;
end

%setting properties in customer to tell WO to generate more WOs
cust.new_wo=1;
cust.new_wo_due_date=20;

%make this an array of WorkOrder objects
js_wos=genWO(js_wos,cust.new_wo,cust.new_wo_due_date,[js_wos.unique_id]);

for i=1:length(js_wos)
    if strcmp(js_wos(i).status,'new')
        [js_wos(i).routing,js_wos(i).status]=generateRouting(dir);
    end
    
    if strcmp(js_wos(i).status,'planned')
        [js_wos(i).start_date js_wos(i).cp_duration]=calculateStartDate(js_wos(i));
    end
end

%add new WO to master schedule
[js_sch.master_schedule revised_wo_dates]=addWoToMasterSchedule(js_sch,js_wos(masterSchedule(dir, js_wos)));

%plotting the graph of the network schedule
figure;
h=plot(js_sch.master_schedule,'EdgeLabel',js_sch.master_schedule.Edges.EdgeLabel);
%try to layout the graph a little more like a Gantt Chart
layout(h,'layered','Direction','right','Sources',1);
%layout(h,'force','WeightEffect','direct'); - won't work with 0 edge weights
[HideNodeNames{1:numnodes(js_sch.master_schedule)}]=deal('');
%needs some work... labelnode(h,unique([source target]),HideNodeNames);
