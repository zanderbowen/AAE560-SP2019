function [ js_wos, cust ] = createWO( wo_count, cust_due_date, cust, js_wos )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%Checks if new work order is needed
if wo_count > 0
    
    %setting properties in customer to tell WO to generate more WOs
    cust.new_wo = wo_count;
    cust.new_wo_due_date = cust_due_date;
    
    %instantiate a job shop work order object array
    %js_wos=WorkOrder.empty;
    
    %add a job shop work order to the array - #1
    for i = 1:wo_count
        %setting properties in customer to tell WO to generate more WOs
        cust.new_wo = wo_count;
        cust.new_wo_due_date = cust_due_date;
        %wo = genWO(js_wos,cust.new_wo,cust.new_wo_due_date,[js_wos.unique_id]);
        js_wos = [js_wos; WorkOrder(cust.new_wo_due_date,[js_wos.unique_id])];
    end
end
