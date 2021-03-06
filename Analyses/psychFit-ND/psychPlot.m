function psychPlot(x, k, N, params, method, lineCol, markerCol)
% Plot psychometric function that's been fit by psychFit
%
% lineCol and markerCol are optional
%
% SF 2014 - edited by ND 2021

if ~exist('lineCol')
    lineCol = 'k';
end
if ~exist('markerCol')
    markerCol = 'b';
end
base = linspace(min(x), max(x), 200);

switch method
    case 'normal'
        pred = cumNormPred(base, params(1), params(2));    
    case 'normguess'
        pred = cumNormGuessPred(base, params(1), params(2), params(3));  
end

plot(x, k./N, 'Color', markerCol, 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 2, 'LineWidth', 1.5);
hold on
plot(base, pred, 'Color', lineCol, 'LineWidth', 2);