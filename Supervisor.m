classdef Supervisor < handle
    %Releases work based on JS schedule, reports work completed
    %   Detailed explanation goes here
    
    properties%(GetAccess = 'public', SetAccess = 'public')
        job_status %Value is retrieved from MachineCenter 
        next_job %Value is retrieved from JobShopSchedule
        
    end
    
    methods
        function SupA = Supervisor(job_status, next_job)
            %Creates an instance of the Supervisor object with properties
            %for work status and the next job released to the machine
            %center
            SupA.job_status = get(MachineCenter,job_status);%checks current job status at Machine Center
            SupA.next_job = get(JobShopSchedule,next_job);% checks next scheduled job in JobShopSchedule
        end
        
        function releaseWork(SupA)
            if SupA.job_status == true
               disp('Job x is complete, start job y');% need to point to current job in MachineCenter for x
               set(SupA,SupA.next_job, true);
               %set(MachineCenter,MachA.next_job, true); This probably
               %belongs in the MachineCenter methods
               SupA.job_status = false;
            else
               disp('Job x is incomplete,cannot start next job');% need to point to current job in MachineCenter for x
               SupA.next_job = false; 
            end           
        end
        
          function workComplete(SupA)
            if SupA.job_status == true
               disp('Job x is complete');
               set(JobShopSChedule,current_job, true)
            else
               disp('Job x incomplete');
            end
            
        end
            
    end
end

