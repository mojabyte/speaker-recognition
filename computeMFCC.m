function [pitch, mfcc] = computeMFCC(s, fs)

highCutoff = 600; % Pitch will not be higher than this
lowCutoff = 50;  % Pitch will not be lower than this
pwrThreshold = -50; % Frames with power below this threshold are likely to be silence
freqThreshold = 1000; % Frames with zero crossing rate above this threshold are likely to be silence or unvoiced speech
clipLevel = 68; % Center clip level for pitch detection

bpf = audiopluginexample.VarSlopeBandpassFilter(lowCutoff,highCutoff,'48','48');
interp4 = dsp.FIRInterpolator(8,designMultirateFIR(4,1));
interp8 = dsp.FIRInterpolator(8,designMultirateFIR(8,1));
interp12 = dsp.FIRInterpolator(8,designMultirateFIR(12,1));
interp16 = dsp.FIRInterpolator(8,designMultirateFIR(16,1));
interp20 = dsp.FIRInterpolator(8,designMultirateFIR(20,1));
mfccComputer = audioexample.MelFrequencyCepstralCoefficients('SampleRate',fs);

% Audio data will be divided into frames of 30 ms with 75% overlap
frameTime = 30e-3;
samplesPerFrame = floor(frameTime*fs); 
startIdx = 1;
stopIdx = samplesPerFrame;
increment = floor(0.25*samplesPerFrame);
pitch = [];
mfcc = [];
pPrev = nan;

while 1
    xFrame = s(startIdx:stopIdx,1); % 30ms frame
    p = nan;
    
    % Compute pitch
    if audiopluginexample.SpeechPitchDetector.isVoicedSpeech(xFrame,fs,...
            pwrThreshold,freqThreshold)
        xFiltered = bpf(xFrame);
        p = audiopluginexample.SpeechPitchDetector.autoCorrelationPitchDecision(...
            xFiltered,fs,clipLevel,frameTime,interp4,interp8,interp12,...
            interp16,interp20,highCutoff,lowCutoff);
        p = audiopluginexample.SpeechPitchDetector.penalizeJumps(pPrev,p,20);
    end
    pitch = [pitch; p];
    pPrev = p;
    
    % Compute MFCC
    if ~isnan(p)
        [c,logE] = mfccComputer(xFrame);
        c(1) = logE;
    else
        c = nan(13,1);
    end
    mfcc = [mfcc; c.'];

    startIdx = startIdx + increment;
    stopIdx = stopIdx + increment;
    if stopIdx > size(s, 1)
        break;
    end
end

end