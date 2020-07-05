% MAIN_BUTTER compute velocity with butterworth filter

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

%% FFT transform of plot
figure;
% signal length
L = length(velocity);
NFFT = 2^nextpow2(L);
velocity_fft = fft(velocity, NFFT) / L;
angle_fft = fft(angle_c, NFFT) / L;
% sampling frequency (= 1/time interval)
Fs = 60;
% sampling period = time interval
T = 1 / Fs;
% frequency axis
f = Fs / 2 * (linspace(0, 1, NFFT / 2 + 1))';
subplot(121);
plot(f, 2 * abs(velocity_fft(1:NFFT / 2 + 1)));
xlabel('Frequency (Hz)'); ylabel('Amplitude'); title('Velocity In Frequency Domain');
subplot(122);
plot(f, 2 * abs(angle_fft(1:NFFT / 2 + 1)));
xlabel('Frequency (Hz)'); ylabel('Amplitude'); title('Orientation In Frequency Domain');

fft_fig = gcf;

%% velocity & acceleration plot including Butterworth Filtered results
figure;
fs = Fs / 2;
% design an appropriate Butterworth IIR Filter.
% Wp: passband corner frequency.
% Ws: stopband corner frequency.
Wp = 2 / fs; Ws = 10 / fs;
% calculate the filter order and cut-off frequency
[n, Wn] = buttord(Wp, Ws, 1, 100);
[a, b] = butter(n, Wn);

% filtering velocity
subplot(221);hold on;
velocity_f = filtfilt(a, b, velocity);
plot(time_v, velocity)
plot(time_v, velocity_f);
xlabel('Time (s)'); ylabel('Velocity (mm/s)'); title('Velocity');
legend("Raw velocity", "Velocity after filtering");
% filtering acceleration
subplot(222);hold on;
acceleration_f = (velocity_f(3:end) - velocity_f(1:end - 2)) / (2 * t_interval);
plot(time_a, acceleration);
plot(time_a, acceleration_f);
xlabel('Time (s)'); ylabel('Acceleration (mm/s^2)'); title('Acceleration');
legend("Raw acceleration", "Acceleration after filtering");
% filtering angle
subplot(223);hold on;
angle_f = filtfilt(a, b, angle_c);
plot(time, angle_c);
plot(time, angle_f);
xlabel('Time (s)'); ylabel('Orientation (rad)'); title('Orientation');
legend("Raw orientation", "Orientation after filtering");
% filtering angular velocity
subplot(224);hold on;
angular_velocity_f = (angle_f(3:end) - angle_f(1:end - 2)) / (2 * t_interval);
plot(time_v, angular_velocity);
plot(time_v, angular_velocity_f);
xlabel('Time (s)'); ylabel('Angular velocity (rad/s)'); title('Angular velocity');
legend("Raw angular velocity", "Angular velocity after filtering");

all_in_one_fig = gcf;

%% Kinetic Energy plot
figure;hold on;

% I_com: Rotational Inertia of the boat about an axis through its center of
% mass Kg*m^2
I_com = 1.419896735106977e-05;
% Ek: Kinetic Energy (J)
Ec = m / 1000 * (velocity_f / 1000).^2/2;
Er = I_com * angular_velocity_f.^2/2;
Ek = Ec + Er;
plot(time_v, Ec, 'r');
plot(time_v, Er, 'b');
plot(time_v, Ek);
% hold off;
legend('Ec', 'Er', 'Ek');
xlabel('Time (s)'); ylabel('Energy (J)'); title('Kinetic Energy of Boat');

energy_fig = gcf;

%% Console info
max_velocity = max(velocity_f);
max_angular_velocity = max(abs(angular_velocity_f));
max_kinetic_energy = max(Ek);
fprintf('%20s (mm/s)  %20s (rad/s)  %20s (J)\n', "Max Velocity", "Max Angular Velocity", "Max Kinetic Energy");
fprintf('%20s (mm/s)  %20s (rad/s)  %20s (J)\n', num2str(max_velocity), num2str(max_angular_velocity), num2str(max_kinetic_energy));

%% Save
savefig(trace_fig, fullfile(data_folder, "trace.fig"));
savefig(fft_fig, fullfile(data_folder, "fft.fig"));
savefig(all_in_one_fig, fullfile(data_folder, "velocity.fig"));
savefig(energy_fig, fullfile(data_folder, "energy.fig"));
close all;
save(fullfile(data_folder, 'Data'));
clear;
