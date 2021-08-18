function [params, fVal] = psychFit(x, k, N, pArray, method)
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
% pArray(3) - guess rate (only for normal + guess model)
%
% method = 'normal' or 'normguess' 
%
% params - fitted values of mu and sig (and lamda)
%
% Steve Fleming 2014 sf102@nyu.edu - edited by ND 2021

options = optimset;
[params, fVal] = fminsearch(@fitfunc, pArray, options);

    function negLL = fitfunc(pArray)
                
                mu = pArray(1);
                sig = pArray(2);
                
                switch method
                    case 'normal'                         
                       pmf = cumNormBinoPMF(x, mu, sig, N, k);                      
                        
                    case 'normguess'
                        g   = pArray(3);
                        pmf = cumNormGuessBinoPMF(x, mu, sig, g, N, k);
                end
                
                negLL = -sum(log(pmf));                
    end

end