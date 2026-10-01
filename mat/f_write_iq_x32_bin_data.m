%**********************************************************************************************
% FONCTION : Exportation de donnees complexes au format 32-bits flottant (little-endian)
%            de l'environnement MATLAB vers un fichier binaire pour lecture dans GNU Radio
%
% APPEL :
%
% f_write_iq_x32_bin_data(v_data_out, s_file_name_out)
%
% ARGUMENTS D'ENTREE :
%
% v_data_out       : vecteur de donnees complexes (échantillons I/Q)
% s_file_name_out  : (optionnel) chemin + nom du fichier de donnees (*.dat), defaut : UI Dialog Box
%
% ARGUMENTS DE SORTIE :
%
% - N/A
%
% EXEMPLES D'USAGE (Command Window) :
%
% >> v_data_out = f_write_iq_x32_bin_data(v_data_out, '..\dat\tx_iq_bin_data.dat');
%
% >> f_write_iq_x32_bin_data(v_data_out);
% 
%**********************************************************************************************

%**********************************************************************************************
%                                Institut Mines-Telecom / IMT Atlantique
%     	                    Departement Mathematical & Electrical Engineering
%                                       Technopôle de Brest-Iroise
%                                     CS 83818 - 29238 BREST CEDEX 3
%----------------------------------------------------------------------------------------------
%                                     -  Tous droits reserves -
%
% AUTEUR(s) : Thierry LE GALL (Dept. MEE)
%
% HISTORIQUE DE DEVELOPPEMENT :
%
% Date         Nom(s)       Version   Description
% -----------  ------------- -------  ---------------------------------------------------------
% 14-jan-2020  T. LE GALL    0.1      Creation de la fonction
% 25-fev-2021  T. LE GALL    0.2      Mise a jour: Dept. MEE
%
% FONCTIONS EXTERNES UTILISEES :
%
% - N/A
% 
% REFERENCES/NOTES/COMMENTAIRES :
%
% - N/A
% 
%**********************************************************************************************

function f_write_iq_x32_bin_data(v_data_out, s_file_name_out)

global s_path_name_out; % keep memory of previous output data file location

%% ** ---------------------------------- Constantes ----------------------------------------- **

C_CURRENT_DIR = pwd; % current working dir.

%% ** ------------------------------- Initialisations -------------------------------------- **

[d_lines, d_rows] = size(v_data_out);

if (d_lines < d_rows) % donnees ligne
    v_data_buff = v_data_out.'; % donnees reagencees en colonne
else
    v_data_buff = v_data_out; % donnees restent en colonne
end

d_sample_num = max(d_lines, d_rows); % nombre d'echantillons complexes

m_data_buff = [real(v_data_buff), imag(v_data_buff)]; % (matrice) buffer de donnees

v_data_buff = reshape(m_data_buff.', d_sample_num*2, 1); % entrelacement Re et Im en colonne

%% ** ---------------------------------- Traitements ----------------------------------------**

% data file name managed through GUI
if (nargin < 2)
   if (and((~isempty(s_path_name_out)), (s_path_name_out  ~= 0)))
       cd(s_path_name_out);   % GUI to same location as previous file 1
   end
    s_dialog_box_in = 'Export Data from MATLAB  to GNU Radio in File :';
    [s_file_name_out, s_path_name_out] = uigetfile(('*.dat'), s_dialog_box_in);
    if isequal(s_file_name_out, 0) || isequal(s_path_name_out, 0)
      disp('User pressed cancel')
      cd(C_CURRENT_DIR);
      return;
   end
   s_file_name_out = strcat(s_path_name_out, s_file_name_out);
   cd(C_CURRENT_DIR);
end

% ** Input File ID an Opening Control **

d_fid = fopen(s_file_name_out, 'w+');  

if (d_fid < 3)
   errordlg(['Fail Open Output Data File: ', s_file_name_out]);
   
else % write data to File **
	disp('--> START Writing I/Q DATA (complex float x32) to Binary File')
	disp(' ')
    disp(['Data File Name : ', s_file_name_out])
    
    fwrite(d_fid, v_data_buff, 'float32', 'ieee-le'); % data : 64-bits float little-endian
    
    d_data_cnt = length(v_data_buff)/2;
    
    disp(' ')                    
    disp(['Write: ', num2str(d_data_cnt),' 32-bits Complex Samples'])
    disp(' ')
    disp('   STOP Writing I/Q DATA (complex float x32) to Binary File <--')
	disp(' ')
    
   fclose(d_fid); 
end

%% ** --------------------------------- FIN DE LA FONCTION -------------------------------------**
