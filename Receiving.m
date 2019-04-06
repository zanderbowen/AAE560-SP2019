
classdef Receiving < handle
    %Evolution1 Receiving Class = Working with single part from vendor, 
   
    %Info about Receiving class: 
        %Vendor part is either received or it is not
        %Vendor part is either received on time or it is not
        %Vendor part is either correct or it is not
        %Receiving either communicates vendor part status or not to
        %Supervisors A and/or Supervisor B
        %Receiving eiher updates work order with vendor part recieve date
        %or not
        %
    
  properties
   vendor_part_received_schedule_difference %used to determine if ahead of, on time, or late to schedule
   vendor_part_received %dependent on Vendor class "Deliver parts()". If 0, parts not received
   vendor_part_correct %May be too complex for evolution1?. If 0, parts incorrect. Would require return to Vendor and vendor_part_received_date would need to be updated when new part delivered
        
    end
end
  
        
    %methods
     %   function obj = Receiving()
%             %UNTITLED Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.Property1 = inputArg1 + inputArg2;
      %  end
        
        
       % function %???????????
            %
        
%         function job_shop_work_orders=generateWorkOrder(obj,due_date,job_shop_work_orders)
%             
%             end
%                 
%         end
  