% ASEN 3802 Lab 2 Part 1
clear; clc; close all;

%% Plotting Options
part1plotting = 0;
part2plotting = 0;

%% Part 1
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

if part1plotting == 1
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

if part1plotting == 1
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
end

%% Part 2
% Part 1
% Aluminum 25V, Hany, T0 from P1, x loc Th8
% Plot t = 1 vs t = 1000, Al 25 V was index 1 in values
xp2 = thermocoupleLoc(end); % x position of thermocouple 8
Lr = L(end); % overall length of rod

N = 10; % Max number of terms
t = [1 1000]; % Time in seconds for loops
n = 1:1:10; % Array of possible terms

% alpha = k/(rho*cp), formula in intro docs
alpha = k.("Aluminum")/(rho.("Aluminum")*cp.("Aluminum"));
allalpha.("Aluminum") = k.("Aluminum")/(rho.("Aluminum")*cp.("Aluminum"));
allalpha.("Brass") = k.("Brass")/(rho.("Brass")*cp.("Brass"));
allalpha.("Steel") = k.("Steel")/(rho.("Steel")*cp.("Steel"));

% u(x,t) for t = 1 and t = 1000, preallocating
ualt1 = zeros(1,N);
ualt1000 = zeros(1,N);

% Two time values to plug in
t1 = 1;
t2 = 1000;

% Outer loop for both times
for i = 1:N
    % Getting number of n terms
    terms = n(i);
    % Reset summation term to zero at end of each n loop
    fssum1 = 0;
    fssum1000 = 0;
    % Inner loop for various ns
    for ii = 1:terms
        % for both ts
        % For loop n = ii for n values b/c n is number of terms ii is looped value of number of terms
        lambdan = pi*(2*ii-1)/(2*Lr); % Calculating new lambda n for each value, same for t1 and t2
        % Temporary value of summation at given n
        tempbn1 = (8*H(1)*Lr*(-1)^ii)/((2*ii-1)^2*pi^2) * sin(lambdan*xp2) * exp(-lambdan^2*alpha*t1);
        tempbn1000 = (8*H(1)*Lr*(-1)^ii)/((2*ii-1)^2*pi^2) * sin(lambdan*xp2) * exp(-lambdan^2*alpha*t2);
        % Adding temporary sum to get total at end of loop
        fssum1 = fssum1 + tempbn1;
        fssum1000 = fssum1000 + tempbn1000;
    end
    % Adds T0 + Slope*position + summation to n terms
    ualt1(i) = intercepts(1) + H(1)*xp2 + fssum1;
    ualt1000(i) = intercepts(1) + H(1)*xp2 + fssum1000;
end

% Fourier Number Calculation
Fo1 = alpha*t1/L^2;
Fo1000 = alpha*t2/L^2;

% Creating figures to show convergence after n terms
if part2plotting == 1
    figure();
    subplot(2,1,1)
    plot(n,ualt1);
    xlabel("Number of terms (n)");
    ylabel("Temperature at Th8 (\circ C)");
    title("Temperature at Thermocouple 8 vs n Number Modes Approximation for t = 1");
    subplot(2,1,2);
    plot(n,ualt1000);
    xlabel("Number of terms (n)");
    ylabel("Temperature at Th8 (\circ C)");
    title("Temperature at Thermocouple 8 vs n Number Modes Approximation for t = 1000");
end

colors = [
    230, 159,   0; % Orange
    86,  180, 233; % SkyBlue
    0,   158, 115; % BluishGreen
    240, 228,  66; % Yellow
    0,   114, 178; % Blue
    213,  94,   0; % Vermillion
    204, 121, 167; % ReddishPurple
    0,     0,   0  % Black
]/255;

% Apply the colors
colororder(colors);

% Task 2, 3, 4
for i = 1:length(a)
    file = a(i).name;

    raw = data.(file);
    t = raw(:,1);
    Texpt = raw(:,2:9);  % 8 thermocouples

    % material properties
    mat = names(i);
    alpha = k.(mat)/(rho.(mat)*cp.(mat));

    % Model IA: analytical H
    H_IA  = H(i);
    T0_IA = intercepts(i);

    % Model IB: 
    H_IB = slopes(i);

    if part2plotting == 1

    % Model IA plot
    figure(); hold on; grid on;
    for j = 1:8
        Tana = rodTransientModel(thermocoupleLoc(j), t, L, alpha, H_IA, T0_IA, N, H_IA);
        plot(t, Tana, 'LineWidth', 1.2,Color=colors(j,:));
        plot(t, Texpt(:,j), '--', 'LineWidth', 1.0,Color=colors(j,:));
    end
    title("Model IA: ", fullname(i),Interpreter="none");
    xlabel("Time (s)"); ylabel("Temperature (\circ C)");
    legend("TC1_{ana}", "TC1_{exp}", "TC2_{ana}", "TC2_{exp}", "TC3_{ana}", "TC3_{exp}", "TC4_{ana}", "TC4_{exp}",...
        "TC5_{ana}", "TC5_{exp}", "TC6_{ana}", "TC6_{exp}", "TC7_{ana}", "TC7_{exp}", "TC8_{ana}", "TC8_{exp}", location="eastoutside")
    
    % Model IB plot
    figure(); hold on; grid on;
    for j = 1:8
        Tana = rodTransientModel(thermocoupleLoc(j), t, L, alpha, H_IB, T0_IA, N, H_IB);
        plot(t, Tana, 'LineWidth', 1.2,Color=colors(j,:));
        plot(t, Texpt(:,j), '--', 'LineWidth', 1.0,Color=colors(j,:));
    end
    title("Model IB: ", fullname(i),Interpreter="none");
    xlabel("Time (s)"); ylabel("Temperature (\circ C)");
    legend("TC1_{ana}", "TC1_{exp}", "TC2_{ana}", "TC2_{exp}", "TC3_{ana}", "TC3_{exp}", "TC4_{ana}", "TC4_{exp}",...
        "TC5_{ana}", "TC5_{exp}", "TC6_{ana}", "TC6_{exp}", "TC7_{ana}", "TC7_{exp}", "TC8_{ana}", "TC8_{exp}", location="eastoutside")
    
    % Model II plot
    T0 = intercepts_0(i);
    M = slopes_0(i);
    figure(); hold on; grid on;
    for j = 1:8
        Tana = rodTransientModel(thermocoupleLoc(j), t, L, alpha, H_IB, T0, N, (H_IB-M));
        plot(t, Tana, 'LineWidth', 1.2,Color=colors(j,:));
        plot(t, Texpt(:,j), '--', 'LineWidth', 1.0,Color=colors(j,:));
    end
    title("Model II: ", fullname(i),Interpreter="none");
    xlabel("Time (s)"); ylabel("Temperature (\circ C)");
    legend("TC1_{ana}", "TC1_{exp}", "TC2_{ana}", "TC2_{exp}", "TC3_{ana}", "TC3_{exp}", "TC4_{ana}", "TC4_{exp}",...
        "TC5_{ana}", "TC5_{exp}", "TC6_{ana}", "TC6_{exp}", "TC7_{ana}", "TC7_{exp}", "TC8_{ana}", "TC8_{exp}", location="eastoutside");

    end
end

%% Functions:
function T = rodTransientModel(x, t, L, alpha, Huse, T0use, N, bnScale)
% bnScale = coefficient multiplier for bn term

    Tsteady = T0use + Huse.*x;

    T = Tsteady; 

    % Force shapes: x = 1xNx, t = Nt x1
    x = x(:).';      % row
    t = t(:);        % col
    Tsteady = T0use + Huse.*x;  % row

    sumTerm = zeros(length(t), length(x));

    for n = 1:N
        lambda = pi*(2*n-1)/(2*L);
        bn = (8*L*bnScale*(-1)^n) / (pi^2*(2*n-1)^2); 
        sumTerm = sumTerm + bn .* sin(lambda*x) .* exp(-(lambda^2)*alpha*t);
    end

    T = Tsteady + sumTerm;
end

%% Part 3
% Model III, modification of IB
% Model IB plot
alpharange = linspace(0.25,1.75,1001);
for i = 1:length(a)
    rootmeansquares = zeros(length(alpharange),length(thermocoupleLoc)); % 5x8, rows exp num, cols thermocouple num
    file = a(i).name;

    raw = data.(file);
    t = raw(:,1);
    Texpt = raw(:,2:9);  % 8 thermocouples

    % Data Needed for IB
    H_IB = slopes(i);
    T0_IA = intercepts(i);

    % material properties
    mat = names(i);
    alpha = k.(mat)/(rho.(mat)*cp.(mat));
    % Modifying alphas by range from 0.9 to 1.1 of original
    adjalphas.(fullname(i)) = alpharange.*alpha;

    % Calculates rms for different experiments
    for ii = 1:length(alpharange)
        % Choosing 1 alpha per loop
        alpha = adjalphas.(fullname(i))(ii);
        for iii = 1:8
             Tana = rodTransientModel(thermocoupleLoc(iii), t, L, alpha, H_IB, T0_IA, N, H_IB); % Calculated analytical
             Tana = fillmissing(Tana,"previous");
             Texp = Texpt(:,iii); %Experimental
             Texp = fillmissing(Texp,"previous",1);
             rootmeansquares(ii,iii) = rmse(Tana,Texp);
        end
    end
    rmsallexperiments.(fullname(i)) = rootmeansquares; % Putting into structure for storage
    overallrms.(fullname(i)) = zeros(1,length(alpharange));
    % Calculates overall rms of each alpha adjusted by finding rms of the rms of each thermocouple location
    for v = 1:length(alpharange)
        overallrms.(fullname(i))(v) = rms(rmsallexperiments.(fullname(i))(v,:));
    end

    % Calc orig rms value
    [val,idx] = find(alpharange == 1);

    % RMS plot for each experiments, rms vs alpha for all thermocouples
    figure(); hold on;
    plot(adjalphas.(fullname(i)),overallrms.(fullname(i)),lineWidth=2);
    plot(allalpha.(names(i)),overallrms.(fullname(i))(idx),'.',"MarkerSize",20);
    xlabel("Adjusted Alpha");
    ylabel("RMS");
    title("RMS vs Adjusted Alpha for: ", fullname(i), Interpreter="none");
    legend("Adjusted Alpha RMS","Original Alpha")
end

% Finding Correct Adj Alpha from Above
alphaadjusted = zeros(1,length(a));
% Loop through all cases
for i = 1:length(a)
    [val, idx] = min(overallrms.(fullname(i)));
    % idx = find(min(overallrms.(fullname(i)))); % Find index of lowest rms
    alphaadjusted(i) = adjalphas.(fullname(i))(idx);
end

% Plotting Model 3 (Model IB w/ adjusted alphas)

epsT = 0.75;      % deg C tolerance to declare "steady"
holdTime = 60;    % seconds it must stay steady

tss  = NaN(1,length(a));
Foss = NaN(1,length(a));

for i = 1:length(a)
    file = a(i).name;

    raw = data.(file);
    t = raw(:,1);
    Texpt = raw(:,2:9);  % 8 thermocouples

    % Data Needed for IB
    H_IB = slopes(i);
    T0_IA = intercepts(i);
    alpha = alphaadjusted(i);

    % Analytical Temps
    TanaAll = zeros(length(t), 8);
    TssAll = zeros(1,8);

    for j = 1:8
        xj = thermocoupleLoc(j);
        TanaAll(:,j) = rodTransientModel(xj, t, L, alpha, H_IB, T0_IA, N, H_IB);
        TssAll(j)    = T0_IA + H_IB*xj;  % steady-state line at that TC
    end

    % Compute time to steady state
    dev = max(abs(TanaAll - TssAll), [], 2);  % max deviation across TCs at each time

    dt = median(diff(t));
    holdN = max(1, round(holdTime/dt));

    ok = dev <= epsT;

    for k = 1:(length(t) - holdN + 1)
        if all(ok(k:k+holdN-1))
            tss(i) = t(k);
            Foss(i) = alpha * tss(i) / L^2;  % Fourier number at steady state
            break;
        end
    end

    % Model III plot
    figure(); hold on; grid on;
    for j = 1:8
        Tana = rodTransientModel(thermocoupleLoc(j), t, L, alpha, H_IB, T0_IA, N, H_IB);
        plot(t, Tana, 'LineWidth', 1.2,Color=colors(j,:));
        plot(t, Texpt(:,j), '--', 'LineWidth', 1.0,Color=colors(j,:));
    end
    title("Model III (Alpha Adjusted)", fullname(i),Interpreter="none");
    xlabel("Time (s)"); ylabel("Temperature (\circ C)");
    legend("TC1_{ana}", "TC1_{exp}", "TC2_{ana}", "TC2_{exp}", "TC3_{ana}", "TC3_{exp}", "TC4_{ana}", "TC4_{exp}",...
        "TC5_{ana}", "TC5_{exp}", "TC6_{ana}", "TC6_{exp}", "TC7_{ana}", "TC7_{exp}", "TC8_{ana}", "TC8_{exp}", location="eastoutside")
end

% Task 3 

for i=1:length(a)
    file = a(i).name; % Reading in TC8 experimental data
    raw = data.(file);
    t = raw(:,1);
    Texpt = raw(:,9);

    IA = Model_IA_data.(file); % Loading in model data
    IB = Model_IB_data.(file);
    II = Model_II_data.(file);
    III = Model_III_data.(file);

    figure
    hold on 
    grid on
    plot(t,IA, 'LineWidth', 1, Color=colors(1,:))
    plot(t,IB, 'LineWidth', 1, Color=colors(2,:))
    plot(t,II, 'LineWidth', 1, Color=colors(3,:))
    plot(t,III, 'LineWidth', 1, Color=colors(4,:))
    plot(t,Texpt,'k.', 'LineWidth', 0.75)
    plot(t,Texpt + err*ones(length(Texpt)),'b--'); % upper error
    plot(t,Texpt - err*ones(length(Texpt)),'b--'); % lower error
    title('Model Comparison for:', fullname(i), Interpreter="none")
    legend('Model IA', 'Model IB', 'Model II', 'Model III', 'Experimental', 'Error Bars', 'Location','southeast')
    hold off

end