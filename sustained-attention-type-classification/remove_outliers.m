function [ filtered_signal ] = remove_outliers ( signal,time )
%my_filter Remove Outliers of input signal 

%signal: Input signal
%time: Time vector
%filtered_signal: Output signal


%% Remove Negative Outliers

for i =2:length(signal)-1
    if signal(i)<0
        
        signal(i) = (signal(i-1)+signal(i+1))/2;  %Replace negative values with mean of neighbours
    
    end
end

if signal(1)<0
    
    signal(1)=signal(2); %Do this if the first sample is negative

end

if signal(end)<0
    
    signal(end)=signal(end-1); %Do this if the last sample is negative

end


%% Remove Possitive Outliers

stats = regstats(signal,time,'linear');
outlier = stats.cookd > 4/length(time);   %Find outliers using cook's distance metric
outlier_index = find(outlier);            %Find the the indexes of outliers

for j = 1:length(outlier_index)
    
    signal(outlier_index(j)) = trimmean(signal,10); %Replace outliers with trimmean of signal

end

filtered_signal = signal;

end

