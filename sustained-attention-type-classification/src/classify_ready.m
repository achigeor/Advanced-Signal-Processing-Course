function [ attributes ] = classify_ready( feature_matrix,l1, l2, sex )
%classify_ready Returns a table ready to use for classification
%Input: feature_matrix: The feature matrix 
%       l1: Number of channels for p300-n400 erp (256 if no channel selection)
%       l2: Number of channels for n170 erp (256 if no channel selection)
%       sex: String to define sex oriented classification
%Output: attributes : Table, ready to be used for classification


%% Create Table
%Comment this if you have R2013b or older
attributes = table (feature_matrix(:,1),feature_matrix(:,2),feature_matrix(:,3),feature_matrix(:,4),feature_matrix(:,5),feature_matrix(:,6),'VariableNames',{'Feature1','Feature2','Feature3','Feature4','Feature5','Feature6'});

%% Create Binary Class Vector
for k = 1:(2*(l1+l2))
    if k<=(l1+l2)
        category(k) = 1;
    end
    if k>(l1+l2)
        category(k) = 2;
    end
end

%% Select Mode
switch sex
    case {'all'}
        Number_of_subjects = 16;
    case{'boys'}
        Number_of_subjects = 7;
    case{'girls'}
        Number_of_subjects = 9;
    case{'fast'}
        Number_of_subjects = 11;
    case{'slow'}
        Number_of_subjects = 5;
    otherwise
        disp('Something is wrong!');
end

%% Insert Nominal Class in attributes table

category = repmat(category',Number_of_subjects,1);
length(category)
%Use this if you have R2013b or older
%attributes = [feature_matrix category];

%Comment these if you have R2013b or older
valueset = [1:2];
catnames = {'bot','top'};
attention = categorical(category,valueset,catnames); 

attributes.class = attention;

end

