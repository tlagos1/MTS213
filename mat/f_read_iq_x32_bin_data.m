%**********************************************************************************************
% FONCTION : Importationn de donnees complexes au format 32-bits flottant (little-endian)
%            depuis un fichier binaire enregistre par GNU Radio pour lecture dans Matlab
%
% APPEL :
%
% v_data_out = f_read_iq_x32_bin_data(s_file_name_in)
%
% ARGUMENTS D'ENTREE :
%
% s_file_name_in  : (optionnel) chemin + nom du fichier de donnees (*.dat), defaut : UI Dialog Box
%
% ARGUMENTS DE SORTIE :
%
% % v_data_out    : vecteur donnees importees sous Matlab (complexe 64-bits flottant double precision)
%
% EXEMPLES D'USAGE (Command Window) :
%
% >> v_data_out = f_read_iq_x32_bin_data('..\dat\rx_iq_bin_data.dat');
%
% >> f_read_iq_x32_bin_data;
% 
%**********************************************************************************************

%**********************************************************************************************
%                                Institut Mines-Telecom / IMT Atlantique
%     	                     Departement Mathematical & Electrical Engineering
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
% 14-jan-2020  T. LE GALL    0.0      Creation
% 25-fev-2021  T. LE GALL    0.2      Mise a jour: Dept. MEE
%
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

function [v_data_out] = f_read_iq_x32_bin_data(s_file_name_in)

global s_path_name_in; % keep memory of previous input data file location

%% ** ---------------------------------- Constantes ----------------------------------------- **
C_CURRENT_DIR = pwd; % current working dir.

%% ** ------------------------------- Initialisations -------------------------------------- **

v_data_out = []; % output vector
    
%% ** ---------------------------------- Traitements ----------------------------------------**

% data file name managed through GUI
if (nargin < 1)
   if (and((~isempty(s_path_name_in)), (s_path_name_in  ~= 0)))
       cd(s_path_name_in);   % GUI to same location as previous file 1
   end
    s_dialog_box_in = 'Import Data from GNU Radio to MATLAB from File :';
    [s_file_name_in, s_path_name_in] = uigetfile(('*.dat'), s_dialog_box_in);
    if isequal(s_file_name_in, 0) || isequal(s_path_name_in, 0)
      disp('User pressed cancel')
      cd(C_CURRENT_DIR);
      return;
   end
   s_file_name_in = strcat(s_path_name_in, s_file_name_in);
   cd(C_CURRENT_DIR);
end

% ** Input File ID an Opening Control **

d_fid = fopen(s_file_name_in, 'r');  

if (d_fid < 3)
   errordlg(['Fail to Open Imput Data File: ', s_file_name_in]);
   
else % read data from File **
	disp('--> START Reading I/Q DATA (complex float x32) from Binary File')
	disp(' ')
    disp(['Data File Name : ', s_file_name_in])
    
    v_data_buff = fread(d_fid, 'float32', 'ieee-le'); % data : 32-bits float little-endian
    
    v_data_out = v_data_buff(1:2:end) + 1j*v_data_buff(2:2:end); % matrice des donnees complexe
    
    d_data_cnt = length(v_data_buff)/2;
    disp(' ')                    
    disp(['Found : ', num2str(d_data_cnt),' 32-bits Complex Samples'])
    disp(' ')
    disp('   STOP Reading I/Q DATA (complex float x32) from Binary File from File <--')
    disp(' ')
    
   fclose(d_fid); 
end

%% ** --------------------------------- FIN DE LA FONCTION -------------------------------------**
