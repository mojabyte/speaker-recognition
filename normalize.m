function [mfcc] = normalize(mfcc)

mini = min(mfcc);
maxi = max(mfcc);

mfcc = (mfcc - mini) / (maxi - mini);

end