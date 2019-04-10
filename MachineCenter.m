classdef MachineCenter < handle
    %%overtime is ignored in this version
    
    properties
       machines_running                                  %array that flags which machines are working
       number_of_machines = 1                            %number of machines (can be varied)
       machine_hours = zeros(1,number_of_machines);      %array of total hours worked
       max_machine_hours                                 %maximum hours alowed by the supervisor
       warning_flag = 0          %if no machines can work set up a flag to alert the supervisor 
    end
    
    
    methods
    
      %first update the array with which machines can work
      function whichMachinesCanWork
        %get the max machine hours from the supervisor
        max_machine_hours = Supervisor.max_hours; %%   <-----One supervisor? Can we specify this machine center's supervisor?
        
        %check which machines still have time left
        machines_running = machine_hours - max_machine_hours;
        %turn the negative values to zero
        machines_running = .5*(abs(machines_running)+machines_running);
        %turn all non-zeros to 1
        machines_running = logical(machines_running);
        %%Now the matrix "machines_running" is an array of 1s and 0s depending on whether that machine is free to do work.
        if(sum(machines_running) = 0)
            warning_flag = 1;
         else
            warning_flag = 0;
          end
       end
    
    
    %Next check if there is any work to be done
    function getToWork
    
       if(obj.work_needed > 0)%%% This might need altering depending on what the work order calls it
          %%Divide the hours among the working machines and then update the hours 
          machine_hours = machine_hours + (1/sum(machines_running))*machines_running;
            %%subtract 1 hour worked from the work needed on the work order
            obj.work_needed = obj.work_needed - 1;
           end

      end
      
    end
   end 
    
    
    
