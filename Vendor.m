classdef Vendor < handle
    
    properties
  
        delivery_time = 0;
 
    end
 %Read Work Orders and determine if they need to send a part
 

 function checkWorkOrder
    import WorkOrder
    import Schedule
    
   get.WorkOrder(vendor_part);
    If (vendor_part = 1)
        get.Schedule(work_order_schedule_time);
        
        work_order_schedule_time = delivery_time;
 end
 
 %Read the schedule to see when to deliver the part
 %Notify the Receiving object that the part has been sent
 
 function sendVendorPart
    import Schedule
    
 get.Schedule(the_time)
 
  If (the_time = delivery_time)
        part_delivery = 1;
        
        %I'm assuming that Receiving will be able to see that the part_delivery
        %variable is now 1 so it won't need to actually be notified.
        
 end