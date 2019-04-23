classdef Customer < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        new_wo
        new_wo_due_date
        unique_id
    end
    
    methods
        function obj = Customer(unique_id,id_vec)
            %check to make sure that a supervisor is not already assigned to the functional group
            if isempty(find(id_vec==unique_id))
                obj.unique_id=unique_id;
            else
                error(['This identifier is already used by Customer ',num2str(unique_id),'.']);
            end
        end
    end
end