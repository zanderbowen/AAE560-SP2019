function [actual_duration, total_time_reduction, js_wos] = scheduleVariance(comm_net, js_wos, planned_duration, operation, mach_no)
%SCHEDULEVARIANCE Summary of this function goes here
%   Detailed explanation goes here

%For a given machine, representing the work required on a work order
actual_duration=poissrnd(planned_duration);
part_delivery_delay=poissrnd(5);

source = comm_net.Edges.EndNodes(:,1);
target = comm_net.Edges.EndNodes(:,2);
weights = comm_net.Edges.Weight;
G = graph(source, target, weights);

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

js_wos.routing.Edges.SV(mach_no) = planned_duration - actual_duration;
js_wos.total_SV = sum(js_wos.routing.Edges.SV);

end
