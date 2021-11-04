% prepare_for_figure6A

% run "gridtask_SRSR" and save data for Figure 6

rand('twister',7093353);
a_sum_set = [0.75 1 1.25];
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
a_SRfeatures = 0.05;
b_set = [5 10];
g_set = [0.7 0.8];
dur_ini = 500;
dur_epoch = 500;
num_epoch = 9;
R_prob = 0.6;
num_sim = 100;
for k_g = 1:length(g_set)
    for k_b = 1:length(b_set)
        for k_a_sum = 1:length(a_sum_set)
            totalRset{k_g}{k_b}{k_a_sum} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
            if k_a_sum == length(a_sum_set)
                range_k_SR1 = [2:1:length(a_posiprop_set)-1];
            else
                range_k_SR1 = [1:length(a_posiprop_set)];
            end
            for k_SR1 = range_k_SR1
                if k_a_sum == length(a_sum_set)
                    range_k_SR2 = [2:1:k_SR1];
                else
                    range_k_SR2 = [1:k_SR1];
                end
                for k_SR2 = range_k_SR2
                    a_SR1 = [a_sum_set(k_a_sum)*[a_posiprop_set(k_SR1), 1-a_posiprop_set(k_SR1)], a_SRfeatures];
                    a_SR2 = [a_sum_set(k_a_sum)*[a_posiprop_set(k_SR2), 1-a_posiprop_set(k_SR2)], a_SRfeatures];
                    for k_sim = 1:num_sim
                        fprintf('%d-%d-%d-%d-%d-%d\n',k_g,k_b,k_a_sum,k_SR1,k_SR2,k_sim);
                        Out = gridtask_SRSR([a_SR1;a_SR2],b_set(k_b),g_set(k_g),dur_ini,dur_epoch,num_epoch,R_prob);
                        totalRset{k_g}{k_b}{k_a_sum}(k_SR1,k_SR2,k_sim) = Out.totalR;
                    end
                end
            end
        end
    end
end
save data_gridtask_SRSR totalRset
