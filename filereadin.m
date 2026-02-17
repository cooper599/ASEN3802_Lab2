% ASEN 3802 Lab 2 Part 1
clear; clc; close all;

a=dir('*mA');
volts = zeros(1,length(a));
amps = zeros(1,length(a));

for i=1:length(a)
    % load(a(i).name)
    data.(a(i).name) = readmatrix(a(i).name);
    % 'material'_'volts'V_'amps'mA
    b = strsplit(a(i).name,'_'); % gives a cell array (b) that is 1x3
    % {'material','voltsV','ampsmA'} -- now split by 'V' and 'mA'
    v = strsplit(b{2},'V'); % volts are always in the second portion
    ampval= strsplit(b{3},'mA'); % amps are always in the third portion
    volts(i) = str2num(v{1}); % convert string to number (vector)
    amps(i) = str2num(ampval{1});
end

% Dimensions
d = 1; % in
L = 11/8 + 0.5*7 + 1; % in, 1 3/8 in to left, 8 thermo*spacing, 1 in to end

% Thermocouple locations
for i = 1:8
    thermocoupleLoc(i) = 11/8 + 0.5*(i-1);
end
span = [0,thermocoupleLoc,L];

% Extracting Steady State Temperatures across L, fitting line
for i = 1:length(a)
    % Temp data
    temp = data.(a(i).name);
    % Cleaning data for steady state temperature
    temps = temp(:,2:9);
    temps = fillmissing(temps,"previous",1);
    Tss.(a(i).name) = temps(end,:);
    % Getting slope and intercept of fitting steady state
    p = polyfit(thermocoupleLoc,Tss.(a(i).name),1);
    slopes(i) = p(1);
    intercepts(i) = p(2);
end

% Calculating Steady state for all
rho.("Aluminum") = 2810;
rho.("Brass") = 8500;
rho.("Steel") = 8000;

for i = 1:length(a)
    
end

% Plotting
for i = 1:length(a)
    figure(i); hold on;
    % Scatter of thermocouple steady state data at locations
    scatter(thermocoupleLoc,Tss.(a(i).name));
    % Extrapolated fitted steady state solution
    plot(span,intercepts(i) + span*slopes(i)); % Polyfit line
    % Analytical Steady State solution
    % plot(x,y)
    % Scale x axis for beginning to end of bar
    xlim([0 L]);
    xlabel("Position Along Bar (in)");
    ylabel("Temperature (\circ C)");
    title("Experimental vs Analytical Steady State Temperatures Along Bar,",a(i).name)
end