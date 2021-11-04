% make_figure5

% load
load data_gridtask_SRIR_viewsaveall

% parameters
num_sim = 100;
dur_ini = 500;
num_epoch = 9;

% Figure 5A (learning curves)
for k_paraset = 1:3
    timeforGmean{k_paraset} = NaN(num_epoch,100);
    for k_epoch = 2:num_epoch
        timeforGset{k_paraset}{k_epoch} = NaN(num_sim,100);
        for k_sim = 1:num_sim
            if ~isnan(max(SRIRdetails{k_paraset}{k_sim}.G_times(k_epoch,:)))
                tmp_last_timeforG_in_prevepoch = max(SRIRdetails{k_paraset}{k_sim}.G_times(k_epoch-1,:));
                if isnan(tmp_last_timeforG_in_prevepoch) % if goal was not reached
                    if k_epoch == 2
                        error('goal was not reached');
                    end
                    if k_epoch >= 3
                        tmp_last_timeforG_in_prevepoch = max(SRIRdetails{k_paraset}{k_sim}.G_times(k_epoch-2,:));
                        if isnan(tmp_last_timeforG_in_prevepoch)
                            if k_epoch >= 4
                                tmp_last_timeforG_in_prevepoch = max(SRIRdetails{k_paraset}{k_sim}.G_times(k_epoch-3,:));
                                if isnan(tmp_last_timeforG_in_prevepoch)
                                    error('goal was not reached');
                                end
                            end
                        end
                    end
                end
                tmp_init_timeforG = SRIRdetails{k_paraset}{k_sim}.G_times(k_epoch,1) - tmp_last_timeforG_in_prevepoch;
                timeforGset{k_paraset}{k_epoch}(k_sim,:) = [tmp_init_timeforG, diff(SRIRdetails{k_paraset}{k_sim}.G_times(k_epoch,:))];
            end
        end
        for k = 1:100
            tmp = timeforGset{k_paraset}{k_epoch}(:,k);
            if length(tmp(~isnan(tmp))) >= num_sim/4
                timeforGmean{k_paraset}(k_epoch,k) = mean(tmp(~isnan(tmp)));
            end
        end
    end
end
% plot
F = figure;
A = axes;
hold on;
axis([0 18 0 85]);
P = plot(mean(timeforGmean{1}(2:end,1:17),1),'r');
P = plot(mean(timeforGmean{2}(2:end,1:17),1),'b');
P = plot(mean(timeforGmean{3}(2:end,1:17),1),'g');
set(A,'XTick',[1:17],'XTickLabel',[1:17],'FontSize',22);
set(A,'YTick',[0:10:80],'YTickLabel',[0:10:80],'FontSize',22);
print(F,'-depsc','Figure5A');

% Figure 5B
tmp_abc = 'abc';
% extract examples
SRIRdetails_examples{1} = SRIRdetails{1}{15};
SRIRdetails_examples{2} = SRIRdetails{2}{12};
SRIRdetails_examples{3} = SRIRdetails{3}{11};
% left panels
for k_paraset = 1:3
    F = figure;
    A = axes;
    hold on;
    if k_paraset ~= 2
        axis([0 26 -16 16]);
    else
        axis([0 26 -1.6 1.6]);
    end
    lastGtime = max(SRIRdetails_examples{k_paraset}.G_times(9,:));
    P = plot([0 26],[0 0],'k:');
    P = plot([1:25],SRIRdetails_examples{k_paraset}.SV_all{2}(:,lastGtime+1),'b');
    P = plot([1:25],SRIRdetails_examples{k_paraset}.SV_all{1}(:,lastGtime+1),'r');
    P = plot([1:25],SRIRdetails_examples{k_paraset}.intSV_all(:,lastGtime+1),'k');
    set(A,'XTick',[1:25],'XTickLabel',[1:25],'FontSize',27);
    if k_paraset ~= 2
        set(A,'YTick',[-15:5:15],'YTickLabel',[-15:5:15],'FontSize',27);
    else
        set(A,'YTick',[-1.5:0.5:1.5],'YTickLabel',[-1.5:0.5:1.5],'FontSize',27);
    end
    print(F,'-depsc',['Figure5B' tmp_abc(k_paraset) '-left']);
end
% middle panels
for k_paraset = 1:3
    F = figure;
    A = axes;
    hold on;
    axis([0 26 -1.6 1.6]);
    lastGtime = max(SRIRdetails_examples{k_paraset}.G_times(9,:));
    P = plot([0 26],[0 0],'k:');
    P = plot([1:25],SRIRdetails_examples{k_paraset}.intSV_all(:,lastGtime+1),'k');
    set(A,'XTick',[1:25],'XTickLabel',[1:25],'FontSize',27);
    set(A,'YTick',[-1.5:0.5:1.5],'YTickLabel',[-1.5:0.5:1.5],'FontSize',27);
    print(F,'-depsc',['Figure5B' tmp_abc(k_paraset) '-middle']);
end
% right panels
for k_paraset = 1:3
    F = figure;
    A = axes;
    hold on
    axis([0.5 5.5 0.5 5.5]);
    [lastGtime, tmp_index] = max(SRIRdetails_examples{k_paraset}.G_times(9,:));
    G = SRIRdetails_examples{k_paraset}.R_states(9,tmp_index);
    P = image(32+20*reshape(SRIRdetails_examples{k_paraset}.intSV_all(:,lastGtime+1),5,5)');
    P = plot(mod(G-1,5)+1,ceil(G/5),'wx'); set(P,'MarkerSize',20,'LineWidth',4);
    set(A,'PlotBoxAspectRatio',[1 1 1]);
    set(A,'Box','on');
    set(A,'XTick',[1:5],'XTickLabel',[1:5],'FontSize',27);
    set(A,'YTick',[1:5],'YTickLabel',[1:5],'FontSize',27);
    print(F,'-depsc',['Figure5B' tmp_abc(k_paraset) '-right']);
end
% colorbar
F = figure;
A = axes;
hold on;
P = colorbar;
set(P,'YTick',[1 33 65],'YTickLabel',[-1.6 0 1.6],'FontSize',22);
print(F,'-depsc','Figure5B-right-colorbar');
