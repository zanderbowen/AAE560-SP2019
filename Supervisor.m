classdef Supervisor < handle
    %Creates the Supervisor class
    %   Releases work to Machine Center, reports Work Complete to Work
    %   Order
    
    properties
       start_next %start_next is read by the machine_center, it is determined by current job_status and availability of next_job
       job_done %job_done is determined by the status of the current job in the machine center
       functional_group %this is the letter of the group of machine functions that the supervisor oversees, it also corresponds to the Routing/operation an individual machine performs
    end
    
    methods
        function obj = Supervisor %Creates supervisor object
        end
        
        function s = ReleaseWork(obj,job_status,next_job)
            
            if job_status == true && next_job == true %if both job_status and next_job are true, Machine shop can start another job and the current job is marked as complete in the WO
               obj.start_next = true;
               disp("Start next job")
               obj.job_done = true;
               disp("The current job has been completed")
            else
               obj.start_next = false;
               disp("Current job incomplete, cannot start next job")
               obj.job_done = false;
               disp("The current job is still in work")
            end
            s = obj.start_next;
        end
    end
end
