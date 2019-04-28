classdef Director < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = Director()
%             %UNTITLED Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.Property1 = inputArg1 + inputArg2;
        end
        
        function [G, status]=generateRouting(obj)
            %network schedule starting and ending nodes
            SchStartNode=1;
            SchEndNode=2;

            %source node - node 1 is the start of the schedule
            source=[1 3 4];
            %target node - node 3 is the finish node
            target=[3 4 2];
            %weights - ***duration of the activity***
            weight=[10 10 10];
            %Activity (Edge) Name
            operation={'A'; 'B'; 'C'};
            
            %creation of the digraph object which contains the routing for
            %the WO
            G=digraph(source,target,weight);

            %adding edge names to the graph edge table
            G.Edges.Operation=operation;                            
            
            %initializing the Vendor part required  column
            G.Edges.VendorPart={'NA';'NA';'NA'};
            
            %initializing the Vendor part delivered column
            G.Edges.PartDelivered=zeros(length(weight),1);
            
            %initializing the operation complete column column
            G.Edges.WorkComplete=zeros(length(weight),1);
            
            %initializing the WO hours worked column
            G.Edges.HoursWorked=zeros(length(weight),1);
            
            %initializing the budgeted cost of the WO
            G.Edges.BudgetedCost=zeros(length(weight),1);
            
            %initializing the actual cost of the WO
            G.Edges.ActualCost=zeros(length(weight),1);
            
            %initializing the cost variance of the WO operations
            G.Edges.CV=zeros(length(weight),1);
            
            %initializing schedule variance of the WO operations
            G.Edges.SV=zeros(length(weight),1);
            
            %initializing the status of each operation
            G.Edges.Status(linspace(1,length(weight),length(weight)),1)={char('planned')};
            
            %set WO status to planned
            status='planned';
            
        end
        
        %method to add all routings to the master schedule by calling a
        %method passing inputs and calling a method on JobShopSchedule
        function [add_master_ids]=masterSchedule(obj, wo_obj_array)
            %the wo_obj_array is passed into this method
            
            %find the objects where master_schedule=0
            add_master=findobj(wo_obj_array,'master_schedule',0);
            
            %extract vector of WO unique identifiers that need to be added
            %to master schedule
            add_master_ids=[add_master.unique_id];
        end
            
    end
end