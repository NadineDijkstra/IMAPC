function pred = cumNormGuessPred(x, mu, sig, theta)
% Gets predicted values for cumulative normal psychometric function with lapse rate lamda
% pred = cumNormGuessPred(x, mu, sig, theta)
%
% SF 2012 - edited by ND 2021

for i = 1:length(x)
    
    % get predicted pc for this parameter setting   
    g = 1/(1+exp(-theta));
    pred(i) = g+(1-g)*0.5.*(1 + erf((x(i) - mu)./sqrt(2.*(sig.^2))));
end
