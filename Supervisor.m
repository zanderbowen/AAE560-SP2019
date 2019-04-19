classdef Supervisor < handle
    %Creates the Supervisor class
    %   Releases work to Machine Center, reports Work Complete to Work
    %   Order
    
    properties
       job_queue %structure that contains operations specific to the functional group supervised
       functional_group %this is the letter of the group of machine functions that the supervisor oversees, it also corresponds to the Routing/operation an individual machine performs
    end
    
    methods
        function obj = Supervisor(functional_group) %Creates supervisor object
            obj.functional_group=functional_group;
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
    %('wo_id',[],'es',[],'ls',[],'ef',[],'lf',[],'duration',[])
    job_queue.wo_id=ms_e_table.EdgeWO(row_index); %work order id
    job_queue.es=ms_e_table.ES(row_index); %early start
    job_queue.ls=ms_e_table.LS(row_index); %late start
    job_queue.ef=ms_e_table.EF(row_index); %early finish
    job_queue.lf=ms_e_table.LF(row_index); %late finish
    job_queue.duration=ms_e_table.Weight(row_index); %duration
end