function [files_in,files_out,opt] = Module_VSI(files_in,files_out,opt)
% This is a template file for "brick" functions in NIAK.
%
% SYNTAX:
% [IN,OUT,OPT] = PSOM_TEMPLATE_BRICK(IN,OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% IN
%   (string) a file name of a 3D+t fMRI dataset .
%
% OUT
%   (structure) with the following fields:
%       flag_test
%   CORRECTED_DATA
%       (string, default <BASE NAME FMRI>_c.<EXT>) File name for processed
%       data.
%       If OUT is an empty string, the name of the outputs will be
%       the same as the inputs, with a '_c' suffix added at the end.
%
%   MASK
%       (string, default <BASE NAME FMRI>_mask.<EXT>) File name for a mask
%       of the data. If OUT is an empty string, the name of the
%       outputs will be the same as the inputs, with a '_mask' suffix added
%       at the end.
%
% OPT
%   (structure) with the following fields.
%
%   TYPE_CORRECTION
%      (string, default 'mean_var') possible values :
%      'none' : no correction at all
%      'mean' : correction to zero mean.
%      'mean_var' : correction to zero mean and unit variance
%      'mean_var2' : same as 'mean_var' but slower, yet does not use as
%      much memory).
%
%   FOLDER_OUT
%      (string, default: path of IN) If present, all default outputs
%      will be created in the folder FOLDER_OUT. The folder needs to be
%      created beforehand.
%
%   FLAG_VERBOSE
%      (boolean, default 1) if the flag is 1, then the function prints
%      some infos during the processing.
%
%   FLAG_TEST
%      (boolean, default 0) if FLAG_TEST equals 1, the brick does not do
%      anything but update the default values in IN, OUT and OPT.
%
% _________________________________________________________________________
% OUTPUTS:
%
% IN, OUT, OPT: same as inputs but updated with default values.
%
% _________________________________________________________________________
% SEE ALSO:
% NIAK_CORRECT_MEAN_VAR
%
% _________________________________________________________________________
% COMMENTS:
%
% _________________________________________________________________________
% Copyright (c) <NAME>, <INSTITUTION>, <START DATE>-<END DATE>.
% Maintainer : <EMAIL ADDRESS>
% See licensing information in the code.
% Keywords : PSOM, documentation, template, brick

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the module's parameters with default values
if isempty(opt)
    %
    %     %%   % define every option needed to run this module
    %     % --> module_option(1,:) = field names
    %     % --> module_option(2,:) = defaults values
    module_option(:,1)   = {'folder_out',''};
    module_option(:,2)   = {'flag_test',true};
    module_option(:,3)   = {'OutputSequenceName','AllName'};
    module_option(:,4)   = {'B0',4.7};
    module_option(:,5)   = {'Gamma',2.67502};
    module_option(:,6)   = {'deltaxi_CA',0.264};
    module_option(:,7)   = {'RefInput',1};
    module_option(:,8)   = {'InputToReshape',1};
    module_option(:,9)   = {'Table_in', table()};
    module_option(:,10)   = {'Table_out', table()};
    module_option(:,11)   = {'output_filename_ext','VSI'};
    module_option(:,12)   = {'Output_orientation','First input'};
    
    
    
    
    opt.Module_settings = psom_struct_defaults(struct(),module_option(1,:),module_option(2,:));
    %
    %      additional_info_name = {'Operation', 'Day of the 2nd scan', 'Name of the 2nd scan'};
    %         additional_info_data = {'Addition', 'first', handles.Math_parameters_list{1}};
    %         additional_info_format = {{'Addition', 'Subtraction', 'Multiplication', 'Division', 'Percentage', 'Concentration'},...
    %             ['first', '-1', '+1',  'same', handles.Math_tp_list], handles.Math_parameters_list};
    %         additional_info_editable = [1 1 1];
    
    
    %     %% list of everything displayed to the user associated to their 'type'
    %      % --> user_parameter(1,:) = user_parameter_list
    %      % --> user_parameter(2,:) = user_parameter_type
    %      % --> user_parameter(3,:) = parameter_default
    %      % --> user_parameter(4,:) = psom_parameter_list
    %      % --> user_parameter(5,:) = Help : text data which describe the parameter (it
    %      % will be display to help the user)
    user_parameter(:,1)   = {'Description','Text','','','', '','Description of the module'}  ;
    user_parameter(:,2)   = {'Select the DeltaR2 scan','1Scan','','',{'SequenceName'}, 'Mandatory',''};
    user_parameter(:,3)   = {'Select the DeltaR2* scan','1Scan','','',{'SequenceName'}, 'Mandatory',''};
    user_parameter(:,4)   = {'Select the ADC scan','1Scan','','',{'SequenceName'}, 'Mandatory',''};
    user_parameter(:,5)   = {'   .Output filename','char','VSI','output_filename_ext','','',...
        {'Specify the name of the output scan.'
        'Default filename extension is ''VSI''.'}'};
    user_parameter(:,6)   = {'   .Output orientation','cell',{'First input', 'Second input', 'Third Input'},'Output_orientation','','',...
        {'Specify the output orientation'
        '--> Output orienation = First input'
        '--> Output orientation = Second input'
        '--> Output orientation = Third input'
        }'};
    user_parameter(:,7)   = {'   .B0','numeric', '','B0','','',...
    {''}'};
    user_parameter(:,8)   = {'   .Gamma (10^8)','numeric','','Gamma','','',...
    {''}'};
    user_parameter(:,9)   = {'   .deltaxi HBC (10^-6)','numeric', '','deltaxi_CA','','',...
    {''}'};
    VariableNames = {'Names_Display', 'Type', 'Default', 'PSOM_Fields', 'Scans_Input_DOF', 'IsInputMandatoryOrOptional','Help'};
    opt.table = table(user_parameter(1,:)', user_parameter(2,:)', user_parameter(3,:)', user_parameter(4,:)', user_parameter(5,:)', user_parameter(6,:)', user_parameter(7,:)','VariableNames', VariableNames);
    %%
    
    % So for no input file is selected and therefore no output
    % The output file will be generated automatically when the input file
    % will be selected by the user
    files_in = {''};
    files_out = {''};
    return
    
end
%%%%%%%%

if isempty(files_out)
    opt.Table_out = opt.Table_in(opt.RefInput,:);
    opt.Table_out.IsRaw = categorical(0);   
    opt.Table_out.Path = categorical(cellstr([opt.folder_out, filesep]));
    if strcmp(opt.OutputSequenceName, 'AllName')
        opt.Table_out.SequenceName = categorical(cellstr(opt.output_filename_ext));
    elseif strcmp(opt.OutputSequenceName, 'Extension')
        opt.Table_out.SequenceName = categorical(cellstr([char(opt.Table_out.SequenceName), opt.output_filename_ext]));
    end
    opt.Table_out.Filename = categorical(cellstr([char(opt.Table_out.Patient), '_', char(opt.Table_out.Tp), '_', char(opt.Table_out.SequenceName)]));
    f_out = [char(opt.Table_out.Path), char(opt.Table_out.Patient), '_', char(opt.Table_out.Tp), '_', char(opt.Table_out.SequenceName), '.nii'];
    files_out.In1{1} = f_out;
end





%% Syntax
if ~exist('files_in','var')||~exist('files_out','var')||~exist('opt','var')
    error('Module_Coreg_Est:brick','Bad syntax, type ''help %s'' for more info.',mfilename)
end

%% Inputs
%if ~ischar(files_in)
%    error('files in should be a char');
%end

%% If the test flag is true, stop here !

if opt.flag_test == 1
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load input Nii file
input(1).nifti_header = spm_vol(files_in.In1{1});
input(2).nifti_header = spm_vol(files_in.In2{1});
input(3).nifti_header = spm_vol(files_in.In3{1});

J_Delta = spm_jsonread(strrep(files_in.In1{1}, '.nii', '.json'));
J_DeltaStar = spm_jsonread(strrep(files_in.In2{1}, '.nii', '.json'));
J_ADC = spm_jsonread(strrep(files_in.In3{1}, '.nii', '.json'));


if strcmp(opt.Output_orientation, 'First input')   
    ref_scan = 1;
elseif strcmp(opt.Output_orientation, 'Second input')
    ref_scan = 2;
else
    ref_scan = 3;
end
DeltaR2 = read_volume(input(1).nifti_header, input(ref_scan).nifti_header, 0);
DeltaR2Star = read_volume(input(2).nifti_header, input(ref_scan).nifti_header, 0);
ADC = read_volume(input(3).nifti_header, input(ref_scan).nifti_header, 0);

B0=opt.B0;
gamma=opt.Gamma; gamma = gamma*10^8;
deltaxi=opt.deltaxi_CA; deltaxi = deltaxi*10^-6;


temp_thickness = [J_DeltaStar.SliceThickness J_Delta.SliceThickness  J_ADC.SliceThickness];
temp_slice_nbr = [size(DeltaR2Star,3) size(DeltaR2,3)  size(ADC,3)];
temp_resolution = [size(DeltaR2Star,1)*size(DeltaR2Star,2) size(DeltaR2,1)*size(DeltaR2,2)  size(ADC,1)*size(ADC,2)];

% check data compatibility (slice thickness and slice number)
% if  length(find(temp_thickness == deltaR2star.reco.thickness)) ~= numel(temp_thickness)
%     warning_text = sprintf('##$ Can not calculate the VSI map because there is\n##$ a slice thickness missmatch between\n##$deltaR2star=%s\n##$ and \n##$deltaR2=%s\n##$ and\n##$ADC=%s\n',...
%         deltaR2star_filename,deltaR2_filename,ADC_filename);
%     msgbox(warning_text, 'VSI map warning') ;
%      VSImap = [];
%     return
% end
% if length(find(temp_resolution == deltaR2star.reco.no_samples)) ~= numel(temp_resolution)
%      warning_text = sprintf('##$ Can not calculate the VSI map because there is\n##$ a resolution missmatch between\n##$deltaR2star=%s\n##$ and \n##$deltaR2=%s\n##$ and\n##$ADC=%s\n',...
%        deltaR2star_filename,deltaR2_filename,ADC_filename);
%     msgbox(warning_text, 'VSI map warning') ;
%      VSImap = [];
%     return
% end

VSImap = DeltaR2;

if length(find(temp_slice_nbr == size(DeltaR2Star,3))) ~= numel(temp_slice_nbr)
    VSImap_slice_nbr = 0;
    for i = 1:size(DeltaR2Star, 3)
        for j = 1:size(DeltaR2, 3)
                for x = 1:size(ADC, 3)
                        VSImap_slice_nbr = VSImap_slice_nbr+1;
                        % Compute the VSI map each slice with the same offset
                        ratio = DeltaR2Star(:,:,i,1) ./ DeltaR2(:,:,j,1); % ratio : no unit
                        index_ratiofinite= find(~isfinite(ratio));
                        index_rationan= find(isnan(ratio));
                        if ~isempty(index_ratiofinite)
                            ratio(index_ratiofinite) = 0;
                        end
                        if ~isempty(index_rationan)
                            ratio(index_rationan)    = 0;
                        end
                        index_neg= find(ratio<0);
                        if ~isempty(index_neg)
                            ratio(index_neg)    = 0;
                        end
                        ratio = ratio.^1.5;
                          slice_data = 1.77^(-1.5) * sqrt(squeeze(ADC(:,:,x,1)) ./ (gamma * deltaxi * B0)) .* squeeze(ratio);
                       %%%% Rui data
%                        test = imresize(squeeze(ADC.reco.data(:,:,1,x)), [128 128]);
%                        index_inferieurzero=find(test < 0);
%                        test(index_inferieurzero) = 0;
%                        slice_data = 1.77^(-1.5) * sqrt(test ./ (gamma * deltaxi * B0)) .* squeeze(ratio);
                        %%%
                        
                        index_vsifinite=find(~isfinite(slice_data));
                        slice_data(index_vsifinite)= nan;
                        index_vsinan=find(isnan(slice_data));
                        slice_data(index_vsinan)= nan;
                        index_infzero=find(slice_data < 0);
                        slice_data(index_infzero)= nan;
                        VSImap(:,:,VSImap_slice_nbr,1) = slice_data;
                        
                end

        end
    end
    if VSImap_slice_nbr == 0
        warning_text = sprintf('##$ Can not calculate the VSI map because there is\n##$ no slice offset match between\n##$deltaR2star=%s\n##$ and \n##$deltaR2=%s\n##$ and\n##$ADC=%s\n',...
            deltaR2star_filename,deltaR2_filename,ADC_filename);
        msgbox(warning_text, 'VSI map warning') ;
        return
    end
else
    % calculate VSI map for all slices
    ratio = DeltaR2Star ./ DeltaR2; % ratio : no unit
    index_ratiofinite= find(~isfinite(ratio));
    index_rationan= find(isnan(ratio));
    if ~isempty(index_ratiofinite)
        ratio(index_ratiofinite) = 0;
    end
    if ~isempty(index_rationan)
        ratio(index_rationan)    = 0;
    end
     index_neg= find(ratio<0);
    if ~isempty(index_neg)
        ratio(index_neg)    = 0;
    end
    ratio = ratio.^1.5;
    VSImap(:,:,:,1) = 1.77^(-1.5) * sqrt(squeeze(ADC(:,:,:,1)) ./ (gamma * deltaxi * B0)) .* squeeze(ratio);
    % VSImap(:,:,:,1) = 1.77^(-1.5) * sqrt(squeeze(ADC) ./ (gamma * deltaxi * B0)) .* squeeze(ratio);
    
    index_vsifinite=find(~isfinite(VSImap));
    VSImap(index_vsifinite)= 0;
    index_vsinan=find(isnan(VSImap));
    VSImap(index_vsinan)= 0;
    index_infzero=find(VSImap < 0);
    VSImap(index_infzero)= 0;
    
end


OutputImages = VSImap;
OutputImages(OutputImages < 0) = -1;
OutputImages(OutputImages > 5000) = -1;
OutputImages(isnan(OutputImages)) = -1;
if ~exist('OutputImages_reoriented', 'var')
    OutputImages_reoriented = write_volume(OutputImages, input(ref_scan).nifti_header);
end

%% Initial function 


%% 




% save the new files (.nii & .json)
% update the header before saving the new .nii
info = niftiinfo(files_in.(['In' num2str(ref_scan)]){1});

info2 = info;
info2.Filename = files_out.In1{1};
info2.Filemoddate = char(datetime('now'));
info2.Datatype = class(OutputImages);
%info2.Description = [info.Description, 'Modified by the DeltaR2 Module'];

% save the new .nii file
niftiwrite(OutputImages_reoriented, files_out.In1{1}, info2);

% so far copy the .json file of the first input
copyfile(strrep(files_in.In1{1}, '.nii', '.json'), strrep(files_out.In1{1}, '.nii', '.json'))
% 

