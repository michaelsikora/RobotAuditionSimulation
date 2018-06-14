# RobotAuditionSimulation
MATLAB Code for simulating Robot Audition source localization scenario

Michael Sikora <m.sikora@uky.edu>
2018.06.13


How To:

1. Set Variables at top of robotAudition.m script
2. Run robotAudition.m. Program outputs error analysis table for each
    iteration of main loop. No plotting is done here. Images are saved with
    'localvars','vars','im', and 'mjs_platform' in testdata.mat
3. Run plotIM.m to view the series of plots. I resize figure and rerun to 
    get a better view.
4. Run plotIM2.m script to view the averaged image, minimum image, and 
    maximum image.