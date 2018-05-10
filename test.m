function [x] = test(inputs, w, sizes)
        
x = inputs;

if sizes(1) == length(inputs)
    x = [ones(1), inputs];
end

for l = 1:length(w)
    x = sigmf(x * w{l}, [1 0]);
end

end
