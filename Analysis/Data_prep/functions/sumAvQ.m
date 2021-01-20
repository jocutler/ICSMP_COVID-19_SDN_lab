function [data] = sumAvQ(data,measure,info)

% Average or sum values from each item on a questionnaire
% Jo Cutler, May 2020

% Input:    - data: cell array containing the data in numerical format and at
%           least one row of headings with the names of measures, recoded
%           items in a column with R at the end of the heading
%           - measure: structure containing information about the measure with fields:
%                   - name: name of the measure
%                   - num: numbers of items (e.g 2nd item on OAS measure is
%                   OAS_2 -> name_num)
%                   - how: char either 'av' to average or 'sum' to sum
%                   - recode: optional, if any items are recoded,
%                   information on which items
%           - info: structure containing information about the overall data with fields:
%                   - titlerow: which row contains the titles of measures
%                   (name_num as above)
%                   - txtrows: total number of rows containing headings, not
%                   data
%                   - row1: which row is the first containing data
%                   - output name: name of output file (optional, not used here)
% Output:   - data: as input with additional column at the end for each
%           totalled measure


try
    varR = measure.recode.items; % items to recode
catch
end

if length(measure.num) == 1
    va = measure.num(1);
    if exist('varR','var') == 1 && ismember(va,varR) == 1
        var{1} = [measure.name,'R'];
    else
        var{1} = [measure.name];
    end
else

for v = 1:length(measure.num)
    va = measure.num(v);
    if exist('varR','var') == 1 && ismember(va,varR) == 1
        var{v} = [measure.name,num2str(va),'R'];
    else
        var{v} = [measure.name,num2str(va)];
    end
end

end

nextcol = size(data,2) + 1;

try
    how = measure.how;
catch
    disp(['Not specified how to total ',measure.name,'. Assuming average, if require sum then specificy in m.',measure.name])
    how = 'av';
end

try name = measure.newname;
catch
    name = measure.name;
end

switch how
    
    case 'av'
        
        data{info.titlerow, nextcol} = [name,'_average'];
        for c = 1:length(var)
            cname = var{c};
            varcol = find(strcmp(data(info.titlerow,:), cname)==1);
            tototal(c) = varcol;
        end
        data(info.row1:end,nextcol) = num2cell(nanmean(cell2mat(data(info.row1:end,tototal)),2));
        
    case 'sum'
        
        data{info.titlerow, nextcol} = [name,'_sum'];
        for c = 1:length(var)
            cname = var{c};
            varcol = find(strcmp(data(info.titlerow,:), cname)==1);
            tototal(c) = varcol;
        end
        data(info.row1:end,nextcol) = num2cell(nansum(cell2mat(data(info.row1:end,tototal)),2));
        
    case 'single'
        
        data{info.titlerow, nextcol} = name;
        for c = 1:length(var)
            cname = var{c};
            varcol = find(strcmp(data(info.titlerow,:), cname)==1);
            tototal(c) = varcol;
        end
        data(info.row1:end,nextcol) = num2cell(cell2mat(data(info.row1:end,tototal)),2);
        
end

end

