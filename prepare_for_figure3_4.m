% prepare_for_figur3_4

% run "gridtask_SRIR" and save data for Figures 3 and 4

rand('twister',7093351); % set the "rand" function
a_sum_set = [0.75 1 1.25]; % set for the sum of the learning rates for positive and negative TD-RPEs
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6]; % set for the proportion of the learning rate from positive TD-RPEs within the sum
a_SRfeatures = 0.05; % learning rate for SR features
b_set = [5 10]; % set for the inverse temperature
g_set = [0.7 0.8]; % set for the time discount factor
dur_ini = 500; % duration (time steps) for the initial no-reward epoch
dur_epoch = 500; % duration for each rewarded epoch
num_epoch = 9; % number of the rewarded epochs
R_prob = 0.6; % probability with which reward was placed at the special reward candidate state
num_sim = 100; % number of simulations
for k_g = 1:length(g_set)
    for k_b = 1:length(b_set)
        for k_a_sum = 1:length(a_sum_set)
            totalRset{k_g}{k_b}{k_a_sum} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
            if k_a_sum == length(a_sum_set) % if a_sum = 1.25, (1/6 5/6) was omitted because one of the learning rates becomes larger than 1
                range_k_IR_SR = [2:1:length(a_posiprop_set)-1];
            else
                range_k_IR_SR = [1:length(a_posiprop_set)];
            end
            for k_IR = range_k_IR_SR
                for k_SR = range_k_IR_SR
                    a_IR = a_sum_set(k_a_sum)*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)]; % learning rates for the IR system
                    a_SR = [a_sum_set(k_a_sum)*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures]; % learning rates for the SR system
                    for k_sim = 1:num_sim
                        fprintf('%d-%d-%d-%d-%d-%d\n',k_g,k_b,k_a_sum,k_IR,k_SR,k_sim);
                        Out = gridtask_SRIR(a_SR,a_IR,b_set(k_b),g_set(k_g),dur_ini,dur_epoch,num_epoch,R_prob);
                        totalRset{k_g}{k_b}{k_a_sum}(k_IR,k_SR,k_sim) = Out.totalR;
                    end
                end
            end
        end
    end
end
save data_gridtask_SRIR totalRset
