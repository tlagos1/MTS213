%
% SCRIPT ID : s_tp_sdr_03022021.m
%
% PROJECT ID : TAF ISC - UUE4 - TP SDR
%
% PURPOSE : AM-DSB-TC Temporal View
%
% USAGE : (Command Window) :
%
% >> s_tp_sdr_03022021.m;
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
% Mar-03-2021  T. LE GALL    0.1      Creation of code
% 
% EXTERNAL FUNCTIONS USED :
% 
% REFERENCES/NOTES/COMMENTAIRES :
%
% - N/A
% 
%**********************************************************************************************

close all
clc

s_project_name = 'TP SDR'; % put the name of the project here
d_script_id = 's_tp_sdr_03022021.m'; % should be : day month year (at least)

    %% ---------------(DO NOT MODIFY)---------------------------
    disp(['--> Run Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id)])
    disp(' ')
    tic    
    %% ------------- BEGINNING OF SCRIPT -----------------------
    
    % ** constants **
    
    
    % ** initialisations **
    
    d_samp_num = 1e4;
    
    v_mu_a = [0.5, 0.99];  % mudulation index 0 < \mu_a < 1
    d_sig_amp = 1; % A
    d_msg_amp = 1; % M
    d_f0 = 100/d_samp_num; % f0 (carrier)
	d_fm = 5/d_samp_num; % fm (message)
    d_phi0 = 0;
    
    v_time = (0:1:d_samp_num-1).'; % time vector
    
    % ** processing **
    
    v_m = d_msg_amp * sin(2*pi*d_fm*v_time); % message
    
    v_env1 = d_sig_amp * (1 + (v_mu_a(1) / d_msg_amp)*v_m);
    v_env2 = d_sig_amp * (1 + (v_mu_a(2) / d_msg_amp)*v_m);    
    
    v_s1 = v_env1 .*cos(2*pi*d_f0*v_time + d_phi0); % TX signal
	v_s2 = v_env2 .*cos(2*pi*d_f0*v_time + d_phi0); % TX signal
    
    % ** diplays **
    
    C_OSD_FONT_SIZE_1 = 24; % for title on figure and labels on axes
    C_OSD_FONT_SIZE_2 = 20; % for legends inside axes
    C_OSD_FONT_SIZE_3 = 16; % for simulation ID tag on figure
    
    figure
        subplot(1, 2, 1)
            hold on
            plot(v_time, v_s1);
            plot(v_time, v_env1, 'r--')
            plot(v_time, -v_env1, 'r--')
            axis([min(v_time), max(v_time), 1.1*min(v_s1), 1.1*max(v_s1)])
            hold off
            h_x = xlabel('Sample Time');
            h_y = ylabel('Amplitude');
            h_t = title(['AM-DSB-TC with \mu = ', num2str(v_mu_a(1))]);
            h_l = legend('s(t)', 'm(t)');
            grid
            set(h_x, 'FontSize', C_OSD_FONT_SIZE_1);
            set(h_y, 'FontSize', C_OSD_FONT_SIZE_1);
            set(h_t, 'FontSize', C_OSD_FONT_SIZE_1);            
            set(h_l, 'FontSize', C_OSD_FONT_SIZE_2);
            set(gca, 'FontSize', C_OSD_FONT_SIZE_3);
        subplot(1, 2, 2)
            hold on
            plot(v_time, v_s2);
            plot(v_time, v_env2, 'r--')
            plot(v_time, -v_env2, 'r--')
            axis([min(v_time), max(v_time), 1.1*min(v_s2), 1.1*max(v_s2)])
            hold off
            h_x = xlabel('Sample Time');
            h_y = ylabel('Amplitude');
            h_t = title(['AM-DSB-TC with \mu = ', num2str(v_mu_a(2))]);
%             h_l = legend('s(t)', 'm(t)');
            grid
            set(h_x, 'FontSize', C_OSD_FONT_SIZE_1);
            set(h_y, 'FontSize', C_OSD_FONT_SIZE_1);
            set(h_t, 'FontSize', C_OSD_FONT_SIZE_1);            
%             set(h_l, 'FontSize', C_OSD_FONT_SIZE_2);
            set(gca, 'FontSize', C_OSD_FONT_SIZE_3);
    
 
    %% ---------------(DO NOT MODIFY)---------------------------
    toc
    disp(' ')    
    disp(['End of Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id), ' <--'])
    
%% ********************************** END OF SCRIPT **************************************