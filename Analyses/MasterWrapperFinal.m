% add paths etc
clear;
addpath('Analyses');
addpath('Analyses\psychFit-ND');

dataDir = 'Data';

load('Analyses/vis_levels');

nSubs     = length(str2fullfile(dataDir,'*mat'));
sub_idx   = 1:nSubs;


%% Remove subjects

% because of imagery
for sub = 1:nSubs    
    load(fullfile(dataDir,sprintf('sub_%03d.mat',sub)),'data');
    cfg             = [];
    cfg.data        = data;
    cfg.levels      = [0; visibility_levels];
    cfg.num_blocks  = 12;
    include(sub) = imagery_check(cfg);
end

fprintf('Removed %d subjects due to failure imagery check \n', sum(~include));
rm_idx  = find(~include);

% because of data quality
exclude_based_on_data = [2 19];
rm_idx = unique([rm_idx exclude_based_on_data]);
fprintf('Removed %d subjects due to bad data \n', length(exclude_based_on_data));

sub_idx(rm_idx) = []; nSubs = length(sub_idx);
fprintf('Continuing analysis with %d participants \n',nSubs);

%% Analyze the data

% get descriptives
for sub = 1:nSubs
    load(fullfile(dataDir,sprintf('sub_%03d.mat',sub_idx(sub))),'data');
    
    [V(sub),A(sub),IQ{sub},C{sub},IC{sub}] = get_descriptives(data);    
end

% curve fitting
params = nan(nSubs,3,3); curves = nan(nSubs,1000,3); 
fval = nan(nSubs,3); props = nan(nSubs,length(cfg.levels),3);
for sub = 1:nSubs
    load(fullfile(dataDir,sprintf('sub_%03d.mat',sub_idx(sub))),'data');

    cfg             = [];
    cfg.data        = data;
    cfg.levels      = [0; visibility_levels];
    cfg.num_blocks  = 12;
    cfg.plotting    = false; % plot the individual data?
    
    [params(sub,:,:),curves(sub,:,:),fval(sub,:),props(sub,:,:)] = curve_fitting(cfg);
end
% convert theta to guess rate
params(:,:,3) = 1./(1+exp(-params(:,:,3)));

%% Plot the results 
figure; 
cs = ['k','b','r'];
log_base = logspace(log10(cfg.levels(1)+0.1), log10(max(visibility_levels)+0.1), 100);
lin_base = linspace(cfg.levels(1)+0.1, max(visibility_levels)+0.1, 1000);
lin_idx  = nan(100,1);
for v = 1:100; [~,lin_idx(v)] = min(abs(lin_base-log_base(v))); end
for c = 1:3
    
    semilogx(lin_base,squeeze(mean(curves(:,:,c))),cs(c),'LineWidth',2); hold on;
       
    semilogx(cfg.levels+0.1,squeeze(mean(props(:,:,c),1)),'marker','*',...
        'color',cs(c),'LineWidth',2,'LineStyle', 'none'); hold on;
    
    hold on;
    for v = 1:length(cfg.levels) % plot SD
        SEM = std(squeeze(props(:,v,c)))/sqrt(nSubs);
        m   = mean(squeeze(props(:,v,c)));
        mSEM = [m-SEM m+SEM];
        semilogx([cfg.levels(v)+0.1 cfg.levels(v)+0.1],mSEM,'color',cs(c),...
            'LineWidth',2,'LineStyle', '-'); hold on;
    end
end
grid on; xlabel('Visibility'); ylabel('p(presence'); 

% plot the parameters
figure;
pNames = {'mean','variance','guess rate'};
for p = 1:3
    subplot(3,1,p)
    
    barwitherr(squeeze(std(params(:,:,p),[],1))./sqrt(nSubs),...
        squeeze(mean(params(:,:,p)))); hold on

    set(gca,'XTickLabels',{'no imagery','congruent','incongruent'});
    title(pNames{p})
end