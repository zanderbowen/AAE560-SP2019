classdef Machine < handle

    
    properties
       functional_group                                  %property that assigns the machine to a specific class and therefore a supervisor
       machine_number                                    %unique idenifer for each machine object instantiated
       machine_idle                                      %flag that says the machine is available for work but not working
       machine_running                                   %flag that says whether the machine is running
       machine_hours                                     %total hours worked
       max_machine_hours                                 %maximum hours alowed by the supervisor
       waiting_on_part                                   %waiting for part from vendor
       job_status                                        %lets the supervisor know that the job is finished
       work_needed                                       %variable to be set by the supervisor
       
    end
    
    method
    
      function doWork
         
         waiting_on_part = false;  %%placeholder for adding the ability to check if it needs a vendor part from recieving
         
         if(max_machine_hours > machine_hours)
                     %%% Supervisor(functional_class) is how I'm naming the supervisor that it is listening too for the moment
          if(work_needed > 0 && Supervisor(functional_class).start_next == true) 
                if(waiting_on_part == false)
                     machine_idle = false:
                     machine_running = true;
                     machine_hours = machine_hours + 1;
                     %%subtract 1 hour worked from the work needed on the project
                     work_needed = work_needed - 1;      
                
                else
                     machine_idle = true;
                     machine_running = false;
                  
                  end
             else
                 machine_idle = true;
                 machine_running = false;
             
             end
          else
             machine_idle = false;
             machine_running = false;
          end
          
          %flags the supervisor as to whether or not the job is complete
          if(work_needed <= 0)             
               job_status = true;
           else
               job_status = false;
          end
      end
     end
    end
