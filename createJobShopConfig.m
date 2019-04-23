function [ sup, mach ] = createJobShopConfig( no_sup, no_mach, sup, mach)
%
%--------------------------------------------------------------------------
%CREATEJOBSHOP  Function that insantiates all the objects of a designed job
%               job
%
%   This function allows a user to create a single job shop configuration.
%   The user provides the number of supervisors, machines, and receiving 
%   focals, then inputs the number of machines assigned to a supervisor.  
%   The function then populates the supplied object arrays.  
%
%   Inputs:
%   no_sup      Number of Supervisors
%   no_mach     Number of Machines
%   mach2sup    Number of Machines Assigned to a Supervisor
%   sup         The Previously Generated Supervisor Array
%   mach        The Previously Generated Machine Array

%--------------------------------------------------------------------------

    %------------------------------------------
    %Populate Objects of Job Shop 
    %------------------------------------------
    
    %Supervisor
    for i = 1:no_sup
        if i == 1
            sup = [sup; Supervisor('A',{sup.functional_group})];
        else if i == 2
            sup = [sup; Supervisor('B',{sup.functional_group})];
        else if i == 3
            sup = [sup; Supervisor('C',{sup.functional_group})];
        else if i == 4
            sup = [sup; Supervisor('D',{sup.functional_group})];
        else 
            sup = [sup; Supervisor('E',{sup.functional_group})];
        end
        end
        end
        end
    end       
    
    %Machines:
    if no_sup == 1
        for i=1:no_mach
            mach = [mach; Machine('A',{sup.functional_group},i,[mach.full_name],8)];
        end
    else if no_sup == 2
        for i = 1:no_mach/2
            mach = [mach; Machine('A',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = no_mach/2+1:no_mach
            mach = [mach; Machine('B',{sup.functional_group},i,[mach.full_name],8)];
        end
    else if no_sup == 3
        for i = 1:no_mach/3
            mach = [mach; Machine('A',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = no_mach/3+1:2/3*no_mach
            mach = [mach; Machine('B',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = 2/3*no_mach+1:no_mach
            mach = [mach; Machine('C',{sup.functional_group},i,[mach.full_name],8)];
        end
    else if sup == 4
        for i = 1:no_mach/4
            mach = [mach; Machine('A',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = no_mach/4+1:1/2*no_mach
            mach = [mach; Machine('B',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = 1/2*no_mach+1:3/4*no_mach
            mach = [mach; Machine('C',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = 3/4*no_mach+1:no_mach
            mach = [mach; Machine('D',{sup.functional_group},i,[mach.full_name],8)];
        end
        
    else if sup == 5
        for i = 1:no_mach/5
            mach = [mach; Machine('A',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = no_mach/5+1:2/5*no_mach
            mach = [mach; Machine('B',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = 2/5*no_mach+1:3/5*no_mach
            mach = [mach; Machine('C',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = 3/5*no_mach+1:4/5*no_mach
            mach = [mach; Machine('D',{sup.functional_group},i,[mach.full_name],8)];
        end
        for i = 4/5*no_mach+1:no_mach
            mach = [mach; Machine('E',{sup.functional_group},i,[mach.full_name],8)];
        end
    end
    end
    end
    end
    end

end