% Optimize a trajectory starting at a specified point.
function [states,u,initu,r] = optimizetrajectory(s,T,mdp_data,discrete_mdp,mdp,reward,true_reward,optimal,restarts)

% Currently this finds the trajectory by optimizing R(zeta).
% Later on, if we want to draw estimates from exp(R(zeta)), we should use
% MCMC sampling, which does not require computing the partition function.

fprintf('optimize_trajectory: called \n')


% Set up optimization options.
options = struct();
options.Method = 'lbfgs';
options.maxIter = 1000;
options.MaxFunEvals = 1000;
options.display = 'on';
options.TolX = 1.0e-16;
options.TolFun = 1.0e-8;
options.Display = 'off';
%options.DerivativeCheck = 'on';

if size(restarts,2) > 1,
  
    fprintf('optimize_trajectory: if size branch executed \n')
  
    % Set number of iterations.
    options.maxIter = restarts(2);
    options.MaxFunEvals = restarts(2);
end;


% if branch doesnt execute for singletest
if optimal,
  
    fprintf('optimize_trajectory: if optimal branch executed \n')
    
    % If we have a precomputed policy, initialize with it here.
    u = zeros(T,mdp_data.udims);
    state = s;
    for t=1:T,
        % Evaluate each action.
        best_val = -Inf;
        [s_s,s_p] = interpolatestate(state,discrete_mdp,mdp_data);
        vt = discrete_mdp.V(:,t);
        for a=1:discrete_mdp.actions,
            % Take the action.
            next_state = feval(strcat(mdp,'control'),mdp_data,state,discrete_mdp.act_vals(a,:));
        
            % Interpolate value and reward.
            [n_s,n_p] = interpolatestate(next_state,discrete_mdp,mdp_data);
            ra = discrete_mdp.R(:,a);
            val = sum(vt(n_s).*n_p,3) + sum(ra(s_s).*s_p,3);
            
            % Take the best action.
            if val > best_val,
                best_val = val;
                u(t,:) = discrete_mdp.act_vals(a,:);
                newstate = next_state;
            end;
        end;
        
        % Switch to new state.
        state = newstate;
    end;
else
    
    fprintf('optimize_trajectory: else optimal branch executed \n')
    
    u = feval(strcat(mdp,'samplecontrols'),T,mdp_data);
end;
              
% Run random restarts.
rbest = -Inf;
ubest = [];
bestinitu = [];
for i=1:restarts(1),
    % Optimize the states.
    initu = u(:);
    
    fprintf('optimize_trajectory: restarts for loop exectued t = %i\n', i)
    
    if isfield(mdp_data,'optimizes'),
        % Run task-specific optimization.
               
        fprintf('CALLING feval(strcat(mdp,optimize))')
        display(s)
        display(u)
        display(mdp)
        display(reward)
        display(options)
        
        [u,r] = feval(strcat(mdp,'optimize'),s,u,mdp_data,mdp,reward,options);
        
        fprintf('optimize_trajectory: FINSIHED executing feval(strcat(mdp,optimize))')
        
        u = u(:);
    else
        % Run minFunc.
        
        fprintf('opt_traj: Running minFunc - testing inputs \n')
        display()
        
        [u,r] = minFunc(@(p)trajectoryreward(p,s,mdp_data,mdp,reward),u(:),options);
    end;
    
    r = -r;
    if r > rbest,
        % Store the best results.
        rbest = r;
        ubest = u;
        bestinitu = initu;
    end;
    
    % Create next controls.
    u = feval(strcat(mdp,'samplecontrols'),T,mdp_data);
end;

r = -trajectoryreward(ubest(:),s,mdp_data,mdp,true_reward);
u = reshape(ubest,T,mdp_data.udims);
initu = reshape(bestinitu,T,mdp_data.udims);
states = feval(strcat(mdp,'control'),mdp_data,s,u);
