function [ cust ] = createCustomer( no_cust )

%--------------------------------------------------------------------------
%CREATECUSTOMER Function that insantiates all the objects of a customer
%               base
%
%   This function allows a user to create a customer base.  The user
%   provides the number of desired customers and the function insantiates
%   the corresponding object arrays
%
%   Inputs:
%   no_cust     Number of Customers
%--------------------------------------------------------------------------

    %------------------------------------------
    %Instantiate Objects of Customer Base
    %------------------------------------------
    
    %Customer Object(s):
    for i = 1:no_cust
        cust(i)=Customer(0,0);
    end

end

