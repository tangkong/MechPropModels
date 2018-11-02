function [elementAppearanceTable,pairAppearanceTable] = elementStats(filename,wfilename,varargin)
%function elementStats
% counts the number of compositions in the read file
% in which each element appears and the number of compositions in which each
% binary combination of elements appears, and writes them to separate sheets
% of an Excel file.
%   Usage:
%       [elementAppearanceTable, pairAppearanceTable] =
%           elementStats(filename,wfilename,modifiers)
% 
%   Arguments:
%       elementAppearanceTable: table containing the number of compositions
%           in which each element appears
%       pairAppearanceTable: table containing the number of compositions
%           in which each pair of elements appears
%       filename: string containing the name of the file to be read.  This
%           file can be an Excel file or a csv file.
%       wfilename: string containing the name of the Excel file in which to
%           write the results.  The default is 'training_set_stats.xlsx'
% 
%   In the results tables, the elements are in the first column
%   ('elements'), for single elements, or in the first 2 columns
%   ('element_A' and 'element_B'), for element pairs.  The next column in
%   both tables contains the number of compositions in which the element or
%   pair appears, labeled 'appearances' and 'pair_appearances'
%   respectively.  Include the modifier string 'descend' or 'ascend' to sort the
%   tables by descending or ascending number of appearances, respectively.
%   Include the string 'merge' to combine the element columns of
%   pairAppearanceTable into one column, with the two elements in each pair
%   separated by a comma (,).
%   
%   'logical' writes logical tables intended to be used by the Elastic
%   Properties meta-notebook in Ryan's MG_elastic_properties_package to do
%   iterative holdout validation.  There will probably be a lot of these,
%   and they greatly increase the time required to run this function, at
%   least in MATLAB R2014a
% 
%   'stats' writes various stats sheets that require that the read file
%   include measured and predicted values for the target property in the
%   second and third columns
% 
%   'timed' displays the duration of the function in the Command Window at
%   the end of the function
% 
%   
%   Modifier strings may be included in any
%   combination or order, although obviously it can't sort both
%   ascending and descending.
% 
% 
%   This function creates an empty text file in the cwd if it isn't already
%   there, in order to allow communication with an external program that
%   runs this function.  The name of the file is "mat2py_link.txt"
%   
%   --RWS 8/06/2018
    

    
    if any(strcmpi(varargin,'timed'))
        tic
    end

    if nargin < 2
        wfilename = 'training_set_stats.xlsx';
    end
    disp('Reading required files...');
    T = readtable(filename);
    
    warning('off','MATLAB:table:ModifiedVarnames');
    elementsTable = readtable('element_symbols.xlsx');
    warning('on','all');
    warning('off','MATLAB:xlswrite:AddSheet')
    disp('Calculating...');
    elements = elementsTable.symbols;
    compositions = T{:,1};

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
    appearances = appears(appears>0);
    avec = zeros(nchoosek(numel(elements),2),1);
    bvec = avec;
    
    
    
    
    
    pair_comps_ind = zeros(numel(compositions),nchoosek(numel(elements),2));
    
    pairAppVec = avec;
    npairs = 0;
    for a = 1:(numel(elements)-1)
        for b = (a+1):numel(elements)
            cInd = appArray(:,a) & appArray(:,b);
            c = sum(cInd);
            if c
                npairs = npairs + 1;
                pairAppVec(npairs) = c;
                avec(npairs) = a;
                bvec(npairs) = b;
                pair_comps_ind(:,npairs) = cInd;
            end
        end
    end
    avec = avec(1:npairs);
    bvec = bvec(1:npairs);
    pairAppVec = pairAppVec(1:npairs);
    pair_comps_ind = pair_comps_ind(:,1:npairs);
    element_A = elements(avec);
    element_B = elements(bvec);
    pair_appearances = pairAppVec;
    
    
    
    
    
    systemcells = cell(numel(compositions),1);
    systems = systemcells;
    
    n_elements = sum(appArray>0,2);
    max_elements = max(n_elements);
    
    
    systems_int = uint8(zeros(numel(compositions),max_elements));
    
    combos_int = cell(max_elements,1);
    for k=1:max_elements
        combos_int{k,1} = uint8.empty(0,k);
    end
    
    
    logic_cell = combos_int;
    combos = combos_int;
    elementsT = transpose(elements);
    
    logic_table_cell = logic_cell;
    
    
    for r = 1:numel(compositions)
        logicAppVec = appArray(r,:)>0;
        system_int = uint8(find(logicAppVec));
        systems_int(r,1:n_elements(r)) = system_int;
        thisSystem = elementsT(logicAppVec);
        systemcells{r,1} = thisSystem;
        systems{r,1} = strjoin(thisSystem,',');
        for k = 1:n_elements(r)
            combos_int{k,1} = union(combos_int{k,1},nchoosek(system_int,k),'rows');
        end
    end
    combo_labels = combos;
    
    
    for k = 1:max_elements
        combos_int_k = combos_int{k,1};
        nc = size(combos_int_k,1);
        combos_k = cell(nc,1);
        combo_labels_k = combos_k';
        logic_mat = uint8(zeros(numel(compositions), nc))>0; % not actually logical, so that Python pandas can easily read the logic
        for rc = 1:nc
            combos_k{rc,1} = elementsT(combos_int_k(rc,:));
            combo_labels_k{1,rc} = strjoin(combos_k{rc,1},'');
            for r = 1:numel(compositions)
                logic_mat(r,rc) = all(ismember(combos_int_k(rc,:),systems_int(r,:)));
            end
        end
        logic_cell{k,1} = logic_mat;
        combos{k,1} = combos_k;
        combo_labels{k,1} = combo_labels_k;
        logic_table_cell{k,1} = array2table(logic_mat,'RowNames',compositions,'VariableNames',combo_labels_k);
        n_appearances = sum(logic_mat)';
        combination = combo_labels_k';
        disp(['Writing sheet: ','count appearances k=',num2str(k)]);
        writetable(table(combination,n_appearances),wfilename,'Sheet',['count appearances k=',num2str(k)])
        disp(['Finished writing sheet: ','count appearances k=',num2str(k)]);
        pause(2);
    end
    
    
    
    
    if any(strcmpi(varargin,'logical'))
        
%         The following lines are commented out since they are redundant
%         with the loop.  I left them here anyway in case someone wants to
%         restore these for some reason. --RWS 8/6/2018
        
%         appLogicTable = array2table(appArray,'RowNames',compositions,'VariableNames',elements);
%         PairAppLogicTable = array2table(pair_comps_ind,'RowNames',compositions,'VariableNames',strcat(element_A,element_B));
%         disp(['Writing sheet: ','logic table']);
%         writetable(appLogicTable,wfilename,'WriteRowNames',true,'Sheet','logic table'); pause(2); disp(['Finished writing sheet: ','logic table']);
%         disp(['Writing sheet: ','pair logic table']);
%         writetable(PairAppLogicTable,wfilename,'WriteRowNames',true,'Sheet','pair logic table'); pause(2); disp(['Finished writing sheet: ','pair logic table']);
        
        for k=1:max_elements
            disp(['Writing sheet: ','logic table k=',num2str(k),' elements']);
            writetable(logic_table_cell{k,1},wfilename,'WriteRowNames',true,'Sheet',['logic table k=',num2str(k),' elements']);
            disp(['Finished writing sheet: ','logic table k=',num2str(k),' elements']);
            pause(2);
        end
        
    end
    
    
    pair_comps_ind = pair_comps_ind>0;
    
    
    systemTable = table(compositions,systems,n_elements);
    
    
    
    
    
    
    
    
    
    elementAppearanceTable = table(elements,appearances);
    
    if any(strcmpi(varargin,'merge'))
        element_pair = strcat(element_A,{','},element_B);
        pairAppearanceTable = table(element_pair,pair_appearances);
    else
        pairAppearanceTable = table(element_A,element_B,pair_appearances);
    end
    
    pairStatsTable = pairAppearanceTable;
    
    
    if any(strcmpi(varargin,'ascend'))
        elementAppearanceTable = sortrows(elementAppearanceTable,width(elementAppearanceTable));
        pairAppearanceTable = sortrows(pairAppearanceTable,width(pairAppearanceTable));
    elseif any(strcmpi(varargin,'descend'))
        elementAppearanceTable = sortrows(elementAppearanceTable,width(elementAppearanceTable),'descend');
        pairAppearanceTable = sortrows(pairAppearanceTable,width(pairAppearanceTable),'descend');
    end
    
    disp(['Writing sheet: ','element #appearances']);
    writetable(elementAppearanceTable,wfilename,'Sheet','element #appearances');
    disp(['Finished writing sheet: ','element #appearances']);
    pause(2);
    disp(['Writing sheet: ','pair #appearances']);
    writetable(pairAppearanceTable,wfilename,'Sheet','pair #appearances');
    disp(['finished writing sheet: ','pair #appearances']);
    pause(2);
    disp(['Writing sheet: ','element systems']);
    writetable(systemTable,wfilename,'Sheet','element systems'); pause(2);
    disp(['Finished writing sheet: ','element systems']);
    
    
    if any(strcmpi(varargin,'stats'))
        statsTable = [systemTable T(:,2:3)];
        statsTable.abs_error = abs(T.(2)-T.(3));
        statsTable.relative_error = statsTable.abs_error./T.(2);
        
        maeVec = zeros(npairs,1);
        mreVec = maeVec;
        
        for z = 1:npairs
            maeVec(z) = mean(statsTable.abs_error(pair_comps_ind(:,z)));
            mreVec(z) = mean(statsTable.relative_error(pair_comps_ind(:,z)));
        end
        
        pairStatsTable.MAE = maeVec;
        pairStatsTable.MRE = mreVec;
        
        
        statsTable = sortrows(statsTable,{'n_elements','systems','compositions'});
        systemStats = varfun(@mean,statsTable,'InputVariables',{'abs_error','relative_error'},'GroupingVariables',{'n_elements','systems'});
        groupCountStats = varfun(@mean,systemStats,'InputVariables',{'mean_abs_error','mean_relative_error'},'GroupingVariables',{'GroupCount'});
        
        
        
        disp(['Writing sheet: ','cv stats']);
        writetable(statsTable,wfilename,'Sheet','cv stats'); pause(2); disp(['Finished writing sheet: ','cv stats']);
        disp(['Writing sheet: ','System stats']);
        writetable(systemStats,wfilename,'Sheet','System stats'); pause(2); disp(['Finished writing sheet: ','System stats']);
        disp(['Writing sheet: ','System Group Count stats']);
        writetable(groupCountStats,wfilename,'Sheet','System Group Count stats'); pause(2); disp(['Finished writing sheet: ','System Group Count stats']);
        disp(['Writing sheet: ','Pair Stats']);
        writetable(pairStatsTable,wfilename,'Sheet','Pair Stats'); pause(2); disp(['Finished writing sheet: ','Pair Stats']);
    end
    
    if any(strcmpi(varargin,'timed'))
        toc
    end
    warning('on','all');
    fileID = fopen('mat2py_link.txt','wt');
    fclose(fileID);
    
end

