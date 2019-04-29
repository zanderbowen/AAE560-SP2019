function [js_wos] = routing( js_wos, dir )

for i=1:length(js_wos)
    if strcmp(js_wos(i).status,'new')
        [js_wos(i).routing,js_wos(i).status]=generateRouting(dir);
        
        ops = length(js_wos(i).routing.Edges.VendorPart);
        r = randi([1 2], 1, ops);
        
        for j = 1:ops
            if r(j) == 1
            js_wos(i).routing.Edges.VendorPart{j}='required';
            end
        end
    end
    
    if strcmp(js_wos(i).status,'planned') && js_wos(i).master_schedule==0
        [js_wos(i).start_date js_wos(i).cp_duration]=calculateStartDate(js_wos(i));
    end
end

end

