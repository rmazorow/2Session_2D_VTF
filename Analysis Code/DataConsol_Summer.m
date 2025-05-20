function [TrialStruct, sham] = DataConsol_Summer(subID,cond,blocks,myRootDir, SubOrder)
%% DataConsolidation.m
% This function takes all subject's .mat files and consolidates them
%
% Variables:
%   subID       String of the subject
%   cond        End point test or joint angle test
%   blocks      Order of blocks for subject
%   myRootDir   Root directory of subject's data files
% 
% Output:
%   Void       Creates a file of subject's consolidated data

% trial branch leaves each NaN'ed out
TrialStruct(1:length(blocks)*25) = struct(...
    'trial',NaN,... 
    'block',NaN,...
    'trial_bNum',NaN,...
    'target_x_pos',NaN,...
    'target_y_pos',NaN,...
    'start_x_pos',NaN,...
    'start_y_pos',NaN,...
    'end_x_pos',NaN,...
    'end_y_pos',NaN,...
    'num_time_samples',NaN,...
    'trial_time',NaN,...
    'total_distance',NaN,...
    'optimal_distance',NaN,...
    'speed_x', NaN,...
    'speed_y', NaN,...
    'speed_total', NaN,...
    'signed_x_error',NaN,...
    'signed_y_error',NaN,...
    'signed_total_error',NaN,...
    'unsigned_x_error',NaN,...
    'unsigned_y_error',NaN,...
    'unsigned_total_error',NaN,...
    'unsigned_dist_error',NaN);

row = 1;
oldTrial = 0;
oldTimeStamp = 0;
sham = true;

for i = 1:length(blocks) %for each block
    % Counting number of files for subject
    block = blocks{i};
    disp(['      ', block])
    
    % Identify row of subOrder to grab correct targets
    index = find((SubOrder(:,1) == subID) & (SubOrder(:,2) == cond), 1);
    ord = find((SubOrder(index,:) == block),1);
    if isempty(ord)
        disp(['Block ', block, ' does not exist for ', subID, ' ', cond]);
        TrialStruct = TrialStruct(1:length(TrialStruct)-25);
        sham = false;
        continue;
    else
        idx = ord - 2;
    end
    
    curSubjModeDir = ['/',subID,'/',cond,'/Block_',block,'/']; %current directory
    %disp([myRootDir,curSubjModeDir])
    listOfFiles = dir([myRootDir,curSubjModeDir]); %opens each block folder
    listOfFiles = listOfFiles(~[listOfFiles.isdir]); %removes folders from consideration 
    numOfFiles = size(listOfFiles);
    
    if numOfFiles == 0
        disp('EMPTY TRIAL FOLDER') %folder is empty
    else
        for n = 1:numOfFiles %for each of the files
             strOfCurFileName = listOfFiles(n).name; % find curent trial file name
%             nameCheck = strfind(strOfCurFileName,'trial'); %checks if it is a trial
            
%             if isempty(nameCheck)
%                 disp('    NOT A TRIAL')
%                 disp(['      ', strOfCurFileName])
%             else

            % If has trial in filename then run
            if contains(strOfCurFileName, 'trial')
                trlData = load([myRootDir, curSubjModeDir, strOfCurFileName]);  %loads trial data
                underscoreLoc = strfind(strOfCurFileName,'_');                  %find the underscore in the file name
                trialNum = str2double(strOfCurFileName(7:underscoreLoc(2)-1));  %determine the trial number
                timeLoc = strfind(strOfCurFileName,'T');                  %find T in the file name
                timeStamp = str2double(strOfCurFileName(timeLoc+1:end-4)); %determine the trial number
                
                % if there are two runs of the same trial, keep the data
                % from the later time stamp
                %disp(['old: ', num2str(oldTrial), ', new: ', num2str(trialNum)]);
                if trialNum == oldTrial
                    disp(['     Duplicate trial: ', num2str(trialNum)]);
                    
                    if (timeStamp > oldTimeStamp)
                        row = row-1;
                    else 
                        continue;
                    end
                end
                
                trial = trlData.TargetData; %reduce trial call out

                targetDir = ['/',subID,'/']; %current directory
                list = dir([myRootDir,targetDir]); %opens each block folder
                list = list(~[list.isdir]); %removes folders from consideration 
                trialInfo = load([myRootDir, targetDir, list(1).name]);
                %disp([i, ' ', trialNum])
                target_row = trialNum + ((idx-1)*25);

                % Write to TrialStruct
                idx_mov = find(trial(:,2)==3); %establish mode to be inspected (mode 3)
                % Shift for right handed subjects
                shift = 0.20;

                TrialStruct(row).trial = target_row;
                TrialStruct(row).block = block;
                TrialStruct(row).trial_bNum = trialNum;
                TrialStruct(row).target_x_pos = trialInfo.ActivePosturePoints(target_row, 1) * 100;
                TrialStruct(row).target_y_pos = trialInfo.ActivePosturePoints(target_row, 2) * 100;
                TrialStruct(row).start_x_pos = (trial(idx_mov(1),3) + shift)* 100;
                TrialStruct(row).start_y_pos = trial(idx_mov(1),4) * 100;
                TrialStruct(row).end_x_pos = (trial(idx_mov(end),3)+ shift) * 100;
                TrialStruct(row).end_y_pos = trial(idx_mov(end),4) * 100;

                x_pos_all = (trial(idx_mov,3)+ shift) * 100;
                y_pos_all = trial(idx_mov,4) * 100;

                TrialStruct(row).num_time_samples = length(x_pos_all);

                time = 0;
                for t = 1:TrialStruct(row).num_time_samples
                    time = time+0.005;
                end

                TrialStruct(row).trial_time = time;

                %Calculate total distance traveled per trial
                distance = 0;
                for d = 1:(TrialStruct(row).num_time_samples-1)
                    x_1 = x_pos_all(d);
                    x_2 = x_pos_all(d+1);
                    y_1 = y_pos_all(d);
                    y_2 = y_pos_all(d+1);
                    dist = sqrt((x_2-x_1)^2 + (y_2-y_1)^2);
                    distance = distance + dist;
                end
                TrialStruct(row).total_distance = distance;

                %Calculate speed from start to target
                speed = distance/time;

                %Calculate optimal distance between start location and
                %target
                x_1 = TrialStruct(row).start_x_pos;
                x_2 = TrialStruct(row).target_x_pos;
                y_1 = TrialStruct(row).start_y_pos;
                y_2 = TrialStruct(row).target_y_pos;
                opt = sqrt((x_2-x_1)^2 + (y_2-y_1)^2);
                TrialStruct(row).optimal_distance = opt;

                %calculate difference between actual and optimal
                TrialStruct(row).unsigned_dist_error = abs(distance - opt);

                %calculate x and y error
                t_x = TrialStruct(row).target_x_pos;
                t_y = TrialStruct(row).target_y_pos;
                x = TrialStruct(row).end_x_pos;
                y = TrialStruct(row).end_y_pos;
                TrialStruct(row).signed_x_error = x-t_x;
                TrialStruct(row).signed_y_error = y-t_y;
                TrialStruct(row).signed_total_error = sqrt((TrialStruct(row).signed_x_error).^2 +(TrialStruct(row).signed_y_error).^2);
                TrialStruct(row).unsigned_x_error = abs(x-t_x);
                TrialStruct(row).unsigned_y_error = abs(y-t_y);
                TrialStruct(row).unsigned_total_error = sqrt((TrialStruct(row).unsigned_x_error).^2 +(TrialStruct(row).unsigned_y_error).^2);

                %calculate x and y velocity
                V_x = zeros(TrialStruct(row).num_time_samples,1);
                V_y = zeros(TrialStruct(row).num_time_samples,1);
                Speed = zeros(TrialStruct(row).num_time_samples,1);
                for r = 1:TrialStruct(row).num_time_samples-1
                    V_x(r) = (x_pos_all(r+1,1)-x_pos_all(r,1))/0.005;
                    V_y(r) = (y_pos_all(r+1,1)-y_pos_all(r,1))/0.005;
                    Speed(r) = sqrt((V_x(r)).^2+(V_y(r)).^2);
                end

                TrialStruct(row).speed_x = mean(abs(V_x));
                TrialStruct(row).speed_y = mean(abs(V_y));
                TrialStruct(row).speed_total = mean(Speed);

                % Store old trial and time stamp for next
                % comparison
                oldTrial = trialNum;
                oldTimeStamp = timeStamp;
                row = row+1;
            end    
        end
    end
end

saveDir = [myRootDir,'/ConsDataFile'];
if ~exist(saveDir, 'dir')
   mkdir(saveDir);
end
save([saveDir,'/',subID,'_',cond,'_SubDat.mat']); %save subdata to my folder 