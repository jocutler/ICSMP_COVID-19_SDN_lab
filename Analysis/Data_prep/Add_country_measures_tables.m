%%% Script to combine information on different countries:
%%% Gross national income (GNI)
%%% World bank categorisation of GNI
%%% COVID case & deaths (including calculating slopes)
%%% written for the for the Many Labs COVID19 study

% Jo Cutler, June 2020

% This script loads participant data files and saves a new xlsx with
% all the aspects of data for their country and date of testing (covid
% measures) added

% Edit the elements marked with **

% clear all
clearvars -except altnames

filename = 'Person_level_score_revised_Jan 2021_totals'; % **
writeslopes = 0; % **

% Inputs:

fulldata = readtable(['../../Raw_data/',filename,'.csv'], 'ReadVariableNames', true); % read table keeps date as date format

cvdata = readtable('../../Raw_data/Country_measures/Covid_data.xlsx', 'ReadVariableNames', true); % read table keeps date as date format
gnidata = readtable('../../Raw_data/Country_measures/GNI_World_Bank/GNI.xlsx', 'ReadVariableNames', true); % read table keeps date as date format
lifedata = readtable('../../Raw_data/Country_measures/Life_expectancy.xlsx', 'ReadVariableNames', true); % read table keeps date as date format
checkcountries = readtable('../../Raw_data/Country_measures/List_countries.xlsx', 'ReadVariableNames', true); % read table keeps date as date format
pilotdata = readtable('../../Raw_data/covid_randomrowsa_country_data.xlsx', 'ReadVariableNames', true);
pilotdata((pilotdata.DataRow == 7738),:) = []; % duplicate row in pilot data

dateforms = readtable('../../Raw_data/Date_formats.csv', 'ReadVariableNames', true); % read table keeps date as date format

% Outputs:

cvslopes = '../../Raw_data/Country_measures/Covid_with_slopes.xlsx';
fullname = ['../../Raw_data/',filename,'_country_data.xlsx'];

%% slopes in covid data

newtitles = {'rolling_cases', 'rolling_deaths', 'new_cases_slope', 'new_deaths_slope', 'rolling_cases_slope', 'rolling_deaths_slope'};
cvtitles = [cvdata.Properties.VariableNames, newtitles];

for newcol = 1:length(newtitles)
    newtitle = newtitles{newcol};
   cvdata.(newtitle) = NaN(height(cvdata),1);
end

day = 7; % ** number to have rolling average & slope over
X = [ones(day,1), (1:day)'];

cvcountries = unique(cvdata.Country(:),'stable');

numcols = 5:8; % ** index of the numerical columns in cvdata to use for averages, slopes etc

for c = 1:length(cvcountries)
    
    clear cdata crows slope rows
    
    country = cvcountries{c};
    crows = find(strcmp(cvdata.Country(:), country) == 1);
    cdata = cvdata(crows,numcols(1):end);
    rows = height(cdata);
    for r = day:rows
        cdata.rolling_cases(r) = mean(cdata.new_cases(r-day+1:r));
        cdata.rolling_deaths(r) = mean(cdata.new_deaths(r-day+1:r));
        slope = X\cdata.new_cases(r-day+1:r);
        cdata.new_cases_slope(r) = slope(2);
        slope = X\cdata.new_deaths(r-day+1:r);
        cdata.new_deaths_slope(r) = slope(2);
        slope = X\cdata.rolling_cases(r-day+1:r);
        cdata.rolling_cases_slope(r) = slope(2);
        slope = X\cdata.rolling_deaths(r-day+1:r);
        cdata.rolling_deaths_slope(r) = slope(2);
    end
    
    cvdata(crows,numcols(1):end) = cdata;
    
end

if writeslopes == 1
    writetable(cvdata,cvslopes) % save an xlsx file of the data
else
end

cvdates = datetime(cvdata.date(:));

for k = 1:height(cvdata)
    cvdata.date(k) = datetime(cvdata.date(k));
end

%% add covid data for each participant that has a date of testing

pcols = width(fulldata);
nextcol = pcols + 1;
cvcols = width(cvdata);

for t = 1:3
fulldata.(cvtitles{t}) = repmat({''}, height(fulldata), 1);
end
fulldata.date = repmat(NaT, height(fulldata), 1);
for t = 5:cvcols
fulldata.(cvtitles{t}) = NaN(height(fulldata), 1);
end

fulldata.RecordDate(:) = strrep(fulldata.RecordDate(:), '.', ':');

if ~exist('altnames','var')
    altnames = {};
end
altdates = {};

for k = 1:height(fulldata)
    
    clear pdate
    
    pcountry = fulldata.ISO3{k};
    pcrows = cvdata(strcmpi(cvdata.CountryCode(:), pcountry),:);
    
    dateformat = dateforms.Format(strcmpi(dateforms.ISO3(:), pcountry));
    dateformatnum = dateforms.NumFormat(strcmpi(dateforms.ISO3(:), pcountry));
    
    if sum(strcmp(dateformat,'NaN')) > 0
        cvdate = NaT;
    elseif strcmp(fulldata.RecordDate{k},'NaN')
        cvdate = NaT;
    else
        try
            pdate = datetime(fulldata.RecordDate{k}, 'Format', 'dd-MMM-yyyy', 'InputFormat', dateformat{1});
        catch
            try
                pdate = datetime(fulldata.RecordDate{k}, 'Format', 'dd-MMM-yyyy', 'InputFormat', dateformat{2});
            catch
                try
                    pdate = datetime(fulldata.RecordDate{k}, 'Format', 'dd-MMM-yyyy', 'InputFormat', dateformat{3});
                catch
                    try
                        pdate = datetime(fulldata.RecordDate{k}, 'Format', 'dd-MMM-yyyy');
                    catch
                        try
                            fulldata.RecordDate(k) = strrep(fulldata.RecordDate(k), ':', '.');
                            for df = 1:length(dateformat)
                                if contains(dateformat{df}, ' ')
                                    dateformat{df} = extractBefore(dateformat{df},' ');
                                else
                                end
                            end
                            pdate = datetime(datestr(x2mdate(str2double(fulldata.RecordDate{k})), dateformatnum{1}),'Format', 'dd-MMM-yyyy', 'InputFormat', dateformat{1});
                        catch
                        end
                        if ~exist('pdate','var') || pdate > '30-May-2020' || pdate < '22-Apr-2020'
                            try
                                pdate = datetime(datestr(x2mdate(str2double(fulldata.RecordDate{k})), dateformatnum{2}),'Format', 'dd-MMM-yyyy', 'InputFormat', dateformat{1});
                                if isnat(pdate) || pdate > '30-May-2020' || pdate < '22-Apr-2020'
                                    error('trigger catch')
                                end
                            catch
                                try
                                    longdate = strrep(fulldata.RecordDate{k}, '.', '');
                                    pdate = datetime(datestr(x2mdate(str2double([longdate(1:5),'.',longdate(6:end)])), dateformatnum{1}),'Format', 'dd-MMM-yyyy', 'InputFormat', dateformat{1});
                                    if pdate > '30-May-2020' || pdate < '22-Apr-2020'
                                        error('trigger catch')
                                    end
                                    fulldata.RecordDate{k} = [longdate(1:5),'.',longdate(6:end)];
                                catch
                                    try
                                        longdate = strrep(fulldata.RecordDate{k}, '.', '');
                                        pdate = datetime(datestr(x2mdate(str2double([longdate(1:5),'.',longdate(6:end)])), dateformatnum{2}),'Format', 'dd-MMM-yyyy', 'InputFormat', dateformat{1});
                                        fulldata.RecordDate{k} = [longdate(1:5),'.',longdate(6:end)];
                                    catch
                                        error('date issue')
                                    end
                                end
                            end
                        end
                        if isnat(pdate) == 1
                            clear pdate
                        else
                        end
                    end
                end
            end
        end
        if ~exist('pdate','var')
            try
                pdate = altdates{strcmpi(altdates(:,1), fulldata.RecordDate{k}),2};
            catch
                pdate = input([pcountry, ' - can`t convert date ',fulldata.RecordDate{k}, ', date in DD/MM/YYYY format: '],'s');
                altdates = [altdates; {fulldata.RecordDate{k}, pdate}];
            end
            pdate = datetime(pdate, 'Format', 'dd-MMM-yyyy', 'InputFormat', 'dd/MM/yyy');
        end
        
        if pdate > '30-May-2020' || pdate < '22-Apr-2020'
            pdate = input([pcountry, ' - date out of range ',fulldata.RecordDate{k}, ', date in DD/MM/YYYY format: '],'s');
            pdate = datetime(pdate, 'Format', 'dd-MMM-yyyy', 'InputFormat', 'dd/MM/yyy');
        end
        
        cvdate = pdate - 1;
        
    end
    
    if isnat(cvdate)
        
        fulldata(k,nextcol:nextcol+2) = pcrows(1,1:3);
        
    else
        fulldata.RecordDate{k} = datestr(pdate, 'dd/mm/yyyy');
        pcdates = cvdates(strcmpi(cvdata.CountryCode(:), pcountry),:);
        while isempty(pcrows)
            try
                othername = altnames{strcmpi(altnames(:,1), pcountry),2};
                newothername = 0;
            catch
                othername = input(['Can`t find rows for ',pcountry, ', other name? '],'s');
                newothername = 1;
            end
            pcdates = cvdates(strcmpi(cvdata.CountryCode(:), othername),:);
            pcrows = cvdata(strcmpi(cvdata.CountryCode(:), othername),:);
        end
        if exist('othername','var') && newothername == 1
            altnames = [altnames; {pcountry, othername}];
        end
        clear othername
        pdaterow = find(pcdates == cvdate);
        if isempty(pdaterow)
            pdaterow = find(pcdates > pdate-2 & pcdates < pdate-1);
        end
        
        if length(find(pcdates > cvdate)) == length(pcdates)
            fulldata(k,nextcol:nextcol+3) = pcrows(1,1:4);
            fulldata(k,nextcol+4:nextcol+cvcols-1) = num2cell(zeros(1,10));
        else
            pcvrow = pcrows(pdaterow,:);
            fulldata(k,nextcol:nextcol+cvcols-1) = pcvrow(1,:);
        end
        
    end
    
end

%% add covid data worldwide for each participant that has a date of testing

worldrows = cvdata(strcmp(cvdata.Country, "World"),:);

pcols = width(fulldata);
nextcol = pcols + 1;
cvcols = width(cvdata);

for t = 5:cvcols
fulldata.(['world_',cvtitles{t}]) = NaN(height(fulldata), 1);
end

for k = 1:height(fulldata)
    
    clear pdate
    
    if ~isnat(fulldata.date(k))
        
        cvdate = datetime(fulldata.date(k), 'Format', 'dd-MMM-yyyy');
        
        pdaterow = find(worldrows.date == cvdate);
        if isempty(pdaterow)
            pdaterow = find(worldrows.date > cvdate-1 & worldrows.date < cvdate);
        end
        
        pcvrow = worldrows(pdaterow,5:end);
        fulldata(k,nextcol:nextcol+cvcols-5) = pcvrow(1,:);
        
    end
    
end

%% add start and end testing dates
% for countries with a test date per participant look at the first and last entry for each country
% (these can then be compared with the form that PIs completed)
% for countries without these dates input from the form that PIs completed)
% identify any countries without testing dates or form entries
% for countries with a start date, add covid rates on the start date

countrydates = array2table(unique(fulldata.ISO2(:),'stable'));
countrydates.Properties.VariableNames = {'ISO2'};
countrydates.ISO3 = unique(fulldata.ISO3(:),'stable');

for c = 1:height(countrydates)
    
    countryiso = countrydates{c,1};
    countryrows = fulldata(strcmp(fulldata.ISO2(:), countryiso),:);
    countrydatenums = datenum(countryrows.date(:));
    startdate = countryrows.date(countrydatenums == min(countrydatenums));
    enddate = countryrows.date(countrydatenums == max(countrydatenums));
    
    try
        countrydates.Start{c} = datestr(startdate(1,1), 'dd/mm/yyyy');
    catch
        countrydates.Start{c} = '';
    end
    try
        countrydates.End{c} = datestr(enddate(1,1), 'dd/mm/yyyy');
    catch
        countrydates.End{c} = '';
    end

end

missingdate = countrydates.ISO2(strcmp(countrydates.Start,''));
for m = 1:length(missingdate)
    countryiso = missingdate{m};
    countryrows = dateforms(strcmp(dateforms.ISO2(:), countryiso),:);
    if ~isnat(countryrows.StartDate(1))
        countrydates.Start{strcmp(countrydates.ISO2(:), countryiso)} = datestr(countryrows.StartDate(1), 'dd/mm/yyyy');
    end
    if ~isnat(countryrows.EndDate(1))
        countrydates.End{strcmp(countrydates.ISO2(:), countryiso)} = datestr(countryrows.EndDate(1), 'dd/mm/yyyy');
    end
    
end

nextcol = width(countrydates) + 1;

countrydates.CVDate = repmat(NaT, height(countrydates), 1);
for t = 5:cvcols
countrydates.(['start_',cvtitles{t}]) = NaN(height(countrydates), 1);
end

for c = 1:height(countrydates)
    
    pcountry = countrydates.ISO3{c};

    if ~isempty(countrydates.Start{c})
    cvdate = datetime(countrydates.Start{c}, 'Format', 'dd/MM/yyyy', 'InputFormat', 'dd/MM/yyyy') - 1;
    pcrows = cvdata(strcmpi(cvdata.CountryCode(:), pcountry),:);
    pcdates = cvdates(strcmpi(cvdata.CountryCode(:), pcountry),:);
        while isempty(pcrows)
            try
                othername = altnames{strcmpi(altnames(:,1), pcountry),2};
                newothername = 0;
            catch
                othername = input(['Can`t find rows for ',pcountry, ', other name? '],'s');
                newothername = 1;
            end
            pcdates = cvdates(strcmpi(cvdata.CountryCode(:), othername),:);
            pcrows = cvdata(strcmpi(cvdata.CountryCode(:), othername),:);
        end
        if exist('othername','var') && newothername == 1
            altnames = [altnames; {pcountry, othername}];
        end
        clear othername
        pdaterow = find(pcdates == cvdate);
        if isempty(pdaterow)
            pdaterow = find(pcdates > cvcdate-1 & pcdates < cvdate);
        end
        
        if length(find(pcdates > cvdate)) == length(pcdates)
            countrydates(c,nextcol:nextcol+9) = num2cell(zeros(1,10));
        else
            pcvrow = pcrows(pdaterow,:);
            countrydates(c,nextcol:nextcol+10) = pcvrow(1,4:end);
        end
        
    end

end

nextcol = width(fulldata) + 1;

fulldata.StartDate = repmat(NaT, height(fulldata), 1);
for t = 5:cvcols
fulldata.(['SD',cvtitles{t}]) = NaN(height(fulldata), 1);
end

for k = 1:height(fulldata)
    
    pcountry = fulldata.ISO3{k};
    pcrow = countrydates(strcmpi(countrydates.ISO3, pcountry),:);
    fulldata(k,nextcol:end) = pcrow(1,5:end);
    
end

%% add index of days from start to end of data collection

dates = unique(fulldata.date(~isnat(fulldata.date)));
dates = sort([dates; datetime('20/05/2020', 'Format', 'dd-MMM-yyyy')]);

fulldata.date_count = NaN(height(fulldata), 1);

for d=1:length(dates)
    
    dateind = find(fulldata.date == dates(d));
    fulldata.date_count(dateind) = d;
    
end

%% add country data and adjust participant age for life expectancy

newtitles = [gnidata.Properties.VariableNames, lifedata.Properties.VariableNames];

for newcol = 1:length(newtitles)
    newtitle = newtitles{newcol};
    fulldata.(newtitle) = NaN(height(fulldata),1);
end

fulldata.Region = repmat({''}, height(fulldata), 1);
fulldata.IncomeGroup = repmat({''}, height(fulldata), 1);

countries = unique(fulldata.ISO3(:),'stable');

for c = 1:length(countries)
    
    countryiso = countries{c};
    country = dateforms.Country{strcmp(dateforms.ISO3(:), countryiso)};
    pcrows = find(strcmp(fulldata.ISO3(:), countryiso));
    gcrow = find(strcmpi(gnidata.CountryCode(:), countryiso));
    
    while isempty(gcrow)
        try
            othername = altnames{strcmpi(altnames(:,1), countryiso),2};
            newothername = 0;
        catch
            othername = input(['Can`t find rows for ',country, ' in GNI data, other code? '],'s');
            % try possible other ISO codes e.g. if a mistake in original code. Taiwan code is ROC
            newothername = 1;
        end
        gcrow = find(strcmpi(gnidata.CountryCode(:), othername) == 1);
        if newothername == 1
            altnames = [altnames; {country, othername}];
        end
    end
    if exist('othername','var')
        clear *othername
    end
    
    lcrow = find(strcmpi(lifedata.Country(:), country));
    
    while isempty(lcrow)
        try
            othername = altnames{strcmpi(altnames(:,1), country),2};
            newothername = 0;
        catch
            othername = input(['Can`t find rows for ',country, ' in life expectancy data, other name? '],'s'); 
            % try different versions e.g. United Kingdom, United States or
            % spelling e.g. Uruguay
            newothername = 1;
        end
        lcrow = find(strcmpi(lifedata.Country(:), othername) == 1);
        if newothername == 1
            altnames = [altnames; {country, othername}];
        end
    end
    if exist('othername','var')
        clear *othername
    end
    
    for p = 1:length(pcrows)
        for newcol = 3:width(gnidata)
            fulldata.(gnidata.Properties.VariableNames{newcol})(pcrows(p)) = gnidata.(gnidata.Properties.VariableNames{newcol})(gcrow);
        end
        for newcol = [1,3:width(lifedata)]
            fulldata.(lifedata.Properties.VariableNames{newcol})(pcrows(p)) = lifedata.(lifedata.Properties.VariableNames{newcol})(lcrow);
        end
    end
    
end

%% adjust age based on country life expectancy

expcol = [find(strcmp(fulldata.Properties.VariableNames, 'Life_exp_males')), find(strcmp(fulldata.Properties.VariableNames, 'Life_exp_females')), find(strcmp(fulldata.Properties.VariableNames, 'Life_exp_all'))];

newlifetitles = {'Life_exp_p', 'Adjusted_age'};

for newcol = 1:length(newlifetitles)
    newtitle = newlifetitles{newcol};
    fulldata.(newtitle) = NaN(height(fulldata),1);
end

for p = 1:height(fulldata)
    
    sex = fulldata.sex(p);
    if isempty(sex)
        sex = 3;
    end
    if sex ~= 1 || sex ~= 2 || sex ~= 3
        sex = 3;
    end
    fulldata.Life_exp_p(p) = fulldata{p,expcol(sex)};
    fulldata.Adjusted_age(p) = fulldata.age(p) / fulldata.Life_exp_p(p);
    
end

for r = 1:height(fulldata)
    for c = 1:width(fulldata)
        try
            if ~isnan(str2double(fulldata{r,c}))
                try
                    fulldata{r,c} = str2double(fulldata{r,c});
                catch
                end
            end
        catch
        end
    end
end


%% add index of whether each participant was in the 10% pilot dataset

cols(1,1) = find(strcmp(fulldata.Properties.VariableNames, 'age'));
cols(2,1) = find(strcmp(fulldata.Properties.VariableNames, 'Duration_sec'));
cols(3,1) = find(strcmp(fulldata.Properties.VariableNames, 'risk1'));
cols(4,1) = find(strcmp(fulldata.Properties.VariableNames, 'risk2'));
cols(5,1) = find(strcmp(fulldata.Properties.VariableNames, 'contact1'));
cols(6,1) = find(strcmp(fulldata.Properties.VariableNames, 'hygiene1'));
cols(7,1) = find(strcmp(fulldata.Properties.VariableNames, 'PoliticId'));
cols(8,1) = find(strcmp(fulldata.Properties.VariableNames, 'moral_circle'));
cols(9,1) = find(strcmp(fulldata.Properties.VariableNames, 'health_cond'));
cols(10,1) = find(strcmp(fulldata.Properties.VariableNames, 'morlid1'));
cols(11,1) = find(strcmp(fulldata.Properties.VariableNames, 'ISO3'));

cols(1,2) = find(strcmp(pilotdata.Properties.VariableNames, 'age'));
cols(2,2) = find(strcmp(pilotdata.Properties.VariableNames, 'Duration_sec'));
cols(3,2) = find(strcmp(pilotdata.Properties.VariableNames, 'risk_perception__1'));
cols(4,2) = find(strcmp(pilotdata.Properties.VariableNames, 'risk_perception__2'));
cols(5,2) = find(strcmp(pilotdata.Properties.VariableNames, 'physical_contact__1'));
cols(6,2) = find(strcmp(pilotdata.Properties.VariableNames, 'physical_hygiene__1'));
cols(7,2) = find(strcmp(pilotdata.Properties.VariableNames, 'political_ideology'));
cols(8,2) = find(strcmp(pilotdata.Properties.VariableNames, 'moral_circle'));
cols(9,2) = find(strcmp(pilotdata.Properties.VariableNames, 'health_cond'));
cols(10,2) = find(strcmp(pilotdata.Properties.VariableNames, 'Moral_ID__1'));
cols(11,2) = find(strcmp(pilotdata.Properties.VariableNames, 'Country_code_1'));

cols(1:11,3) = [1;1;1;1;1;1;1;1;1;1;0]; 

fulldata.In_pilot = zeros(height(fulldata),1);
fulldata.Index = [1:height(fulldata)]';
pilotdata.Index = [1:height(pilotdata)]';
pilotdata.Not_in_data = zeros(height(pilotdata),1);

multiples = 0;
g1d = 0;
g2d = 0;

for p = 1:height(pilotdata)
    
    colnum = 1;
    possiblerows = fulldata;
    
    try
   
    while height(possiblerows) ~= 1
        
        if cols(colnum,3) == 1
            
            if ~isnan(pilotdata.(cols(colnum,2))(p))
                ind = find(round(possiblerows.(cols(colnum,1))(:)) == round(pilotdata.(cols(colnum,2))(p)));
                possiblerows = possiblerows(ind,:);
            end
            
        else
            
            ind = ismember(possiblerows.(cols(colnum,1))(:), pilotdata.(cols(colnum,2)){p});
            possiblerows = possiblerows(ind,:);
            
        end
        
        colnum = colnum+1;
        
    end
    
    if round(possiblerows.generosity1(1)) ~= round(pilotdata.generosity__1(p))
        g1d = g1d + 1;
        gen1diffs{g1d,1} = possiblerows;
        gen1diffs{g1d,2} = pilotdata(p,:);
    end
        if round(possiblerows.generosity2(1)) ~= round(pilotdata.generosity__2(p))
        g2d = g2d + 1;
        gen2diffs{g2d,1} = possiblerows;
        gen2diffs{g2d,2} = pilotdata(p,:);
        end
    fulldata.In_pilot(possiblerows.Index(1)) = 1;
    
    catch
        
        if height(possiblerows) == 0
            
            pilotdata.Not_in_data(p) = 1;
            
        else
        
        for l = 1:height(possiblerows)
           fulldata.In_pilot(possiblerows.Index(l)) = 1; 
        end
        
        multiples = multiples + 1;
        multiplerows{multiples} = possiblerows;
        
        end
        
    end
    
end

writetable(fulldata,fullname) % save an xlsx file of the data