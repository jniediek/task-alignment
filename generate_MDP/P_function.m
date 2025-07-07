function p = P_function(pos_in, pos_in_1, pos_in_2, orient_in, ia_curr_in, ia_prev_in, ...
    pos_out, pos_out_1, pos_out_2, orient_out, ia_curr_out, ia_prev_out, rew_in, rew_out, action, is_movement)
% JN 2021-03-09
% JN 2022-12-22
% JN 2023-05-11

% the rew_in and rew_out arguments refer to the type of activation
% (A, B, C, P)

p_punish = .1;
p_not_punish = 1 - p_punish;

pos_equality = (pos_in_1 == pos_out_1) && (pos_in_2 == pos_out_2);
if is_movement
    if pos_equality
        p = 0;
        return
    elseif strcmp(pos_out, action)
        p_position = is_neighbor(pos_in_1, pos_in_2, pos_out_1, pos_out_2);
    else
        p = 0;
        return
    end
else
    p_position = pos_equality;
end

if p_position == 0
    p = 0;
    return
end


%% this is the interaction area block

a_type = pos_in(1);
a_num = pos_in(2);

if is_movement
    % moving does never change the status of IAs or the currently active
    % reward type
    if (ia_curr_in ~= ia_curr_out) || (ia_prev_in ~= ia_prev_out) || (rew_in ~= rew_out)
        p = 0;
        return
    else
        p_inter = 1;
    end
    
elseif strcmp(action, "AC")
    % JN 2023-05-11 this is now an activate action
    % JN 2022-12-22 have to consider the reward type here
    if (ia_prev_in ~= ia_prev_out)
        p = 0;
        return
    end
    
    % this action should not be available if something is active already
    if (ia_curr_in ~= '0')
        p = 0;
        return
    end
    
    if (ia_prev_in == ia_prev_out) && (ia_curr_in == '0')
        % these are the options to activate an IA / punishment
        % the ia_curr_out == '1' just means that we are 'inside' a trial,
        % it does not refer to IA1 in this case
        
        if (rew_out == 'P') && (ia_curr_out == '1') && (a_type ~= 'D')
            p_inter = p_punish;
        else
            
            if a_type == 'A'
                if (ia_prev_in ~= a_num) && (ia_curr_out == a_num)
                    p_inter = p_not_punish;
                    if rew_out ~= 'A'
                        p = 0;
                        return
                    end
                    
                elseif ia_prev_in == a_num
                    % only here we have to calculate the next number
                    next_anum = pos_in_2 + 1;
                    if next_anum == 7
                        next_anum = 1;
                    end
                    next_anum = sprintf('%d', next_anum);
                    if ia_curr_out == next_anum
                        p_inter = p_not_punish;
                        if rew_out ~= 'A'
                            p = 0;
                            return
                        end
                        
                    else
                        p = 0;
                        return
                    end
                else
                    p = 0;
                    return
                end
                
            elseif a_type == 'B'
                if ia_curr_out == a_num
                    p_inter = p_not_punish;
                    if rew_out ~= 'B'
                        p = 0;
                        return
                    end
                    
                else
                    p = 0;
                    return
                end
            elseif a_type == 'C'
                if ia_curr_out ~= '0'
                    p_inter = 1/6 * p_not_punish;
                    if rew_out ~= 'C'
                        
                        p= 0;
                        return
                    end
                else
                    p = 0;
                    return
                end
                % JN 2023-05-11 this seems strange to me
            elseif a_type == 'D'
                %                  if (ia_prev_in == '0') && (ia_curr_out == '0') && (rew_in == rew_out)
                %                      p_inter = 1;
                %                  else
                p = 0;
                return
                
            end
        end
    end
    
    % this is the time-out
elseif strcmp(action, "TO")
   if rew_in ~= rew_out
       p = 0;
       return
   end
    
    if (a_type == 'D')
        if (ia_curr_in ~= '0') && (ia_prev_out == ia_curr_in) && (ia_curr_out == '0') 
            p_inter = 1;
        else
            p = 0;
            return
        end
    elseif (ia_curr_in ~= '0')
        
        if (rew_in ~= 'A')  
            if  (ia_curr_out == '0') && (ia_prev_out == ia_prev_in)
                p_inter = 1;
            else
                p = 0;
                return
            end
            
        elseif (rew_in == 'A') 
            if (ia_prev_out == pos_in(2)) && (ia_curr_out == '0')
                p_inter = 1;
            else
                p = 0;
                return
            end
            
            
        else
            p = 0;
            return
        end
        
    else
        p = 0;
        return
    end
    
elseif strcmp(action, "WA") || strcmp(action, "FD")
    
    if (a_type ~= 'A')
        p = 0;
        return
    end
    
    if (rew_out ~= rew_in)
        p = 0;
        return
    end
    
    if ia_curr_in ~= '0'
        % first deal with active IA
        if rew_in == 'P'
            if (ia_prev_out == ia_prev_in) && (ia_curr_out == '0')
                p_inter = 1;
            else
                p = 0;
                return
            end
        else
            
             if (rew_in == 'A') && (ia_prev_out == pos_in(2)) && (ia_curr_out == '0')
                 p_inter = 1;
%             elseif (rew_in ~= 'A') && (ia_prev_out == ia_prev_in) && (ia_curr_out == '0')
             elseif (rew_in ~= 'A') && (ia_prev_out == ia_curr_in) && (ia_curr_out == '0')
                p_inter = 1;
            else
                p = 0;
                return
            end
        end
    else % ia_curr_in == '0'
        
        if (ia_prev_in == ia_prev_out) && (ia_curr_out == ia_curr_in)
            p_inter = 1;
        else
            p = 0;
            return
        end
    end
    
end

p_rew = 1;

%% this is the orientation transition

path_orientation = get_path_orientation(pos_in_1, pos_in_2, pos_out_1, pos_out_2);

if path_orientation == 0
    if orient_in == orient_out
        p_orient = 1;
    else
        p = 0;
        return
    end
else
    %idx_O2 = find(strcmp(orient_out, orientation_names));
    if path_orientation == orient_out
        p_orient = 1;
    else
        p = 0;
        return
    end
end

p = p_inter * p_position * p_orient * p_rew;
