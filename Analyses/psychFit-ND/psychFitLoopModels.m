function [params, fVal] = psychFitLoopModels(x, k, N, c, pArray, fixedfree)
% Wrapper code for maximum likelihood fitting of the psychometric function
%
% params = psychFit(x, k, N, pArray)
%
% x - x-axis bin values
% k - counts of response "A" in bin x(i)
% N - total number of responses in each bin
%
% pArray - starting values for parameters
% pArray(1) - mu
% pArray(2) - sig
% pArray(3) - lapse rate (only for normal + lapse model)
%
% method = 'normal' or 'normguess'
%
% params - fitted values of mu and sig (and lamda)
%
% Steve Fleming 2014 sf102@nyu.edu - edited by ND 2021

options = optimset('MaxFunEvals',1e10);
[params, fVal] = fminsearch(@fitfunc, pArray, options);

    function negLL = fitfunc(pArray)        
               
        cnt = 1; nCond = length(unique(c));
        if fixedfree(1)==1; mu = pArray(cnt); cnt = cnt+1; 
        else; mu = pArray(cnt:cnt+nCond-1); cnt = cnt+nCond; end
        if fixedfree(2)==1; sig = pArray(cnt); cnt = cnt+1; 
        else; sig = pArray(cnt:cnt+nCond-1); cnt = cnt+nCond; end
        if fixedfree(3)==1; g = pArray(cnt); cnt = cnt+1; 
        else; g = pArray(cnt:cnt+nCond-1); cnt = cnt+nCond; end
        
        pmf = [];
        for i = min(c):max(c)
            if length(mu) > 1; muC = mu(i); else; muC = mu; end
            if length(sig) > 1; sigC = sig(i); else; sigC = sig; end
            if length(g) > 1; gC = g(i); else; gC = g; end
            
            pmf = [pmf,cumNormGuessBinoPMF(x(c==i), muC, sigC, gC, N(c==i), k(c==i))];
        end
        
        negLL = -sum(log(pmf));
        
    end

end