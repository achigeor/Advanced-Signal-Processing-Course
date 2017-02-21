function [fv] = feature_vector(erp)
%Input: erp is the ERP of an EEG channel
%Output: fv is an 1x6 array with the feature vector of the ERP

%% Get IMFs from EMD
    a_imf = emd(erp);
    imfN = length(a_imf);
    
%% Initialization
    
    a_hilbert = cell(1,imfN);
    a_inst_amp = cell(1,imfN);
    a_inst_th = cell(1,imfN);
    a_inst_freq = cell(1,imfN);
    max_ampl_vector = zeros(1,imfN);
    max_ampl_time_vector = zeros(1,imfN);
    time = 1:length(erp);

    
%% Get analytic signal for each IMF
    
    for i = 1:length(a_imf)
        a_hilbert{i} = hilbert(a_imf{i});
    end
    
%% Get instantaneous amplitude and frequency for each analytic signal
    
    for i=1:length(a_hilbert)
        
        a_inst_amp{i} = abs(a_hilbert{i});      %instantaneous amplitude
        a_inst_th{i} = angle(a_hilbert{i});     %instantaneous phase
        a_inst_freq{i} = diff(a_inst_th{i})/(1/256)/(2*pi); %instantaneous frequency **DIFF() SHORTENS VECTORS BY ONE SAMPLE**
        a_inst_freq{i} = remove_outliers(a_inst_freq{i},time(1:end-1)); %filter frequency to remove outliers
        a_inst_freq{i}(end+1) = a_inst_freq{i}(end); % This is done due to diff()


        [the_max, the_max_ind] = max(a_inst_amp{i});
        max_ampl_vector(i) = the_max;           %maximum amplitude
        max_ampl_time_vector(i) = the_max_ind;  %corresponding time of max amplitude
        
    end
    
%% We need the 2 HHTs with the highest instantaneous amplitude
    
    [u,v] = sort(max_ampl_vector,'descend');
    
    
%% Get feature vector
    
    fv = zeros(1,6);
    
    %if length(u)>1 %If an ERP yields only one IMF, keep the feature vector = 0 
    
    fv(1) = u(1);                                               %The first maximum
    fv(2) = a_inst_freq{v(1)}(max_ampl_time_vector(v(1)));      %The corresponding frequency to the first maximum
    fv(3) = range_feature(a_inst_amp{v(1)},a_inst_freq{v(1)});  %The frequency range for the first maximun
    if length(u)>1 %If an ERP yields only one IMF, keep the feature vector = 0 
    fv(4) = u(2);                                               %The second maximum
    fv(5) = a_inst_freq{v(2)}(max_ampl_time_vector(v(2)));      %The corresponding frequency to the second maximum
    fv(6) = range_feature(a_inst_amp{v(2)},a_inst_freq{v(2)});  %The frequency range for the second maximun
    
    end
