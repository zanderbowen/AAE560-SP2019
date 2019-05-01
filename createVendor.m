function [ ven ] = createVendor( no_ven, early_delivery, del_lambda, stoch )
%
%--------------------------------------------------------------------------
%CREATEVENDOR  Function that insantiates all the objects of a vendor base
%
%   This function allows a user to generate a vendor base. The user
%   provides the number of desired vendors, and the function instantiates 
%   the corresponding object arrays.  
%
%   Inputs:
%   no_ven          Number of Vendors
%   early_delivery  Time Units that Job Shop Desires an Early Delivery
%   del_lambda      Property to define stochastic behavior range
%   stoch           Switch to initiate stochastic behavior
%--------------------------- -----------------------------------------------

    %------------------------------------------
    %Instantiate Objects of Vendors
    %------------------------------------------
    
    %Vendor Object(s):
    if no_ven > 0
        ven=Vendor.empty;
        for i = 1:no_ven
            ven = [ven; Vendor(i,[ven.unique_id],early_delivery,del_lambda, stoch)];
        end

end
