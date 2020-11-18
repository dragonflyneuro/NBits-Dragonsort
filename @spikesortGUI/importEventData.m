function [output, statusStr] = importEventData(fN)

output = [];
input = load(fN);
vars = fieldnames(input);

if length(vars) > 2 || length(vars) < 1
    statusStr = "Too many or too few variables found!";
    return;
end

% 1 variable case
if length(vars) == 1
    if min(size(input.(vars{1}))) > 2 || min(size(input.(vars{1}))) < 1
        statusStr = "Variable size does not make sense!";
        return;
    end
    
    output = input.(vars{1});
    
% 2 variable case
else
    if input.(vars{1}) > input.(vars{2})
        output(1,:) = input.(vars{2});
        output(2,:) = input.(vars{1});
    else
        output(1,:) = input.(vars{1});
        output(2,:) = input.(vars{2});
    end
end

statusStr = "Ready";

end