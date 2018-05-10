function [w] = train(inputs, target, iter, rate, sizes)

w = {};
[m, ~] = size(inputs);

%------------------ initial weights

for l = 1:(length(sizes) - 2)
    w{l} = 2 * rand(sizes(l) + 1, sizes(l+1) + 1) - 1;
end

w{l+1} = 2 * rand(sizes(l+1) + 1, sizes(l+2)) - 1;

%------------------ add bias to input

inputs = [ones(m, 1), inputs];

%------------------ train

for i = 1:iter
    
    error = 0;
    
    for s = 1:m
        
        x = {inputs(s,:)};
        
        %---------- forward
        
        for l = 1:length(w)
            prod = x{l} * w{l};
			x{l+1} = sigmf(prod, [1 0]);
        end
        
        %---------- back prop
        
        delta = target(s,:) - x{end};
		d{length(x)} = delta .* sigmf(x{end}, [1 0]) .* (1 - sigmf(x{end}, [1 0]));

		for l = (length(x)-1):-1:1
			d{l} = (d{l+1} * transpose(w{l})) .* sigmf(x{l}, [1 0]).*(1 - sigmf(x{l}, [1 0]));
        end

		for l = 1:length(w)
			w{l} = w{l} + rate .* (transpose(x{l}) * d{l+1});
        end
        
        %---------- calc error

        x = test(inputs(s,:), w, sizes);
        
        e = 0;
        
        for l = 1:length(x)
            e = e + 0.5 * ((target(s,l) - x(l)) .^ 2);
        end
        
        error = error + e;
        
    end
    
    if ~mod(i,10)
        fprintf('iter: %d\n', i);
        fprintf('error: %f\n\n', error);
    end
    
end

end
