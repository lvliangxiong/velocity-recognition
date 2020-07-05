function ac = correct_angle(a)
    PI = 3.141592654;
    ac = a;

    for index = 1:length(a) - 1

        if ((a(index + 1) - a(index)) >= 3)
            ac(index + 1:end) = ac(index + 1:end) - PI;
        elseif ((a(index + 1) - a(index)) <= -3)
            ac(index + 1:end) = ac(index + 1:end) + PI;
        end

    end
