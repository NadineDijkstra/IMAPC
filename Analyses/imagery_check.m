function include = imagery_check(cfg)

v2struct(cfg)

nTrls = length(data.main);
nTrlsBlock = nTrls/num_blocks;
ima_check = sum(data.main(:,6)==1)/nTrlsBlock;
if ima_check/num_blocks > 0.7
    fprintf('\t Answered imagery check correctly on %d out of %d blocks, including in analysis \n',ima_check,num_blocks);
    include = 1;
else
    fprintf('\t Answered imagery check correctly on %d out of %d blocks, excluding this participant \n',ima_check,num_blocks);
    include = 0;
end