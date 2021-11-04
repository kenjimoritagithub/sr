% prepare_for_figure5

% run "gridtask_SRIR_viewsaveall" (and "gridtask_SRIR") and save data for Figure 5

rand('twister',7093351);
a_sum_set = [0.75 1 1.25];
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
a_SRfeatures = 0.05;
b_set = [5 10];
g_set = [0.7 0.8];
dur_ini = 500;
dur_epoch = 500;
num_epoch= 9;
R_prob = 0.6;
view_yn = 0;
num_sim = 100;
for k_g = 1%:length(g_set)
    for k_b = 1%:length(b_set)
        for k_a_sum = 1:2%length(a_sum_set)
            if k_a_sum == length(a_sum_set)
                range_k_IR_SR = [2:1:length(a_posiprop_set)-1];
            else
                range_k_IR_SR = [1:length(a_posiprop_set)];
            end
            for k_IR = range_k_IR_SR
                for k_SR = range_k_IR_SR
                    a_IR = a_sum_set(k_a_sum)*[a_posiprop_set(k_IR), 1-a_posiprop_set(k_IR)];
                    a_SR = [a_sum_set(k_a_sum)*[a_posiprop_set(k_SR), 1-a_posiprop_set(k_SR)], a_SRfeatures];
                    for k_sim = 1:num_sim
                        fprintf('%d-%d-%d-%d-%d-%d\n',k_g,k_b,k_a_sum,k_IR,k_SR,k_sim);
                        if (k_a_sum == 2) && (((k_IR==2)&&(k_SR==8)) || ((k_IR==5)&&(k_SR==5)) || ((k_IR==8)&&(k_SR==2)))
                            Out = gridtask_SRIR_viewsaveall(a_SR,a_IR,b_set(k_b),g_set(k_g),dur_ini,dur_epoch,num_epoch,R_prob,view_yn);
                            SRIRdetails{(k_IR+1)/3}{k_sim} = Out;
                        else
                            Out = gridtask_SRIR(a_SR,a_IR,b_set(k_b),g_set(k_g),dur_ini,dur_epoch,num_epoch,R_prob);
                        end
                    end
                end
            end
        end
    end
end
save -v7.3 data_gridtask_SRIR_viewsaveall SRIRdetails
