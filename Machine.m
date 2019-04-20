classdef Machine < handle
   
    properties
        functional_group %property that assigns the machine to a specific class and therefore a supervisor
        machine_number %unique idenifer for each machine object instantiated
        full_name %functional_group.machine_number
        status %machine status is either 'idle' or 'running'
        machine_hours %total hours worked on the work order
        max_machine_hours %maximum hours alowed by the supervisor
        waiting_on_part %waiting for part from vendor
        op_status %lets the supervisor know the mode of the operation: 'set-up', 'run', ['complete.wo_id']     
        
        %these are properties from the WO that the machine is currently working on
        wo_id
        op_plan_duration %duration from the routing within the WO object
        vendor_part %flag to determine if a vendor part is required
        
    end
    
    methods
        
        function obj=Machine(functional_group,f_grp_vec,machine_number,full_name_vec,max_machine_hours) %('A',{m_grp_A.functional_group},1,[m_grp_A.machine_number],8)
            if ~isempty(f_grp_vec) && ~any(strcmp(f_grp_vec,functional_group))
                error(['No supervisor exists for functional group ',functional_group,'.']);
            end
            
            if any(strcmp(full_name_vec,{char([functional_group,'.',num2str(machine_number)])}))
                error(['Machine number ',num2str(machine_number),' already exits in functional group ',functional_group,'.']);
            end
            
            obj.functional_group=functional_group;
            obj.machine_number=machine_number;
            obj.max_machine_hours=max_machine_hours;
            obj.status='idle';
            obj.full_name={char([functional_group,'.',num2str(machine_number)])};
        end
    
%       function doWork
%          
%          waiting_on_part = false;  %%placeholder for adding the ability to check if it needs a vendor part from recieving
%          
%          if(max_machine_hours > machine_hours)
%                      %%% Supervisor(functional_class) is how I'm naming the supervisor that it is listening too for the moment
%           if(work_needed > 0 && Supervisor(functional_class).start_next == true) 
%                 if(waiting_on_part == false)
%                      machine_idle = false:
%                      machine_running = true;
%                      machine_hours = machine_hours + 1;
%                      %%subtract 1 hour worked from the work needed on the project
%                      work_needed = work_needed - 1;      
%                 
%                 else
%                      machine_idle = true;
%                      machine_running = false;
%                   
%                   end
%              else
%                  machine_idle = true;
%                  machine_running = false;
%              
%              end
%           else
%              machine_idle = false;
%              machine_running = false;
%           end
%           
%           %flags the supervisor as to whether or not the job is complete
%           if(work_needed <= 0)             
%                job_status = true;
%            else
%                job_status = false;
%           end
    end
end
