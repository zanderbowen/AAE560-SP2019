classdef Supervisor < handle
    %Creates the Supervisor class
    %   Releases work to Machine Center, reports Work Complete to Work
    %   Order
    
    properties
       job_queue %structure that contains operations specific to the functional group supervised
       functional_group %this is the letter of the group of machine functions that the supervisor oversees, it also corresponds to the Routing/operation an individual machine performs
    end
    
    methods
        function obj = Supervisor(functional_group,fun_grp_vec) %Creates supervisor object
            %check to make sure that a supervisor is not already assigned to the functional group
            if ~any(strcmp(fun_grp_vec,functional_group))
                obj.functional_group=functional_group;
            else
                error(['A supervisor is already assigned to group ',functional_group,'.']);
            end
            obj.job_queue=struct('wo_id',[],'es',[],'ls',[],'ef',[],'lf',[],'duration',[]);
        end
        
        function obj=getWork(obj,ms_e_table)
            %clear out the job_queue object - concerned that a short table
            %will "corrupt data"
            obj.job_queue=struct('wo_id',[],'es',[],'ls',[],'ef',[],'lf',[],'duration',[]);
            for i=1:length(obj)
                obj(i).job_queue=l_fun_getWork(ms_e_table,obj(i).functional_group,obj(i).job_queue);
            end
        end
        
        function f_grp_machines=assignWork(obj,f_grp_machines,js_wos,i)
            %check the number of idle machines
            n_idle_machines=sum(strcmp({f_grp_machines.status},'idle'));
            %determine the number of available wo operations to be worked
            n_open_ops=0;
            for j=1:length(js_wos)
                %find the jth WO that contains the ith supervisor functional group
                [temp index]=find(strcmp(js_wos(j).routing.Edges.Operation,obj(i).functional_group));
                %sum the number of planned operations
                n_open_ops=sum(strcmp(js_wos(j).routing.Edges.Status(index),'planned')+n_open_ops);
            end
            
            %assign work to the machines limited by either the # of machines or open operations
            for k=1:min([n_idle_machines, n_open_ops])
                %set the machine status to running
                f_grp_machines(k).status='running';
                %populate the machines properties
                %wo id - assigned off supervisor.job_queue but must be checked to see if it is not already being worked
                ct=0;
                while ct<=1  %counter inequality is set to 1 b/c only a single operation will be allocated
                %duration
                %vendor part required
                
                
            end
            
        end
        
        function s = ReleaseWork(obj,job_status,next_job)
            
            if job_status == true && next_job == true %if both job_status and next_job are true, Machine shop can start another job and the current job is marked as complete in the WO
               obj.start_next = true;
               disp("Start next job")
               obj.job_done = true;
               disp("The current job has been completed")
            else
               obj.start_next = false;
               disp("Current job incomplete, cannot start next job")
               obj.job_done = false;
               disp("The current job is still in work")
            end
            s = obj.start_next;
        end
    end
end

function job_queue=l_fun_getWork(ms_e_table,fun_grp,job_queue)
    %search for row indicies from master schedule Edge table that
    %correspond to the supervisor's functional group
    row_index=find(strcmp(ms_e_table.OperationWO,fun_grp));
    
    %sort early start, save indicies to ensure operations are ordered correctly
    [temp s_index]=sort(ms_e_table.ES(row_index));
    
    job_queue.wo_id=ms_e_table.EdgeWO(row_index(s_index)); %work order id
    job_queue.es=ms_e_table.ES(row_index(s_index)); %early start
    job_queue.ls=ms_e_table.LS(row_index(s_index)); %late start
    job_queue.ef=ms_e_table.EF(row_index(s_index)); %early finish
    job_queue.lf=ms_e_table.LF(row_index(s_index)); %late finish
    job_queue.duration=ms_e_table.Weight(row_index(s_index)); %duration
end