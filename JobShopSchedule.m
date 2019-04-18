classdef JobShopSchedule < handle
    %Job Shop Schedule class, holds job schedule
    %Based on a Activity on Arrow network schedule (e.g. PERT)
    
    properties
        master_schedule %directed graph that contains the master schedule
        start_node %the starting node number
        end_node %the ending node number
    end
    
    methods
        function obj = JobShopSchedule() %Job Shop Schedule constructor method
            %create an empty directed graph
            obj.master_schedule=digraph([],[]);
            obj.start_node={'Start'};
            obj.end_node={'End'};
        end
        
        %add WOs to Job Shop master schedule
        function [master_schedule revised_wo_dates]=addWoToMasterSchedule(obj,wos_add_master)
            
            %initialize master_schedule
            master_schedule=obj.master_schedule;
            
            %create revised_wo_dates structure
            revised_wo_dates=struct('id',[],'start_date',[],'end_date',[]);
            
            %check to ensure there are work orders to add
            if ~isempty(wos_add_master)
                
                if isempty(obj.master_schedule.Nodes) %check to see if the js_sch object has any data in it
                    %organize work orders by due date
                    %assuption is this is the FIFO shop prioritized by due date
                    [temp index]=sort([wos_add_master.start_date]);
                    
                    %*** Serialize Work Orders ***
                    for i=1:length(wos_add_master)
                        
                        %assume the first work order starts at t=0
                        %populate a structure with revised information
                        %assuming all work order are performed serially
                        if i==1
                            %assume the first work order starts at t=0
                            %populate a structure with revised information
                            revised_wo_dates.id(i)=wos_add_master(index(i)).unique_id;
                            revised_wo_dates.start_date(i)=0;
                            revised_wo_dates.end_date(i)=revised_wo_dates.start_date(i)+wos_add_master(index(i)).cp_duration;
                        else
                            revised_wo_dates.id(i)=wos_add_master(index(i)).unique_id;
                            revised_wo_dates.start_date(i)=revised_wo_dates.end_date(i-1);
                            revised_wo_dates.end_date(i)=revised_wo_dates.start_date(i)+wos_add_master(index(i)).cp_duration;
                        end
                    end
                    %*** End Work Order Serialization***
                    
                    %*** Add Operations to Empty Master Schedule***
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
                                
                                %add the first operation to the schedule
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
                            elseif rout_source~=1 && rout_target==2 %edge is the last routing operation
                                %add the last operation to the schedule
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
                                
                                %add the end lag edge to the schedule
                                source={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
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
                                master_schedule.Edges.RoutingEndNodes(edge_index,:)=[tempG.Edges.EndNodes(j,2) NaN];
                            elseif rout_source==1 && rout_target==2 %single operation in the routing
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
                                
                                %add the only operation to the schedule
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
                                
                                %add the end lag edge to the schedule
                                source={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
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
                                master_schedule.Edges.RoutingEndNodes(edge_index,:)=[tempG.Edges.EndNodes(j,2) NaN];
                            else %fo all other operations in the WO
                                %add the operation to the schedule
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
                            end
                            
                        end
                    end
                    %*** End Add Operations to Empty Master Schedule***
                    
                else %if the master schedule already has data in it then
                    %calcuate the critical path through the master sch
                    %sort the new WOs based on due date
                    %calculate revised dates using critical path
                    %add new WOs to master
                end
                %perform fwd/bwd schedule passes - calc early/late start/finish
                %pass info to update WO due dates
            end
        end
    end
end

