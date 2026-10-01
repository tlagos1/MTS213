%
% PURPOSE: TX/RX Symbols Eye Diagram
%
% FUNCTION CALL:
%
% [m_i_trace_osd, m_q_trace_osd] = f_eye_diagram(v_i_samples, v_q_samples, d_oversampl_fact, d_trace_length, d_trace_num)
%
% ARGUMENTS IN:
%
%	v_i_samples : real part of data
%	v_q_samples : imaginary part of data
%	d_oversampl_fact : oversampling factor (T/Te)
%	d_eye_length : eye length in multiple of T
%	d_trace_num : (optional) number of traces (all traces by default)
%
% ARGUMENTS OUT:
%
%	m_i_trace_osd : real signal part eye diagram for OSD
%	m_q_trace_osd : imaginary signal eye diagram for OSD
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
% Oct-25-2019  T. LE GALL    0.1      creation of code
% Oct-28-2019  T. LE GALL    0.2      update : only one data path instead of IQ
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

function m_trace_osd = f_eye_diagram(v_samples, ...
                                     d_oversampl_fact, ...
                                     d_eye_length, ...
                                     d_trace_num)

    % Force input to column vector
    v_samples = v_samples(:);

    % Number of samples per eye trace
    d_trace_length = round(d_eye_length * d_oversampl_fact);

    % Available samples
    d_buff_len = numel(v_samples);

    % Maximum possible number of complete traces
    d_max_trace_num = floor(d_buff_len / d_trace_length);

    if nargin < 4
        d_trace_num = d_max_trace_num;
    else
        d_trace_num = min(floor(d_trace_num), d_max_trace_num);
    end

    % Protection against invalid dimensions
    if d_trace_length <= 0 || d_trace_num <= 0
        m_trace_osd = [];
        return;
    end

    % Only take the samples actually needed
    d_num_samples = d_trace_length * d_trace_num;

    v_eye = v_samples(1:d_num_samples);

    % Build eye diagram matrix directly
    m_trace_osd = reshape(v_eye, ...
                          d_trace_length, ...
                          d_trace_num);

end



