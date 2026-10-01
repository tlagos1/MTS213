%
% PURPOSE: TX QPSK Symbols Generator
%
% FUNCTION CALL:
%
% [v_symb_tx, d_oversampl_fact_tx, v_oversampl_symb_tx] = f_qpsk_symb_generator(d_sample_freq_tx,...
%                                                                            d_symb_rate_tx,...
%                                                                            d_symb_num_tx,..
%                                                                            d_symb_seed_tx,..
%                                                                            d_diff_coding_enable_tx);
%
% ARGUMENTS IN:
%
%   d_sample_freq_tx : [Hz] TX sampling frequency (1/Te)
%	d_symb_rate_tx : [Baud] TX symbol rate (1/T)
%	d_symb_num_tx : [symbols] TX symbol number
%	d_symb_seed_tx : TX seed for random generator
% 	d_diff_coding_enable_tx : TX symbols differential coding, 0 : OFF (default), 1 ON
%
% ARGUMENTS OUT:
%
%	v_symb_tx : symbols (1/T)
%	d_oversampl_fact_tx : oversamping factor (T x Te)
%	v_oversampl_symb_tx : vector of oversampled symbols
%

%**********************************************************************************************
%                            IMT Atlantique -  All rights reserved
%                              Department Signal & Communications
%                                  Technopole de Brest-Iroise
%                                CS 83818 - 29238 BREST CEDEX 3
%
% AUTHOR: Thierry LE GALL
%
% DEVELOPMENT HISTORY:
%
% Date         Name(s)       Version  Description
% -----------  ------------- -------  ------------------------------------------------------
% Oct-23-2019  T. LE GALL    0.1      creation of code
% Dec-10-2019  T. LE GALL    0.2      updade : rng('shuffle')
% 
%
% EXTERNAL FUNCTIONS USED:
%
% - none.
%
% SCRIPTS CALLING FUNCTION:
%
% - none.
%
% REFERENCES/NOTES/COMMENTS:
%
% - none.
% 
%**********************************************************************************************

function  [v_symb_tx, d_oversampl_fact_tx, v_oversampl_symb_tx] = f_symb_generator(d_sample_freq_tx,...
                                                                                        d_symb_rate_tx,...
                                                                                        d_symb_num_tx,...
                                                                                        d_symb_seed_tx,...
                                                                                        d_diff_coding_enable_tx, modulationType)
                                                                       
%% ** ------------------------------- Initialisations -------------------------------------- **

if (d_symb_seed_tx > 0)
    rng(d_symb_seed_tx); % freeze the seed to get the same sequence every run
else
    rng('shuffle'); % seed using the current time (different for each runs) 
end

%% ** ---------------------------------- Processing -----------------------------------------**
% bit chains
v_b1k = round(rand(1, d_symb_num_tx)); % binaries - I
v_b2k = round(rand(1, d_symb_num_tx)); % binaries - Q

% symbols (bit-symbols mapping)
v_ak = (1/sqrt(2))*(2*v_b1k - 1); % {ak} - I Mapping
v_bk = (1/sqrt(2))*(2*v_b2k - 1); % {bk} - Q Mapping

v_symb_tx = (v_ak + 1i*v_bk*(modulationType==2)).'; % {dk}

% symbols differential coding
if (d_diff_coding_enable_tx)

    d_ck_1 = 1/sqrt(2)*(1+1j);

    for k = 1:d_symb_num_tx
        d_ck = d_ck_1*v_symb_tx(k)*exp(-1j*pi/4);
        d_ck_1 = d_ck;
        v_symb_tx(k) = d_ck;
    end
    
end

% oversampling factor
d_oversampl_fact_tx = d_sample_freq_tx/d_symb_rate_tx; % N = T/Te (samples/symbol)

% symbol clocking
v_clock_tx  = [1; zeros(d_oversampl_fact_tx-1, 1)];

m_oversampl_symb = v_symb_tx * v_clock_tx.';
v_oversampl_symb_tx = reshape(m_oversampl_symb.', d_oversampl_fact_tx*d_symb_num_tx, 1);


%% ** --------------------------------- END OF FUNCTION -------------------------------------**

