function Out = gridtask_SRIR(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,R_prob)

% Simulated reward navigation task in a two-dimensional grid space by an agent equipped with two sytems, one of which uses
% successor representation (SR) and the other of which uses individual (punctate) representation (IR) of states
% The grid space is as follows.
%  S21 S22 S23 S24 S25
%  S16 S17 S18 S19 S20
%  S11 S12 S13 S14 S15
%   S6  S7  S8  S9 S10
%   S1  S2  S3  S4  S5
% The agent always starts from S1.
% During the initial "dur_ini", there is no reward, and the agent just freely moves around (i.e., latent learning).
% After "dur_ini", there are "num_epoch" (1 to 9) phases with a rewarded state.
% In each phase, one of the reward-candidate-states (S[5 10 15 20 21 22 23 24 25]), determined by pseudo-random permulation,
% becomes the rewarded state with a high probability "R_prob", whereas one of the remaining 8 reward-candidate-states 
% becomes the rewarded state with probability "1 - R_prob".
% When the agent reaches the rewarded state, it obtains the reward (set to 1), and immediately returns to the start (S1).
%
% <Input variables>
%   a_SR: learning rates for [non-negative TD-RPEs,negative TD-RPEs,SR features] for the system using SR
%	a_IR: learning rates for [non-negative TD-RPEs,negative TD-RPEs] for the system using IR
%	b: inverse temperature
%	g: time discount factor
%	dur_ini: duration (time steps) for the initial no-reward epoch
%	dur_epoch: duration (time steps) for each rewarded epoch
%	num_epoch: number of the rewarded epochs (1 to 9)
%	R_prob: probability with which the special reward candidate state becomes the rewarded state in a given rewarded epoch
%
% <Output variable>
%   Out: containing the following
%           Out.totalR: total rewards that the agent has obtained
%
% <Example>
%	Out = gridtask_SRIR([0.6 0.4 0.05],[0.4 0.6],5,0.7,500,500,9,0.6);

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
        else % set one of the normal (non-special) candidate states for the current epoch as the rewarded state
            tmp_rand = randperm(8);
            tmp = SRCS_set(SRCS_set~=SRCS_set(R_epoch));
            G = tmp(tmp_rand(1));
        end
        R(G) = 1; % place reward at the rewarded state
    end
    
    % state transition
    currS = nextS; % current state
    
    % integrated state values, which are the means of the system-specific state values of the two systems
    intSV = (IRSV + SR*w)/2;
    
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
        % next rewarded state
        R_epoch = ceil((k-dur_ini)/dur_epoch); % epoch for the reward set now
        R = zeros(25,1);
        if rand <= R_prob % set the special candidate state for the current epoch as the rewarded state
            G = SRCS_set(R_epoch);
        else % set one of the normal (non-special) candidate states for the current epoch as the rewarded state
            tmp_rand = randperm(8);
            tmp = SRCS_set(SRCS_set~=SRCS_set(R_epoch));
            G = tmp(tmp_rand(1));
        end
        R(G) = 1;
    end
    
end

% output total reward
Out.totalR = totalR;
