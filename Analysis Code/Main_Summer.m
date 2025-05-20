clc
clear

% Fill in location on computer of subject's data
disp('Select folder containing your data');
myRootDir = uigetdir('title', 'Select folder containing your data');

disp('Select .mat file containing sub block order');
orderFile = uigetfile('*.mat', 'Select .mat file containing sub block order');

% Will save within the data folder you select first
name = 'SubjectInfo_Summer_v3.xlsm';

% for all 15 subjects...
for sub = 2:16
    %Fill in subject ID
    if sub < 10
        subID = ['S0',num2str(sub)];
    else
        subID = ['S',num2str(sub)];
    end
    
    %subID = 'S02';

    blocks = {'A', 'B1', 'C1', 'C2', 'C3' ,'C4', 'C5', 'B2', 'E', 'F'};
    %blocks = {'E', 'F'};
    
    % Import SubOrder File
    load([myRootDir, '/', orderFile]);
    SubOrder = table2array(SubOrder);

    % for each encoding scheme...
    for c = 1:2
        if c == 1
            cond = 'State';
        else
            cond = 'Joint';
        end

        % Processes data to be written to file
        disp('Consolidating Data...');
        disp(['   ', subID, ' ', cond]);
        [TrialStruct, sham] = DataConsol_Summer(subID,cond,blocks,myRootDir,SubOrder);
        disp('   Data Consolidated');

        % Prepares data to be written to file
        disp(['   Writing Data to ',name,'...']);
        filename = [myRootDir,'/',name];
        tInfo = struct2table(TrialStruct);

        % Signed average error to target
%         avg_s_x_error = varfun(@mean,tInfo,'InputVariables','signed_x_error','GroupingVariables','block');
%         avg_s_y_error = varfun(@mean,tInfo,'InputVariables','signed_y_error','GroupingVariables','block');
%         avg_s_t_error = varfun(@mean,tInfo,'InputVariables','signed_total_error','GroupingVariables','block');
%         avg_s_error = join(avg_s_x_error, join(avg_s_y_error, avg_s_t_error));

        % Unsigned average error to target
%         avg_u_x_error = varfun(@mean,tInfo,'InputVariables','unsigned_x_error','GroupingVariables','block');
%         avg_u_y_error = varfun(@mean,tInfo,'InputVariables','unsigned_y_error','GroupingVariables','block');
        avg_u_t_error = varfun(@mean,tInfo,'InputVariables','unsigned_total_error','GroupingVariables','block');
%         avg_u_error = join(avg_u_x_error, join(avg_u_y_error, avg_u_t_error));

        % Average speed to target
%         avg_x_speed = varfun(@mean,tInfo,'InputVariables','speed_x','GroupingVariables','block');
%         avg_y_speed = varfun(@mean,tInfo,'InputVariables','speed_y','GroupingVariables','block');
        avg_t_speed = varfun(@mean,tInfo,'InputVariables','speed_total','GroupingVariables','block');
%         avg_speed = join(avg_x_speed, join(avg_y_speed, avg_t_speed));

        % Average pathlength to target
        avg_path = varfun(@mean,tInfo,'InputVariables','total_distance','GroupingVariables','block');

        % Average trial time to target
        avg_time = varfun(@mean,tInfo,'InputVariables','trial_time','GroupingVariables','block');

        % Average precision to target
%         x_precision = varfun(@std,tInfo,'InputVariables','signed_x_error','GroupingVariables','block');
%         y_precision = varfun(@std,tInfo,'InputVariables','signed_y_error','GroupingVariables','block');
%         t_precision = varfun(@std,tInfo,'InputVariables','signed_total_error','GroupingVariables','block');
%         precision = join(x_precision, join(y_precision, t_precision));
%         unsigned_dist_error = varfun(@mean,tInfo,'InputVariables','unsigned_dist_error','GroupingVariables','block');
%         precision = join(precision, unsigned_dist_error);

        % Merge signed error, unsigned error, average speed, and precision
%         avg_error = join(avg_s_error, avg_u_error);
%         avg_effic = join(avg_speed, precision);
%         avg_data = join(avg_error, avg_effic);

        % Merge unsigned error, average speed, and average trial time
        avg_data = join(avg_u_t_error,avg_t_speed);
        avg_data = join(avg_data, avg_path);
        avg_data = join(avg_data, avg_time);

        if sham == true
            size = length(blocks);
        else 
            size = length(blocks)-1;
        end
        
        order = zeros(size,1);
        for ord = 1:size
            index = find(string(avg_data.block) == blocks(ord));
            order(index) = ord;
        end

        avg_data = [array2table(order,'VariableNames',{'order'}), avg_data];
        avg_data = sortrows(avg_data,'order');

        tInfo = sortrows(tInfo,'trial');

        writetable(tInfo,filename,'Sheet',[subID,'_',cond],'Range','B:X')
        writetable(avg_data,filename,'Sheet',[subID,'_',cond],'Range','AA:AP');
        disp('   Data Written');
    end
end