classdef MachineCenter < handle
    %%overtime is ignored in this version
    
    properties
       machines_running       %array that flags which machines are working
       machine_hours         %total hours worked
       max_machine_hours     %maximum hours alowed by the supervisor
       number_of_machines = 1 %number of machines (can be varied)
        
    end
    
    %first update the array with which machines can work
    methods
       function whichMachinesCanWork
        %get the max machine hours from the supervisor
        max_machine_hours = Supervisor.max_hours; %%   <-----One supervisor? Can we specify this machine center's supervisor?
        
    
    if (max_machine_hours > hours_machine_A1)
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
    end
   end 
    
    
    
