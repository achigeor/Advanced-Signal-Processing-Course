function [range] = range_feature(inst_ampl,inst_freq)
%Return the frequency range
%

%% Find t1 (left border) and t2 (right border)
[the_max,t0] = max(inst_ampl);

%In case the amplitude never drops lower than the 0.1*the_max we initialize
%t1 and t2 so that they include the entire time window
t1 = 1;
t2 = length(inst_ampl);

%% Find the window

%Go from t0 to the left with a step of -1
for i=t0:-1:1
    %If we find an amplitude value less than 10% of the max
    if inst_ampl(i)<=0.1*the_max
        t1 = i;     %then we renew the left border
        break;
    end
end

%Go from t0 to the right with a step of 1
for i=t0:1:length(inst_ampl)
    %If we find an amplitude value less than 10% of the max
    if inst_ampl(i)<=0.1*the_max
        t2 = i;     %then we renew the right border
        break;
    end
end

%% Limit freq window
inst_freq_window = inst_freq(t1:t2);

%% Get std of freq
range = std(inst_freq_window);