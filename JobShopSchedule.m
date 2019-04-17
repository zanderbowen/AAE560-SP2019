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
            
            %create revised_wo_dates structure
            revised_wo_dates=struct('id',[],'start_date',[],'end_date',[]);
            
            %check to ensure there are work orders to add
            if ~isempty(wos_add_master)
                
                if isempty(obj.master_schedule.Nodes) %check to see if the js_sch object has any data in it
                    %find the earliest start date
                    [temp index]=sort([wos_add_master.start_date]);
                    %loop through wos_add_master and add WO routing to the master schedule
                    
                    for i=1:length(wos_add_master)
                        %no need to check due date for the first WO
                        %extract the wo unique id
                        u_id=wos_add_master(index(i)).unique_id;
                        %extract the wo routing
                        tempG=wos_add_master(index(i)).routing;
                        %extrace the wo critical path duration
                        cp_duration=wos_add_master(index(i)).cp_duration;
                        
                        if i==1
                            %assume the first work order starts at t=0
                            %populate a structure with revised information
                            revised_wo_dates.id(i)=u_id;
                            revised_wo_dates.start_date(i)=0;
                            revised_wo_dates.end_date(i)=revised_wo_dates.start_date(i)+cp_duration;
                            
                            %loop through the WO routing edges and add them to the master schedule digraph
                            for j=1:length(tempG.Edges.EndNodes)
                                
                                if j==1 %first loop thru the WO routing
                                    source=obj.start_node;
                                    %target node is named unique wo id dot edge ending node - the edges of are more importance
                                    target={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
                                    weight=tempG.Edges.Weight(j);
                                    master_schedule=addedge(obj.master_schedule,source,target,weight);
                                    %adding edge labels to the master schedule
                                    %naming convention: WO id dot Operation = Operation Duration
                                    edge_label{j,1}=[num2str(u_id),'.',char(tempG.Edges.Operation(j)),'=',num2str(weight)];
                                    %adding additional routing information
                                    %ot the Edges table for future
                                    %use/reference
                                    edge_wo(j,1)=u_id;
                                    operation_wo{j,1}=char(tempG.Edges.Operation(j));
                                    routing_end_nodes(j,:)=tempG.Edges.EndNodes(j,:);
                                    
                                    master_schedule.Edges.EdgeLabel=edge_label; %gives the edges a label name that is WO_id.Operation=Duration
                                    master_schedule.Edges.EdgeWO=edge_wo; %add the WO unique ID to each edge in the edges table
                                    master_schedule.Edges.OperationWO=operation_wo; %add the WO operation identifier to each edge in the edges table 
                                    master_schedule.Edges.RoutingEndNodes=routing_end_nodes; %add the WO routing end nodes for each edge in the edges table
                                    
                                else %all other loops thru the very first WO routing in the master schedule
                                    source={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,1))]};
                                    target={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
                                    weight=tempG.Edges.Weight(j);
                                    master_schedule=addedge(master_schedule,source,target,weight);
                                    edge_label{j,1}=[num2str(u_id),'.',char(tempG.Edges.Operation(j)),'=',num2str(weight)];                                 
                                    edge_wo(j,1)=u_id;
                                    operation_wo{j,1}=char(tempG.Edges.Operation(j));
                                    routing_end_nodes(j,:)=tempG.Edges.EndNodes(j,:);
                                    
                                    master_schedule.Edges.EdgeLabel=edge_label; %gives the edges a label name that is WO_id.Operation=Duration
                                    master_schedule.Edges.EdgeWO=edge_wo; %add the WO unique ID to each edge in the edges table
                                    master_schedule.Edges.OperationWO=operation_wo; %add the WO operation identifier to each edge in the edges table 
                                    master_schedule.Edges.RoutingEndNodes=routing_end_nodes; %add the WO routing end nodes for each edge in the edges table
                                    
                                    
                                end
                            end
                            
                        else %all other loops thru second to nth WO
                            %adjust the start date of the next work order
                            %to right after the previous one
                            
                            %populate a structure with revised information
                            revised_wo_dates.id(i)=u_id;
                            revised_wo_dates.start_date(i)=revised_wo_dates.end_date(i-1)+1;
                            revised_wo_dates.end_date(i)=revised_wo_dates.start_date(i)+cp_duration;
                            
                            %??? indexing for master schedule will need to be based on a counter ???
                            ct=length(master_schedule.Edges.EndNodes)+1;
                            
                            %extract the wo unique id
                            u_id=wos_add_master(index(i)).unique_id;
                            %extract the wo routing
                            tempG=wos_add_master(index(i)).routing;
                            %extrace the wo critical path duration
                            cp_duration=wos_add_master(index(i)).cp_duration;
                            
                            for j=1:length(tempG.Edges.EndNodes)+1
                                
                                if j==1 %first loop thru the WO routing
                                    source=obj.start_node;
                                    %since these WOs occur serially, there
                                    %is a lead time between the start of
                                    %the simulation and the start of the
                                    %next work order called
                                    %Start.Lead.wo_id.node
                                    target={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,1))]};
                                    weight=revised_wo_dates.start_date(i)-revised_wo_dates.start_date(i-1);
                                    master_schedule=addedge(master_schedule,source,target,weight);
                                    
                                    %find edge index
                                    edge_index=findedge(master_schedule,source,target);
                                    %adding edge labels to the master schedule
                                    %naming convention: WO id dot Operation = Operation Duration
                                    master_schedule.Edges.EdgeLabel{edge_index}=['Start.Lead.',num2str(u_id),'=',num2str(weight)];
                                    %adding additional routing information
                                    %ot the Edges table for future
                                    %use/reference
                                    master_schedule.Edges.EdgeWO(edge_index)=u_id;
                                    master_schedule.Edges.OperationWO{edge_index}=char(tempG.Edges.Operation(j));
                                    master_schedule.Edges.RoutingEndNodes(edge_index,:)=[NaN tempG.Edges.EndNodes(j,1)];
                                    
                                else %all other loops thru the very first WO routing in the master schedule
                                    %??? need to go to j-1 index ???
%                                     source={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,1))]};
%                                     target={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
%                                     weight=tempG.Edges.Weight(j);
%                                     master_schedule=addedge(master_schedule,source,target,weight);
%                                     edge_label{j,1}=[num2str(u_id),'.',char(tempG.Edges.Operation(j)),'=',num2str(weight)];                                 
%                                     edge_wo(j,1)=u_id;
%                                     operation_wo{j,1}=char(tempG.Edges.Operation(j));
%                                     routing_end_nodes(j,:)=tempG.Edges.EndNodes(j,:);
%                                     
%                                     master_schedule.Edges.EdgeLabel=edge_label; %gives the edges a label name that is WO_id.Operation=Duration
%                                     master_schedule.Edges.EdgeWO=edge_wo; %add the WO unique ID to each edge in the edges table
%                                     master_schedule.Edges.OperationWO=operation_wo; %add the WO operation identifier to each edge in the edges table 
%                                     master_schedule.Edges.RoutingEndNodes=routing_end_nodes; %add the WO routing end nodes for each edge in the edges table
                                    
                                    
                                end
                                %increment the counter
                                ct=ct+1;
                            end
                            
                        end
                     
                    end
                else %if the master schedule already has data in it then
                    %if not then append WOs to master schedule
                    %assumptions: JS works on FIFO, all serial operations,no parallel functionally simialar machines
                end
            end
        %??? need to update WO due dates ???
    end
    end
end

