%% Initilization
botNv = [58 59 59 59 59 59 59 59 59 59 56 56 59 59 59 59];
topNv = [60 63 63 63 63 63 63 63 63 62 57 57 63 63 63 63];
Number_Of_Subjects = 16;
Skipped_Subjects = 0;
boys = [4:7 11 14 15];

%Channels / brain areas
occipital = [120:126 138 149 158 167 175 187 133:137 148 157 166 174];
temporal = [91 102 111 82 92 103 112 217 209 200 188 216 208 199];
parietal = [113:119 127 139 150 159 168 176 104:110 101 128 140 151 160 169 177 189];
central_parietal = [74:81 83:90 93:100 131 143 154 163 172 180 192 130 142 153 162 171 179 191 129 141 152 161 170 178 190 201];
p300_n400_channels = [parietal central_parietal];
n170_channels = [occipital temporal];

feature_matrix = zeros(2*(length(p300_n400_channels)+length(n170_channels))*length(boys),6);     

win_p300 = 62:125;
win_n170 = 25:50;


%% Feature Extraction
for j=1:Number_Of_Subjects
    
    if ~ismember(j,boys)  
        Skipped_Subjects = Skipped_Subjects+1;       
        continue; %Skip subject if its a girl
    end
    
    tic
    clearvars -except j feature_matrix botNv topNv p300_n400_channels n170_channels win_p300 win_n170 Number_Of_Subjects Skipped_Subjects boys
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

    %Extract ERPs from Bot Segments, applying the correct window depending on channel
    erp_bot_p300 = zeros(length(p300_n400_channels),length(win_p300));
    erp_bot_n170 = zeros(length(n170_channels),length(win_n170));
    n_p300 = 0;
    n_n170 = 0;
    
    for k=1:256
        
        if ismember(k,p300_n400_channels) 
            n_p300 = n_p300+1;
            for i=1:botN
            
                erp_bot_p300(n_p300,:) = erp_bot_p300(n_p300,:) + bot{i}(k,win_p300);
            
            end
             erp_bot_p300(n_p300,:) = erp_bot_p300(n_p300,:) / botN;
        
        elseif ismember(k,n170_channels)
            n_n170 = n_n170+1;
            for i=1:botN
                
                erp_bot_n170(n_n170,:) = erp_bot_n170(n_n170,:) + bot{i}(k,win_n170);
           
            end
            
            erp_bot_n170(n_n170,:) = erp_bot_n170(n_n170,:) / botN;
       
        end
        
    end
    
    %Extract ERPs from Top Segments, applying the correct window depending on channel
    erp_top_p300 = zeros(length(p300_n400_channels),length(win_p300));
    erp_top_n170 = zeros(length(n170_channels),length(win_n170));
    n_p300 = 0;
    n_n170 = 0;
    
    for k=1:256
        
        if ismember(k,p300_n400_channels)
            n_p300 = n_p300+1;
            for i=1:topN
            
                erp_top_p300(n_p300,:) = erp_top_p300(n_p300,:) + top{i}(k,win_p300);
            
            end
             erp_top_p300(n_p300,:) = erp_top_p300(n_p300,:) / topN;
        
        elseif ismember(k,n170_channels)
            n_n170 = n_n170+1;
            for i=1:topN
                
                erp_top_n170(n_n170,:) = erp_top_n170(n_n170,:) + top{i}(k,win_n170);
           
            end
            
            erp_top_n170(n_n170,:) = erp_top_n170(n_n170,:) / topN;
       
        end
        
    end
    
    %Get the feature matrix - 6 features for each channel
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
        feature_matrix(jj+(2*(l1+l2)*(j-1-Skipped_Subjects)),:) = curr_fv_bot;      
        feature_matrix((jj+(l1+l2))+(2*(l1+l2)*(j-1-Skipped_Subjects)),:) = curr_fv_top;
    end
toc
end

clearvars -except feature_matrix l1 l2

attributes = classify_ready(feature_matrix,l1,l2,'boys');

