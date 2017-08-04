%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of ICIP.
%
%    ICIP is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    ICIP is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with ICIP.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AddSemantic2PreprocessedFile(semantic_extracted_file, preprocessed_file)

    [~, fname, ~] = fileparts(semantic_extracted_file);

    %% Getting info from extracted_file.
    if ~isempty(strfind(fname, 'face'))
        extractor = 'face';
    else
        fprintf('The specified file is not compatible. Please run ExtractAndSave first\n');
        return;
    end

    if (exist(semantic_extracted_file, 'file') == 2 )
        load(semantic_extracted_file);
    else
        fprintf('Please run ExtractAndSave first\n');
        return;
    end

    load(preprocessed_file);

    seqdata.DetectedSemanticDetails = Rects;

    save(preprocessed_file,'seqdata');

end
