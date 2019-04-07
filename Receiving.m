
classdef Receiving < handle
    %Evolution1 Receiving Class = Working with single part from vendor, 
   
    %Info about Receiving class: 
        %Vendor part is either received or it is not
            
  properties
  % part_delivered - variable that only Vendor class is able to read/write
  % to telling receiving that they delivered a part of a sepcfic work order
  % and operation
  
    vendor_part_received %dependent on Vendor class "Deliver parts()". If 0, parts not received
  end 

%methods
    %Check that part is has been delivered
    %If parts have been delivered, mark them as delivered in appropriate
    %place in routing and activity
    %after parts have been delivered, clar the part_delivered property
    
    %   function obj = Receiving()
%             %UNTITLED Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.Property1 = inputArg1 + inputArg2;
      %  end
        
      
%Check tatus of vendor part

% part_delivered - variable that only Vendor class is able to read/write
  % to telling receiving that they delivered a part of a specific work order
  % and operation
  
   %Check that part is has been delivered
    %If parts have been delivered, mark them as delivered in appropriate
    %place in routing and activity
    %after parts have been delivered, clear the part_delivered property

 %Anna Questions...
    %How to read if part delivered from vendor?
    % How to mark as delivered in routing and activity?
  
  %Check with vendor that part was delivered  
    
  function check_vendor_part_status
    import Vendor  %to access part delivery status
    import WorkOrder %to be able to update routing and activity
   
    %set default variable value
        vendor_part_received = 0
    
    %Check from vendor class if part was delivery
  
    get.Vendor(vendor_part_delivered); %Change variable name to match whatever vendor class calls it. 
        %Is this is how to check value of property from different class??
    
        
    %Update receiving class variable for vendor part status 
    
    if vendor_part_delivered == 1 %Assuming vendor part status uses logicals for part status
        vendor_part_received = 1; %Set receiving block internal variable for recording part status as "yes, received"
    else 
        vendor_part_received = 0; %Set receiving block internal variable for recording part status as "no, not received"
    end 
    
    
    %Update workorder class routing and activity with vendor part status
    
    if vendor_part_received == 1
        set.Workorder(vendor_routing_complete) = 1 %change variable name to match whatever workorder class calls it
        set.Workorder(vendor_activity_complete)
            %Is this how to set value of property from different class??          
    else 
        set.Workorder(vendor_routing_complete) = 0 %Change variable name to match whatever workorder class calls it
             %Is this how to set value of property from different class??
    end 
  
   %Clear part received status to prepare for assess status of next incoming vendor part
   
   clearvars vendor_part_received
end 
   
%Making assumption that work order compares vendor part received time vs. scheduled due date (aka, receiving doesn't report that)




  
  
  %Likely useless code - uses dialog box user input instead of referencing
  %information from other classes 
    
 %Check part delivery using using dialog box with user input
            %answer = questdlg('Was vendor part received?', ...
             %   'Vendor Part Status', ...
              %  'Yes','No','Yes');
         % Handle response
         %   switch answer
          %      case 'Yes'
           %         vendor_part_received = 1;
            %    case 'No'
             %       vendor_part_received = 0;
           % end

%Check part delivery versus schedule timing using dialog box with user
%input
     %If vendor part is received, what was it's timing compared to schedule?

     %   if vendor_part_received == 1;
%        answer = questdlg('Did the vendor part meeting timing?', ...
 %           'Vendor Part Timing', ...
  %          'Early','On time','Late', 'On time');
      
     %Handle response
     %       switch answer
      %          case 'Early' %If early, determine how early
       %             prompt = {'How many days early?'}
        %             vendor_part_recieved_schedule_difference = str2double(inputdlg(prompt));
%                case 'On time'
 %               vendor_part_received_schedule_difference = 0;

  %              case 'Late' 
   %               prompt = {'How many days late?'};
    %                vendor_part_received_late = str2double(inputdlg(prompt));
     %               vendor_part_received_schedule_difference = -1.* vendor_part_received_late

          %  end
       % else 
   % vendor_part_received == 0; %part not received...updates needed to work order?
%end


