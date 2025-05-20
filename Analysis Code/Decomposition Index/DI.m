function DIvalue = DI(axis1,axis2,SampleRate)

cf_pos = 4;  % 4 Hz cf ends up making the data look nice when plotted..
[b,a] = butter(2, cf_pos/(SampleRate/2));
p1 = filtfilt(b,a,axis1);
p2 = filtfilt(b,a,axis2);

% Compute velocity;
v1 = SampleRate*filtfilt(b,a,diff(p1)); % Data from the target are sampled at 200 Hz
v1 = filtfilt(b,a,v1);
v2 = SampleRate*filtfilt(b,a,diff(p2));
v2 = filtfilt(b,a,v2);
v = sqrt(v1.^2+v2.^2);

v1_max = max(abs(v1));
v2_max = max(abs(v2));
delta_1 = sum(abs(diff(p1)));
delta_2 = sum(abs(diff(p2)));

part1 = (abs(diff(p1)/delta_1).*(v2_max-abs(v2))/v2_max);
part2 = (abs(diff(p2)/delta_2).*(v1_max-abs(v1))/v1_max);

DIvalue = 0.5*sum(part1+part2);
