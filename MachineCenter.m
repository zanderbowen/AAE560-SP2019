classdef MachineCenter < handle
    %%overtime is ignored in this version
    
    properties
       machines_running                                  %array that flags which machines are working
       number_of_machines = 1                            %number of machines (can be varied)
       machine_hours = zeros(1,number_of_machines);      %array of total hours worked
       max_machine_hours                                 %maximum hours alowed by the supervisor
       warning_flag = 0       %if no machines can work set up a flag to alert the supervisor 
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
       end
    
    
    %Next check if there is any work to be done
    function getToWork
       

      end
      
    end
   end 
    
    
    
