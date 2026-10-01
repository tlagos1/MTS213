%
% SCRIPT ID : 06122021
%
% PROJECT ID : ATE SI3 SDR
%
% PURPOSE : Reset all IQ data files (*.dat) to 0 bytes
%
% USAGE : (Command Window) :
%
% >> s_reset_id_data_files;
%

%**********************************************************************************************
%                                Institut Mines-Telecom / IMT Atlantique
%     	                         Mathematical & Electrical Engineering Dpt.
%                                         Technopole de Brest-Iroise
%                                     CS 83818 - 29238 BREST CEDEX 3
%----------------------------------------------------------------------------------------------
%                                     -  All Rights Reserved -
%
% AUTHOR(s) : Thierry LE GALL (Dept. MEE)
%
% DEVELOPMENT HISTORY :
%
% Date         Name(s)       Version  Comment
% -----------  ------------- -------  ---------------------------------------------------------
% Dec-06-2021  T. LE GALL    0.1      Creation of code
% 
% EXTERNAL FUNCTIONS USED :
%
% - f_write_iq_x32_bin_data()
% 
% REFERENCES/NOTES/COMMENTAIRES :
%
% - N/A
% 
%**********************************************************************************************

clear all %#ok<CLALL>
close all
clc

s_project_name = 'ATE SDR SI3'; % put the name of the project here
d_script_id = 06122021; % should be : day month year (at least)

%% ---------------(DO NOT MODIFY)-------------------
disp(['--> Run Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id)])
disp(' ')
tic    
%% -------------- INITIALISATIONS ------------------	
    
if (isunix) % working in UNIX env.
    S_DATA_PATH_NAME = '../dat/';        
else % working in Windows env.
    S_DATA_PATH_NAME = '..\dat\';
end
    
v_iq_bb_signal = []; % empty
    
    
S_DATA_FILE_NAME_1 = 'tx_x32_iq_data_to_usrp.dat';
S_DATA_FILE_NAME_2 = 'rx_x32_iq_data_from_usrp.dat';
S_DATA_FILE_NAME_3 = 'test_rw_x32_data.dat';

%% ----------------- PROCESSING --------------------

f_write_iq_x32_bin_data(v_iq_bb_signal, strcat(S_DATA_PATH_NAME, S_DATA_FILE_NAME_1)) % Write CDB Data in File -> reset
f_write_iq_x32_bin_data(v_iq_bb_signal, strcat(S_DATA_PATH_NAME, S_DATA_FILE_NAME_2)) % Write CDB Data in File -> reset
f_write_iq_x32_bin_data(v_iq_bb_signal, strcat(S_DATA_PATH_NAME, S_DATA_FILE_NAME_3)) % Write CDB Data in File -> reset

disp(['All Data Files Reseted Successfully in: ', S_DATA_PATH_NAME])
disp(' ')

%% ---------------(DO NOT MODIFY)---------------------------
toc
disp(' ')    
disp(['End of Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id), ' <--'])

%% ********************************** END OF SCRIPT **************************************
