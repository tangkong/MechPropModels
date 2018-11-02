function [] = reformat4ternary(filename,property)
%reformat4ternary
% Rearrange the predicted data contained in a csv or excel file, in which
% the first column contains composition formulae and the second column 
% contains the target property values, into a new csv file readable by
% Jae's ternary plotter (plothte_ternary_scalar_zach.py) and also by the
% Elastic Properties meta-notebook in Ryan's MG_elastic_properties_package
% 
%   Usage: 
%       reformat4ternary(filename,~property)
%   Arguments:
%       filename:  string containing the name of the file to be read
%       property:  string denoting the target property to be written in the
%           output file.  Default is 'elastic_modulus'.
%   The function automatically generates the new file's name by appending
%   the prefix 'ref_' to the beginning of the input filename.
% 
%  --RWS 8/06/2018
    
    T1 = readtable(filename);
    compositions = T1{:,1};
    elastic_modulus = T1{:,2};
    elementsTable = readtable('element_symbols.xlsx');
    elements = elementsTable.symbols;
    numcomps = height(T1);

    appears = zeros(118,1);
    appArray = zeros(numel(compositions),numel(elements));

    for a = 1:118
        element = elements{a,1};
        exclElement = [element,'[a-z]'];
        locs = regexp(compositions,element);
        exclLocs = regexp(compositions, exclElement);
        numlocs = cellfun(@numel,locs)-cellfun(@numel,exclLocs);
        appArray(:,a) = numlocs;
        appears(a) = sum(numlocs>0);
    end

    appArray = appArray(:,(appears>0)');
    elements = elements(appears>0);


    for el = 1:3
        element = elements{el,1};
        for c = 1:numcomps
            if appArray(c,el) && (length(compositions{c,1})>2)
                match = regexp(compositions{c,1},[element,'0\.\d+'],'match');
                comp = match{1,1};
                appArray(c,el) = str2double(comp(1+length(element):length(comp)));
                    % appArray becomes array of atomic fractions
            end
        end
    end

    finalTable = array2table(appArray,'VariableNames',elements);
    finalTable.elastic_modulus = elastic_modulus;
    if nargin>1
        finalTable.Properties.VariableNames{1,4} = property;
    end
    writetable(finalTable,['ref_',filename]);
    fileID = fopen('mat2py_link.txt','wt');
    fclose(fileID);
end














