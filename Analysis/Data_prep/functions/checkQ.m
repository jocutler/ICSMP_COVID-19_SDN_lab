function [] = checkQ(data,measure,info,docheck)

% Print output to the command line about the items being recoded or not
% being recoded. Removes text at the start of each question that is the
% same on each measure although sometimes also removes some extra
% unintended characters from the question.
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
%                   - txtrow: total number of rows containing headings, not
%                   data
%                   - row1: which row is the first containing data
%                   - output name: name of output file (optional, not used here)
%           - docheck: if == 1 then will run the function and output text
%           to the command window, if ~= 1 nothing will happen

if docheck == 1 & length(measure.num) > 1
    
try
    varR = measure.recode.items; % items to recode
catch
    
end


for v = 1:length(measure.num)
    va = measure.num(v);
    varname = [measure.name,'_',num2str(va)];
    varcol(v) = find(strcmp(data(info.titlerow,:),varname));
    questions{v} = data{info.txtrow,varcol(v)};
end
    

for q = 1:length(questions)
    lengths(q) = length(questions{1,q});
end

short = find(lengths == min(lengths));
shortQs = questions;
lind = 1;

while lind < 2
    for l = 1:min(lengths)
        
        letter = questions{1,short(1)}(l);
        
        for q = 1:length(questions)
            letters(l,q) = strcmp(letter,questions{1,q}(l));
        end
        
        if sum(letters(l,:)) == length(questions)
            for q = 1:length(questions)
                if letters(l,q) == 1 && letters(max(l-1,1),q) == 1 && letters(max(l-2,1),q) == 1
                shortQs{1,q}(lind) = [];
                end
            end
        else
            lind = lind + 1;
        end
    end
end

nrind = 1;
rind = 1;

for v = 1:length(measure.num)
    va = measure.num(v);

    if exist('varR','var') == 1 && ismember(va,varR) == 1
        questionsR{rind} = shortQs{v};
        rind = rind + 1;
    else
         questionsNR{nrind} = shortQs{v};
         nrind = nrind + 1;
    end
end
    
if exist('varR','var') == 1
    disp([num2str(length(questionsR)),' items to recode on ',measure.name])
    disp('Recoded measure(s): ')
    disp(questionsR')
    if exist('questionsNR','var')
    disp('Measure(s) not recoded are: ')
    disp(questionsNR')
    
    end
else
    disp(['No items to recode on ',measure.name])
    disp('Measures are: ')
    disp(questionsNR')
    
end

else
    
end

end

