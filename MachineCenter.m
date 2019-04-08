classdef MachineCenter < handle
    
    properties
    %Operational Group A
        %Machine_A1
        %Machine_A2
    %Operational Group B
        %Machine_B1
 
    end
    
    %first check which machines can work based on overtime hours, etc
    function checkWhichMachinesCanWork
    
    import Supervisor;
    
    get.Supervisor(max_hours_machine_A1,hours_machine_A1);
    
    machine_A1 = 0;
    
    if (max_hours_machine_A1 > hours_machine_A1)
        machine_A1 = 1;
    end
    
    end
    
    %Next check if there are any jobs for machine_A1
    function workingHours
    import WorkOrder
    get.WorkOrder(job_A_hours);
    
    %if A1 can work...
    if (machine_A1 == 1)
        %it takes 1 hours off of Job A
        job_A_hours = job_A_hours - 1;
        %records 1 hour worked in its log for the Supervisor
        hours_machine_A1 = hours_machine_A1 + 1;
    end
    end
    
    
    
    
    