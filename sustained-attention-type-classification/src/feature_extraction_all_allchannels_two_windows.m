%% Initialization
botNv = [58 59 59 59 59 59 59 59 59 59 56 56 59 59 59 59]; %Number Of Bot Segments in each subject
topNv = [60 63 63 63 63 63 63 63 63 62 57 57 63 63 63 63]; %Number of Top Segments in each subject
Number_Of_Subjects = 16;

p300_n400_channels = 256;
n170_channels = 256;

feature_matrix = zeros(2*(p300_n400_channels+n170_channels)*Number_Of_Subjects,6);

win_p300 = 62:125;
win_n170 = 25:50;

%% Feature Extraction
for j=1:Number_Of_Subjects
    tic
    
    clearvars -except j feature_matrix botNv topNv p300_n400_channels n170_channels win_p300 win_n170 Number_Of_Subjects
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
    erp_bot_p300 = zeros(p300_n400_channels,length(win_p300));
    erp_bot_n170 = zeros(n170_channels,length(win_n170));
 
    for k=1:256   
            
            for i=1:botN
                erp_bot_p300(k,:) = erp_bot_p300(k,:) + bot{i}(k,win_p300);
            end
             erp_bot_p300(k,:) = erp_bot_p300(k,:) / botN;
            
            for i=1:botN
                erp_bot_n170(k,:) = erp_bot_n170(k,:) + bot{i}(k,win_n170);
            end
            erp_bot_n170(k,:) = erp_bot_n170(k,:) / botN;    
    end
    
    %Extract ERPs from Top Segments
    erp_top_p300 = zeros(p300_n400_channels,length(win_p300));
    erp_top_n170 = zeros(n170_channels,length(win_n170));
    
    for k=1:256
            
            for i=1:topN
                erp_top_p300(k,:) = erp_top_p300(k,:) + top{i}(k,win_p300);
            end
            erp_top_p300(k,:) = erp_top_p300(k,:) / topN;
           
            for i=1:topN
                erp_top_n170(k,:) = erp_top_n170(k,:) + top{i}(k,win_n170);
            end
            erp_top_n170(k,:) = erp_top_n170(k,:) / topN;
    end
    
    %Get the feature matrix - 6 features for channel
    %Each row is a channel
    %Each column is a feature
    
    %For each channel
    l1 = size(erp_bot_p300,1);
    l2 = size(erp_bot_n170,1);
    for jj=1:(l1+l2)
      %Get the correct current ERP, given the channel
      if jj<=l1
        
        k=jj;
        curr_erp_bot = erp_bot_p300(k,:);
        curr_erp_top = erp_top_p300(k,:);
     
      else                                
        
        k = jj-l1;
        curr_erp_bot = erp_bot_n170(k,:);
        curr_erp_top = erp_top_n170(k,:);
     
      end  
        %Extract features
        curr_fv_bot = feature_vector(curr_erp_bot);
        curr_fv_top = feature_vector(curr_erp_top);
        %Insert them in their correct place in the feature matrix
        feature_matrix(jj+(2*(l1+l2)*(j-1)),:) = curr_fv_bot;      
        feature_matrix((jj+(l1+l2))+(2*(l1+l2)*(j-1)),:) = curr_fv_top;
    end
toc
end

clearvars -except feature_matrix l1 l2

attributes = classify_ready(feature_matrix,l1,l2,'all');


