function [ dir, sup, mach, rec ] = createJobShop( no_dir, no_sup, no_mach, no_rec )
%
%--------------------------------------------------------------------------
%CREATEJOBSHOP  Function that insantiates all the objects of a designed job
%               job
%
%   This function allows a user to create a single job shop configuration.
%   The user provides the number of directors, supervisors, machines, and
%   receiving focals, and the function instantiates the corresponding
%   object arrays.  After initializing an array, the createJobShopConfig
%   function is called to layout the configuration.
%
%   Inputs:
%   no_dir      Number of Directors
%   no_sup      Number of Supervisors
%   no_mach     Number of Machines (MUST BE DIVISIBLE BY no_sup!)
%   no_rec      Number or Receiving Focals
%--------------------------------------------------------------------------

    %------------------------------------------
    %Instantiate Objects of Job Shop 
    %------------------------------------------
    
    %Director Object(s):
    if no_dir > 0
        for i = 1:no_dir
            dir(i)=Director();
        end
    else
        disp('No directors generated')
    end
    
    %Supervisor Object(s):
    if no_sup > 5
        disp('Number of supervisors exceeds maximum allowed (5)')
        else if no_sup > 0
            sup = Supervisor.empty;
        else
            disp('No supervisors generated')
        end
    end
    
    %Machine Object(s):
    if no_mach > 10
        disp('Number of machines exceeds maximum allowed (5)')
        else if no_mach > 0
            mach = Machine.empty;
        else
            disp('No machines generated')
        end
    end
    
    %Receiving Object(s):
    if no_rec > 0
        for i = 1:no_rec
            rec(i)=Receiving();
        end
    else
        disp('No receiving focals generated')
    end
    
    %Create the Job Shop Configuration
    [sup, mach] = createJobShopConfig(no_sup, no_mach, sup, mach);
    
end