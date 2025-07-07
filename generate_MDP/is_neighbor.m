function res = is_neighbor(idx1, num1, idx2, num2)

if (idx1 == idx2) && (num1 == num2)
    res = 1;
    return
end


% idx is 1 to 4 for ABCD, num is 1 to 6
% [idx1, num1] = parse_position(pos_in);
% [idx2, num2] = parse_position(pos_out);


if idx1 > idx2
    temp = idx2;
    idx2 = idx1;
    idx1 = temp;
    temp = num2;
    num2 = num1;
    num1 = temp;
end

if idx1 == 1
    if idx2 < 3
        res = num1 == num2;
        % (cost would be 1 for A -> B; 0 for A -> A and B -> B)
    elseif idx2 == 3
        % this is the case A -> C
        
        %[C1 is neighboring A1 and A6, but not A2]
        % JN this was the case in the past, now we updated this to reflect
        % Maciej's position
        
        % 2019-07-16: Really, Neighbors of C1 are A1 and A2. 
        % Neighbors of C6 are A6 and A1.
        if (num2 == num1) || (num2 == num1 - 1)
            res = 1;
        elseif (num1 == 1) && (num2 == 6)
            res = 1;
        else
            res = 0;
        end
    elseif idx2 == 4
        res = 0;
    end
elseif idx1 == 2
    if idx2 == 2
        res = num1 == num2;
    elseif idx2 == 3
        % this is the case B -> C
        if (num2 == num1) || (num2 == num1 - 1)
            res = 1;
        elseif (num1 == 1) && (num2 == 6)
            res = 1;
        else
            res = 0;
        end
    elseif idx2 == 4
        res = 1;
    end
elseif idx1 == 3
    if idx2 == 3
        res = num1 == num2;
    elseif idx2 == 4
        res = 1;
    end
elseif idx1 == 4
    res = 1;
end