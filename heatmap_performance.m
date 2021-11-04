function heatmap_performance(data_to_image,num_posiprop,max_min,savename)

% function for drawing the heat map indicating the performance

if isempty(max_min)
    max_min = [max(max(data_to_image)), min(min(data_to_image))];
end
F = figure;
A = axes;
hold on;
axis([0.5 num_posiprop+0.5 0.5 num_posiprop+0.5]);
[value,index1] = max(max(data_to_image,[],2));
[value,index2] = max(max(data_to_image,[],1));
P = image(64*(data_to_image' - max_min(2))/(max_min(1) - max_min(2)));
P = colorbar;
set(P,'YTick',[1.5 64.5],'YTickLabel',[max_min(2) max_min(1)]);
P = plot([0.5 num_posiprop+0.5],[0.5 num_posiprop+0.5],'k-');
P = plot(index1,index2,'wx'); set(P,'MarkerSize',14);
set(A,'PlotBoxAspectRatio',[1 1 1]);
set(A,'XTick',[],'XTickLabel',[],'FontSize',22);
set(A,'YTick',[],'YTickLabel',[],'FontSize',22);
title(num2str(max(max(data_to_image))),'FontSize',22);
if ~isempty(savename)
    print(F,'-depsc',savename);
end
