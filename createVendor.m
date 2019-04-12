function [ ven ] = createVendor( no_ven )
%
%--------------------------------------------------------------------------
%CREATEVENDOR  Function that insantiates all the objects of a vendor base
%
%   This function allows a user to generate a vendor base. The user
%   provides the number of desired vendors, and the function instantiates 
%   the corresponding object arrays.  
%
%   Inputs:
%   no_ven      Number of Vendors
%--------------------------------------------------------------------------

    %------------------------------------------
    %Instantiate Objects of Vendors
    %------------------------------------------
    
    %Vendor Object(s):
    for i = 1:no_ven
        ven(i)=Vendor();
    end

end

