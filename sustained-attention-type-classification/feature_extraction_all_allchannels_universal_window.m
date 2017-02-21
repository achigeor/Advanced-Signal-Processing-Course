%% Initialization
botNv = [58 59 59 59 59 59 59 59 59 59 56 56 59 59 59 59]; %Number Of Bot Segments in each subject
topNv = [60 63 63 63 63 63 63 63 63 62 57 57 63 63 63 63]; %Number of Top Segments in each subject
Number_Of_Subjects = 16;
Channels = [1:256];
Number_Of_Channels = length(Channels);
Time_Window = 25:125;
L1 = length(Time_Window);
feature_matrix = zeros((2*Number_Of_Channels)*16,6);


%% Feature Extraction
for j=1:Number_Of_Subjects

    
    tic
    clearvars -except j feature_matrix botNv topNv Number_Of_Subjects Time_Window L1 Number_Of_Channels Channels erp_top erp_bot

    %Load subject
    %NOTE: all .mat files are named classX.mat
    %where X denotes the number of the subject
    load(['class' num2str(j) '.mat']);
    
    %Create ERPs
    
    %Put Bot Segments in a cell
    n = 'bot_Segment';
    botN = botNv(j);
    bot = cell(1,botN);
    for i = 1:botN
        name = ([n,num2str(i)]);
        bot{i} = eval(name);
    end
    
    %Put Top Segments in a cell 
    t = 'top_Segment';
    topN = topNv(j);
    top = cell(1,topN);
    for i=1:topN
        name = ([t,num2str(i)]);
        top{i} = eval(name);
    end

    %Extract ERPs from Bot Segments
    erp_bot = zeros(Number_Of_Channels,L1);
    for k=1:Number_Of_Channels
        for i=1:botN
            erp_bot(k,:) = erp_bot(k,:) + bot{i}(k,Time_Window);
        end
        erp_bot(k,:) = erp_bot(k,:) / i;
    end
    
    %Extract ERPs from Top Segments
    erp_top = zeros(Number_Of_Channels,L1);
    for k=1:Number_Of_Channels
        for i=1:topN
            erp_top(k,:) = erp_top(k,:) + top{i}(k,Time_Window);
        end
        erp_top(k,:) = erp_top(k,:) / i;
    end
    
    %Get the feature matrix - 6 features for each of the 256 channels
    %Each row is a channel
    %Each column is a feature
    
    %For each channel
    for jj=1:Number_Of_Channels
        
        %Get the ERP
        curr_erp_bot = erp_bot(jj,:);
        curr_erp_top = erp_top(jj,:);
        
        %Extract features
        curr_fv_bot = feature_vector(curr_erp_bot);
        curr_fv_top = feature_vector(curr_erp_top);
        
        %Insert them in their correct place in the feature matrix
        feature_matrix(jj+(2*Number_Of_Channels*(j-1)),:) = curr_fv_bot;      
        feature_matrix((jj+Number_Of_Channels)+(2*Number_Of_Channels*(j-1)),:) = curr_fv_top;
    
    end
toc
end
clearvars -except feature_matrix Number_Of_Channels

classify_ready(feature_matrix,Number_Of_Channels/2,Number_Of_Channels/2,'all');





