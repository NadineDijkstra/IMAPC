function BIC = model_comparison(cfg)
% using Steve's PF functions

v2struct(cfg)
BIC = nan(2,2,2);

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

% only select congruent and incongruent
x(c==1) = []; k(c==1) = []; N(c==1) = [];
c(c==1) = []; c(c==3) = 1;

%% Fit the different PC models
cnt2 = 1; cs = ['k','b','r']; pls = ['m','s','g']; 
for m = 1:2 % shared or free
    if m == 1; mu = 0.05; else; mu = [0.05 0.05]; end
    for s = 1:2
        if s == 1; sig = 0.05; else; sig = [0.05 0.05]; end
        for g = 1:2
            if g == 1; gu = -8; else; gu = [-8 -8]; end
            
            fixedfree = [m s g];
            pArray    = [mu sig gu];
            nP        = length(pArray); % number of free parameters
            
            % fit model
            [params, fval] = psychFitLoopModels(x, k, N, c, pArray, fixedfree);
            
            % plot fit
            if cfg.plotting
            cnt = 1; nCond = length(unique(c));
            if fixedfree(1)==1; muI = params(cnt); cnt = cnt+1;
            else; muI = params(cnt:cnt+nCond-1); cnt = cnt+nCond; end
            if fixedfree(2)==1; sigI = params(cnt); cnt = cnt+1;
            else; sigI = params(cnt:cnt+nCond-1); cnt = cnt+nCond; end
            if fixedfree(3)==1; gI = params(cnt); cnt = cnt+1;
            else; gI = params(cnt:cnt+nCond-1); cnt = cnt+nCond; end
        
            subplot(2,4,cnt2)
            base = linspace(min(x), max(x), 1000);
            for i = min(c):max(c)
                if length(muI) > 1; muC = muI(i); else; muC = muI; end
                if length(sigI) > 1; sigC = sigI(i); else; sigC = sigI; end
                if length(gI) > 1; gC = gI(i); else; gC = gI; end
                
                pred = cumNormGuessPred(base, muC, sigC, gC);
                plot(x(c==i), k(c==i)./N(c==i), 'Color', cs(i), 'LineStyle', 'none', 'Marker', 'o', 'MarkerSize', 2, 'LineWidth', 1.5);
                hold on; plot(base, pred, 'Color', cs(i), 'LineWidth', 2);hold on;
            end            
            fixed = [m,s,g]==1; title(['free: ' pls(~fixed)]);
            end
            
            % compute BIC
            LL = sum(log(fval)); % convert pmf to LL
            BIC(m,s,g) = -2 * LL + log(sum(N(:))) * nP;
            
            cnt2 = cnt2+1;
        end       
    end
end


