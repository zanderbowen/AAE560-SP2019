
classdef Receiving < handle
    %Evolution1 Receiving Class = Working with single part from vendor, 
    
    % part_delivered - variable that only Vendor class is able to read/writ to telling receiving that they delivered a part of a sepcfic work order and operation
    %Check that part is has been delivered
    %If parts have been delivered, mark them as delivered in appropriate place in routing and activity. After parts have been delivered, clear the part_delivered property
   
                
  properties(GetAccess = 'public', SetAccess ='public');
 
    vendor_part_received = 0; %dependent on Vendor class "Deliver parts()". Default of 0, parts not received
 
  end 

methods  %Note: can call method by either obj.methodName(arg) OR methodName(obj,arg)
       
      function obj = Receiving(vendor_part_received)
            %Creates an instance of the Receiving object with properties for vendor part received status            
        obj.vendor_part_received = vendor_part_received;

      end
         
      %functions are output = methodname(obj, arg)
      
      %Check status of vendor part
      function report_vendor_part_status = reportVendorDeliveryStatus(obj,vendor_part_delivery_status) %Update variable name to to match what's called in Vendor class
          import Vendor
          import WorkOrder
          get.Vendor(vendor_part_delivery_status); %No clue if this is how you actually read value from another class? I know it works when reading from a file
          
          if vendor_part_delivery_status == 1 
                obj.vendor_part_received = 1;
            else
                obj.vendor_part_received = 0;
          end 
          
          if obj.vendor_part_received == 1
              set.WorkOrder(vendor_part_operation_complete) = 1; %Update variable to match what's called in WorkOrder class, assuming 1 = completed
              set.WorkOrder(vendor_part_routing_complete) = 1;  %Update variable to match what's called in WorkOrder class, assuming 1 = completed
          else
              set.WorkOrder(vendor_part_operation_complete) = 0;
              set.WorkOrder(vendor_part_routing_complete) = 0;
          end
         
         %Clear part received status to prepare for assess status of next incoming vendor part
            clearvars vendor_part_received    
      end
   
end 
   
%Making assumption that work order compares vendor part received time vs. scheduled due date (aka, receiving doesn't report that)




  
  