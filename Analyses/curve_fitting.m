function [params,curves,BIC,props] = curve_fitting(cfg)
% using Steve's PF functions

v2struct(cfg)

% first exlude blocks with incorrect imagery check
data.main(data.main(:,6)~=1,:) = [];

% get indices per condition
idx{1} = ismember(data.main(:,2),[0,3]); % no imagery
idx{2} = ismember(data.main(:,2),[1,5]); % congruent
idx{3} = ismember(data.main(:,2),[2,4]); % incongruent

% save RTs per condition per response
results.RTs = zeros(3,1);
for i=1:3    
    ind = idx{i} & data.main(:,3)==1 & data.main(:,4) <5000;
    results.RTs(i,1) = mean(data.main(ind,4));
    ind = idx{i} & data.main(:,3)==0 & data.main(:,4) <5000;
    results.RTs(i,2) = mean(data.main(ind,4));    
end

%% split responses per condition
nLevels = length(cfg.levels);
responses = zeros(nLevels,3,3);
level_idx = unique(data.main(:,1));
for i = 1:3
    for v = 1:length(cfg.levels)
        ind = idx{i} & data.main(:,1) == level_idx(v);
        responses(v,1,i) = cfg.levels(v); % x 
        responses(v,2,i) = sum(data.main(ind,3)); % k
        responses(v,3,i) = sum(ind); % n
    end        
end
x = reshape(responses(:,1,:),nLevels*3,1);
k = reshape(responses(:,2,:),nLevels*3,1);
N = reshape(responses(:,3,:),nLevels*3,1);
c = [ones(nLevels,1); ones(nLevels,1)*2; ones(nLevels,1)*3];

% get proportion presence per level per condition
props = nan(length(cfg.levels),3);
for i = 1:3
    for v = 1:length(cfg.levels)
        props(v,i) = responses(v,2,i)./responses(v,3,i);
    end
end

%% Fit the PC models

% fit model
params = zeros(3,3); fval = zeros(3,1);
for cnd = min(c):max(c)
    pArray = [0.05 0.05 -8];
    [params(cnd,:), fval] = psychFit(x(c==cnd), k(c==cnd),...
        N(c==cnd), pArray, 'normguess');
    % compute BIC - goodness of fit
    LL = sum(log(fval)); % convert pmf to LL
    BIC(cnd) = -2 * LL + log(sum(N(c==cnd))) * length(pArray);
end

% get curves
base = linspace(min(x), max(x), 1000);
curves = zeros(length(base),length(unique(c)));
for cnds = min(c):max(c)
    curves(:,cnds) = cumNormGuessPred(base, ...
       params(cnds,1),params(cnds,2),params(cnd,3));
end



if cfg.plotting
   figure;
   for cnd = min(c):max(c)
       subplot(1,3,cnd);
       plot(x(c==cnd), k(c==cnd)./N(c==cnd), 'Color', 'k', 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 2, 'LineWidth', 1.5);
       hold on
       plot(base, curves(:,cnd), 'Color', 'k', 'LineWidth', 2);
   end
end

