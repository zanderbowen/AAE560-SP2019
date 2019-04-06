%Status of vendor part

answer = questdlg('Was vendor part received?', ...
	'Vendor Part Status', ...
	'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
        vendor_part_received = 1;
    case 'No'
        vendor_part_received = 0;
end
  
%If vendor part is received, what was it's timing compared to schedule?
if vendor_part_received == 1;
    
answer = questdlg('Did the vendor part meeting timing?', ...
	'Vendor Part Timing', ...
	'Early','On time','Late', 'On time');
% Handle response
    switch answer
        case 'Early' %If early, determine how early
            prompt = {'How many days early?'}
             vendor_part_recieved_schedule_difference = str2double(inputdlg(prompt));
                    
        case 'On time'
        vendor_part_received_schedule_difference = 0;
                  
        case 'Late' 
          prompt = {'How many days late?'};
            vendor_part_received_late = str2double(inputdlg(prompt));
            vendor_part_received_schedule_difference = -1.* vendor_part_received_late
            
    end
else 
    vendor_part_received == 0; %part not received...updates needed to work order?

%Difference from schedule for part received needs to be communicated
% Vendor part not received needs to be communicated

end   