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
        function master_schedule=addWoToMasterSchedule(obj,wos_add_master)
            
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
                        %extract the wo critical path duration
                        cp_duration=wos_add_master(index(i)).cp_duration;
                        %extract the work order start date
                        start_date=wos_add_master(index(i)).start_date;
                        %extract the work order due date
                        due_date=wos_add_master(index(i)).due_date;
                        
                        if i==1
                            
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
                                    master_schedule.Edges.EdgeLabel=edge_label;
                                    source=target;
                                else %all other loops thru the very first WO routing in the master schedule
                                    target={[num2str(u_id),'.',num2str(tempG.Edges.EndNodes(j,2))]};
                                    weight=tempG.Edges.Weight(j);
                                    master_schedule=addedge(master_schedule,source,target,weight);
                                    edge_label{j,1}=[num2str(u_id),'.',char(tempG.Edges.Operation(j)),'=',num2str(weight)];
                                    master_schedule.Edges.EdgeLabel=edge_label;
                                    source=target;
                                end
                            end
                            
                        else %all other loops thru second to nth WO
                            ct=length(master_schedule.Edges.EndNodes)+1;
                            %??? indexing for master schedule will need to be based on a counter ???
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

