%
% PURPOSE: TX Symbols Filter Generator (Pulse Shape)
%
% FUNCTION CALL:
%
% [v_forward_coef, v_reverse_coef] = f_symb_filter_generator(d_sample_freq_tx,...
%                                                            d_symb_rate_tx,...
%                                                            d_symb_filter_tx,..
%                                                            d_ir_duration_in_symb_tx_tx,..
%                                                            d_alpha_tx_tx);
%
% ARGUMENTS IN:
%
%   d_sample_freq_tx : [Hz] TX sampling frequency (1/Te)
%	d_symb_rate_tx : [Baud] TX symbol rate (1/T)
%	d_symb_filter_tx : 
%	d_ir_duration_in_symb_tx_tx :
%	d_alpha_tx_tx :
%
% ARGUMENTS OUT:
%
% v_forward_coef : TX filter taps (numerator)
% v_reverse_coef : TX filter taps (denominator)
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

function  [v_forward_coef, v_reverse_coef] = f_symb_filter_generator(d_sample_freq_tx,...
                                                                     d_symb_rate_tx,...
                                                                     d_symb_filter_tx,...
                                                                     d_ir_duration_in_symb_tx,...
                                                                     d_alpha_tx)
                                                                    
%% ** ---------------------------------- Constants ----------------------------------------- **

C_ESPILON = 2.2204e-16; % smallest value

%% ** ---------------------------------- Processing -----------------------------------------**

% oversampling factor
d_oversampl_fact_tx = d_sample_freq_tx/d_symb_rate_tx; % N = T/Te (samples/symbol)

switch d_symb_filter_tx

case 0 % square (gate [-1/2T, +1/2T])
    v_impulse_resp_tx = [zeros(1,(d_ir_duration_in_symb_tx-1)/2*d_oversampl_fact_tx+1)  ones(1, d_oversampl_fact_tx)  zeros(1,(d_ir_duration_in_symb_tx-1)/2*d_oversampl_fact_tx-1)];

case 1 % raised cosinus

    v_t = -d_ir_duration_in_symb_tx/2:1/d_oversampl_fact_tx:d_ir_duration_in_symb_tx/2-1/d_oversampl_fact_tx;
    v_ir_num = sin(pi*v_t).*cos(pi*d_alpha_tx*v_t) + C_ESPILON ;
    v_ir_den = pi*v_t.*(1-4*d_alpha_tx.^2*(v_t).^2) + C_ESPILON;
    v_ir_resp = v_ir_num ./ v_ir_den;
    v_impulse_resp_tx = (v_ir_resp)./max(abs(v_ir_resp));
    
case 2 % Dirac

    v_impulse_resp_tx = zeros(1, d_oversampl_fact_tx);
    v_impulse_resp_tx(1, 1) = 0.8;

end

v_forward_coef = v_impulse_resp_tx(1, :);

v_reverse_coef = [1, 0];

%% ** --------------------------------- END OF FUNCTION -------------------------------------**




