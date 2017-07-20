clear all
close all

addpath('Classes')
addpath('functions')


%% Make input
% but this is not used, as other input from the experiments is loaded
baseline = 0;           % pA
amplitude = 1000;       % pA
ron = 20/3000;          % kHz
roff = 40/3000;         % kHz
mean_firing_rate = (0.5)/1000; % kHz
sampling_rate = 5;     % kHz
dt = 1/sampling_rate; 
duration = 20000;       % ms
[input_current, input_theory, hidden_state] = make_input_experiments(baseline, amplitude, ron, roff, mean_firing_rate, sampling_rate, duration);

%% Do experiment
load example_data
% NB overwrites hidden state, input_theory and input_current for the ones
% used in the example experiment

%% Find spikes 
threshold = 0;
[spiketimes, spikeindices] = findspikes(dt, membrane_potential, threshold);

%% Make spike train
spiketrain = zeros(size(hidden_state));
spiketrain(spikeindices) = 1;

%% Analyze
Analyzed_Data = analyze_exp(ron, roff, hidden_state, input_theory', dt, spiketrain);

%% Run Bayesian neuron for reference

% Make bayesian neuron
bayvars=BayesianNeuronVars;
bayvars.ron=ron; 
bayvars.roff=roff;
bayvars.theta = 0;
bayvars.eta = 6;
bay = OriginalBayesian(bayvars);

% make the same input structure as before
input_bayes             = Input;
input_bayes.dt          = dt;
input_bayes.input       = input_theory;
input_bayes.T           = length(input_theory)*dt;

% run
baysolve = Solver(bay, input_bayes, @Solver.eulerreset);
baysolve.initialize([log(bayvars.ron/bayvars.roff) log(bayvars.ron/bayvars.roff)]);
baysolve.solve;

% analyze
spiketrain_bn = zeros(size(hidden_state));
spiketrain_bn(round(baysolve.spiketimes/dt)) = 1;
Analyzed_Data_BN = analyze_exp(ron, roff, hidden_state, input_theory, dt, spiketrain_bn);

%% Display results
disp(['Transferred fraction of information experiments: ' num2str(Analyzed_Data.MI/Analyzed_Data.MI_i)])
disp(['Firing rate experiments: ' num2str(sum(spiketrain)/(duration/1000)) ' Hz'])
disp(['Transferred fraction of information Bayesian Neuron: ' num2str(Analyzed_Data_BN.MI/Analyzed_Data_BN.MI_i)])
disp(['Firing rate Bayesian Neuron: ' num2str(sum(spiketrain_bn)/(duration/1000)) ' Hz'])

%% Plot
time = (1:length(hidden_state))*dt;
figure
subplot(3,1,1)
plot(time,hidden_state)
hold all
plot(time,Analyzed_Data.xhat_i)
plot(time,Analyzed_Data.xhatspikes)
plot(time,Analyzed_Data_BN.xhatspikes)
legend('true', 'estimated from input','estimated from spikes', 'estimated from spikes BN')
ylim([-0.1, 1.1])
title('Hidden state')
xlim([0 input_bayes.T])

subplot(3,1,2)
plot(time,input_current)
title('Input current')
ylabel('current (pA)')
xlim([0 input_bayes.T])

subplot(3,1,3)
plot(time,membrane_potential)
title('Membrane potential')
ylabel('V_m (mV)')
xlabel('time (ms)')
hold all
plot(spiketimes, 100*ones(size(spiketimes)), 'or')
plot(baysolve.spiketimes, 120*ones(size(baysolve.spiketimes)), 'ob')
legend('membrane potential', 'experimental spikes','spikes Bayesian neuron')
xlim([0 input_bayes.T])
ylim([-125 125])