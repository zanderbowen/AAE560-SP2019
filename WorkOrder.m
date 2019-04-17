classdef WorkOrder < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        due_date
        routing
        start_date
        end_date
        total_SV=0; %total schedule variance
        total_CV=0; %total cost variance
        status %this lets one know what the status of the WO is, possibilities are (new, planned, in work, closed, canceled)
    end
    
    methods
        function obj = WorkOrder(due_date)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 1
                if isnumeric(due_date) && due_date>0
                    obj.due_date=due_date;
                    obj.status='new';
                else
                    error('Value must be numeric or greater than zero.');
                end
            end
        end
        
        %a method to for the customer class to instantiate a new work
        %order- I think that Matt may have a way to do this from the
        %customer class???
        function obj=genWO(obj,new_wo,new_wo_due_date)
            if new_wo==1
                obj=[obj; WorkOrder(new_wo_due_date)];
            end
        end
        
        
    end
end