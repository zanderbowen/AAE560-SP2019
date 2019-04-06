classdef Supervisor < handle
    %Releases work based on JS schedule, reports work completed
    %   Detailed explanation goes here
    
    properties(GetAccess = 'public', SetAccess = 'public')
        job_status %Value is retrieved from MachineCenter 
        next_job %Value is retrieved from JobShopSchedule
        
    end
    
    methods
        function obj = Supervisor(job_status, next_job)
            %Creates an instance of the Supervisor object with properties
            %for work status and the next job released to the machine
            %center
            obj.job_status = job_status;
            obj.next_job = next_job;
        end
        
        function release_Work = method1(obj,inputArg)
            %I want to create a function here that reads from job_status  
            %from the machine center and determines if work can be released
            %value will be 0 or 1 for incomplete or complete, if the job is
            %complete, work is released
            %if (job_status == 1)
                %disp ('job is complete')
            %else disp('job is incomplete')
            release_Work = obj.Property1 + inputArg;
        end
        
          function assign_Next = method2(obj,inputArg)
            %I want to create a function here that reads from job_status  
            %from the machine center and determines if the last job is
            %complete, if it is complete, the next job in the schedule is
            %assigned
            %if (job_status == 1)
                %disp ('job is complete')
            %else disp('job is incomplete')
            assign_Next = obj.Property1 + inputArg;
        end
            
    end
end

