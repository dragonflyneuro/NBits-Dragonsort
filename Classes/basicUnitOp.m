function [obj, e] = basicUnitOp(obj, fh, n, I)
    e = 0;
    if length(I) == length(obj(n(1)).spikeTimes)
        % no point in doing operation
        e = 1;
        return;
    end
    obj = fh(obj, n, I);
    
end