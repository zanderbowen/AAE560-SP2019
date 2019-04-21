classdef Vendor < handle
    
    properties
  
        unique_id % unique identifier for each instantiated vendor object
        vendor_po % structure that contains information vendor requires to deliver a part
        early_delivery = 0  %integer of time units that the job shop desires an early delivery
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
                        obj(1).vendor_po.operation{ct}=r_table.Operation(row_index); %WO Operatoin
                        %find the row index in the master schedule containing the early start for the operationa that requires a vendor part
                        ms_edge_name={[num2str(u_id),'.',char(r_table.Operation(row_index))]};
                        ms_row_index=find(contains(ms_table.EdgeLabel,ms_edge_name));
                        obj(1).vendor_po.delivery_date(ct)=ms_table.ES(ms_row_index)-obj(1).early_delivery; %Delivery date
                        %make sure the delivery date is not less than zero
                        if obj(1).vendor_po.delivery_date(ct)<0
                            obj(1).vendor_po.delivery_date(ct)=0;
                        end
                        
                        %mark the PO status to 'received'
                        obj(1).vendor_po.status{ct}='received';
                    end
                end
                ct=ct+1;
            end
        end
    end
end