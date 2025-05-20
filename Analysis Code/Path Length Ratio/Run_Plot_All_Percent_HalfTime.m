% Rocky Mazorow
% 5/6/2022

% This script goes through all 15 subjects (S02-S16) in the specified root
% folder, finds the ratio of their first half and second half of distance  
% traveled (for respective half of time samples) over their total distance 
% traveled per trial, averages these per block, and then creates a box plot 
% of all 15 subjects' ratios per block. Individual subject means are 
% overlayed on box plot.

% The raw means of each subject per block are stored in:
%     - initByBlock_S = mean of initial State distance ratio
%     - lastByBlock_S = mean of last State distance ratio
%     - initByBlock_J = mean of initial Joint distance ratio
%     - lastByBlock_J = mean of last Joint distance ratio

clc
clear

% Root directory that holds subjects' data folders
% Mac Laptop
root = ('/Users/rmazorow/Library/CloudStorage/OneDrive-MarquetteUniversity/MATLAB/Ramsey_State_Joint/data/');
% Mac Desktop
%root = (['/Users/Rocky/OneDrive - Marquette University/MATLAB/Ramsey_State_Joint/data/',sub,'/']);
% Windows Desktop
%root = (['C:/Users/0961mazoror/OneDrive - Marquette University/MATLAB/Ramsey_State_Joint/data/',sub,'/']);
    
blocks = {'A', 'B1', 'C1', 'C2', 'C3', 'C4', 'C5', 'B2', 'E'};

% Create matrices for initial and last ratios
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
        if c == 1
            cond = 'State';
        else
            cond = 'Joint';
        end

        disp(['Evaluating Subject ',sub,' Condition ', cond])
        rootCond = strcat(root,sub,'/',cond,'/');

        % For each block (defined above in blocks)
        for b = 1:size(blocks,2)
            triInitDist = zeros(1,25);
            triLastDist = zeros(1,25);
            
            disp(['    Evaluating Block ',blocks{b}])
            curDirectory = strcat(rootCond,'Block_',blocks{b},'/');
            ListofTrlFiles = dir(strcat(curDirectory, '*.mat'));

            if size(ListofTrlFiles) == 0
                disp(['File for ',cond,' ',blocks{b},' Not Found']);
            else
                
                % For each trial, calculate ratio of each half
                for trials = 1:size(ListofTrlFiles)
                    % Identify and load name of trial file
                    fName = strcat(curDirectory, ListofTrlFiles(trials).name);
                    file = load(fName);
                    trial = file.TargetData;
                    idx_mov = find(trial(:,2)==3);
                    % Calculate half time of samples
                    half = length(idx_mov) / 2;

                    % Calculate total distance traveled per trial
                    x_pos_all = trial(idx_mov,3) * 100;
                    y_pos_all = trial(idx_mov,4) * 100;
                    num_time_samples = length(x_pos_all);
                    distance = 0;
                    first = 0;
                    last = 0;

                    for i = 1:(num_time_samples-1)
                        x_1 = x_pos_all(i);
                        x_2 = x_pos_all(i+1);
                        y_1 = y_pos_all(i);
                        y_2 = y_pos_all(i+1);
                        d = sqrt((x_2-x_1)^2 + (y_2-y_1)^2);
                        distance = distance + d;

                        % Also calculate percentage of each half along distance
                        if i < half
                            first = first + d;
                        else
                            last = last + d;
                        end

                    end
                    
                    % Save ratio for each trial
                    triInitDist(trials) = first / distance;
                    triLastDist(trials) = last / distance;
                end
            end  
            
            % Add each average ratio per subject to array for each block
            if c == 1
                initByBlock_S(s-1, b) = mean(triInitDist);
                lastByBlock_S(s-1, b) = mean(triLastDist);
            else
                initByBlock_J(s-1, b) = mean(triInitDist);
                lastByBlock_J(s-1, b) = mean(triLastDist);
            end 
        end
    end
end
    
% Define color for subject data overlay
color = '#D48799';

% Plot the data a box plot and then overlay with subject data points
% Top tile = State, Bottom tile = Joint
disp('Plotting...')
figure('Units', 'normalized', 'OuterPosition', [0 0 1 1])
tiledlayout(2,1)

nexttile;
boxplot(lastByBlock_S)
hold on;
for b = 1:size(blocks,2)
    plot(ones(1,numel(lastByBlock_S(:,b)))*b, lastByBlock_S(:,b),  'o', 'Color', color)
end
title('State: Percent of Total Distance Traveled in Second Half of Movement Time')
xlabel('Condition')
ylabel('Percent of Total Trial Distance')
xlim([0 10])  
ylim([0 1])
yticks(0:.1:1);
yticklabels({'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'})
xticklabels({'A', 'B1', 'C1', 'C2', 'C3', 'C4', 'C5', 'B2', 'E'})
hold off;

nexttile;
boxplot(lastByBlock_J)
hold on;
for b = 1:size(blocks,2)
    plot(ones(1,numel(lastByBlock_J(:,b)))*b, lastByBlock_J(:,b), 'o', 'Color', color)
end
title('Joint: Percent of Total Distance Traveled in Second Half of Movement Time')
xlabel('Condition')
ylabel('Percent of Total Trial Distance')
xlim([0 10])  
ylim([0 1])
yticks(0:.1:1);
yticklabels({'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'})
xticklabels({'A', 'B1', 'C1', 'C2', 'C3', 'C4', 'C5', 'B2', 'E'})
hold off;

% Save the figures as png and svg
saveas(gcf, 'images/All_Subs/All_Perc_HalfTime.png')
saveas(gcf, 'images/All_Subs/All_Perc_HalfTime.svg')
