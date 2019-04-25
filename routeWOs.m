function [ t, ven, js_wos, js_sch, sup, mach ] = routeWOs(js_wos, js_sch, ven, sup, mach, count)

t = timer;
t.UserData = js_sch.master_schedule;
t.StartFcn = @TimerStart;
t.TimerFcn = @readTime;
t.StopFcn = @TimerCleanup;
t.Period = .1;
t.TasksToExecute = 1;
t.ExecutionMode = 'fixedRate';

function TimerStart(mTimer,~)
disp('Starting Timer.  ')
end

function readTime(mTimer,~)
       
%Vendor Class processPO method
ven=processPO(ven,js_wos,js_sch); 

%Vendor Class deliverPart method
%for i=1:max(js_sch.master_schedule.Edges.LF)+1
    [ven, js_wos]=deliverPart(ven,js_wos,count);
%end

%have the supervisors get the job queues from the master schedule
sup=getWork(sup,js_sch.master_schedule.Edges);

%!!! supervisor should check for completed work before assigning new work !!!
%??? need to think about order of operations for functions that run inside
%of the wrapper ???

%for i=1:max(js_sch.master_schedule.Edges.LF)
    %[run_machines js_wos]=performWork(findobj(mach,'status','running'),js_wos);
%end


%supervisor to assign work to a machine and update WOs to released
for i=1:length(sup)
    %find all machines in a particular functional group that are idle
    f_grp_idle_machines=findobj(mach,'functional_group',sup(i).functional_group,'-and','status','idle');
    %passing f_grp_machines back from the assign work function should update the m_arr object array accordingly
    [f_grp_idle_machines, sup, js_wos]=assignWork(sup,f_grp_idle_machines,js_wos,i,count);
    clear f_grp_machines
end
clear i

[run_machines js_wos]=performWork(findobj(mach,'status','running'),js_wos);

end


function [time] = TimerCleanup(mTimer,~)
disp('Stopping Timer.')
delete(mTimer)
end

end

