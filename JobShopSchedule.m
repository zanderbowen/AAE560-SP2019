classdef JobShopSchedule < handle
    %Holds scheduled jobs and job order
    %   Detailed explanation goes here
    
    properties
        current_job
        next_job
        job_status
    end
    
    methods
        function obj = JobShopSchedule(current_job,next_job,job_status)
            %Creates JS Schedule object
            %Holds properties for current job, next job in the schedule and
            %the status of the current job in the schedule
            obj.current_job = current_job;
            obj.next_job = next_job;
            obj.job_status = job_status;
        end
        
        %function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %outputArg = obj.Property1 + inputArg;
        %end
    end
end

