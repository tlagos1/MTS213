%
% SCRIPT ID : 13122019
%
% PROJECT ID : ATE SI3 SDR / LAB 005
%
% PURPOSE : RX QPSK IQ Base Band Demodulator (read IQ CDB Data file from USRP 2900)
%
% USAGE : (Command Window) :
%
% >> s_qpsk_iq_bb_demodulator;
%

%**********************************************************************************************
%                                Institut Mines-Telecom / IMT Atlantique
%     	                         Mathematical & Electrical Engineering Dpt.
%                                       Technopole de Brest-Iroise
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
% Dec-13-2019  T. LE GALL    0.1      Creation of code
% Dec-18-2019  T. LE GALL    0.2      update : P-frame & symbol synchro + Phase estimate
% Dec-20-2019  T. LE GALL    0.3      update : DEBUG (phase estimation : rotation)
% Dec-23-2019  T. LE GALL    0.4      update : code correction (phase estimation)
% Jan-07-2020  T. LE GALL    0.5      update : code cleaning
% Jan-14-2020  T. LE GALL    0.6      update : test write x32 IQ data for GNU Radio
% Jan-16-2020  T. LE GALL    0.7      update : UPDATE_16012020
% Dec-05-2021  T. LE GALL    0.8      udpate : x32 bin data for GRC
% Sep-**-2022  A. Masmoudi   0.9      update : use BPSK and QPSK, add
% different filters
% Sep-**-2022  A. Masmoudi   0.9'     update : adapt to phase and synchro
% errors
%
% EXTERNAL FUNCTIONS USED :
%
% - f_qpsk_symb_generator()
% - f_symb_filter_generator()
% - f_read_iq_x32_bin_data()
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
        S_RX_DATA_PATH_NAME = '../dat/TPL1/rx/';
    else % working in Windows env.
        S_RX_DATA_PATH_NAME = '..\dat\';
    end

    % parameters to manipulate

    modulationType = 2; % 1 for BPSK, 2 for QPSK
    samp_error = 0; % normalised sampling error
    phase_error = 0; % phase error
    d_symb_filter_rx = 1; % RX filter waveform, 0 : square (default), 1 raised cos.
    d_alpha_rx = 0.1; % RX filter roll-off factor (raised cos.)

    loopBack = 0;
    if loopBack
        S_RX_DATA_FILE_NAME = 'rx_qpsk_rc_01.dat'; % Matlab Loop-Back
    else
        S_RX_DATA_FILE_NAME = 'rx_qpsk_rc_01.dat'; % file to load
    end
    % default parameters

    C_INIT_SAMPLE_FREQ_RX = 1000e3/modulationType; % [Hz] RX sampling frequency (1/Te)
    C_INIT_SYMBOL_RATE_RX = 100e3/modulationType; % [Baud] RX symbol rate (1/T)
    C_INIT_SYMBOL_NUM_P_RX = 500; % P, number of symbols (preamble)
    C_INIT_BIT_NUM_M_RX = 20000; % number of bits, to be converted to number of symbols depending on the used modulation
    C_INIT_RX_P_SYMBOL_SEED = 55; % RX seed for random generator of preamble
    C_INIT_RX_M_SYMBOL_SEED = 33; % RX seed for random generator of preamble
    C_INIT_RX_SYMBOL_FILT = 1; % RX filter waveform, 0 : square (default), 1 raised cos.
    C_INIT_RX_IR_DURATION = 6; % RX filter impulse response duration [symbols]
    C_INIT_RX_DIFF_CODING = 0; % RX symbols differential coding, 0 : OFF (default), 1 ON

    % ** init variables (RX modem API) **

    d_sample_freq_rx = C_INIT_SAMPLE_FREQ_RX;
    d_symb_rate_rx = C_INIT_SYMBOL_RATE_RX;
	d_symb_num_p_rx = C_INIT_SYMBOL_NUM_P_RX;
	d_symb_num_m_rx = C_INIT_BIT_NUM_M_RX/modulationType;
    d_symb_seed_p_rx = C_INIT_RX_P_SYMBOL_SEED;
    d_symb_seed_m_rx = C_INIT_RX_M_SYMBOL_SEED;
    d_diff_coding_enable_rx = C_INIT_RX_DIFF_CODING;
    d_ir_duration_in_symb_rx = C_INIT_RX_IR_DURATION;

    %% ----------------- PROCESSING --------------------

	%% -------- DATA ACQUISITION & ANALYSIS --------------

	[v_bb_iq_signal_rx] = f_read_iq_x32_bin_data(strcat(S_RX_DATA_PATH_NAME, S_RX_DATA_FILE_NAME)); % read CDB IQ baseband Date from file
	d_iq_bb_signal_len_rx = length(v_bb_iq_signal_rx); % [complex samples]
    d_iq_bb_signal_duration_rx = d_iq_bb_signal_len_rx / d_sample_freq_rx; % [s]
	d_oversampl_fact_rx = d_sample_freq_rx/d_symb_rate_rx; %[ samples/symbol]
	d_symb_num_rx =  d_iq_bb_signal_len_rx / d_oversampl_fact_rx; % [complex symbols]

    disp(['--> RX IQ BB Signal Length : ', num2str(d_iq_bb_signal_len_rx), ' [samples]'])
	disp(['--> RX IQ BB Signal duration : ', num2str(d_iq_bb_signal_duration_rx ), ' [s]'])
 	disp(['--> RX IQ BB Symbol Rate (1/T) : ', num2str(d_symb_rate_rx), ' [symbols/s]'])
    disp(['--> RX IQ BB Symbols Number : ', num2str(d_symb_num_rx), ' [complex symbols]'])
    disp(['--> RX Sampling Frequency : ' num2str(d_sample_freq_rx), ' [Hz]'])
    disp(['--> RX Symbol Duration (T): ', num2str(d_oversampl_fact_rx/d_sample_freq_rx), ' [s]'])
    disp(['--> RX Samples per Symbol (T/Te): ', num2str(d_oversampl_fact_rx), ' [samples]'])
    disp('')

	%% -------------- SIGNAL PROCESSING -----------------

	disp('--> RX P-Frame Detection Symbols Generation')

	% re-generate TX symbols P (preamble) for frame synchronisation

    [v_symb_p_tx, ~, v_oversampl_symb_p_tx] = f_symb_generator(d_sample_freq_rx,...
                                                                    d_symb_rate_rx,...
                                                                    d_symb_num_p_rx,...
                                                                    d_symb_seed_p_rx,...
                                                                    d_diff_coding_enable_rx, modulationType);

     % re-generate RX symbols M (message) for Bit-Error Rate (BER) calculation

    [v_symb_m_tx, d_oversampl_fact_tx, ~] = f_symb_generator(d_sample_freq_rx,...
                                                d_symb_rate_rx,...
                                                d_symb_num_m_rx,...
                                                d_symb_seed_m_rx,...
                                                d_diff_coding_enable_rx, modulationType); % RX symbols M (message) for BER

    disp('--> RX Detector Symbols Filter Generation')

    [v_forward_coef, v_reverse_coef] = f_symb_filter_generator(d_sample_freq_rx,...
                                                               d_symb_rate_rx,...
                                                               d_symb_filter_rx,...
                                                               d_ir_duration_in_symb_rx,...
                                                               d_alpha_rx); % RX filter shape

    %v_bb_iq_signal_rx_filt = filter(  v_forward_coef,  v_reverse_coef, v_bb_iq_signal_rx);

	disp('--> RX P-Frame Detection Symbols Filtering')

    v_oversampl_symb_p_tx = [v_oversampl_symb_p_tx; zeros(d_ir_duration_in_symb_rx/2*d_oversampl_fact_tx, 1)];
    v_signal_p_tx = filter(v_forward_coef,  v_reverse_coef,  v_oversampl_symb_p_tx); % TX frame synchro. signal
    v_signal_p_tx = v_signal_p_tx(d_ir_duration_in_symb_rx/2*d_oversampl_fact_tx+1:end);

 	disp('--> RX P-Frame Synchro Detection Start...')

    % ** P-frame detection (correlation) in RX signal **

    v_signal_corr_p_rx = conv(v_bb_iq_signal_rx, conj(flipud(v_signal_p_tx)));

    %v_signal_corr_p_rx = conv( v_bb_iq_signal_rx_filt, conj(flipud(v_signal_p_tx)));

    v_signal_corr_p_rx_ene = abs(v_signal_corr_p_rx);

    [d_signal_corr_max_val, d_signal_corr_max_idx] = max(v_signal_corr_p_rx_ene);

    % ** P-frame synchronisation in RX signal **

	  d_sample_p_idx_start = d_signal_corr_max_idx - length(v_signal_p_tx) + 1;
  	d_sample_p_idx_stop = d_sample_p_idx_start + length(v_signal_p_tx) - 1;


    d_sample_m_idx_start = d_sample_p_idx_stop + 1 + samp_error;
    d_sample_m_idx_stop = d_sample_m_idx_start + d_symb_num_m_rx*d_oversampl_fact_rx - 1;

    v_signal_p_rx = v_bb_iq_signal_rx(d_sample_p_idx_start:d_sample_p_idx_stop); % P-frame extracted of RX IQ BB signal
    %v_signal_p_rx = v_bb_iq_signal_rx_filt(d_sample_p_idx_start:d_sample_p_idx_stop);

    % ** P-symbols synchronisation in RX signal

    d_symb_p_num_rx = floor(length(v_signal_p_rx)/d_oversampl_fact_rx); % number of P symbols available in the frame

    disp(['--> RX P-Symbols Available in detected frame : ', num2str(d_symb_p_num_rx), ' [symbols]'])

    v_signal_p_rx = v_signal_p_rx(1:d_symb_p_num_rx*d_oversampl_fact_rx); % exclude extra-samples if any

%     m_signal_p_rx = reshape(v_signal_p_rx, d_oversampl_fact_rx, d_symb_p_num_rx);
%     v_symb_p_rx = m_signal_p_rx(d_oversampl_fact_rx, :).'; % symbol sample time

    % Automatic symbol sampling offset search
    best_sampling_offset = 0;
    best_ber_p = inf;

    for sampling_offset = 0:d_oversampl_fact_rx-1

        v_symb_p_test = ...
            v_signal_p_rx(1+sampling_offset:d_oversampl_fact_rx:end);

        n_test = min(length(v_symb_p_test), length(v_symb_p_tx));

        % Estimate phase for this sampling position
        phase_test = angle(sum( ...
            v_symb_p_test(1:n_test) .* conj(v_symb_p_tx(1:n_test)) ...
        ));

        % Correct phase
        v_symb_p_test_pc = ...
            v_symb_p_test(1:n_test) .* exp(-1j*phase_test);

        if modulationType == 1

            % BPSK: only I component carries information
            tx_bits = real(v_symb_p_tx(1:n_test)) >= 0;
            rx_bits = real(v_symb_p_test_pc) >= 0;

            ber_test = sum(tx_bits ~= rx_bits) / n_test;

        elseif modulationType == 2

            % QPSK: I and Q carry information
            tx_i = real(v_symb_p_tx(1:n_test)) >= 0;
            tx_q = imag(v_symb_p_tx(1:n_test)) >= 0;

            rx_i = real(v_symb_p_test_pc) >= 0;
            rx_q = imag(v_symb_p_test_pc) >= 0;

            ber_test = ...
                (sum(tx_i ~= rx_i) + sum(tx_q ~= rx_q)) / (2*n_test);

        end

        %fprintf('--> Sampling Offset %d : BER(P) = %g\n', ...
         %   sampling_offset, ber_test);

        if ber_test < best_ber_p
            best_ber_p = ber_test;
            best_sampling_offset = sampling_offset;
        end
    end

    fprintf('--> Best Symbol Sampling Offset : %d [samples]\n', ...
        best_sampling_offset);

    % Use the best sampling position
    v_symb_p_rx = ...
        v_signal_p_rx(1+best_sampling_offset:d_oversampl_fact_rx:end);
    % ** TX-RX P-symbols Phase Estimate and Rotation

    % Estimate phase offset using the complete preamble
    d_symb_p_phase_rx_tx = angle(sum( ...
        v_symb_p_rx .* conj(v_symb_p_tx(1:length(v_symb_p_rx))) ...
    )) + phase_error;

    v_symb_p_pc_rx = ...
        v_symb_p_rx .* exp(-1j*d_symb_p_phase_rx_tx); % Phase Correction (rotation)

    disp(['--> RX/TX P-Symbols Phase Estimate : ', num2str(d_symb_p_phase_rx_tx), ' [rd]'])

% ** P-symbols TX/RX Bit-Error Rate **

    n_p = length(v_symb_p_pc_rx);

    if modulationType == 1
        % BPSK: 1 bit/symbol (I only)
        v_bin_p_tx = real(v_symb_p_tx(1:n_p)) >= 0;
        v_bin_p_rx = real(v_symb_p_pc_rx) >= 0;

    elseif modulationType == 2
        % QPSK: 2 bits/symbol (I and Q)
        tx_i = real(v_symb_p_tx(1:n_p)) >= 0;
        tx_q = imag(v_symb_p_tx(1:n_p)) >= 0;

        rx_i = real(v_symb_p_pc_rx) >= 0;
        rx_q = imag(v_symb_p_pc_rx) >= 0;

        v_bin_p_tx = [tx_i(:); tx_q(:)];
        v_bin_p_rx = [rx_i(:); rx_q(:)];
    end

    d_p_ber = sum(v_bin_p_rx(:) ~= v_bin_p_tx(:)) / numel(v_bin_p_rx);

    disp(['--> RX Bit-Error Rate (P) = ', num2str(d_p_ber), ...
          ', computed on: ', num2str(numel(v_bin_p_rx)), ' [bits]'])

    v_signal_m_rx = v_bb_iq_signal_rx(d_sample_m_idx_start:d_sample_m_idx_stop); % M-frame extracted of RX IQ BB signal
    %v_signal_m_rx = v_bb_iq_signal_rx_filt(d_sample_m_idx_start:d_sample_m_idx_stop);

    % ** M-symbols synchronisation in RX signal

    d_symb_m_num_rx = floor(length(v_signal_m_rx)/d_oversampl_fact_rx); % number of M symbols available in the frame

    disp(['--> RX M-Symbols Available in detected frame : ', num2str(d_symb_m_num_rx), ' [symbols]'])

    v_signal_m_rx = v_signal_m_rx(1:d_symb_m_num_rx*d_oversampl_fact_rx); % exclude extra-samples if any

%     m_signal_m_rx = reshape(v_signal_m_rx, d_oversampl_fact_rx, d_symb_m_num_rx);
%     v_symb_m_rx = m_signal_m_rx(d_oversampl_fact_rx, :).'; % symbol sample time

    % Use the sampling offset estimated from the P-frame
    v_symb_m_rx = ...
        v_signal_m_rx(1+best_sampling_offset:d_oversampl_fact_rx:end);


    % ** TX-RX M-symbols Phase Correction Using P-Frame Estimation

    v_symb_m_pc_rx = v_symb_m_rx .* exp(-1j*d_symb_p_phase_rx_tx); % Phase Correction (rotation + ambiguity)

    % ** M-symbols TX/RX Bit-Error Rate **

    n_m = length(v_symb_m_pc_rx);

    if modulationType == 1
        % BPSK: 1 bit/symbol (I only)
        v_bin_m_tx = real(v_symb_m_tx(1:n_m)) >= 0;
        v_bin_m_rx = real(v_symb_m_pc_rx) >= 0;

    elseif modulationType == 2
        % QPSK: 2 bits/symbol (I and Q)
        tx_i = real(v_symb_m_tx(1:n_m)) >= 0;
        tx_q = imag(v_symb_m_tx(1:n_m)) >= 0;

        rx_i = real(v_symb_m_pc_rx) >= 0;
        rx_q = imag(v_symb_m_pc_rx) >= 0;

        v_bin_m_tx = [tx_i(:); tx_q(:)];
        v_bin_m_rx = [rx_i(:); rx_q(:)];
    end

    d_m_ber = sum(v_bin_m_rx(:) ~= v_bin_m_tx(:)) / numel(v_bin_m_rx);

    disp(['--> RX Bit-Error Rate (M) = ', num2str(d_m_ber), ...
          ', computed on: ', num2str(numel(v_bin_m_rx)), ' [bits]'])


    %% ----------------------- OSD -------------------------

    C_OSD_SYMB_NUM = 25; % [symbols] for OSD (chronogram)
    C_OSD_EYE_LEN = 6;
    C_OSD_EYE_TRACE_NUM = 50;
    C_OSD_XY_MAX_VAL = 1.0; % max value for OSD (scatterplot)
    C_FFT_SIZE_DEFAULT = 1024; % FFT size for spectral analysis

    d_osd_min_sample_idx = d_sample_p_idx_start; % UPDATE_16012020 : first sample of detected P-Frame

    d_osd_max_sample_idx = d_osd_min_sample_idx - 1 + C_OSD_SYMB_NUM*d_oversampl_fact_rx; % index of the last sample to plot
    v_osd_iq_data = v_bb_iq_signal_rx(d_osd_min_sample_idx:d_osd_max_sample_idx); % part of IB BB signal to plot
    v_osd_time = ((d_osd_min_sample_idx:1:d_osd_max_sample_idx) - 1)./d_sample_freq_rx; % [s] OSD time vector (chonogram)
    v_osd_time_eye = (0:1:d_oversampl_fact_rx*C_OSD_EYE_LEN-1)./d_oversampl_fact_rx; % [T] OSD time vector (eye diagram)

	  m_i_trace_osd = f_eye_diagram( ...
      real(v_bb_iq_signal_rx(d_sample_m_idx_start:d_sample_m_idx_stop) ...
      * exp(-1j*d_symb_p_phase_rx_tx)), ...
      d_oversampl_fact_rx, ...
      C_OSD_EYE_LEN, ...
      C_OSD_EYE_TRACE_NUM);

    m_q_trace_osd = f_eye_diagram( ...
      imag(v_bb_iq_signal_rx(d_sample_m_idx_start:d_sample_m_idx_stop) ...
      .* exp(-1j*d_symb_p_phase_rx_tx)), ...
      d_oversampl_fact_rx, ...
      C_OSD_EYE_LEN, ...
      C_OSD_EYE_TRACE_NUM);

    v_spectrum  = fftshift(fft(v_bb_iq_signal_rx, C_FFT_SIZE_DEFAULT));
    v_frequency = (-C_FFT_SIZE_DEFAULT/2:1:C_FFT_SIZE_DEFAULT/2-1)/C_FFT_SIZE_DEFAULT;

    figure

        subplot(3, 2, 1)
        plot(v_osd_time, real(v_osd_iq_data))
        title(['RX Signal - I - First ', num2str(C_OSD_SYMB_NUM), ' Symbols (P-Frame)']) % UPDATE_16012020
        xlabel('Time [s]')
        ylabel('Amplitude')
        grid

        subplot(3, 2, 3)
        plot(v_osd_time, imag(v_osd_iq_data))
        title(['RX Signal - Q - First ', num2str(C_OSD_SYMB_NUM), ' Symbols (P-Frame)']) % UPDATE_16012020
        xlabel('Time [s]')
        ylabel('Amplitude')
        grid

        subplot(3, 2, 2)
        plot(v_osd_time_eye, m_i_trace_osd)
        title(['Eye Diagram - I - alpha=', num2str(d_alpha_rx)])
        xlabel('Symbol Time [T]')
        ylabel('Amplitude')
        grid

        subplot(3, 2, 4)
        plot(v_osd_time_eye, m_q_trace_osd)
        title(['Eye Diagram - Q - alpha=', num2str(d_alpha_rx)])
        xlabel('Symbol Time [T]')
        ylabel('Amplitude')
        grid

        subplot(3, 2, 5)
            plot(v_signal_corr_p_rx_ene);
            line('xdata', [d_signal_corr_max_idx, d_signal_corr_max_idx], 'ydata', [0, d_signal_corr_max_val], 'Color', [1 0 0]);
            title('RX Signal and TX P Signal Correlation')
            xlabel('Samples')
            ylabel('Modulus')
            grid

        subplot(3, 2, 6)
        semilogy(v_frequency, abs(v_spectrum))
        xlabel('Frequency [Hz]')
        ylabel('Magnitude')
        grid
        title('RX BB Signal PSD')

    if modulationType == 2

        %% FIGURE 2
        figure

        subplot(1, 2, 1)
        plot(v_symb_m_rx, 'r*')
        axis([-C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL, ...
              -C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL])
        axis square
        xlabel('In-Phase (I)')
        ylabel('Quadrature (Q)')
        grid on
        title('RX M-Symbols (sync. IN)')

        subplot(1, 2, 2)
        plot(v_symb_m_pc_rx, 'r*')
        axis([-C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL, ...
              -C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL])
        axis square
        xlabel('In-Phase (I)')
        ylabel('Quadrature (Q)')
        grid on
        title('RX M-Symbols (sync. OUT)')


        %% FIGURE 3
        figure

        c = 1/sqrt(2) + 1j/sqrt(2);

        subplot(1, 2, 1)
        plot(v_symb_m_rx(1), 'r*')
        hold on
        plot(c, 'o')
        plot(conj(c), 'o')
        plot(-c, 'o')
        plot(-conj(c), 'o')
        axis([-C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL, ...
              -C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL])
        axis square
        xlabel('In-Phase (I)')
        ylabel('Quadrature (Q)')
        grid on
        title('RX one Symbol (sync. IN)')
        hold off

        subplot(1, 2, 2)
        plot(v_symb_m_pc_rx(1), 'r*')
        hold on
        plot(c, 'o')
        plot(conj(c), 'o')
        plot(-c, 'o')
        plot(-conj(c), 'o')
        axis([-C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL, ...
              -C_OSD_XY_MAX_VAL, C_OSD_XY_MAX_VAL])
        axis square
        xlabel('In-Phase (I)')
        ylabel('Quadrature (Q)')
        grid on
        title('RX one Symbol (sync. OUT)')
        hold off

    end

    %% ---------------(DO NOT MODIFY)---------------------------
    toc
    disp(' ')
    disp(['End of Simulation - Project Name : ', s_project_name, ' - Script ID = ', num2str(d_script_id), ' <--'])

%% ********************************** END OF SCRIPT **************************************
