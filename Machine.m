classdef Machine < handle
   
    properties
        functional_group %property that assigns the machine to a specific class and therefore a supervisor
        machine_number %unique idenifer for each machine object instantiated
        full_name %functional_group.machine_number
        status %machine status is either 'idle' or 'running'
        machine_hours %total hours worked on the work order
        max_machine_hours %maximum hours alowed by the supervisor
        op_status %lets the supervisor know the mode of the operation: 'set-up', 'run', 'complete'
        op_actual_duration %deterministic: op_actual_duration=op_plan_duration stochastich: op_actual_duration PDF determined
        
        %these are properties from the WO that the machine is currently working on
        wo_id
        op_plan_duration %duration from the routing within the WO object
        vendor_part %flag to determine if a vendor part is required
        
    end
    
    methods
        
        %Constructor Method
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
        
        function obj=performWork(obj,js_wos)
                for i=1:length(obj)
                %deterministic: op_actual_duration=op_plan_duration stochastich: op_actual_duration PDF determined
                obj(i).op_actual_duration=obj(i).op_plan_duration;
                
                %pull in the routing table for the specific WO
                r_table=js_wos(obj(i).wo_id).routing.Edges;
                %find the row index for the operation in the routing table
                row_index=find(strcmp(r_table.Operation,obj(i).functional_group));
                
                if obj(i).vendor_part==1 && r_table.PartDelivered(row_index)==0
                    %letting that the machine has the WO but not manufacturing
                    obj(i).op_status='set-up';
                    %adding a time unit based on timer wrapper iteration to machine_hours which is the time spent on the operation
                    obj(i).machine_hours=obj(i).machine_hours+1;
                elseif obj(i).machine_hours<obj(i).op_actual_duration
                    obj(i).op_status='run';
                    obj(i).machine_hours=obj(i).machine_hours+1;
                else
                    obj(i).op_status='complete';
                    obj(i).status='idle';
                end
            end
        end
    

    end
end
