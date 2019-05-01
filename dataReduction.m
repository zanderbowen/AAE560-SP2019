%pull in total SV from each WO
total_SV_vec=[js_wos.total_SV];

%sum the total SV vector
SV_sum=sum(total_SV_vec);

%generate a histogram of total variances
figure;
histogram(total_SV_vec);
xlabel('Schedule Variance - Network 1');

%calculated mean total SV
mean_SV=mean(total_SV_vec);

%calculate the standard deviation
std_SV=std(total_SV_vec);

%display results
disp(['The mean schedule variance is ',num2str(mean_SV),'.']);
disp(['The standard distribution of schedule variance is ',num2str(std_SV),'.']);