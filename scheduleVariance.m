function [js_wos] = scheduleVariance(comm_net, js_wos, planned_duration, operation, mach_no)

%--------------------------------------------------------------------------
%SCHEDULEVARIANCE   Function that calculates schedule variance of a
%                   selected network stochastically
%
%   This function allows a user to calculate schedule variance in a 
%   stochastic manner. The user provides the communication network being
%   used, the work order, the expected duration, what operation within the
%   work order is being performed. The function then generates the actual
%   time it will take to peform the operation in a stochastic manner (using
%   poissrnd).  The function then determines the shortest path bewteen the
%   machine performing work and the directo & vendors, which dictates the
%   time penalty/improvement experienced in different networks.  The
%   function then calculates the schedule variance and adds it to the work
%   order.
%
%   Inputs:
%   comm_net            Network from Communications Network function
%   js_wos              The job shop work order being worked
%   planned_duration    The expected duration of the operation
%   operation           Which operation is being performed
%   mach_no             The machine number corresponding to the operation
%--------------------------------------------------------------------------

%   Gernate the actual time required to perform the taks
actual_duration=poissrnd(planned_duration);
part_delivery_delay=poissrnd(5);

%   Determine sources, targets, and weights from the supplier network
source = comm_net.Edges.EndNodes(:,1);
target = comm_net.Edges.EndNodes(:,2);
weights = comm_net.Edges.Weight;
G = graph(source, target, weights);

%   Calculate shortest path (and therefore time reductions) for each
%   machine.  The node names must match those of assigned in the
%   Communication Network function. 
if strcmp(operation,'A')

    [dir_P, d_length] = shortestpath(G,'Director','Machine.A1');
    [ven_P, v_length] = shortestpath(G,'Vendor.1','Machine.A1');

    dir_time_reduction = 10/d_length;
    ven_time_reduction = 10/v_length;
    
elseif strcmp(operation,'B')
        
    [dir_P, d_length] = shortestpath(G,'Director','Machine.B2');
    [ven_P, v_length] = shortestpath(G,'Vendor.1','Machine.B2');

    dir_time_reduction = 10/d_length;
    ven_time_reduction = 10/v_length;
    
elseif strcmp(operation,'C')
    
    [dir_P, d_length] = shortestpath(G,'Director','Machine.C3');
    [ven_P, v_length] = shortestpath(G,'Vendor.1','Machine.C3');

    dir_time_reduction = 10/d_length;
    ven_time_reduction = 10/v_length;
    
elseif strcmp(operation,'D')
    
    [dir_P, d_length] = shortestpath(G,'Director','Machine.D4');
    [ven_P, v_length] = shortestpath(G,'Vendor.1','Machine.D4');

    dir_time_reduction = 10/d_length;
    ven_time_reduction = 10/v_length;
    
elseif strcmp(operation,'E')
    
    [dir_P, d_length] = shortestpath(G,'Director','Machine.E5');
    [ven_P, v_length] = shortestpath(G,'Vendor.1','Machine.E5');

    dir_time_reduction = 10/d_length;
    ven_time_reduction = 10/v_length;
    
else
    disp('Too many machines!');
        
end
    
%   Determine time reduction and the impact it has to actual duration
if actual_duration > planned_duration
    
    if sum(strcmp(js_wos.routing.Edges.VendorPart(mach_no),'required')) > 0
        
        total_time_reduction = dir_time_reduction + ven_time_reduction;
        actual_duration = actual_duration - total_time_reduction + part_delivery_delay;
    
    else
        total_time_reduction = dir_time_reduction;
        actual_duration = actual_duration - total_time_reduction;
    end
    
else
    total_time_reduction = 0;
    
end

%   Calculate schedule variance
js_wos.routing.Edges.SV(mach_no) = planned_duration - actual_duration;
js_wos.total_SV = sum(js_wos.routing.Edges.SV);

end

