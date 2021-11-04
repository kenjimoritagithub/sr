% make_figure7

% common parameters
a_sum = 1;
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
a_SRfeatures = 0.05;
b = 5;
g = 0.7;
dur_ini = 500;
num_sim = 100;

% Figure 7A
rand('twister',7152427);
dur_epoch = 500;
num_epoch = 9;
R_prob_set = [0.7:0.1:1];
for k_R_prob = 1:length(R_prob_set)
    totalRset{k_R_prob} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
    for k_IR = 1:length(a_posiprop_set)
        for k_SR = 1:length(a_posiprop_set)
            a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
            a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
            for k_sim = 1:num_sim
                fprintf('%d-%d-%d-%d\n',k_R_prob,k_IR,k_SR,k_sim);
                Out = gridtask_SRIR(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob_set(k_R_prob));
                totalRset{k_R_prob}(k_IR,k_SR,k_sim) = Out.totalR;
            end
        end
    end
end
save data_figure7A totalRset
for k_R_prob = 1:length(R_prob_set)
    heatmap_performance(mean(totalRset{k_R_prob},3),length(a_posiprop_set),[],['Figure7A-' num2str(k_R_prob)]);
end

% Figure 7B
rand('twister',7163255);
dur_epoch = 500;
num_epoch = 9;
R_prob = 0.6;
dur_reset_set = [500 250 100 50];
for k_dur_reset = 1:length(dur_reset_set)
    totalRset{k_dur_reset} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
    for k_IR = 1:length(a_posiprop_set)
        for k_SR = 1:length(a_posiprop_set)
            a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
            a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
            for k_sim = 1:num_sim
                fprintf('%d-%d-%d-%d\n',k_dur_reset,k_IR,k_SR,k_sim);
                Out = gridtask_SRIR2(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob,dur_reset_set(k_dur_reset),0);
                totalRset{k_dur_reset}(k_IR,k_SR,k_sim) = Out.totalR;
            end
        end
    end
end
save data_figure7B totalRset
for k_dur_reset = 1:length(dur_reset_set)
    heatmap_performance(mean(totalRset{k_dur_reset},3),length(a_posiprop_set),[],['Figure7B-' num2str(k_dur_reset)]);
end

% Figure 7C,D
rand('twister',7164145);
%
k_cond = 1;
dur_epoch = 4500;
num_epoch = 1;
R_prob = 0.6;
totalRset{k_cond} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
for k_IR = 1:length(a_posiprop_set)
    for k_SR = 1:length(a_posiprop_set)
        a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
        a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
        for k_sim = 1:num_sim
            fprintf('%d-%d-%d-%d\n',k_cond,k_IR,k_SR,k_sim);
            Out = gridtask_SRIR(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob);
            totalRset{k_cond}(k_IR,k_SR,k_sim) = Out.totalR;
        end
    end
end
%
k_cond = 2;
dur_epoch = 100;
num_epoch= 45;
R_prob = 1;
totalRset{k_cond} = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
for k_IR = 1:length(a_posiprop_set)
    for k_SR = 1:length(a_posiprop_set)
        a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
        a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
        for k_sim = 1:num_sim
            fprintf('%d-%d-%d-%d\n',k_cond,k_IR,k_SR,k_sim);
            Out = gridtask_SRIR2(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob,[],0);
            totalRset{k_cond}(k_IR,k_SR,k_sim) = Out.totalR;
        end
    end
end
save data_figure7CD totalRset
%
tmp_CD = 'CD';
for k_cond = 1:2
    heatmap_performance(mean(totalRset{k_cond},3),length(a_posiprop_set),[],['Figure7' tmp_CD(k_cond)]);
end

% Figure 7E
rand('twister',7164272);
dur_epoch = 500;
num_epoch = 9;
R_prob = 1/9;
totalRset = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
for k_IR = 1:length(a_posiprop_set)
    for k_SR = 1:length(a_posiprop_set)
        a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
        a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
        for k_sim = 1:num_sim
            fprintf('%d-%d-%d\n',k_IR,k_SR,k_sim);
            Out = gridtask_SRIR(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob);
            totalRset(k_IR,k_SR,k_sim) = Out.totalR;
        end
    end
end
save data_figure7E totalRset
heatmap_performance(mean(totalRset,3),length(a_posiprop_set),[],'Figure7E');

% Figure 7F
rand('twister',7164748);
dur_epoch = 4500;
num_epoch = 1;
totalRset = NaN(length(a_posiprop_set),length(a_posiprop_set),num_sim);
for k_IR = 1:length(a_posiprop_set)
    for k_SR = 1:length(a_posiprop_set)
        a_IR = a_sum*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
        a_SR = [a_sum*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
        for k_sim = 1:num_sim
            fprintf('%d-%d-%d\n',k_IR,k_SR,k_sim);
            Out = gridtask_SRIR2(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,[],[],1);
            totalRset(k_IR,k_SR,k_sim) = Out.totalR;
        end
    end
end
save data_figure7F totalRset
heatmap_performance(mean(totalRset,3),length(a_posiprop_set),[],'Figure7F');
