%%% Script to recode and then sum or average questionnaire items

% Jo Cutler, May 2020

% This script recodes items (reverse scored or with a scale different to required) 
% then calculates subscale and overall total scores (average or sum) for the questionnaires entered.

% Edit the elements in this section marked with **

% For each questionnaire enter the following information: 
%       name: name of the measure as in info.titlerow in data
%       newname: (optional) - name to use for column of total
%       num: number of items
%       how: how to total - 'av' = mean, 'sum' = sum, 'single' = only one item
%       recode: (optional) - items to recode: struct with information about
%           them, see function recodeQ
%       sub: (optional) - subscales: struct with information about each
%           containing: 
%               - newname: name of subscale 
%               - num: numerical index of items in subscale relative to num above

clear all

addpath('functions')

filename = 'Person_level_score_revised_Jan 2021';

% ** enter path and file name here:
data = table2cell(readtable(['../../Raw_data/',filename,'.xlsx'], 'ReadVariableNames', false)); % read table keeps date as date format

% ** enter the path and file name to be used in the output here:
info.outputname = ['../../Raw_data/',filename,'_totals.csv'];

% ** enter number of rows of text above numbers here (Qualtrics output can have 2 or 3 rows):
info.txtrow = 1;

% ** enter row number containing the question titles here:
info.titlerow = 1;

% ** if == 1 will print information about which items are being recoded to the command window, any other value will prevent this
docheck = 0; % note questions in output have been shortened and may be missing characters because of this, they are not missing in the actual datafile

info.row1 = info.txtrow + 1; % first row of data (below text)

data = cleanQcore(data,info); % data-specific cleaning to do first

%% Scales **

m.physical_contact.name = 'contact'; % name of the measure as in info.titlerow in data
% m.physical_contact.newname = 'social_distancing'; % new name (optional) to rename the total column
m.physical_contact.num = 1:5; % number of items
m.physical_contact.how = 'av'; % how to total - 'av' for average, 'sum' for sum (note any nan in sum will act as 0)
m.physical_contact.recode.items = [2];  % items to recode - numerical index as in 'num'
m.physical_contact.recode.scores = [0:10]; % how the scores are currently in the data
m.physical_contact.recode.scoresR = [10:-1:0]; % how recoded scores should end up
m.physical_contact.recode.toadd = 10; % number to add after multiplying scores by -1 to equal scoresR

m.physical_hygiene.name = 'hygiene';
m.physical_hygiene.num = 1:5;
m.physical_hygiene.how = 'av';

m.policy_support.name = 'psupport';
m.policy_support.num = 1:5;
m.policy_support.how = 'av';

m.generosity.name = 'generosity';
m.generosity.num = 2:3; % to just total %s for charity (1 = keep)
m.generosity.how = 'sum';

m.wellbeing.name = 'wellbeing';
m.wellbeing.num = 1:2;
m.wellbeing.how = 'av';

m.collective_narcis.name = 'cnarc';
m.collective_narcis.num = 1:3;
m.collective_narcis.how = 'av';

m.national_identity.name = 'nidentity';
m.national_identity.num = 1:2;
m.national_identity.how = 'av';

m.conspiracy_theories.name = 'ctheory';
m.conspiracy_theories.num = 1:4;
m.conspiracy_theories.how = 'av';

m.open_mindness.name = 'omind';
m.open_mindness.num = 1:6;
m.open_mindness.how = 'av';
m.open_mindness.recode.items = [1 5 6]; 
m.open_mindness.recode.scores = [0:10];
m.open_mindness.recode.scoresR = [10:-1:0];
m.open_mindness.recode.toadd = 10;

m.morality_as_cooperat.name = 'mcoop';
m.morality_as_cooperat.num = 1:7;
m.morality_as_cooperat.how = 'av';

m.trait_optimism.name = 'optim';
m.trait_optimism.num = 1:2;
m.trait_optimism.how = 'av';

m.social_belonging.name = 'sbelong';
m.social_belonging.num = 1:4;
m.social_belonging.how = 'av';

m.trait_selfcontrol.name = 'slfcont';
m.trait_selfcontrol.num = 1:4;
m.trait_selfcontrol.how = 'av';
m.trait_selfcontrol.recode.items = [3 4]; 
m.trait_selfcontrol.recode.scores = [0:10];
m.trait_selfcontrol.recode.scoresR = [10:-1:0];
m.trait_selfcontrol.recode.toadd = 10;

m.narcissism.name = 'narc';
m.narcissism.num = 1:6;
m.narcissism.how = 'av';

m.moral_identity.name = 'morlid';
m.moral_identity.num = 1:10;
m.moral_identity.how = 'av';
m.moral_identity.recode.items = [4 7]; 
m.moral_identity.recode.scores = [0:10];
m.moral_identity.recode.scoresR = [10:-1:0];
m.moral_identity.recode.toadd = 10;

m.risk_perception.name = 'risk';
m.risk_perception.num = 1:2;
m.risk_perception.how = 'av';



%%

% convert numbers saved as characters to numbers and replace any missing
% data with NaN
for r = 2:size(data,1)
    for c = 1:size(data,2)
        if isempty(data{r,c})
            data{r,c} = NaN; % to leave cells empty comment this line
        else
            try
                if data{r,c} == -99
                    data{r,c} = NaN; % to leave cells empty comment this line
                end
            catch
            end
            if isnan(str2double(data{r,c}))
                if strcmp(data{r,c},'NA')
                    data{r,c} = NaN;
                end
            else
                data{r,c} = str2double(data{r,c});
            end
        end
    end
end

% % convert replace any missing data coded as -99 with NaN
% 
% for r = 2:size(data,1)
%     for c = 1:size(data,2)
%         try
%             if data{r,c} == -99
%                 data{r,c} = NaN; % to leave cells empty comment this line
%             end
%         catch
%         end
%     end
% end


%% Recoding

f = fieldnames(m);

for s = 1:length(f)
    
    measure = m.(f{s});
        
    name = measure.name;
    
    checkQ(data,measure,info,docheck);
    
    try
        re = measure.recode;
        try
            data = recodeQ(data,measure,info);
        catch
            error(['Issue with recoding ',name]);
        end
    catch    
    end
    
end


%% Averaging / summing

for s = 1:length(f)
    
    measure = m.(f{s});
    
    name = measure.name;
    
    data = sumAvQ(data,measure,info);
    
    try
        subscales = measure.sub;
        subs = fieldnames(subscales);
        for sub = 1:length(subs)
            subscale = subscales.(subs{sub});
            subscale.name = measure.name;
            subscale.how = measure.how;
            try
            subscale.recode = measure.recode;
            end
            data = sumAvQ(data,subscale,info);
        end
    end
    
end

        
%% Save datafile

dataT = cell2table(data(info.row1:end,:), 'VariableNames', data(info.titlerow,:));

% Write the table to a CSV file
writetable(dataT,info.outputname)