function [ t, ven, js_wos, js_sch, sup, mach ] = routeWOs(js_wos, js_sch, ven, sup, mach, count)

t = timer;
%t.UserData = count;
t.StartFcn = @TimerStart;
t.TimerFcn = @readTime;
t.StopFcn = @TimerCleanup;
t.ExecutionMode = 'singleShot';

function TimerStart(mTimer,~)
    str1 = sprintf('Begin Hour %d', count);
    disp(str1);
end

function readTime(mTimer,~)
    
    %have master schedule write to the command line which operations should be performed this clock cycle
    planningMessage(js_sch,count,{sup.functional_group});

    %Vendor Class processPO method
    [ ven js_wos ] = processPO(ven,js_wos,js_sch);
    
    %Vendor Class deliverPart method
    [ven, js_wos ]=deliverPart(ven,js_wos,count);
    
    %have the supervisors get the job queues from the master schedule
    sup=getWork(sup,js_sch.master_schedule.Edges);

    %supervisor to assign work to a machine and update WOs to released
    for i=1:length(sup)
        %find all machines in a particular functional group that are idle
        f_grp_idle_machines=findobj(mach,'functional_group',sup(i).functional_group,'-and','status','idle');
        %passing f_grp_machines back from the assign work function should update the m_arr object array accordingly
        [f_grp_idle_machines, sup, js_wos]=assignWork(sup,f_grp_idle_machines,js_wos,i,count);
        clear f_grp_machines
    end
    clear i
    
      %machien performs work
    [run_machines js_wos]=performWork(findobj(mach,'status','running'),js_wos);

    %search for work orders with status in-work
    wos_in_work=findobj(js_wos,'status','in-work');
    %search for work orders with status planned
    wos_planned=findobj(js_wos,'status','planned');
                    
    if length(wos_in_work) > 0 & length(wos_planned) > 0
        %update the master schedule before closing WOs to avoid the code havint to loop thru closed ones
        %update master schedule
        js_sch.master_schedule=updateMasterSchedule(js_sch,wos_in_work,wos_planned);
    end

               
   %search for open work order (i.e. not closed or cancelled)
   open_wos=findobj(js_wos,'status','new','-or','status','planned','-or','status','in-work');
   %call closeWO method to check to see if the WO status should be set to closed
   open_wos=closeWO(open_wos);

   %calculate SV
   js_wos = calcSV(js_wos);%calulates SV for each step and total SV
end


function [time] = TimerCleanup(mTimer,~)
    str2 = sprintf('End Hour %d', count);
    disp(str2);
    delete(mTimer)
end

end

