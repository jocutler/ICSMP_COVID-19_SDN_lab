function [data] = cleanQ(data,info)

% Enter any questionnaire-specific cleaning that needs to be done before
% questionnaires can be recoded and averaged using
% Recoding_questionnaires.m

% Below is for the COVID19 Many Labs data
% Jo Cutler, May 2020

data(info.titlerow,:) = strrep(data(info.titlerow,:),'happy','wellbeing1'); % 2 items in separate questions but need to match for script to work
data(info.titlerow,:) = strrep(data(info.titlerow,:),'slf_ladder','wellbeing2'); % 2 items in separate questions but need to match for script to work

data(info.titlerow,:) = strrep(data(info.titlerow,:),'sinfect','risk1'); % 2 items in separate questions but need to match for script to work
data(info.titlerow,:) = strrep(data(info.titlerow,:),'oinfect','risk2'); % 2 items in separate questions but need to match for script to work

data(info.titlerow,:) = strrep(data(info.titlerow,:),'__',''); % rename generosity items to remove underscores

gooddatecol = find(strcmp(data(info.titlerow,:),'date') == 1);
if ~isempty(gooddatecol)
datecol = find(strcmp(data(info.titlerow,:),'RecordDate') == 1);
for r = info.row1:length(data)
    try
        data{r,datecol} = datetime(data{r,gooddatecol}, 'Format', 'dd-MMM-yyyy', 'InputFormat', 'dd-MMM-yyyy') + 1;
    catch
        data{r,datecol} = NaN;
    end
end

end

end

