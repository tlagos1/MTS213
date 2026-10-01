%
% SCRIPT ID : s_import_iq_x32_bin_data.m
%
% PROJECT ID : TAF ISC - UUE4 - TP SDR
%
% PURPOSE : Test of R/W 32-bits Floating Point Data from/to Binary Files (*.dat) + Plot Graphs
%
% USAGE : (Command Window) :
%
% >> s_import_iq_x32_bin_data.m;
%

%**********************************************************************************************
%                                Institut Mines-Telecom / IMT Atlantique
%     	                        Mathematical & Electrical Engineering Dpt.
%                                       Technopôle de Brest-Iroise
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
% Jan-14-2020  T. LE GALL    0.1      Creation of code
% Feb-25-2021  T. LE GALL    0.2      Update: autodetect UNIX/WINDOWS
% 
% EXTERNAL FUNCTIONS USED :
%
% - f_read_iq_x32_bin_data()
% 
% REFERENCES/NOTES/COMMENTAIRES :
%
% - N/A
% 
%**********************************************************************************************

close all
clc

s_project_name = 'TP GNU RADIO'; % put the name of the project here
d_script_id = 's_import_iq_x32_bin_data.m'; % should be : day month year (at least)

    %% ---------------(DO NOT MODIFY)---------------------------
    disp(['--> Run Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id)])
    disp(' ')
    tic    
    %% --------- <IMPLEMENT INITIAL CONDITIONS HERE> -----------
    
    % ** constants **
    
    S_RX_DATA_FILE_NAME = 'test_rw_x32_data.dat';
    
    if isunix % UNIX
        S_DATA_PATH_NAME = '../dat/';         
    else % WINDOWS
        S_DATA_PATH_NAME = '..\dat\';   
    end
    
    C_RX_IQ_RATE = 1e6; % [Hz] RX sampling frequency
    C_RX_PERIOD = 1e5/C_RX_IQ_RATE; % [s] RX signal period
    
    
    C_RX_SAMPLES_NUM = 1e6; % [samples] RX number of samples
    
    % ** initialisations **
    
    if ~exist(S_DATA_PATH_NAME, 'dir')
       mkdir(S_DATA_PATH_NAME) % create subdir for data
    end  

    
    %% --------------------- Read DATA ----------------------
    
    v_rx_iq_data = f_read_iq_x32_bin_data(strcat(S_DATA_PATH_NAME, S_RX_DATA_FILE_NAME)); % Read 32-bits I/Q data
    
    v_time = (0:1:length(v_rx_iq_data)-1)./C_RX_IQ_RATE;
    
    %% ------------------ DATA RENDERING -----------------------
        
    figure
     
	subplot(2, 1, 1)
     plot(v_time, real(v_rx_iq_data), 'r')
     title('RX Signal - I')
     xlabel('Time [s]')
     ylabel('Amplitude')
     grid
     
	subplot(2, 1, 2)
     plot(v_time, imag(v_rx_iq_data)) 
     title('RX Signal - Q')
     xlabel('Time [s]')
     ylabel('Amplitude')
     grid
 
    %% ---------------(DO NOT MODIFY)---------------------------
    toc
    disp(' ')    
    disp(['End of Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id), ' <--'])
    
%% ********************************** END OF SCRIPT **************************************