function Out = gridtask_SRIR_viewsaveall(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob,view_yn)

% gridtask_SRIR + view of the agent's behavior and record/output of various variables
%
% <Additional input variable>
%   view_yn: view the agent's behavior (current state, rewarded state, integrated state values, and reward candidate states) (1) or not (0)
%
% <Additional fields of the output variable>
%           Out.SR_all: all the sequence of SR matrix
%           Out.w_all: all the sequence of the weights for SR-based system-specific state value function
%           Out.SV_all: all the sequences of system-specific state values for the systems using SR (i.e., SR*w) ({1}) and IR ({2})
%           Out.intSV_all: all the sequence of integrated state values
%           Out.TDRPE_all: all the sequences of TD-RPE
%           Out.R_states: all the set of rewarded states for each reward in each rewarded epoch
%           Out.R_types: all the set of reward types (1:reward at the special candidate state, 2:reward not at the special candidate state)
%           Out.G_times: all the set of goal (reward acquisition) timings
%
% <Example>
%	Out = gridtask_SRIR_viewsaveall([0.6 0.4 0.05],[0.4 0.6],5,0.7,500,500,9,0.6,1);

%# all the history of variables to record for output
SR_all = zeros(25,25,dur_ini+num_epoch*dur_epoch);
w_all = zeros(25,dur_ini+num_epoch*dur_epoch);
SV_all{1} = zeros(25,dur_ini+num_epoch*dur_epoch); % SR*w
SV_all{2} = zeros(25,dur_ini+num_epoch*dur_epoch); % IRSV
intSV_all = zeros(25,dur_ini+num_epoch*dur_epoch);
TDRPE_all = zeros(1,dur_ini+num_epoch*dur_epoch);
R_states = NaN(num_epoch,dur_epoch/5); % rewarded state for each reward in each rewarded epoch
R_types = NaN(num_epoch,dur_epoch/5); % 1:reward at the special candidate state, 2:reward not at the special candidate state
G_times = NaN(num_epoch,dur_epoch/5); % goal (reward acquisition) timings

%# prepare the figure
if view_yn
    F = figure;
    A = axes;
    hold on
    axis([0.5 5.5 0.5 5.5]);
end

% neighboring states of each state, to which the agent can move in the next time step
NB{1} = [2 6]; NB{2} = [1 3 7]; NB{3} = [2 4 8]; NB{4} = [3 5 9]; NB{5} = [4 10];
NB{6} = [1 7 11]; NB{7} = [2 6 8 12]; NB{8} = [3 7 9 13]; NB{9} = [4 8 10 14]; NB{10} = [5 9 15];
NB{11} = [6 12 16]; NB{12} = [7 11 13 17]; NB{13} = [8 12 14 18]; NB{14} = [9 13 15 19]; NB{15} = [10 14 20];
NB{16} = [11 17 21]; NB{17} = [12 16 18 22]; NB{18} = [13 17 19 23]; NB{19} = [14 18 20 24]; NB{20} = [15 19 25];
NB{21} = [16 22]; NB{22} = [17 21 23]; NB{23} = [18 22 24]; NB{24} = [19 23 25]; NB{25} = [20 24];

% initialization of system-specific state values and SR features
SR = zeros(25,25); % SR matrix
w = zeros(25,1); % weights for SR-based system-specific state value function (SR*w gives SR-based system-specific state values)
IRSV = zeros(25,1); % IR-based system-specific state values
I25 = eye(25);

% reward-related settings
RewCandStates = [5 10 15 20 21 22 23 24 25]; % reward candidate states
tmp_rand = randperm(9); % vary across simulations
SRCS_set = RewCandStates(tmp_rand); % special reward candidate states for each rewarded epoch
totalR = 0; % initialization of total rewards
R = zeros(25,1); % initialization of reward in each state
G = NaN; % initialization of rewarded state (goal)

% main loop
nextS = 1; % next state
for k = 1:dur_ini+num_epoch*dur_epoch
    
    % introduce reward after dur_ini
    if k == dur_ini + 1
        R_epoch = 1; % epoch for the reward set now
        if rand <= R_prob % set the special candidate state for the current epoch as the rewarded state
            G = SRCS_set(R_epoch);
            %# record reward type
            R_types(R_epoch,1) = 1;
        else % set one of the normal (non-special) candidate states for the current epoch as the rewarded state
            tmp_rand = randperm(8);
            tmp = SRCS_set(SRCS_set~=SRCS_set(R_epoch));
            G = tmp(tmp_rand(1));
            %# record reward type
            R_types(R_epoch,1) = 2;
        end
        R(G) = 1; % place reward at the rewarded state
        %# record rewarded state
        R_states(R_epoch,1) = G;
    end
    
    % state transition
    currS = nextS; % current state
    
    % integrated state values, which are the means of the system-specific state values of the two systems
    intSV = (IRSV + SR*w)/2;
    
    %# record variables
    SR_all(:,:,k) = SR;
    w_all(:,k) = w;
    SV_all{1}(:,k) = SR * w;
    SV_all{2}(:,k) = IRSV;
    intSV_all(:,k) = intSV;
    
    %# draw
    if view_yn
        hold off
        P = image(flipud(64*reshape(intSV,5,5)'));
        hold on
        if k > dur_ini
            P = plot([0.5 4.5],6-[4.5 4.5],'w'); set(P,'LineWidth',0.5);
            P = plot([4.5 4.5],6-[0 4.5],'w'); set(P,'LineWidth',0.5);
            current_epoch = ceil((k-dur_ini)/dur_epoch);
            SRCS = SRCS_set(current_epoch); % special reward candidate state
            P = plot(mod(SRCS-1,5)+1+[-0.5 0.5],6-(ceil(SRCS/5)-0.5)*[1 1],'w'); set(P,'LineWidth',2);
            P = plot(mod(SRCS-1,5)+1+[-0.5 0.5],6-(ceil(SRCS/5)+0.5)*[1 1],'w'); set(P,'LineWidth',2);
            P = plot((mod(SRCS-1,5)+1-0.5)*[1 1],6-(ceil(SRCS/5)+[-0.5 0.5]),'w'); set(P,'LineWidth',2);
            P = plot((mod(SRCS-1,5)+1+0.5)*[1 1],6-(ceil(SRCS/5)+[-0.5 0.5]),'w'); set(P,'LineWidth',2);
        end
        if ~isnan(G)
            P = plot(mod(G-1,5)+1,6-ceil(G/5),'wx'); set(P,'MarkerSize',20,'LineWidth',4);
        end
        P = plot(mod(currS-1,5)+1,6-ceil(currS/5),'wd'); set(P,'MarkerSize',20,'LineWidth',4);
        set(A,'PlotBoxAspectRatio',[1 1 1]);
        set(A,'XTick',[1:5],'XTickLabel',[1:5],'FontSize',24);
        set(A,'YTick',[1:5],'YTickLabel',[5:-1:1],'FontSize',24);
        ketamax = floor(log10(dur_ini+dur_epoch*num_epoch)) + 1;
        num0add = ketamax - (floor(log10(k))+1);
        tmp_title = [];
        for k_0 = 1:num0add
            tmp_title = [tmp_title, '0'];
        end
        tmp_title = [tmp_title, num2str(k)];
        title(tmp_title,'FontSize',24);
        drawnow;
        pause(0.05);
    end
    
    % select action to move to one of the neighboring states
    if currS ~= G
        tmp_prob = exp(b*intSV(NB{currS})) / sum(exp(b*intSV(NB{currS}))); % soft-max
        tmp = rand;
        if tmp <= tmp_prob(1)
            nextS = NB{currS}(1);
        elseif (length(NB{currS}) >= 3) && (tmp <= tmp_prob(1) + tmp_prob(2))
            nextS = NB{currS}(2);
        elseif (length(NB{currS}) >= 4) && (tmp <= tmp_prob(1) + tmp_prob(2) + tmp_prob(3))
            nextS = NB{currS}(3);
        else
            nextS = NB{currS}(end);
        end
    end
    
    % TD-RPE
    if currS ~= G
        TDRPE = R(currS) + g*intSV(nextS) - intSV(currS);
    else
        TDRPE = R(currS) + 0 - intSV(currS);
    end
    %# record TD-RPE
    TDRPE_all(k) = TDRPE;
    
    % update of IRSV
    if TDRPE >= 0
        IRSV(currS) = IRSV(currS) + a_IR(1)*TDRPE;
    else
        IRSV(currS) = IRSV(currS) + a_IR(2)*TDRPE;
    end
    
    % update of w
    if TDRPE >= 0
        w = w + a_SR(1)*SR(currS,:)'*TDRPE;
    else
        w = w + a_SR(2)*SR(currS,:)'*TDRPE;
    end
    
    % update of SR features
    if currS ~= G
        TDEsr = I25(currS,:) + g*SR(nextS,:) - SR(currS,:);
    else
        TDEsr = I25(currS,:) - SR(currS,:);
    end
    SR(currS,:) = SR(currS,:) + a_SR(3)*TDEsr;
    
    % if the agent reached the rewarded state
    if currS == G
        totalR = totalR + 1;
        nextS = 1; % return to the start state
        %# record goal time
        tmp_index = find(isnan(G_times(R_epoch,:)),1);
        G_times(R_epoch,tmp_index) = k;
        % next rewarded state
        R_epoch = ceil((k-dur_ini)/dur_epoch); % epoch for the reward set now
        R = zeros(25,1);
        if rand <= R_prob % set the SRCS candidate state for the current epoch as the rewarded state
            G = SRCS_set(R_epoch);
            %# record reward type
            R_types(R_epoch,find(isnan(R_types(R_epoch,:)),1)) = 1;
        else % set one of the normal (non-SRCS) candidate states for the current epoch as the rewarded state
            tmp_rand = randperm(8);
            tmp = SRCS_set(SRCS_set~=SRCS_set(R_epoch));
            G = tmp(tmp_rand(1));
            %# record reward type
            R_types(R_epoch,find(isnan(R_types(R_epoch,:)),1)) = 2;
        end
        R(G) = 1;
        %# record rewarded state
        R_states(R_epoch,find(isnan(R_states(R_epoch,:)),1)) = G;
    end
    
end

% output total reward
Out.totalR = totalR;
%# other output variables
Out.SR_all = SR_all;
Out.w_all = w_all;
Out.SV_all = SV_all;
Out.intSV_all = intSV_all;
Out.TDRPE_all = TDRPE_all;
Out.R_states = R_states;
Out.R_types = R_types;
Out.G_times = G_times;
