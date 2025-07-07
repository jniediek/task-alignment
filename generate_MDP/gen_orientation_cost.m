function cost = gen_orientation_cost(O1, O2)

% orientation_names = {'INW', 'CLW', 'OUT', 'CCW'};



if O1 == O2
    cost = 0;
    return
else
    O1_even = (O1 == 2) || (O1 == 4);
    O2_even = (O2 == 2) || (O2 == 4);
    % clockwise or counterclockwise
    
    if O1_even && O2_even
        cost = 2;
    elseif (~O1_even) && (~O2_even)
        cost = 2;
    else
        cost = 1;
    end
end
