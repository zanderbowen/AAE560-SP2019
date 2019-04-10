classdef Vendor < handle
    
    properties
  
        delivery_time = 0 %variable to hold the due date for this part
        part_delivered = 0 %true (1) or false (2) variable to say whether the part was delivered
        waiting_to_send = 0 %variable that tells the timer to keep checking till the part is sent
    end
 %Read Work Orders and determine if they need to send a part
 
methods
 function checkWorkOrder
 
    %Vendor if the part is flagged as needed in Work Order then set delivery time variable to the due date.
    If (obj.vendor_part_needed == 1)
  
         delivery_time = obj.delivery_time;
         part_delivered = 0;
         waiting_to_send = 1;
     end
 
 %Read the schedule to see when to deliver the part
 %Notify the Receiving object that the part has been sent
 
 function sendVendorPart
  
  %Check to see if there is a part in the queue
  If (waiting_to_send == 1)
  
  %%%%%I need the global time to check against the delivery time here as the variable "the_time"%%%%
  %Check to see if they can send the part yet
      If (the_time = delivery_time)
          
          %flag the part as delivered
          part_deliverd = 1;
          %reset the waiting to send flag
          waiting_to_send = 0;
          %%%%%% Question: can I just change the work order variable like this so that the work order doesn't want anymore?
          obj.vendor_part_needed == 0;
        
        end
     end
  end
 end
end
