# [SDN Lab](https://www.sdn-lab.org/) analysis of [ICSMP COVID-19](https://icsmp-covid19.netlify.app/) data

This repository contains analysis resources for analysis of the [International Collaboration on the Social & Moral Psychology of COVID-19](https://icsmp-covid19.netlify.app/) developed by the [SDN Lab](https://www.sdn-lab.org/).

We used the following for transforming the data from the main shared file to the one used in our secondary analysis (see https://osf.io/9wvp4/) :

1. Analysis/Data_prep/Recoding_questionnaires.m - reverses any items that require reversing then sums or averages each scale
1. Analysis/Data_prep/functions - used in Recoding_questionnaires.m (see notes in each file)
1. Analysis/Data_prep/Add_country_measures_tables.m - adds country-level measures to each row - country wealth, life expectancy (including adjusted age), and COVID-19 severity measures on the day before the participant completed the survey and the start date (SD) in that country

1. Raw_data/Person_level_score_revised_Jan 2021.xlsx (main dataset from ICSMP saved csv as xlsx, note not yet available)
1. Raw_data/Date_formats.csv (index of different date formats used in each country to help create common format)
1. Raw_data/Country_measures/Covid_data.xlsx (data for COVID-19 severity measures from [Our World in Data](https://ourworldindata.org/coronavirus))
1. Raw_data/Country_measures/GNI_World_Bank/GNI.xlsx (country wealth data from the World Bank)
1. Raw_data/Country_measures/Life_expectancy.xlsx (life expectancy info from [Worldometers](Worldometers.info)
1. Raw_data/Country_measures/List_countries.xlsx (names and codes for each country)
1. Raw_data/covid_randomrowsa_country_data.xlsx (10% dataset from ICSMP for pilot analysis saved csv as xlsx, note not yet available)



