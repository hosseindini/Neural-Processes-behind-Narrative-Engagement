# Neural-Processes-behind-Narrative-Engagement
Exploring the Neural Processes behind Narrative Engagement: An EEG Study. Here are the codes and data regarding this study.
cite the paper by seaching its title.
The overview of the uploaded files are as below:

-data: includes the raw EEG data for all participants, as well as wveradeg engagament ratings, and surrogated engagement ratings.

-Preprocess: includes the code for preprocessing the file. Please read the README file inside this folder to have all the requirements.

-DYNISC: includes five m files for 5 steps of calculating DYNISC, please read the README file inside this folder before you start.

- DYNFC: includes a m file to calculated the dFC. The code is inspired from : https://github.com/hyssong/NarrativeEngagement

-GRAPH: includes a code to calculate the graph features. See the requirements in the README file.

SVR: includes the suppert vector regression used in study inspired from : 
https://github.com/hyssong/NarrativeEngagement

In order to break down the data to differen phases, use below seconds as starting of each phase:
Exposition: 0s.
Risin: 151s.
Crisis: 300s.
Climax: 345s.
Falling: 460s.
Denouement: 482s.
