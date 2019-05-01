close all;

% *** figure defaults ***
width = 6;     % Width in inches
height = 4;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 11;      % Fontsize
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
% ************************
% figure;
% pos = get(gcf, 'Position');
% set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
% set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

%pull in total SV from each WO
total_SV_vec=[js_wos.total_SV];

%sum the total SV vector
SV_sum=sum(total_SV_vec);

%generate a histogram of total variances
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
histogram(total_SV_vec);
xlabel('Schedule Variance - Network 6');
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

%calculated mean total SV
mean_SV=mean(total_SV_vec);

%calculate the standard deviation
std_SV=std(total_SV_vec);

%display results
disp(['The sum total schedule variance is ',num2str(SV_sum),'.'])
disp(['The mean schedule variance is ',num2str(mean_SV),'.']);
disp(['The standard distribution of schedule variance is ',num2str(std_SV),'.']);


comm_net_sum_SV=[3.1,924.4,2087,737,195,863];
comm_net_mean_SV=[.0062,1.85,4.18,1.47,.39,1.73];
comm_net_std_SV=[6,5.3,4.51,5.28,5.82,5.156];
comm_net_cc=[0 .429 .493 .414 .414 .467];
comm_net_bc=[0 .019 .378 0 0 .037];

%generate a bar chart of total SV
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
bar(comm_net_sum_SV);
xlabel('Network');
ylabel('Total Schedule Variance (500 Processed WOs)');
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

%generate a bar chart of mean values
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
bar(comm_net_mean_SV);
xlabel('Network');
ylabel('Mean Schedule Variance');
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

%generate a bar chart of st. dev. values
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
bar(comm_net_std_SV);
xlabel('Network');
ylabel('Standard Deviation Schedule Variance');
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties

%generate a scatter plot Mean SV v. CC
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
h=scatter(comm_net_cc,comm_net_mean_SV,'ob','MarkerFaceColor','b');
xlabel('Average Clustering Coefficient');
ylabel('Mean Schedule Variance');
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
grid on;

%generate a scatter plot Mean SV v. BC
figure;
pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1) pos(2) width*100, height*100]); %<- Set size
h=scatter(comm_net_bc,comm_net_mean_SV,'ob','MarkerFaceColor','b');
xlabel('Average Alpha Level Betweeness Centrality');
ylabel('Mean Schedule Variance');
set(gca, 'FontSize', fsz, 'LineWidth', alw); %<- Set properties
grid on;