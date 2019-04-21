classdef Vendor < handle
    
    properties
  
        unique_id % unique identifier for each instantiated vendor object
        vendor_po % structure that contains information vendor requires to deliver a part
        early_delivery = 0  %integer of time units that the job shop desires an early delivery
        actual_delivery_date %deterministic: obj.vendor_po.delivery_date=actual_delivery_date stochastic: based on a PDF
    end
 %Read Work Orders and determine if they need to send a part
 
    methods

        %Constructor Method
        function obj = Vendor(unique_id,id_vec,early_delivery) %Creates supervisor object
            %check to make sure that a supervisor is not already assigned to the functional group
            if isempty(find(id_vec==unique_id))
                obj.unique_id=unique_id;
                obj.early_delivery=early_delivery;
                %delivery date will be based off of the 
                obj.vendor_po=struct('wo_id',[],'operation',{''},'delivery_date',[],'status',{''});
            else
                error(['This identifier is already used by Vendor ',num2str(unique_id),'.']);
            end
        end
        
        %a function that mimicks the job shop sending a vendor a purchase order (PO)
        %slight difference, Vendor looks at JS WOs and JS Master Schedule
        function obj=processPO(obj,js_wos,js_sch)
            %find operations that require a vendor part that has not already been delivered
            ms_table=js_sch.master_schedule.Edges;
            ct=1;
            for i=1:length(js_wos)
                u_id=js_wos(i).unique_id;
                r_table=js_wos(i).routing.Edges;
                %find row indicies of operations that require vendor supplied parts
                row_index=find(r_table.VendorPart==1);
                
                for j=1:length(row_index)
                    if r_table.PartDelivered(row_index(j))~=1
                        %assuming only a single vendor in this model
                        %obj.vendor_po=struct('wo_id',[],'operation',{},'delivery_date',[],'status',{});
                        obj(1).vendor_po.wo_id(ct)=u_id; %WO unique ID
                        obj(1).vendor_po.operation{ct}=r_table.Operation(row_index(j)); %WO Operatoin
                        %find the row index in the master schedule containing the early start for the operationa that requires a vendor part
                        %!!! assumes there is only one operation with that specific name in the master schedule !!!
                        ms_edge_name={[num2str(u_id),'.',char(r_table.Operation(row_index(j)))]};
                        ms_row_index=find(contains(ms_table.EdgeLabel,ms_edge_name));
                        obj(1).vendor_po.delivery_date(ct)=ms_table.ES(ms_row_index)-obj(1).early_delivery; %Delivery date
                        %make sure the delivery date is not less than zero
                        if obj(1).vendor_po.delivery_date(ct)<0
                            obj(1).vendor_po.delivery_date(ct)=0;
                        end
                        
                        %mark the PO status to 'received'
                        obj(1).vendor_po.status{ct}='received';
                        ct=ct+1;
                    end
                end
            end
        end
        
        %method that delivers the parts to the JS, by setting the
        %PartDelivered flag in obj.routing.Edges.PartDelivered to 1
        function [obj js_wos]=deliverPart(obj,js_wos,current_time)
            %deterministic: obj.vendor_po.delivery_date=actual_delivery_date stochastic: based on a PDF
            obj(1).actual_delivery_date=obj(1).vendor_po.delivery_date;
            %find all the parts that have a received PO status
            v_po_index=find(strcmp(obj(1).vendor_po.status,'received'));
            
            for i=1:length(v_po_index)
                %check to see if they can be delivered
                if obj(1).actual_delivery_date(v_po_index(i))==current_time
                    %set PartDelivered flag in WO to 1
                    %find row index in WO routing table
                    wo_id=obj(1).vendor_po.wo_id(v_po_index(i));
                    r_table=js_wos(wo_id).routing.Edges;
                    r_table_index=find(strcmp(r_table.Operation,obj(1).vendor_po.operation{v_po_index(i)}));
                    js_wos(wo_id).routing.Edges.PartDelivered(r_table_index)=1;
                    obj(1).vendor_po.status{v_po_index(i)}='delivered';
                end
            end
        end
    end
end