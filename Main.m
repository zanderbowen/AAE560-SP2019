clear all;
clc;

%--------------------------------------------------------------------------
%CREATE SYSTEMS
%--------------------------------------------------------------------------

%Create Job Shop (Director(s), Supervisor(s), Machine(s), & Receiving)
[dir, sup, mach, rec] = createJobShop(1,2,4,1);
%Create Vendor Base
[ven] = createVendor(1);
%Create Customer Base
[cust] = createCustomer(1);


%Initiate Work Orders from Customer Base
cust(1)=Customer(2,1);   %Customer 1 making 2 orders

%Set first work order due in 10 days
cust.js_wo(1).job_shop_work_orders.due_date = 10;

%set second work order due in 20 days
cust.js_wo(2).job_shop_work_orders.due_date = 20;


%Director sets up routing
for i=1:length(cust.js_wo)
    if strcmp(cust.js_wo(i).job_shop_work_orders.status,'new')
        [cust.js_wo(i).job_shop_work_orders.routing,...
            cust.js_wo(i).job_shop_work_orders.status]=generateRouting(dir);
    end
end

%Route to Vendor - Vendor then sends material, if applicable
for i = 1:length(cust.js_wo)
   checkWorkOrder(ven(1), cust.js_wo(i).job_shop_work_orders.status, ...
        cust.js_wo(i).job_shop_work_orders.routing.Edges(i,2));
    
    cust.js_wo(1).job_shop_work_orders.routing.Edges(i,4) = {ven(1).part_delivered};
end
sendVendorPart(ven(1), ven(1).waiting_to_send);

%From Vendor to Receiving
for i = 1:length(cust.js_wo)
   ReportVendorDeliveryStatus(rec(1), ven(1).part_delivered);    
    cust.js_wo(1).job_shop_work_orders.routing.Edges(i,4) = {rec(1).vendor_part_received};
end

%From Receiving to Supervisor
sup(1).no_machines = 2;

ReleaseWork(sup(1), mach(1).job_status, next_job)
%From Sup1 to Sup2
sup(2).no_machines = size(mach)-2;

%From Sup to Dir

%From Dir to Cust

%cust.js_wo(i).job_shop_work_orders.routing.Edges(i,2))