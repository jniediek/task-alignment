function cost = gen_movement_costs(idx1, num1, idx2, ...
    num2, costs)


if (idx1 == idx2) && (num1 == num2)
    cost = 0;
    return
end


if idx2 < idx1
    temp = idx2;
    idx2 = idx1;
    idx1 = temp;
    temp = num2;
    num2 = num1;
    num1 = temp;
end

% for D, the number does not matter
if idx2 == 4
    cost = costs{idx1, idx2};
else
  
    % the distance is treated differently for A-C and B-C versus all others
    if (idx2 == 3) && (idx1 < 3)
        
        % num2 is the Cnum
        % num1 is either the Anum or the Bnum
        num2_tr = 2*num2;
        num1_tr = 2*num1 - 1;
        
        % d is always an odd number
        d = abs(num2_tr - num1_tr);
        d = min(d, 12 - d);
        dist = (d+1)/2;
        
        % the following stand for d = [0 1 2 3 4 5]
        % translate_to = [1 1 2 3 2 1];
        % dist = translate_to(dist);
        
        % 2021-03-17 checked this
%         if dist == 5
%             dist = 0;
%         elseif dist == 4
%             dist = 1;
%         end
%         
%         if num2 <= num1
%             dist = dist + 1;
%         elseif (num2 > 4) && (num1 <= 2)
%             dist = dist + 2;
%         end
%         
%         dist = min(dist, 3);
%     
    else
         dist = abs(num1 - num2);  
        if dist == 5
            dist = 1;
        elseif dist == 4
            dist = 2;
        end
                
        if idx1 ~= idx2
            dist = dist + 1;
        end
    end
    
    cost = costs{idx1, idx2}(dist);
end
