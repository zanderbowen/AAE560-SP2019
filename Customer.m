classdef Customer < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        new_wo=0
        new_wo_due_date=0
    end
    
    methods
        function obj = Customer(new_wo,new_wo_due_date)
%             %UNTITLED Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.Property1 = inputArg1 + inputArg2;
        end
        
%         function job_shop_work_orders=generateWorkOrder(obj,due_date,job_shop_work_orders)
%             if ~exist job_shop_work_orders var
%                 job_shop_work_orders=WorkOrder(due_date);
%             elseif length(job_shop_work_orders)<1
%                 job_shop_work_orders=WorkOrder(due_date);
%             else
%                 job_shop_work_orders.due_date
%                 job_shop_work_orders=[job_shop_work_orders; WorkOrder(due_date)];
%             end
%                 
%         end
    end
end

