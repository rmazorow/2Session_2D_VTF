% function [ThetaS, ThetaE, tctr_x_p, tctr_y_p, tctr_x_n, tctr_y_n]= Vis2Joint(x,y)
function [ThetaS, ThetaE, tctr_x_n, tctr_y_n, tctr_x_p, tctr_y_p]= Vis2Joint(x,y) % empirically, the +/- order needed to be changed in order to have the vibrations "make sense" according to how we define positive shoulder and elbow angle deviations 2021.08.11
% INPUT: x,y (current position) [0.02:0.182] 
% OUTPUT: tctr_x_p tctr_y_p tctr_x_n tctr_y_n [1:102]
global Trial Error_ref_X Error_ref_Y
global tctr_x_p_old tctr_y_p_old tctr_x_n_old tctr_y_n_old


% f: y = m*+offset
    offset = 30; 
    samples_halfTaskSpace = 170; %for half of the grid; units [bitvals] was 91
    w_halfTaskSpace = 0.36; % from the center to frame [rad]
    delta_ang = w_halfTaskSpace;  % 0.055 [m];
    delta_vib = samples_halfTaskSpace;  % [bitvals]
    m = delta_vib/delta_ang;  % [bitvals] / [radian]

% assume joint space encoding
   [Home_ThetaS,Home_ThetaE]=Inverse_Kinematics(Trial.Home(1),Trial.Home(2)); % Joint angles with hand at the home target
   [ThetaS,ThetaE]=Inverse_Kinematics(x,y); % joint-angles of the subject from the hand position [radians]

   ThetaS = ThetaS-Home_ThetaS; %joint angles relative to the home position
   ThetaE = ThetaE-Home_ThetaE;
    
   epsilon_angle = 0.005; % redians = 0.287 degrees
    %//////////////////////////////////
    %% ***** Task Space *****
    % Hand on the Home position: 
%     if (sqrt(pow(x,2)+pow(y,2))<(0.005)) %turn off the tactors (leave this in endpoint coords)
%         tctr_x_p = 0; % shoulder_+
%         tctr_y_p = 0; % elbow_+
%         tctr_x_n = 0; % shoulder_-
%         tctr_y_n = 0; % elbow_-
%     elseif (ThetaS*ThetaE > 0) %1st-3rd quadrant
%         if (ThetaS>epsilon_angle) %1st quadrant
%             tctr_x_p = floor(m*ThetaS+offset);
%             tctr_y_p = floor(m*ThetaE+offset);
%             tctr_x_n = 0;
%             tctr_y_n = 0;
%         elseif (ThetaS<-epsilon_angle) %3rd quadrant
%             tctr_x_p = 0;
%             tctr_y_p = 0;
%             tctr_x_n = floor(-m*ThetaS+offset);
%             tctr_y_n = floor(-m*ThetaE+offset);
%         else
%             tctr_x_p = 0;
%             tctr_y_p = 0;
%             tctr_x_n = 0;
%             tctr_y_n = 0;
%         end
%     elseif (ThetaS*ThetaE  < 0)
%         if (ThetaS>epsilon_angle) %4th quadrant
%             tctr_x_p = floor(m*ThetaS+offset);
%             tctr_y_p = 0;
%             tctr_x_n = 0;
%             tctr_y_n = floor(-m*ThetaE+offset);
%         else %2nd quadrant
%             tctr_x_p = 0;
%             tctr_y_p = floor(m*ThetaE+offset);
%             tctr_x_n = floor(-m*ThetaS+offset);
%             tctr_y_n = 0;
%         end
%     end
        if (ThetaS>epsilon_angle)   
            tctr_x_p = floor(m*ThetaS+offset);
            tctr_x_n = 0;
        elseif(ThetaS<-epsilon_angle) 
            tctr_x_p = 0;
            tctr_x_n = floor(-m*ThetaS+offset);
        else
            tctr_x_p = 0;
            tctr_x_n = 0;
        end
        if (ThetaE>epsilon_angle)   
            tctr_y_p = floor(m*ThetaE+offset);
            tctr_y_n = 0;
        elseif(ThetaE<-epsilon_angle) 
            tctr_y_p = 0;
            tctr_y_n = floor(-m*ThetaE+offset);
        else
            tctr_y_p = 0;
            tctr_y_n = 0;
        end
 
    % ////////////////////////////////////
    % *** Saturation ***
    if tctr_x_p>(samples_halfTaskSpace+offset)
       tctr_x_p=(samples_halfTaskSpace+offset);
    end
    if tctr_x_n>(samples_halfTaskSpace+offset)
       tctr_x_n=(samples_halfTaskSpace+offset);
    end
    if tctr_y_p>(samples_halfTaskSpace+offset)
       tctr_y_p=(samples_halfTaskSpace+offset);
    end
    if tctr_y_n>(samples_halfTaskSpace+offset)
       tctr_y_n=(samples_halfTaskSpace+offset);
    end
    
end

%------------------------- INVERSE KINEMATICS EQ --------------------------
function[ThetaS,ThetaE]=Inverse_Kinematics(x,y)
global Trial

Lu = Trial.ExamineeData.Antropometric(1); %Length upper arm [m]
Lf = Trial.ExamineeData.Antropometric(2); %Length forearm + hand [m]

% re-frame hand position in human-shoulder-centered coordinates / RAS & RR  06/03/21
x = -(x-Trial.ExamineeData.RobotFrameMarker(1)) - Trial.ExamineeData.ShoulderLocation(1); % ShoulderLocation (in human reference frame) is to the right of the marker, so subtract
y = -(y-Trial.ExamineeData.RobotFrameMarker(2)) + Trial.ExamineeData.ShoulderLocation(2); % ShoulderLocation (in human reference frame) is behind the marker, so add

D = sqrt(x^2+y^2); %distance between human shoulder and the hand
ThetaQ = acos((D^2+Lu^2-Lf^2)/(2*Lu*D)); %angle shoulder/hand
ThetaS = (atan2(y,x)-ThetaQ);        %angle shoulder
ThetaE = pi - acos((D^2-Lu^2-Lf^2)/(-2*Lu*Lf));   %relative angle elbow

end
