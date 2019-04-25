function AnimateGraph(G)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all;

filename='C:\Users\david\Documents\network.gif';

fh=figure('units','normalized','outerposition',[0 0 1 1]);

h=plot(G,'LineWidth',3,'MarkerSize',10,'NodeFontSize',16);
cust_index=find(contains(G.Nodes.Name,'Customer'));
ven_index=find(contains(G.Nodes.Name,'Vendor'));

mach_index=find(contains(G.Nodes.Name,'Machine'));
ERP_index=find(contains(G.Nodes.Name,'ERP'));

source_indicies=[cust_index,ven_index];
sink_indicies=[mach_index;ERP_index];

layout(h,'layered','Direction','down','Sources',G.Nodes.Name(source_indicies),'Sinks',G.Nodes.Name(sink_indicies));

plotting_pairs={'Customer.1','Director';...
    'Director','ERP';...
    'Supervisor.A','ERP';...
    'Vendor.1','Receiving';...
    'Receiving','ERP';...
    'Supervisor.A','Machine.A1';...
    'Machine.A1','ERP'};

% Capture the plot as an image 
      frame = getframe(fh); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256);
      
      imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',3); 

for i=1:length(plotting_pairs)
    highlight(h,plotting_pairs(i,:),'EdgeColor','r');
    % Capture the plot as an image 
      frame = getframe(fh); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',3);
      
    highlight(h,plotting_pairs(i,:),'EdgeColor','b');
    % Capture the plot as an image 
      frame = getframe(fh); 
      im = frame2im(frame); 
      [imind,cm] = rgb2ind(im,256); 
      imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',1);
    
end
    
end