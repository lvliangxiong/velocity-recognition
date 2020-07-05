% MAIN_MEDFILT compute velocity with mean and median filter

%% Prepare
close all; clear; clc;
% mass of the boat (g)
m = 0.78;
images_folder = pwd() + "/images/";
data_folder = pwd() + "/data/";
% create the foler if not exists
if (~isfolder(data_folder))
    mkdir(data_folder);
else
    rmdir(data_folder, 's');
    mkdir(data_folder);
end

%% Trace plot
figure;
% import data from 'Points.dat' file
[xpos, ypos, angle] = importfile(fullfile(images_folder, 'Points.dat'));
% time interval is 1/60 s
t_interval = 1/60;
% time axis (begin with 0)
time = t_interval * (0:1:size(xpos) - 1)';
plot(xpos, ypos);
axis([0,800,0,400]);
xlabel('X position (mm)'); ylabel('Y position (mm)'); title('Trace');

trace_fig = gcf;

%% Raw Velocity Computation
% time axis of velocity
time_v = time; time_v(1) = []; time_v(end) = [];
velocity = sqrt((xpos(3:end) - xpos(1:end - 2)).^2 + (ypos(3:end) - ypos(1:end - 2)).^2) / (2 * t_interval);

%% Raw Acceleration Computation
% time axis of acceleration
time_a = time_v; time_a(1) = []; time_a(end) = [];
% central difference
acceleration = (velocity(3:end) - velocity(1:end - 2)) / (2 * t_interval);

%% Raw Angular Velocity Computation
angle_c = correct_angle(angle);
angular_velocity = (angle_c(3:end) - angle_c(1:end - 2)) / (2 * t_interval);

%% Velocity and acceleration plot (including filtering)
figure;
subplot(121);
hold on;

windowSize = 10;
b = (1 / windowSize) * ones(1, windowSize);
a = 1;
% mean filtering
velocity_f = filter(b, a, velocity);
% median filtering
velocity_ff = medfilt1(velocity_f, 20);

plot(time_v, velocity);
plot(time_v, velocity_f, 'LineWidth', 2);
plot(time_v, velocity_ff, 'LineWidth', 2);
xlabel('Time (s)'); ylabel('Velocity (mm/s)'); title('Velocity');
legend('Velocity', 'mean-value-filtering', 'Mean-value-filtering & Median-value-filtering');

subplot(122);
hold on;

acceleration_f = (velocity_f(3:end) - velocity_f(1:end - 2)) / (2 * t_interval);
acceleration_ff = (velocity_ff(3:end) - velocity_ff(1:end - 2)) / (2 * t_interval);

plot(time_a, acceleration);
plot(time_a, acceleration_f);
plot(time_a, acceleration_ff);
xlabel('Time (s)'); ylabel('Acceleration (mm/s^2)'); title('Acceleration');
legend('Acceleration', 'mean-value-filtering', 'Mean-value-filtering & Median-value-filtering');

velocity_acceleration_fig = gcf;

%% Orientation and angular Velocity Plot (including filtering)
figure;
subplot(121);
hold on;

% median filtering
angle_f = filter(b, a, angle_c);
% median filtering
angle_ff = medfilt1(angle_f, 20);

plot(time, angle_c);
plot(time, angle_f, 'LineWidth', 2);
plot(time, angle_ff, 'LineWidth', 2);

xlabel('Time (s)'); ylabel('Orientation (rad)'); title('Orientation');
legend('Orientation of Boat', 'mean-value-filtering', 'Mean-value-filtering & Median-value-filtering');

subplot(122);
hold on;

angular_velocity_f = (angle_f(3:end) - angle_f(1:end - 2)) / (2 * t_interval);
angular_velocity_ff = (angle_ff(3:end) - angle_ff(1:end - 2)) / (2 * t_interval);

plot(time_v, angular_velocity)
plot(time_v, angular_velocity_f)
plot(time_v, angular_velocity_ff);
xlabel('Time (s)'); ylabel('Angular velocity (rad/s)'); title('Angular velocity');
legend('Angular Velocity of Boat', 'mean-value-filtering', 'Mean-value-filtering & Median-value-filtering');

angle_angular_velocity_fig = gcf;

%% Kinetic Energy
figure;
hold on;
% I_com: Rotational Inertia of the boat about an axis through its center of
% mass Kg*m^2
I_com = 1.419896735106977e-05;
% Ek: Kinetic Energy (J)
Ec = m / 1000 * (velocity_ff / 1000).^2/2;
Er = I_com * angular_velocity_ff.^2/2;
Ek = Ec + Er;
plot(time_v, Ec, 'r');
plot(time_v, Er, 'b');
plot(time_v, Ek);
legend('Ec', 'Er', 'Ek');
xlabel('Time (s)'); ylabel('Energy (J)'); title('Kinetic Energy of Boat');
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 6 3];

energy_fig = gcf;

%% Console info
max_velocity = max(velocity_ff);
max_angular_velocity = max(abs(angular_velocity_ff));
max_kinetic_energy = max(Ek);
fprintf('%20s (mm/s)  %20s (rad/s)  %20s (J)\n', "Max Velocity", "Max Angular Velocity", "Max Kinetic Energy");
fprintf('%20s (mm/s)  %20s (rad/s)  %20s (J)\n', num2str(max_velocity), num2str(max_angular_velocity), num2str(max_kinetic_energy));

%% Save
savefig(trace_fig, fullfile(data_folder, "trace.fig"));
savefig(velocity_acceleration_fig, fullfile(data_folder, "velocity & acceleration.fig"));
savefig(angle_angular_velocity_fig, fullfile(data_folder, "angle and angular velocity.fig"));
savefig(energy_fig, fullfile(data_folder, "energy.fig"));
close all;
save(fullfile(data_folder, 'Data'));
clear;