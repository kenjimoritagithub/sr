% make_figure3_4_6

% load the data
load data_gridtask_SRIR
totalRset_set{1} = totalRset;
clear totalRset
%
load data_gridtask_IRIR
totalRset_set{3} = totalRset;
clear totalRset
%
load data_gridtask_SRSR
totalRset_set{2} = totalRset;
clear totalRset

% parameters varied
g_set = [0.7 0.8];
b_set = [5 10];
a_sum_set = [0.75 1 1.25];
a_posiprop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];

% determine the max and min of the color bar
tmp_max_min = [0 Inf];
for k_model = 1:3
    for k_g = 1:length(g_set)
        for k_b = 1:length(b_set)
            for k_a_sum = 1:length(a_sum_set)
                tmp_max_min(1) = max(tmp_max_min(1), max(max(mean(totalRset_set{k_model}{k_g}{k_b}{k_a_sum},3))));
                tmp_max_min(2) = min(tmp_max_min(2), min(min(mean(totalRset_set{k_model}{k_g}{k_b}{k_a_sum},3))));
            end
        end
    end
end % tmp_max_min = [128.5000   27.8400]
max_min = [ceil(tmp_max_min(1)) floor(tmp_max_min(2))]; % so that the highest and lowest performances can be covered

% draw figures
tmp_name{1} = '4'; tmp_name{2} = '6A'; tmp_name{3} = '6B';
for k_model = 1:3
    for k_g = 1:length(g_set)
        for k_b = 1:length(b_set)
            for k_a_sum = 1:length(a_sum_set)
                if k_a_sum < length(a_sum_set)
                    num_posiprop = length(a_posiprop_set);
                else
                    num_posiprop = length(a_posiprop_set)-2;
                end
                data_to_image = mean(totalRset_set{k_model}{k_g}{k_b}{k_a_sum},3);
                if k_a_sum == length(a_sum_set)
                    data_to_image = data_to_image(2:end-1,2:end-1);
                end
                heatmap_performance(data_to_image,num_posiprop,max_min,...
                    ['Figure' tmp_name{k_model} '_g' num2str(k_g) '_b' num2str(k_b) '_a_sum' num2str(k_a_sum)]);
                if (k_model==1) && (k_g==1) && (k_b==1) && (k_a_sum==2)
                    heatmap_performance(data_to_image,num_posiprop,max_min,'Figure3');
                end
            end
        end
    end
end

% Figure 6C
for k_g = 1:length(g_set)
    for k_b = 1:length(b_set)
        for k_a_sum = 1:length(a_sum_set)
            performax{k_g}{k_b}{k_a_sum} = NaN(1,3);
        end
    end
end
for k_comb = 1:3
    for k_g = 1:length(g_set)
        for k_b = 1:length(b_set)
            for k_a_sum = 1:length(a_sum_set)
                performax{k_g}{k_b}{k_a_sum}(k_comb) = max(max(mean(totalRset_set{k_comb}{k_g}{k_b}{k_a_sum},3)));
            end
        end
    end
end
tmp_color = [1/2 0 1/2; 1 0 0; 0 0 1]; % purple, red, blue
for k_g = 1:length(g_set)
    for k_b = 1:length(b_set)
        F = figure;
        A = axes;
        hold on
        axis([0.5 11.5 0 130]);
        for k_a_sum = 1:length(a_sum_set)
            for k_comb = 1:3
                P = bar(4*(k_a_sum-1)+k_comb,performax{k_g}{k_b}{k_a_sum}(k_comb));
                set(P,'FaceColor',tmp_color(k_comb,:));
            end
        end
        set(A,'PlotBoxAspectRatio',[3 1 1]);
        set(A,'Box','off');
        set(A,'XTick',[1:3 5:7 9:11],'XTickLabel',[]);
        set(A,'YTick',[0:20:120],'YTickLabel',[0:20:120],'FontSize',16);
        print(F,'-depsc',['Figure6C_g' num2str(k_g) '_b' num2str(k_b) '_']);
    end
end
