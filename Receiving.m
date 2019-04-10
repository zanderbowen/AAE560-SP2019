
classdef Receiving < handle
    %Evolution1 Receiving Class = Working with single part from vendor, 
    
    % part_delivered - variable that only Vendor class is able to read/writ to telling receiving that they delivered a part of a sepcfic work order and operation
    %Check that part is has been delivered
    %If parts have been delivered, mark them as delivered in appropriate place in routing and activity. After parts have been delivered, clear the part_delivered property
   
                
  properties
    (GetAccess = 'public', SetAccess ='public');
 
    vendor_part_received %Receiving status based on vendor reported delivery status
 
  end 

methods  %Note: can call method by either obj.methodName(arg) OR methodName(obj,arg)
       
      function obj = Receiving  %Creates an instance of the Receiving object            
      
      end
         
           
      %Check read status of vendor part delivery from vendor class and then update work order
      
      function receiving_status = ReportVendorDeliveryStatus(obj,vendor_part_delivery_status) %Check if part has been deliverer from vendor class
                 %Update variable name (vendor_part_delivery_status) to to match what it's called in vendor class
                    
          if vendor_part_delivery_status == 1 %Using logical, 1 = delivered, 0 = not delivered
                obj.vendor_part_received = 1; %Check
                disp("Vendor part delivered to receiving");
            else
                obj.vendor_part_received = 0; %Noted that not received
                disp("Vendor part not delivered to receivign");
          end 
          
          %Update status of vendor part status in work order for activity/operationg and routing
          
          if obj.vendor_part_received == 1
              obj.vendor_part_operation_complete = 1; %Update variable to match what's called in WorkOrder class, logical 1 = completed 
              obj.vendor_part_routing_complete = 1;  %Update variable to match what's called in WorkOrder class, logical 1 = completed
              disp("Work Order vendor part operation and routing marked complete");
          else
              obj.vendor_part_operation_complete = 0;
              obj.vendor_part_routing_complete = 0;
              disp("Work Order vendor part operation and routing marked incomplete");
          end
         
         %Clear part received status to prepare for assess status of next incoming vendor part
            clearvars vendor_part_received    
      end
   
end 
   
%Making assumption that work order compares vendor part received time vs. scheduled due date (aka, receiving doesn't report that)




  
  
