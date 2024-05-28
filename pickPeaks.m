function sortedPeaks = pickPeaks(data, supressHelp)
    
    arguments
        data (1, :) double {mustBeNumeric, mustBeNonNan}
        supressHelp logical = false;
    end
    
    if ~supressHelp
        showInstructions()
    end
    
    allPeaks = struct([]);
    peakCount = 1;
    
    figure('units', 'normalized', 'outerposition', [0.05, 0.05, 0.9, 0.9])
    ax = gca;
    plot(ax, 1:length(data), data)
    hold on
    
    [allPeaks, peakCount] = findAllChargePeaks(data, allPeaks, peakCount, ax);
    [allPeaks, peakCount] = findAllDischargePeaks(data, allPeaks, peakCount, ax);
    [allPeaks, ~] = findAllOscillationPeaks(data, allPeaks, peakCount, ax);
    
    sortedPeaks = table2struct(sortrows(struct2table(allPeaks), 'i'));
    
end


function showInstructions()
    msg = {...
        'This program has three stages: charging, discharging, and oscillating.', ...
        '', ...
        'Use the mouse to select x-coorindates near desired peaks.', ...
        '', ...
        'Based on the current state, the peak will be determined using the selected x-coorindates.', ...
        '', ...
        'When all peaks have been found for a certain stage, press ENTER on the keyboard to move to the next stage.', ...
        '', ...
        'All located peaks will be sorted and returned as a struct array.', ...
        };
    h = helpdlg(msg, 'Instructions');
    uiwait(h)
end


function [allPeaks, peakCount] = findAllChargePeaks(data, allPeaks, peakCount, ax)
    ax.Title.String = 'Charging Peaks: Stage 1/3';
    while true
        [x, ~, button] = ginput(1);
        if exitRequested(button)
            break
        end
        
        chargePeak = findChargePeak(data, x);
        allPeaks(peakCount).type = 'Charging';
        allPeaks(peakCount).i = chargePeak;
        allPeaks(peakCount).x = data(chargePeak);
        peakCount = peakCount + 1;
        
        plot(ax, chargePeak, data(chargePeak), 'ro','LineWidth',1.5)
        drawnow
    end
end


function [allPeaks, peakCount] = findAllDischargePeaks(data, allPeaks, peakCount, ax)
    ax.Title.String = 'Discharging Peaks: Stage 2/3';
    while true
        [x, ~, button] = ginput(1);
        if exitRequested(button)
            break
        end
        
        dischargePeak = findDischargePeak(data, x);
        allPeaks(peakCount).type = 'Discharging';
        allPeaks(peakCount).i = dischargePeak;
        allPeaks(peakCount).x = data(dischargePeak);
        peakCount = peakCount + 1;
        
        plot(ax, dischargePeak, data(dischargePeak), 'go','LineWidth',1.5)
        drawnow
    end
end


function [allPeaks, peakCount] = findAllOscillationPeaks(data, allPeaks, peakCount, ax)
    ax.Title.String = 'Oscillating Peaks: Stage 3/3';
    while true
        [x, ~, button] = ginput(1);
        if exitRequested(button)
            break
        end
        
        oscillationPeak = findOscillationPeak(data, x);
        allPeaks(peakCount).type = 'Oscillating';
        allPeaks(peakCount).i = oscillationPeak;
        allPeaks(peakCount).x = data(oscillationPeak);
        peakCount = peakCount + 1;
        
        plot(ax, oscillationPeak, data(oscillationPeak), 'bo','LineWidth',1.5)
        drawnow
    end
    ax.Title.String = '';
end


function y = exitRequested(button)
    y = false;
    if isequal(button, [])
        y = true;
    end
end


function chargePeak = findChargePeak(data, xCoordinate)
    startIdx = getStartIdx(data, xCoordinate);
    for i = startIdx:length(data)-1
        if data(i+1) < data(i)
            chargePeak = i;
            break
        end
    end
    chargePeak = i;
end


function dischargePeak = findDischargePeak(data, xCoordinate)
    startIdx = getStartIdx(data, xCoordinate);
    for i = startIdx:length(data)-1
        if data(i+1) > data(i)
            dischargePeak = i;
            break
        end
    end
    dischargePeak = i;
end


function oscillationPeak = findOscillationPeak(data, xCoordinate)
    startIdx = getStartIdx(data, xCoordinate);
    for i = startIdx:-1:3
        if sign(data(i-1) - data(i)) ~= sign(data(i-2) - data(i-1))
            oscillationPeak = i;
            break
        end
    end
    oscillationPeak = i;
end


function startIdx = getStartIdx(data, xCoordinate)
    idx = (1:length(data)).';
    startIdx = find(idx <= xCoordinate);
    startIdx = startIdx(end);
end








