%Script with final output the RMSE of estimated signals(with GWN added)

clear
close all
reps = 1:50;

for j = 1:length(reps)
    clearvars -except j rmse rmse2 rmse3 rmse1 reps first_tier last_tier step
%% Signal Generation
    N = 2048;
    v = exprnd(1,1,N);
    v = v - mean(v);
    q=[1 .93 .85 .72 .59 -.1];
    x = filter(q,1,v);
    
    first_tier = 30;
    last_tier = -5;
    step = -5;
%% For each repetition add GWN with various SNRs
    for snr = first_tier:step:last_tier

        x = awgn(x,snr,'measured'); %Add WGN with given SNR

%% Parametric Estimation of Skewness to check for Non-Gaussianity
%  Uncoment to show console message about the nature of v(k)
%         skew = 0;
%         m = mean(v);
%         s = std(v);
%         for i=1:N
%            skew = skew + ((v(i)-m)^3) ;
%         end
%         
%         skew = skew/((N-1)*(s^3))
%         error = (abs(skew - skewness(v))/abs(skewness(v)))*100;
%         str = ['v[k] is Non-Gaussian with estimated skewness = ' ,num2str(skew)];
%         str2 = ['Approximation Error = ',num2str(error),'%'];
%         
%         if skew ~= 0
%             disp(str);
%             disp(str2);
%         else
%             disp('v[k] is Gaussian');
%         end

%% 3rd Order Cummulant Estimation
        K=32;
        M=64;
        L=20;
        for n =-L:L
            c = cum3est(x,L,M,0,'biased',n);
            c3(:,n+L+1) = c;
        end
        % use the code below only for 1 repetition
%         figure
%         contour(-L:L,-L:L,c3)
%         xlabel('t1');ylabel('t2');title(['3rd Order Cummulants - SNR= ', num2str(snr), 'db']);
%         figure
%         surf(-L:L,-L:L,c3)
%         xlabel('t1');ylabel('t2');title(['3rd Order Cummulants - SNR= ', num2str(snr), 'db']);
      
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

        rmse(j,(first_tier+abs(step))/abs(last_tier)-snr/abs(last_tier)) = sqrt(mean((x-x1).^2)); 
        rmse2(j,(first_tier+abs(step))/abs(last_tier)-snr/abs(last_tier)) = sqrt(mean((x-x2).^2));
        rmse3(j,(first_tier+abs(step))/abs(last_tier)-snr/abs(last_tier)) = sqrt(mean((x-x3).^2));
       
    end
end

%% Plot overall RMSE vs SNR
SNR = 30:-5:-5;
figure
plot(SNR,trimmean(rmse,95))
xlabel('SNR');ylabel('RMSE');title('RMSE-SNR of x1[k]');
figure
plot(SNR,trimmean(rmse2,95))
xlabel('SNR');ylabel('RMSE');title('RMSE-SNR of x2[k]');
figure
plot(SNR,trimmean(rmse3,95))
xlabel('SNR');ylabel('RMSE');title('RMSE-SNR of x3[k]');

%% Plot overall RMSE of tier 1-4-8 GWN vs Repetitions
SNR = 30:-5:-5;
figure
scatter(reps,rmse(:,1))
set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x1[k] for SNR= ', num2str(SNR(1)),'db']);
figure
scatter(reps,rmse(:,4))
set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x1[k] for SNR= ', num2str(SNR(4)),'db']);
figure
scatter(reps,rmse(:,8))
set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x1[k] for SNR= ', num2str(SNR(8)),'db']);

% figure
% scatter(reps,rmse2(:,1))
% set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x2[k] for SNR= ', num2str(SNR(1)),'db']);
% figure
% scatter(reps,rmse2(:,4))
% set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x2[k] for SNR= ', num2str(SNR(4)),'db']);
% figure
% scatter(reps,rmse2(:,8))
% set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x2[k] for SNR= ', num2str(SNR(8)),'db']);
% 
% figure
% scatter(reps,rmse3(:,1))
% set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x3[k] for SNR= ', num2str(SNR(1)),'db']);
% figure
% scatter(reps,rmse3(:,4))
% set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x3[k] for SNR= ', num2str(SNR(4)),'db']);
% figure
% scatter(reps,rmse3(:,8))
% set(gca,'YLim',[0 50]);xlabel('Repetition');ylabel('RMSE');title(['RMSE of x3[k] for SNR= ', num2str(SNR(8)),'db']);
