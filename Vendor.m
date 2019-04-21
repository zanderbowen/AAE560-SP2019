classdef Vendor < handle
    
    properties
  
        unique_id % unique identifier for each instantiated vendor object
        delivery_time = 0 %variable to hold the due date for this part
        part_delivered = 0 %true (1) or false (2) variable to say whether the part was delivered
        waiting_to_send = 0 %variable that tells the timer to keep checking till the part is sent
        early_delivery = 0  %variable from 0 to 1 that marks the percent of the delivery time that the Job shop wants the part delivered
    end
 %Read Work Orders and determine if they need to send a part
 
methods
    
    %Constructor Method
    function obj = Vendor(unique_id,id_vec) %Creates supervisor object
        %check to make sure that a supervisor is not already assigned to the functional group
        if isempty(find(id_vec==unique_id))
            obj.unique_id=unique_id;
        else
            error(['This identifier is already used by Vendor ',num2str(unique_id),'.']);
        end
    end
end
end