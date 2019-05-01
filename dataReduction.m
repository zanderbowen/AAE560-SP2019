%pull in total SV from each WO
total_SV_vec=[js_wos.total_SV];

%sum the total SV vector
SV_sum=sum(total_SV_vec);

%generate a histogram of total variances
figure;
histogram(total_SV_vec);
xlabel('Schedule Variance - Status Quo');

%calculated mean total SV
mean_SV=mean(total_SV_vec);

%calculate the standard deviation
std_SV=std(total_SV_vec);

%display results
disp(['The mean schedule variance is ',num2str(mean_SV),'.']);
disp(['The standard distribution of schedule variance is ',num2str(std_SV),'.']);

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