% Edited by Rocky Mazorow
% 5/3/2022

function [DIj_all, DIe_all, DIj_init, DIe_init, DIj_last, DIe_last] = DIalgorithmByTime (TargetData, ExamineeData)
% algorithm to connvert data from endpoinnt coordinates into joint angle
% coordinnates.
% outputs DI values for joint encoding (DIj) and endpoint encoding (DIe).
% input: some portionn of the TARGETDATA matrix
%
% R Scheidt & R Rayes
% 3/15/22

global Trial

Trial.ExamineeData=ExamineeData;
Trial.Home = [-0.050000000000000,0.600000000000000];
shift = [0.2 0];
%shift = [0 0];

TargetState=TargetData(:,2);
XPos = TargetData(:,3);
YPos = TargetData(:,4);

ValidSamples=find(TargetState==3);

len = size (ValidSamples);
ras_S = zeros(len(1),1);
ras_E = zeros(len(1),1);

for rasi = 1:len(1)
    [ras_S(rasi), ras_E(rasi),  ~, ~, ~, ~]=Vis2Joint(XPos(ValidSamples(rasi))+shift(1),YPos(ValidSamples(rasi))+shift(2));
end

DIj_all = DI(ras_S,ras_E,200);
DIe_all = DI(XPos(ValidSamples),YPos(ValidSamples),200);

ras_len=length(ValidSamples);
ras_init=floor(ras_len/2);

DIj_init = DI(ras_S(1:ras_init),ras_E(1:ras_init),200);
DIe_init = DI(XPos(ValidSamples(1:ras_init)),YPos(ValidSamples(1:ras_init)),200);

DIj_last = DI(ras_S(ras_init+1:end),ras_E(ras_init+1:end),200);
DIe_last = DI(XPos(ValidSamples(ras_init+1:end)),YPos(ValidSamples(ras_init+1:end)),200);
