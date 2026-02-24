% ASEN 3802 Lab 2 Part 1
clear; clc; close all;

a=dir('*mA');
volts = zeros(1,length(a));
amps = zeros(1,length(a));
% fullname = zeros(1,length(a));

for i=1:length(a)
    % load(a(i).name)
    data.(a(i).name) = readmatrix(a(i).name);
    % 'material'_'volts'V_'amps'mA
    b = strsplit(a(i).name,'_'); % gives a cell array (b) that is 1x3
    fullname(i) = string(a(i).name); % Full file name 
    names(i) = string(b(1)); % Material name
    % {'material','voltsV','ampsmA'} -- now split by 'V' and 'mA'
    v = strsplit(b{2},'V'); % volts are always in the second portion
    ampval= strsplit(b{3},'mA'); % amps are always in the third portion
    volts(i) = str2num(v{1}); % convert string to number (vector)
    amps(i) = str2num(ampval{1});
end

% Dimensions
con = 2.54/100; % conversion factor for inches to m
d = 1*con; % m
L = (11/8*con) + (0.5*7*con) + (1*con); % in, 1 3/8 in to left, 8 thermo*spacing, 1 in to end

% Thermocouple locations, in m
for i = 1:8
    thermocoupleLoc(i) = (11/8*con) + (0.5*(i-1)*con);
end
span = [0,thermocoupleLoc,L];

% Extracting Steady State Temperatures across L, fitting line
for i = 1:length(a)
    % Temp data
    temp = data.(a(i).name);
    % Cleaning data for steady state temperature
    temps = temp(:,2:9);
    temps = fillmissing(temps,"previous",1);
    % Steady state values filled from end of data table
    Tss.(a(i).name) = temps(end,:);
    % Getting slope and intercept of fitting steady state
    p = polyfit(thermocoupleLoc,Tss.(a(i).name),1);
    slopes(i) = p(1); % Puts slopes of all into array
    intercepts(i) = p(2); % Put intercept of all into array for plotting
end

% Calculating Steady state for all
rho.("Aluminum") = 2810; rho.("Brass") = 8500; rho.("Steel") = 8000;
cp.("Aluminum") = 960; cp.("Brass") = 380; cp.("Steel") = 500;
k.("Aluminum") = 130; k.("Brass") = 115; k.("Steel") = 16.2;
A = pi/4 * d^2; % Cross dimensional area same for all bars

% Steady State Distribution
x = linspace(0,L,100); % X coords 0 to length of bar
for i = 1:length(a)
    Qdot(i) = volts(i) * amps(i)/1000; % P = IV converted to standard units
    H(i) = Qdot(i)/(k.(names(i))*A);
    % Steady state heat distribution function
    vx.(fullname(i)) = intercepts(i) + H(i).*x; % creating analytic solution for plotting
end

% Plotting
for i = 1:length(a)
    figure(i); hold on;
    err = 2; % Degrees celcius 
    % Scatter of thermocouple steady state data at locations
    scatter(thermocoupleLoc,Tss.(a(i).name),'k');
    % Extrapolated fitted steady state solution
    plot(span,intercepts(i) + span*slopes(i),"b"); % Polyfit line
    plot(span,(intercepts(i) + span*slopes(i)) + err,'b--'); % upper error
    plot(span,(intercepts(i) + span*slopes(i)) - err,'b--'); % lower error
    % Analytical Steady State solution
    plot(x,vx.(fullname(i)),"r");
    plot(x,vx.(fullname(i)) + err,'r--'); % Upper error
    plot(x,vx.(fullname(i)) - err,'r--'); % lower error
    % Scale x axis for beginning to end of bar
    xlim([0 L]);
    xlabel("Position Along Bar (m)");
    ylabel("Temperature (\circ C)");
    title("Experimental vs Analytical Steady State Temperatures Along Bar,", a(i).name, Interpreter="none")
    legend("Thermocouples","Experimental Fit","Experimental Error Bars","","Analytical","Analytical Error Bars","",Location="northwest");
end

% Task 2 

% Extracting Initial Temperatures, fitting line
for i = 1:length(a)
    % Temp data
    temp = data.(a(i).name);
    % Cleaning data for steady state temperature
    temps = temp(1,2:9);
    temps = fillmissing(temps,"previous",1);
    Initial.(a(i).name) = temps(end,:); %Initial state 
    % Getting slope and intercept of fitting steady state
    p = polyfit(thermocoupleLoc,Initial.(a(i).name),1);
    slopes_0(i) = p(1);
    intercepts_0(i) = p(2);
end

% Plotting Initial Conditions
for i = 1:length(a)
    figure(); hold on;
    err = 2;
    % Scatter of thermocouple steady state data at locations
    scatter(thermocoupleLoc,Initial.(a(i).name), "k");
    % Extrapolated fitted steady state solution
    plot(span,intercepts_0(i) + span*slopes_0(i),"r"); % Polyfit line
    plot(span,(intercepts_0(i) + span*slopes_0(i)) + err,'b--'); % upper error
    plot(span,(intercepts_0(i) + span*slopes_0(i)) - err,'b--'); % lower error
    % Scale x axis for beginning to end of bar
    xlim([0 L]);
    ylim([14,22]);
    xlabel("Position Along Bar (m)");
    ylabel("Initial Temperatures (\circ C)");
    title("Initial Conditions Across the Bar,", a(i).name, Interpreter="none")
    legend("Thermocoupes","Experimental Fit", "Error Bar");
end