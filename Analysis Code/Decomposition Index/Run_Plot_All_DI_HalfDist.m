% Rocky Mazorow
% 5/6/2022

% This script goes through all 15 subjects (S02-S16) in the specified root
% folder, finds their average DI by distance per block, and then creates an
% error plot for all 15 subjects' DIs by distance per block.

% The means and standard errors calcuated are stored in:
%     - avg_SI = mean of initial State DI
%     - avg_JI = mean of initial Joint DI
%     - avg_SL = mean of last State DI
%     - avg_JL = mean of last Joint DI
%     - ste_SI = standard error of initial State DI
%     - ste_JI = standard error of initial Joint DI
%     - ste_SL = standard error of last State DI
%     - ste_JL = standard error of last Joint DI

clc
clear

% Root directory that holds subjects' data folders
% Mac Laptop
root = ('/Users/rmazorow/Library/CloudStorage/OneDrive-MarquetteUniversity/MATLAB/Ramsey_State_Joint/data/');
% Mac Desktop
%root = ('/Users/Rocky/OneDrive - Marquette University/MATLAB/Ramsey_State_Joint/data/');
% Windows Desktop
%root = ('C:/Users/0961mazoror/OneDrive - Marquette University/MATLAB/Ramsey_State_Joint/data/');

blocks = {'A', 'B1', 'C1', 'C2', 'C3', 'C4', 'C5', 'B2', 'E'};        

% Create matrices for initial and last DIs
initByBlock_S = zeros(15,size(blocks,2));
lastByBlock_S = zeros(15,size(blocks,2));
initByBlock_J = zeros(15,size(blocks,2));
lastByBlock_J = zeros(15,size(blocks,2));
  
% For each subject (S02-S16)
for s = 2:16
    if s < 10
        sub = strcat('S0',num2str(s));
    else
        sub = strcat('S',num2str(s));
    end
    
    % For each condition (State or Joint)
    for c = 1:2

        % Create empty matrix for DI by trial
        %    col 1: block number
        %    col 2: trial number
        %    col 3: Decomposition index (DI) in joint angles for entire trial
        %    col 4: DI in endpoint coordinates for entire trial
        %    col 5: DI in joint angles for first half of trial
        %    col 6: DI in endpoint coordinates for first half of trial
        %    col 7: DI in joint angles for last half of trial
        %    col 8: DI in endpoint coordinates for last half of trial
        subDIperTri = zeros(225, 8);

        if c == 1
            cond = 'State';
        else
            cond = 'Joint';
        end

        disp(['Evaluating Subject ',sub,' Condition ', cond])
        rootCond = strcat(root,'/',sub,'/',cond,'/');

        % For each block (defined above in blocks)
        for b = 1:size(blocks,2)
            disp(['    Evaluating Block ',blocks{b}])
            curDirectory = strcat(rootCond,'Block_',blocks{b},'/');
            ListofTrlFiles = dir(strcat(curDirectory, '*.mat'));

            if size(ListofTrlFiles) == 0
                disp(['File for ',cond,' ',blocks{b},' Not Found']);
            else
                
                % For each trial, input TargetData into DIalgorithm
                for trials = 1:size(ListofTrlFiles)
                    % Identify and load name of trial file
                    fName = strcat(curDirectory, ListofTrlFiles(trials).name);
                    file = load(fName);

                    % Collect DI data
                    [DIj_all, DIe_all, DIj_init, DIe_init, DIj_last, DIe_last] = DIalgorithmByDist(file.TargetData, file.ExamineeData);

                    % Find the word trial and last underscore to extract specific trial number (ex. '... trial9_ ...')
                    trI = strfind(fName,'trial');
                    usI = strfind(fName,'_');

                    % Load matrix with 8 columns specified above
                    subDIperTri((b-1)*25+trials, 1) = b;
                    subDIperTri((b-1)*25+trials, 2) = str2double(extractBetween(fName,trI+5,usI(end)-1));
                    subDIperTri((b-1)*25+trials, 3) = DIj_all;
                    subDIperTri((b-1)*25+trials, 4) = DIe_all;
                    subDIperTri((b-1)*25+trials, 5) = DIj_init;
                    subDIperTri((b-1)*25+trials, 6) = DIe_init;
                    subDIperTri((b-1)*25+trials, 7) = DIj_last;
                    subDIperTri((b-1)*25+trials, 8) = DIe_last;
                end
            end   
            
            % Add each average DI per subject to array for each block
            if c == 1
                initByBlock_S(s-1, b) = mean(subDIperTri( ((b-1)*25)+1 : b*25,6));
                lastByBlock_S(s-1, b) = mean(subDIperTri( ((b-1)*25)+1 : b*25,8));
            else
                initByBlock_J(s-1, b) = mean(subDIperTri( ((b-1)*25)+1 : b*25,5));
                lastByBlock_J(s-1, b) = mean(subDIperTri( ((b-1)*25)+1 : b*25,7));
            end
        end
    end
end

% Create array to hold means and standard errors
avg_SI = zeros(1,size(blocks,2));
avg_SL = zeros(1,size(blocks,2));
avg_JI = zeros(1,size(blocks,2));
avg_JL = zeros(1,size(blocks,2));
ste_SI = zeros(1,size(blocks,2));
ste_SL = zeros(1,size(blocks,2));
ste_JI = zeros(1,size(blocks,2));
ste_JL = zeros(1,size(blocks,2));

% For each block, calculate mean and standard error per condition
for i = 1:size(blocks,2)
    % Calculate average of each block
    avg_SI(i) = mean(initByBlock_S(:,i));
    avg_JI(i) = mean(initByBlock_J(:,i));
    avg_SL(i) = mean(lastByBlock_S(:,i));
    avg_JL(i) = mean(lastByBlock_J(:,i));

    % Calculate standard error of each block
    ste_SI(i) = std(initByBlock_S(:,i)) / sqrt(15);
    ste_JI(i) = std(initByBlock_J(:,i)) / sqrt(15);
    ste_SL(i) = std(lastByBlock_S(:,i)) / sqrt(15);
    ste_JL(i) = std(lastByBlock_J(:,i)) / sqrt(15);
end 

% Define colors to plot (blue = State, red = Joint)
c_SI = '#0093F5';
c_SL = '#0062A3';
c_JI = '#D48799';
c_JL = '#B4415C';
            
% Plot the data using solid lines for initial half and dashed lines for
% last half
disp('Plotting...')
figure('Units', 'normalized', 'OuterPosition', [0 0 1 1])
errorbar(1:size(blocks,2),avg_SI,ste_SI,'LineStyle','-','Color',c_SI,'MarkerEdgeColor',c_SI,'Marker','s','DisplayName','State Initial Half','CapSize',18,'LineWidth',2)
hold on;
errorbar(1:size(blocks,2),avg_SL,ste_SL,'LineStyle','--','Color',c_SL,'Marker','s','DisplayName','State Last Half','CapSize',18,'LineWidth',2)
errorbar(1:size(blocks,2),avg_JI,ste_JI,'LineStyle','-','Color',c_JI,'Marker','s','DisplayName','Joint Initial Half','CapSize',18,'LineWidth',2)
errorbar(1:size(blocks,2),avg_JL,ste_JL,'LineStyle','--','Color',c_JL,'Marker','s','DisplayName','Joint Last Half','CapSize',18,'LineWidth',2)
xlim([0 10])
ylim([0.25 0.65])
title(sprintf('Decomposition Index of Each Half of Distance Traveled (Mean %c 1 SE)', char(177)));
xlabel('Block')
ylabel('Decomposition Index')
xticklabels({' ','A', 'B1', 'C1', 'C2', 'C3', 'C4', 'C5', 'B2', 'E',' '})
hold off;
legend('Orientation', 'Horizontal');    

% Save the figures as png and svg
saveas(gcf, 'images/All_Subs/All_DI_HalfDist.png')
saveas(gcf, 'images/All_Subs/All_DI_HalfDist.svg')