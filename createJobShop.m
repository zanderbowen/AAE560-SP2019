function [ dir, sup, mach, rec ] = createJobShop( no_dir, no_sup, no_mach, no_rec )
%
%--------------------------------------------------------------------------
%CREATEJOBSHOP  Function that insantiates all the objects of a designed job
%               job
%
%   This function allows a user to create a single job shop configuration.
%   The user provides the number of directors, supervisors, machines, and
%   receiving focals, and the function instantiates the corresponding
%   object arrays.  
%
%   Inputs:
%   no_dir      Number of Directors
%   no_sup      Number of Supervisors
%   no_mach     Number of Machines
%   no_rec      Number or Receiving Focals
%--------------------------------------------------------------------------

    %------------------------------------------
    %Instantiate Objects of Job Shop 
    %------------------------------------------
    
    %Director Object(s):
    for i = 1:no_dir
        dir(i)=Director();
    end
    
    %Supervisor Object(s):
    for i = 1:no_sup
        sup(i)=Supervisor();
    end
    
    %Machine Object(s):
    for i = 1:no_mach
        mach(i)=Machine();
    end
    
    %Receiving Object(s):
    for i = 1:no_rec
        rec(i)=Receiving();
    end

end

