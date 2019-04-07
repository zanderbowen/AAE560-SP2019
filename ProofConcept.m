clear;
clc;

%instantiate customer object
cust=Customer(0,0);

%instantiate director object
dir=Director();

%setting properties in customer to tell WO to generate more WOs
cust.new_wo=1;
cust.new_wo_due_date=10;

%instantiate a job shop work orders variable
job_shop_work_orders=WorkOrder.empty;

%instantiate job shop work order
job_shop_work_orders=genWO(job_shop_work_orders,cust.new_wo,cust.new_wo_due_date);

%setting properties in customer to tell WO to generate more WOs
cust.new_wo=1;
cust.new_wo_due_date=20;

%make this an array of WorkOrder objects
job_shop_work_orders=genWO(job_shop_work_orders,cust.new_wo,cust.new_wo_due_date);

%change due date to the second WO
job_shop_work_orders(2).due_date=30;

%access the second work order due date - as a check
job_shop_work_orders(2).due_date

for i=1:length(job_shop_work_orders)
    [job_shop_work_orders(i).routing,job_shop_work_orders(i).status]=generateRouting(dir);
    job_shop_work_orders(i).routing_complete=1;
end