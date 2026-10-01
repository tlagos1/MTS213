% PURPOSE : TX IQ Base Band Modulator + Generation of IQ CDB Data file for USRP 2900
%
% USAGE : (Command Window) :
%
% >> s_iq_bb_modulator;
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
% Oct-23-2019  T. LE GALL    0.1      Creation of code
% Oct-28-2019  T. LE GALL    0.2      update : call of f_eye_diagram(() - new API
% Dec-10-2019  T. LE GALL    0.3      update : seed decated to preamble
% Dec-13-2019  T. LE GALL    0.4      update : UNIX/WINDOWS env. mngt.
% Dec-05-2021  T. LE GALL    0.5      udpate : x32 bin data for GRC
% Sep-**-2022  A. Masmoudi   0.6      update : use BPSK and QPSK, add
% different filters
%
% EXTERNAL FUNCTIONS USED :
%
% - f_symb_generator()
% - f_symb_filter_generator()
% - f_write_iq_x32_bin_data()
% - f_eye_diagram()
%
% REFERENCES/NOTES/COMMENTAIRES :
%
% - N/A
%
%**********************************************************************************************

s_project_name = 'ATE SDR FIP'; % put the name of the project here
d_script_id = 11102023; % should be : day month year (at least)

    %% ---------------(DO NOT MODIFY)-------------------
    disp(['--> Run Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id)])
    disp(' ')
    tic
    %% -------------- INITIALISATIONS ------------------

    % ** init constants **

    if (isunix) % working in UNIX env.
        S_TX_DATA_PATH_NAME = '../dat/TPL1/';
    else % working in Windows env.
        S_TX_DATA_PATH_NAME = '..\dat\';
    end

    % parameters to manipulate

    modulationType = 1; % 1 for BPSK, 2 for QPSK
    d_symb_filter_tx = 0; % RX filter waveform, 0 : square (default), 1 raised cos.
    d_alpha_tx = 0.1; % RX filter roll-off factor (raised cos.)

    S_TX_DATA_FILE_NAME = 'bpsk_sq.dat';

    % default parameters

    C_INIT_SAMPLE_FREQ_TX = 500e3/modulationType; % [Hz] RX sampling frequency (1/Te)
    C_INIT_SYMBOL_RATE_TX = 50e3/modulationType; % [Baud] RX symbol rate (1/T)
    C_INIT_SYMBOL_NUM_P_TX = 500; % P, number of symbols (preamble)
    C_INIT_BIT_NUM_M_TX = 20000; % number of bits, to be converted to number of symbols depending on the used modulation
    C_INIT_TX_P_SYMBOL_SEED = 55; % TX seed for random generator of preamble
    C_INIT_TX_M_SYMBOL_SEED = 33; % TX seed for random generator of preamble
    C_INIT_TX_SYMBOL_FILT = 1; % TX filter waveform, 0 : square (default), 1 raised cos.
    C_INIT_TX_IR_DURATION = 6; % TX filter impulse response duration [symbols]
    C_INIT_TX_DIFF_CODING = 0; % TX symbols differential coding, 0 : OFF (default), 1 ON

    % ** init variables (TX modem API) **

    d_sample_freq_tx = C_INIT_SAMPLE_FREQ_TX;
    d_symb_rate_tx = C_INIT_SYMBOL_RATE_TX;
	d_symb_num_p_tx = C_INIT_SYMBOL_NUM_P_TX;
	d_symb_num_m_tx = C_INIT_BIT_NUM_M_TX/modulationType;
    d_symb_seed_p_tx = C_INIT_TX_P_SYMBOL_SEED;
    d_symb_seed_m_tx = C_INIT_TX_M_SYMBOL_SEED;
    d_diff_coding_enable_tx = C_INIT_TX_DIFF_CODING;
    d_ir_duration_in_symb_tx = C_INIT_TX_IR_DURATION;

    %% ----------------- PROCESSING --------------------

    [v_symb_p_tx, ~, v_oversampl_symb_p_tx] = f_symb_generator(d_sample_freq_tx,...
                                                                    d_symb_rate_tx,...
                                                                    d_symb_num_p_tx,...
                                                                    d_symb_seed_p_tx,...
                                                                    d_diff_coding_enable_tx, modulationType); % TX symbols P (preamble)

    [v_symb_m_tx, d_oversampl_fact_tx, v_oversampl_symb_m_tx] = f_symb_generator(d_sample_freq_tx,...
                                                                                      d_symb_rate_tx,...
                                                                                      d_symb_num_m_tx,...
                                                                                      d_symb_seed_m_tx,...
                                                                                      d_diff_coding_enable_tx, modulationType); % TX symbols M (message)

    v_symb_tx = [v_symb_p_tx; v_symb_m_tx]; % TX symbols Frame (P+M)
    v_oversampl_symb_tx = [v_oversampl_symb_p_tx; v_oversampl_symb_m_tx]; % TX oversampled symbols Frame (P+M)

    d_symb_num_tx = length(v_symb_tx); % number of TX symbols (P+M)

    disp(['--> Generated : ', num2str(d_symb_num_tx), ' [complex symbols]'])
    disp(['--> Sampling Frequency : ' num2str(d_sample_freq_tx), ' [Hz]'])
    disp(['--> Symbol Duration (T): ', num2str(d_oversampl_fact_tx/d_sample_freq_tx), ' [s]'])
    disp(['--> Samples per Symbol (T/Te): ', num2str(d_oversampl_fact_tx), ' [samples]'])

    [v_forward_coef, v_reverse_coef] = f_symb_filter_generator(d_sample_freq_tx,...
                                                                     d_symb_rate_tx,...
                                                                     d_symb_filter_tx,...
                                                                     d_ir_duration_in_symb_tx,...
                                                                     d_alpha_tx); % TX filter shape

    v_oversampl_symb_tx_zero_padding = [v_oversampl_symb_tx; zeros(d_ir_duration_in_symb_tx/2*d_oversampl_fact_tx, 1)];
    v_tx_iq_bb_signal = filter(v_forward_coef,  v_reverse_coef,  v_oversampl_symb_tx_zero_padding); % % TX base band IQ signal
    v_tx_iq_bb_signal = v_tx_iq_bb_signal(d_ir_duration_in_symb_tx/2*d_oversampl_fact_tx+1:end);
    disp(['--> IQ BB Signal Length : ', num2str(length(v_tx_iq_bb_signal)), ' [samples]'])
    disp(['--> IQ BB Signal Duration : ', num2str(length(v_tx_iq_bb_signal)/d_sample_freq_tx), ' [s]'])
    disp(['--> IQ BB Symbol Rate (1/T) : ', num2str(length(v_symb_tx)/(length(v_tx_iq_bb_signal)/d_sample_freq_tx)), ' [symbols/s]'])
    disp(' ')

    %% --------------------- W/R DATA ----------------------

    f_write_iq_x32_bin_data(v_tx_iq_bb_signal, strcat(S_TX_DATA_PATH_NAME, S_TX_DATA_FILE_NAME)) % Write CDB Data in File

    %% ----------------------- OSD -------------------------

    C_OSD_SYMB_NUM = 25; % [symbols] for OSD (chronogram)
    C_OSD_EYE_LEN = 6; % [symbols] for OSD (eye diagram)
    C_OSD_EYE_TRACE_NUM = 50;
    C_OSD_XY_MAX_VAL = 1.0; % max value for OSD (scatterplot)
    C_FFT_SIZE_DEFAULT = 1024; % FFT size for spectral analysis

    d_osd_min_sample_idx = 1; % index of the fisrt sample to plot
    d_osd_max_sample_idx = d_osd_min_sample_idx - 1 + C_OSD_SYMB_NUM*d_oversampl_fact_tx; % index of the last sample to plot
    v_osd_iq_data = v_tx_iq_bb_signal(d_osd_min_sample_idx:d_osd_max_sample_idx); % part of IB BB signal to plot
    v_osd_time = ((d_osd_min_sample_idx:1:d_osd_max_sample_idx) - 1)./d_sample_freq_tx; % [s] OSD time vector (chonogram)
    v_osd_time_eye = (0:1:d_oversampl_fact_tx*C_OSD_EYE_LEN-1)./d_oversampl_fact_tx; % [T] OSD time vector (eye diagram)

    eye_samples = C_OSD_EYE_LEN * d_oversampl_fact_tx * C_OSD_EYE_TRACE_NUM;

    eye_samples = min(eye_samples, length(v_tx_iq_bb_signal));

    v_eye_signal = v_tx_iq_bb_signal(1:eye_samples);

disp("TEST 1 - DAT escrito");

disp("TEST 2 - antes eye I");
m_i_trace_osd = f_eye_diagram( ...
    real(v_tx_iq_bb_signal), ...
    d_oversampl_fact_tx, ...
    C_OSD_EYE_LEN, ...
    C_OSD_EYE_TRACE_NUM);
disp("TEST 3 - despues eye I");

disp("TEST 4 - antes eye Q");
m_q_trace_osd = f_eye_diagram( ...
    imag(v_tx_iq_bb_signal), ...
    d_oversampl_fact_tx, ...
    C_OSD_EYE_LEN, ...
    C_OSD_EYE_TRACE_NUM);
disp("TEST 5 - despues eye Q");

disp("TEST 6 - antes FFT");
v_spectrum = fftshift(fft(v_tx_iq_bb_signal, C_FFT_SIZE_DEFAULT));
disp("TEST 7 - despues FFT");



    v_frequency = (-C_FFT_SIZE_DEFAULT/2:1:C_FFT_SIZE_DEFAULT/2-1) / C_FFT_SIZE_DEFAULT * d_sample_freq_tx / 1e3

    figure
disp("PLOT 1 - antes");
            subplot(3, 2, 1)
            plot(v_osd_time, real(v_osd_iq_data))
            title(['TX Signal - I - ', num2str(C_OSD_SYMB_NUM), ' Symbols on ', num2str(d_symb_num_tx)])
            xlabel('Time [s]')
            ylabel('Amplitude')
            grid
disp("PLOT 1 - despues");
disp("PLOT 2 - antes");
            subplot(3, 2, 3)
            plot(v_osd_time, imag(v_osd_iq_data))
            title(['TX Signal - Q - ', num2str(C_OSD_SYMB_NUM), ' Symbols on ', num2str(d_symb_num_tx)])
            xlabel('Time [s]')
            ylabel('Amplitude')
            grid
disp("PLOT 2 - despues");

disp("PLOT 3 - antes");
            subplot(3, 2, 2)

            plot(v_osd_time_eye, m_i_trace_osd)
            title('TX Signal - Eye Diagram - I')
            xlabel('Symbol Time [T]')
            ylabel('Amplitude')
            grid
disp("PLOT 3 - despues");

disp("PLOT 4 - antes");
            subplot(3, 2, 4)
            plot(v_osd_time_eye, m_q_trace_osd)
            title('TX Signal - Eye Diagram - Q')
            xlabel('Symbol Time [T]')
            ylabel('Amplitude')
            grid
disp("PLOT 4 - despues");

disp("PLOT 5 - antes");

            subplot(3, 2, 5)

            if modulationType == 2
                % QPSK
                plot(real(v_symb_tx), imag(v_symb_tx), 'r*')

            elseif modulationType == 1
                % BPSK
                plot(real(v_symb_tx), zeros(size(v_symb_tx)), 'r*')
            end

            axis([-C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL, ...
                  -C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL])

            axis square
            xlabel('In-Phase (I)')
            ylabel('Quadrature (Q)')
            grid on
            title('TX Symbols')

disp("PLOT 5 - despues");

disp("PLOT 6 - antes");
            subplot(3, 2, 6)
            semilogy(v_frequency, abs(v_spectrum))
            xlabel('Frequency [kHz]')
            ylabel('Magnitude')
            grid
            title('TX BB Signal PSD')

disp("PLOT 6 - despues");
    %% ---------------(DO NOT MODIFY)---------------------------
    toc
    disp(' ')
    disp(['End of Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id), ' <--'])

%% ********************************** END OF SCRIPT **************************************
