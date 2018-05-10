function [out] = readDir(mod, input, sizes, iterations, rate)

out = '';

%------------------ train

if mod == 1

    data_dir = dir(input);
    data_dir = data_dir([data_dir.isdir]);
    data_dir = [data_dir(3:end) [] []];
    
    speaker_to_mfcc = [struct('name','','mfcc',[]), struct('name','','mfcc',[])];
    
    disp('loading files...');

    for i = 1:length(data_dir)
        disp('------------------------------');
        fprintf('%s    %%%.2f\n', data_dir(i).name, (i-1)/length(data_dir)*100);
        disp('------------------------------');
        
        wav_files = dir([input, '/', data_dir(i).name, '/*.wav']);
        mfcc = [];
        for j = 1:length(wav_files)
            
            [s, fs] = audioread([input, '/', data_dir(i).name, '/', wav_files(j).name]);
            
            [~, m] = computeMFCC(s, fs);
            m = m(m(:,1) > -inf,:);
            mfcc = [mfcc; normalize(mean(m))];
            
            fprintf('%%%.2f\n', j/length(wav_files)*100);
        end
        speaker_to_mfcc(i).name = data_dir(i).name;
        speaker_to_mfcc(i).mfcc = mfcc;
    end
    
    disp('training...');

    inputs = [];
    target = [];
    names = {};
    s_num = 1;

    for s = 1:length(speaker_to_mfcc)
        for i = 1:length(speaker_to_mfcc(s).mfcc(:,1))
            tar = zeros(1, length(speaker_to_mfcc));
            tar(s_num) = 1;
            
            inputs = [inputs; speaker_to_mfcc(s).mfcc(i,:)];
            target = [target; tar];
        end
        names{s} = speaker_to_mfcc(s).name;
        s_num = s_num + 1;
    end

    sizes = [sizes, length(speaker_to_mfcc)];

    weights = train(inputs, target, iterations, rate, sizes);

    save('weights.mat', 'weights');
    save('names.mat', 'names');

%------------------ recognize

else
    if mod == 2
        s = input{1};
        fs = input{2};
        sound(s, fs);
    else
        [s, fs] = audioread(input);
        sound(s, fs);
    end
    
    load('weights.mat');

    [~, m] = computeMFCC(s, fs);
    m = m(m(:,1) > -inf,:);
    mfcc = normalize(mean(m));

    out = test(mfcc, weights, sizes);

end

end
