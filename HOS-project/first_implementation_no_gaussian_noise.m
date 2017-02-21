%Script with final output the RMSE of estimated signals(No WGN added)

clear
close all
reps = 1:50;

for j = 1:length(reps)
    clearvars -except j rmse rmse2 rmse3 rmse1 reps
    %% Signal Generation
    N = 2048;
    v = exprnd(1,1,N);
    v = v - mean(v);
    q=[1 .93 .85 .72 .59 -.1];
    x = filter(q,1,v);

%% Parametric Estimation of Skewness to check for Non-Gaussianity
    skew = 0;
    m = mean(v);
    s = std(v);
    for i=1:N
       skew = skew + ((v(i)-m)^3) ;
    end

    skew = skew/((N-1)*(s^3))
    error = (abs(skew - skewness(v))/abs(skewness(v)))*100;
    str = ['v[k] is Non-Gaussian with estimated skewness = ' ,num2str(skew)];
    str2 = ['Approximation Error = ',num2str(error),'%'];

    if skew ~= 0
        disp(str);
        disp(str2);
    else
        disp('v[k] is Gaussian');
    end

%% 3rd Order Cummulant Estimation
    K=32;
    M=64;
    L=20;
    for n =-L:L
        c = cum3est(x,L,M,0,'biased',n);
        c3(:,n+L+1) = c;
    end
    % use the code below only for 1 repetition
%      figure
%      contour(-L:L,-L:L,c3)
%      xlabel('t1');ylabel('t2');title('3rd Order Cummulants hosa');
%      figure
%      surf(-L:L,-L:L,c3)
%      xlabel('t1');ylabel('t2');title('3rd Order Cummulants hosa');

%% Giannakis equation for known q
    qq = length(q);
    h=c3(qq+L+1,L+1:qq+L+1)./c3(qq+L+1,L+1);

%% Giannakis equation for underestimated q1 = q-2
    qq2 = length(q)-2;
    h2=c3(qq2+L+1,L+1:qq+L+1)./c3(qq2+L+1,L+1);

%% Giannakis equation for overestimated q2 = q+3
    qq3 = length(q)+3;
    h3=c3(qq3+L+1,L+1:qq+L+1)./c3(qq3+L+1,L+1);

%% Signal Generation using Estimated Impulse Response
    x1 = conv(v,h,'same');
    x2 = conv(v,h2,'same');
    x3 = conv(v,h3,'same');

    rmse(j) = sqrt(mean((x-x1).^2));
    rmse2(j) = sqrt(mean((x-x2).^2));
    rmse3(j) = sqrt(mean((x-x3).^2));

end

%% Plot RMSE
figure
scatter(reps,rmse);
set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title('RMSE of x1[k]');
figure
scatter(reps, rmse2,'r')
set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title('RMSE of x2[k]');
figure
scatter(reps , rmse3, 'g')
set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title('RMSE of x3[k]');


%% Overall RMSE
rmse = trimmean(rmse,95);
str = ['Root Mean Square Error of x1[k] is ',num2str(rmse)];
disp(str)
rmse2 = trimmean(rmse2,95);
str = ['Root Mean Square Error of x2[k] is ',num2str(rmse2)];
disp(str)
rmse3 = trimmean(rmse3,95);
str = ['Root Mean Square Error of x3[k] is ',num2str(rmse3)];
disp(str)