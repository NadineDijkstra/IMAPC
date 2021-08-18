function rm_idx = check_PC_fits(cfg)

% load results and check
rm_idx = []; c = 1;
for sub = 1:length(cfg.results)
    load(cfg.results{sub},'results');
    
    if isstruct(results)
        excl = eval(cfg.excl);
        if excl
            rm_idx = [rm_idx; sub];
            ex_res{c} = results; c = c +1;
        end
    end
    
    clear results
end

fprintf('Removed %d subs because of bad PC fits \n',length(rm_idx));

% plot bad subjects
if cfg.plot
figure; ima = {'k','b','r'};
for sub = 1:length(rm_idx)
    subplot(2,ceil(length(rm_idx)/2),sub)
    for i = 1:3
            semilogx(ex_res{sub}.vis_curve+0.1,ex_res{sub}.curves(:,i),....
                'color',ima{i},'LineStyle','-','LineWidth',2);  hold on;
            semilogx(cfg.levels+0.1,ex_res{sub}.proportions(:,i),'marker','*',...
                'color',ima{i},'LineWidth',2,'LineStyle', 'none'); hold on;
    end
    xlabel('log(visibility) + 0.1'); ylabel('p(presence)');
    title(sprintf('Subject %d',rm_idx(sub)))
end
end
    