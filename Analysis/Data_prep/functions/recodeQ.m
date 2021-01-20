function [data] = recodeQ(data,measure,info)

% Recode questionnaire values that are reverse scored
% (e.g 5 needs to be 1 and 1 needs to be 5)
% or come out of Qualtrics with different coding that required for the average
% (e.g. 1:5 needs to be 0:4)
% Jo Cutler, May 2020

% Input:    - data: cell array containing the data in numerical format and at
%           least one row of headings with the names of measures
%           - measure: structure containing information about the measure with fields:
%                   - name: char type of the name of the overall measure as in the
%                   headings in data
%                   - num: numbers of items (e.g 2nd item on OAS measure is
%                   OAS_2 -> name_num)
%                   - how: char either 'av' to average or 'sum' to sum
%                   - recode: structure containing the fields:
%                       - items: numbers of items to recode
%                       - scores: scores as they are to start with
%                       - scoresR: scores as they should be after recoding
%                       - to add: number to add to scores or to scores after
%                       multiplying by -1 to equal scoresR
% Output:   - data: as input with additional column at the end for each
%           recoded item

if (measure.recode.scores * -1 + measure.recode.toadd) == measure.recode.scoresR
    multiple = -1;
elseif (measure.recode.scores + measure.recode.toadd) == measure.recode.scoresR
    multiple = 1;
else
    error(['Mismatch in recoding ', measure.name])
end

for r = measure.recode.items
    nextcol = size(data,2) + 1;
    if length(measure.num) == 1
        data{info.titlerow, nextcol} = [measure.name,'R'];
        varcol = find(strcmp(data(info.titlerow,:), measure.name)==1);
    else
        data{info.titlerow, nextcol} = [measure.name,num2str(r),'R'];
        varcol = find(strcmp(data(info.titlerow,:), [measure.name,num2str(r)])==1);
    end
    data(info.row1:end,nextcol) = num2cell(cell2mat(data(info.row1:end,varcol)) * multiple + measure.recode.toadd);
end
end

