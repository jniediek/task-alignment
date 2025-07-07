function r = R_function(pos_in, pos_in_1, pos_in_2, orient_in, ia_curr_in, ia_prev_in, ...
    pos_out, pos_out_1, pos_out_2, orient_out, ia_curr_out, ia_prev_out, rew_in, action, is_movement, rew_sizes)

% JN 2021-05-20
% adding a small reward for poking per se, even if food or water are not
% delivered

% the reward happens when: rat is Ax, IAx is on, and WA or FD action is
% taken.

if (pos_in(1) ~= 'A') || is_movement || strcmp(action, "TO") || strcmp(action, "AC") || ...
        (pos_in_1 ~= pos_out_1) || (pos_in_2 ~= pos_out_2) || ...
        (orient_in ~= orient_out) 
    
    r = 0;
    return
end


if rew_in ~= 'P'
    give_reward = (ia_curr_in == pos_in(2)) && (ia_curr_out == '0');
else
    give_reward = ia_curr_out == '0';
end

% if rew_in == 'A'
%     if ia_curr_in ~= ia_prev_out
%         give_reward = 0;
%     end
% else
%     if ia_prev_out ~= '0'
%         give_reward = 0;
%     end
% end


if give_reward
    if strcmp(action, 'WA')
        r = rew_sizes.water(pos_in_2);
    elseif strcmp(action , 'FD')
        r = rew_sizes.food(pos_in_2);
    else
        r = 0;
    end
    if rew_in == 'B'
        r = r * rew_sizes.B_factor;
    elseif rew_in == 'C' 
        % this is not truely the model: actually this reward should be
        % randomly drawn at every instance of a C reward
        r = r * rew_sizes.C_factor;
    elseif rew_in == 'P'
        % this is the punish option
        r = r * (-1);
    end
else
    r = 0;
end

% if the action is poking, add a small reward regardless of the IA changes
if strcmp(action, 'WA') || strcmp(action, 'FD')
    r = r + rew_sizes.poke(pos_in_2);
end
