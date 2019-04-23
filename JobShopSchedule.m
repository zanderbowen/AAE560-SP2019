classdef JobShopSchedule < handle
    %Job Shop Schedule class, holds job schedule
    %Based on a Activity on Arrow network schedule (e.g. PERT)
    
    properties
        master_schedule %directed graph that contains the master schedule
        start_node %the starting node number
        end_node %the ending node number
        wo_buffer %a buffer between work orders to provide ability to deliver on time
    end
    
    methods
        %Job Shop Schedule constructor method
        function obj = JobShopSchedule(wo_buffer) 
            %create an empty directed graph
            obj.master_schedule=digraph([],[]);
            obj.start_node={'Start'};
            obj.end_node={'End'};
            obj.wo_buffer=wo_buffer;
        end
        
        %add WOs to Job Shop master schedule
        function [master_schedule revised_wo_dates]=addWoToMasterSchedule(obj,wos_add_master)

            %check to ensure there are work orders to add
            if ~isempty(wos_add_master)
                %initialize master_schedule
                master_schedule=obj.master_schedule;
                %create revised_wo_dates structure
                revised_wo_dates=struct('id',[],'start_date',[],'end_date',[]);
                
                %organize work orders by due date
                %assumption is this is a FIFO shop prioritized by due date
                [temp index]=sort([wos_add_master.start_date]);
                if isempty(index)
                    index=1;
                end
                
                if isempty(obj.master_schedule.Nodes) %start date for first sorted WO is dependent on whether the master schedule is populated or now
                    t_start=0;
                else %find the critical path through the existing master schedule to determine t_start if the master schedule already has work in it
                    t_start=l_critcalPath(master_schedule,obj.start_node,obj.end_node);
                end
                
                %*** Serialize Work Orders *** applies FIFO scheduling based on due date
                for i=1:length(wos_add_master)
                    %the first work order starts at t_start
                    %populate a structure with revised information
                    %assuming all work order are performed serially
                    if i==1
                        %assume the first work order starts at t=0
                        %populate a structure with revised information
                        revised_wo_dates.id(i)=wos_add_master(index(i)).unique_id;
                        revised_wo_dates.start_date(i)=t_start;
                        revised_wo_dates.end_date(i)=revised_wo_dates.start_date(i)+wos_add_master(index(i)).cp_duration+obj.wo_buffer;
                    else
                        revised_wo_dates.id(i)=wos_add_master(index(i)).unique_id;
                        revised_wo_dates.start_date(i)=revised_wo_dates.end_date(i-1);
                        revised_wo_dates.end_date(i)=revised_wo_dates.start_date(i)+wos_add_master(index(i)).cp_duration+obj.wo_buffer;
                    end
                end
                %*** End Work Order Serialization***
                
                %*** Add Operations to Master Schedule***
                for i=1:length(wos_add_master)
                    %extract information to temp variable to make it
                    %easier to work with - note index is from the sort
                    %command based on due date above which enforces
                    %FIFO based on customer supplied due date

                    %wo unique id
                    u_id=wos_add_master(index(i)).unique_id;
                    %wo routing
                    tempG=wos_add_master(index(i)).routing;                    

                    %to simplify the creation of the master schedule, each routing start and end will
                    %have a start lead and an end lag, the weighting
                    %will be calculated from the revised serial dates

                    for j=1:length(tempG.Edges.EndNodes)
                        %for all routing node 1 is start and node 2 is
                        %end
                        rout_source=tempG.Edges.EndNodes(j,1);
                        rout_target=tempG.Edges.EndNodes(j,2);

                        if rout_source==1 && rout_target~=2 %edge is the first routing operation
                            %add in start lead edge
                            master_schedule=l_fun_leadEdge(obj,u_id,tempG,j,revised_wo_dates,i,master_schedule);
                            %add the first operation to the schedule
                            master_schedule=l_fun_addOperation(u_id,tempG,j,master_schedule);

                        elseif rout_source~=1 && rout_target==2 %edge is the last routing operation
                            %add the last operation to the schedule
                            master_schedule=l_fun_addOperation(u_id,tempG,j,master_schedule);
                            %add the buffer edge to the schedule
                            %!!! caution: this only works for operations in serial process !!!
                            master_schedule=l_fun_bufferEdge(u_id,tempG,j,obj,master_schedule);
                            %add the end lag edge to the schedule
                            master_schedule=l_fun_lagEdge(u_id,tempG,j,obj,master_schedule);

                        elseif rout_source==1 && rout_target==2 %single operation in the routing
                            %add in start lead edge
                            master_schedule=l_fun_leadEdge(obj,u_id,tempG,j,revised_wo_dates,i,master_schedule);
                            %add the only operation to the schedule
                            master_schedule=l_fun_addOperation(u_id,tempG,j,master_schedule);
                            %add the buffer edge to the schedule
                            %!!! caution: this only works for operations in serial process !!!
                            master_schedule=l_fun_bufferEdge(u_id,tempG,j,obj,master_schedule);
                            %add the end lag edge to the schedule
                            master_schedule=l_fun_addOperation(u_id,tempG,j,master_schedule);
                            
                        else %for all other operations in the WO
                            %add the operation to the schedule
                            master_schedule=l_fun_addOperation(u_id,tempG,j,master_schedule);
                        end

                    end
                end
                %*** End Add Operations Master Schedule***
                
                %fill the graph edges table with NaN values for ES, EF, LS & LF
                
                %pre-populate early/late start
                master_schedule.Edges.ES=NaN([length(master_schedule.Edges.Weight) 1]);
                master_schedule.Edges.LS=NaN([length(master_schedule.Edges.Weight) 1]);

                %pre-populate early/late finish
                master_schedule.Edges.EF=NaN([length(master_schedule.Edges.Weight) 1]);
                master_schedule.Edges.LF=NaN([length(master_schedule.Edges.Weight) 1]);
                
                %*** Perform Forward Pass - Calculate Early Start/Finish
                s=successors(master_schedule,obj.start_node);
                for i=1:length(s)
                    for j=1:length(master_schedule.Edges.Weight)
                        if strcmp(master_schedule.Edges.EndNodes(j,1),obj.start_node) && strcmp(master_schedule.Edges.EndNodes(j,2),s(i))
                            master_schedule.Edges.ES(j)=0;
                            master_schedule.Edges.EF(j)=master_schedule.Edges.Weight(j);
                        end
                    end
                end
                
                %brute force loop through remaining edges to calculate ES and EF
                ct=1;
                while any(isnan(master_schedule.Edges.ES)) || any(isnan(master_schedule.Edges.EF))
                    if isnan(master_schedule.Edges.ES(ct)) || isnan(master_schedule.Edges.EF(ct))
                        %check preceeding edges have EF calculated
                        node=master_schedule.Edges.EndNodes(ct,1);
                        p=predecessors(master_schedule,node);
                        for i=1:length(p)
                            for j=1:length(master_schedule.Edges.Weight)
                                if strcmp(master_schedule.Edges.EndNodes(j,1),p(i)) && strcmp(master_schedule.Edges.EndNodes(j,2),node)
                                    EF(i)=master_schedule.Edges.EF(j);
                                end
                            end
                        end

                        %check to ensure that ES and EF can be calculated then calculate
                        if ~any(isnan(EF))
                            master_schedule.Edges.ES(ct)=max(EF);
                            master_schedule.Edges.EF(ct)=max(EF)+master_schedule.Edges.Weight(ct);
                        end
                    end

                    %increment counter or reset counter
                    if ct>=length(master_schedule.Edges.ES)
                        ct=1;
                    else
                        ct=ct+1;
                    end

                    %clear EF variable
                    clear EF;
                end
                %*** End Forward Pass ***
                
                %*** Perform Backward Pass - Calculate Late Start/Finish

                p=predecessors(master_schedule,obj.end_node);
                for i=1:length(p)
                    for j=1:length(master_schedule.Edges.Weight)
                        if strcmp(master_schedule.Edges.EndNodes(j,1),p(i)) && strcmp(master_schedule.Edges.EndNodes(j,2),obj.end_node)
                            %typically late finish would be calc as follows
                            %master_schedule.Edges.LF(j)=max(master_schedule.Edges.EF);
                            %however all End Lag edges are set to zero
                            %therefore the EF for the particular edge is used instead of the maximum function
                            %the if statement ensures that the first task can't start the sch_res late and alread eat up all of the management reserve
                            if master_schedule.Edges.EF(j)==0
                                master_schedule.Edges.LF(j)=master_schedule.Edges.EF(j);
                            else
                                master_schedule.Edges.LF(j)=master_schedule.Edges.EF(j);
                            end
                            master_schedule.Edges.LS(j)=master_schedule.Edges.LF(j)-master_schedule.Edges.Weight(j);
                        end
                    end
                end
                
                %brute force loop through remaining edges to calculate LS and LF
                ct=1;
                while any(isnan(master_schedule.Edges.LS)) || any(isnan(master_schedule.Edges.LF))
                    if isnan(master_schedule.Edges.LS(ct)) || isnan(master_schedule.Edges.LF(ct))
                        %check preceeding edges have EF calculated
                        node=master_schedule.Edges.EndNodes(ct,2);
                        s=successors(master_schedule,node);
                        for i=1:length(s)
                            for j=1:length(master_schedule.Edges.Weight)
                                if strcmp(master_schedule.Edges.EndNodes(j,1),node) && strcmp(master_schedule.Edges.EndNodes(j,2),s(i))
                                    LS(i)=master_schedule.Edges.LS(j);    
                                end
                            end
%                             LS(i)=master_schedule.Edges.LS(find(ismember(G.Edges.EndNodes,[node s(i)],'rows')));
                        end

                        %check to ensure that ES and EF can be calculated then calculate
                        if ~any(isnan(LS))
                            master_schedule.Edges.LF(ct)=min(LS);
                            master_schedule.Edges.LS(ct)=min(LS)-master_schedule.Edges.Weight(ct);
                        end

                        %clear LS variable
                        clear LS;
                    end

                    %increment counter or reset it
                    if ct>=length(master_schedule.Edges.ES)
                        ct=1;
                    else
                        ct=ct+1;
                    end
                end
                %*** End Backward Pass ***
                
                %calculate the total slack
                master_schedule.Edges.TS=master_schedule.Edges.LS-master_schedule.Edges.ES;
                
            end
            

%                 %perform fwd/bwd schedule passes - calc early/late start/finish
%                 %pass info to update WO due dates
%             end
        end
        
        %update master schedule based on work performed
        function master_schedule=updateMasterSchedule(obj,wos_in_work,wos_planned);
            master_schedule=obj.master_schedule;
            
            %*** End Update In-Work ***
            %loop thru wos_in_work and update edge weights
            for i=1:length(wos_in_work)
                wo_id=wos_in_work(i).unique_id; %WO unique ID
                wo_r_table=wos_in_work(i).routing.Edges; %WO routing table
                wo_cp=wos_in_work(i).cp_duration; %WO planned critical path duration
                
                %buffer consumed tracker
                buff_con_t=0;
                %loop through each operation in the WO
                for j=1:length(wo_r_table.Weights)
                    op_name=wo_r_table.Operation(j);
                    op_status=wo_r_table.Status(j);
                    op_s_node=wo_r_table.EndNodes(j,1);
                    op_t_node=wo_r_table.EndNodes(j,2);
                    op_planned_duration=wo_r_table.Weight(j);
                    op_hours_worked=wo_r_table.HoursWorked(j);
                    ms_s_node={[num2str(wo_id),'.',num2str(op_s_node)]};
                    ms_t_node={[num2str(wo_id),'.',num2str(op_t_node)]};
                    ms_index(j)=findedge(master_schedule,ms_s_node,ms_t_node);
                    %used for extracting a sub-graph to get critical path
                    %to update Lead starts later
                    ms_index_start(j)=findedge(master_schedule,obj.start_node,{num2str(wo_id),'.1'});
                    ms_index_buffer(j)=findedge(master_schedule,{num2str(wo_id),'.2'},{'Buffer.',num2str(wo_id)});
                    ms_index_end(j)=findedge(master_schedule,{'Buffer.',num2str(wo_id)},obj.end_node);
                    
                    %updating the total consumed buffer
                    buff_con_t=(op_planned_duration-op_hours_worked)+buff_cond_t;
                    
                    %an operation in work with hours exceeding the plan will be written to master schedule
                    %OR completed operations actual hours will be written to the master schedule
                    if op_hours_worked > op_planned_duration || strcmp(op_status,'complete')
                        %updating the master schedule edge weight to the greater value
                        master_schedule.Edges.Weight(ms_index(j))=op_hours_worked;
                    end
                end
                ms_buffer_index=findedge(master_schedule,{num2str(wo_id),'.2'},{'Buffer.',num2str(wo_id)});
                
                %adjusting the WO buffer and tracking the total consumed
                act_wo_cp=l_critcalPath(master_schedule,obj.start_node,{num2str(wo_id),'.2'});
                if (wo_cp-act_wo_cp)<0
                    master_schedule.Edges.Weight(ms_buffer_index)=0;
                    master_schedule.Edges.EdgeLabel(ms_buffer_index)={'Buffer.',num2str(wo_id),'=0'};
                else
                    master_schedule.Edges.Weight(ms_buffer_index)=wo_cp-act_wo_cp;
                    master_schedule.Edges.EdgeLabel(ms_buffer_index)={'Buffer.',num2str(wo_id),'=',num2str(wo_cp-act_wo_cp)};
                end
                master_schedule(ms_buffer_index).BufTrack=buff_con_t;
            end
            
            %calculate critical pathe for only the updated master schedule
            %extract subgraph
            %find nodes based on ms_index !!! need to add in lead, buffer,
            %and lag edges !!!
            sub_s=[master_schedule.Edges.EndNodes(ms_index,1);master_schedule.Edges.EndNodes(ms_index_start,1);...
                master_schedule.Edges.EndNodes(ms_index_buffer,1);master_schedule.Edges.EndNodes(ms_index_end,1)];
            sub_t=[master_schedule.Edges.EndNodes(ms_index,2);master_schedule.Edges.EndNodes(ms_index_start,2);...
                master_schedule.Edges.EndNodes(ms_index_buffer,2);master_schedule.Edges.EndNodes(ms_index_end,2)];
            sub_nodes=unique([sub_s;sub_t]);
            %extract the sub-graph of updated schedule
            subG=subgraph(master_schedule,sub_nodes);
            ms_cp_updated=l_critcalPath(subG,cp_source,cp_target)
            %*** End Update In-Work ***
            
            %*** Update Planned ***
            %loop thru wos_planned and store early starts and corresponding
            %master schedule row indicies
            for i=1:length(wos_in_work)
                wo_id=wos_in_work(i).unique_id; %WO unique ID
                wo_r_table=wos_in_work(i).routing.Edges; %WO routing table
                wo_cp=wos_in_work(i).cp_duration; %WO planned critical path duration
                ms_row_index(i)=findedge(master_schedule)
                wo_es= %WO early start in master schedule
            end
            
            
            
            %adjust buffer (cp_wo - sum[op_work]) - buffer cannot go below zero
            %buffer sum (this can go negative) used to adjust planned buffers
            %update planned start leads cycle through based on early start
            %if the WO is in-work, then schedule lead is already passed
            %maybe just look at differnce between master schedule critical path and early start (just add this difference to the start lead) 
            %previous WOs can consume planned WOs buffer if buffer sum <0
            %previous WO completes early, adds to buffer
            %*** End Update Planned ***
            
            %!!! perform master schedule forward and backward passes !!!
        end
    end
end

function critical_path=l_critcalPath(G,cp_source,cp_target)
    G.Edges.Weight=-G.Edges.Weight;
    [cp_nodes neg_cp_length cp_edge_indicies]=shortestpath(G,cp_source,cp_target);
    critical_path=abs(neg_cp_length);
end

function master_schedule=l_fun_leadEdge(obj,u_id,tempG,j,revised_wo_dates,i,master_schedule)
    %add in start lead edge
    source=obj.start_node;
    target={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,1))]};
    weight=revised_wo_dates.start_date(i);
    master_schedule=addedge(master_schedule,source,target,weight);
    %find new edge index
    edge_index=findedge(master_schedule,source,target);
    %adding edge labels to the master schedule Edges table
    master_schedule.Edges.EdgeLabel{edge_index}=['Start.Lead.',num2str(u_id),'=',num2str(weight)];
    %adding additional routing information to the Edges table
    master_schedule.Edges.EdgeWO(edge_index)=u_id;
    master_schedule.Edges.OperationWO{edge_index}=['StartLead'];
    master_schedule.Edges.RoutingEndNodes(edge_index,:)=[NaN tempG.Edges.EndNodes(j,1)];
    %add BufferTracking column set to NaN to the master schedule Edges
    master_schedule.Edges.BufTrack(edge_index)=NaN;
end

function master_schedule=l_fun_addOperation(u_id,tempG,j,master_schedule)
    source={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,1))]};
    target={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
    weight=tempG.Edges.Weight(j);
    master_schedule=addedge(master_schedule,source,target,weight);
    %find new edge index
    edge_index=findedge(master_schedule,source,target);
    %adding edge labels to the master schedule Edges table
    master_schedule.Edges.EdgeLabel{edge_index}=[num2str(u_id),'.',char(tempG.Edges.Operation(j)),'=',num2str(weight)];
    %adding additional routing information to the Edges table
    master_schedule.Edges.EdgeWO(edge_index)=u_id;
    master_schedule.Edges.OperationWO{edge_index}=char(tempG.Edges.Operation(j));
    master_schedule.Edges.RoutingEndNodes(edge_index,:)=[tempG.Edges.EndNodes(j,1) tempG.Edges.EndNodes(j,2)];
    %add BufferTracking column set to NaN to the master schedule Edges
    master_schedule.Edges.BufTrack(edge_index)=NaN;
end

function master_schedule=l_fun_bufferEdge(u_id,tempG,j,obj,master_schedule)
    source={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
    target={['Buffer.',num2str(u_id)]};
    weight=obj.wo_buffer;
    master_schedule=addedge(master_schedule,source,target,weight);
    %find new edge index
    edge_index=findedge(master_schedule,source,target);
    %adding edge labels to the master schedule Edges table
    master_schedule.Edges.EdgeLabel{edge_index}=['Buffer.',num2str(u_id),'=',num2str(weight)];
    %adding additional routing information to the Edges table
    master_schedule.Edges.EdgeWO(edge_index)=u_id;
    master_schedule.Edges.OperationWO{edge_index}='Buffer';
    master_schedule.Edges.RoutingEndNodes(edge_index,:)=[tempG.Edges.EndNodes(j,2) NaN];
    %add BufferTracking column set to NaN to the master schedule Edges
    master_schedule.Edges.BufTrack(edge_index)=obj.wo_buffer;
end

function master_schedule=l_fun_lagEdge(u_id,tempG,j,obj,master_schedule)
    source={['Buffer.',num2str(u_id)]};
    target=obj.end_node;
    weight=0;
    master_schedule=addedge(master_schedule,source,target,weight);
    %find new edge index
    edge_index=findedge(master_schedule,source,target);
    %adding edge labels to the master schedule Edges table
    master_schedule.Edges.EdgeLabel{edge_index}=['End.Lag.',num2str(u_id)];
    %adding additional routing information to the Edges table
    master_schedule.Edges.EdgeWO(edge_index)=u_id;
    master_schedule.Edges.OperationWO{edge_index}='EndLag';
    master_schedule.Edges.RoutingEndNodes(edge_index,:)=[NaN NaN];
    %add BufferTracking column set to NaN to the master schedule Edges
    master_schedule.Edges.BufTrack(edge_index)=NaN;
end