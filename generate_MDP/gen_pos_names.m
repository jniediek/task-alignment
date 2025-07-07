function names = gen_pos_names()

letters = 'ABC';
names = cell(19, 1);

for il = 1:3
    for in = 1:6
        names{(il-1)*6 + in} = sprintf('%s%d', letters(il), in);
    end
end

names{19} = 'D1';