function pmf = cumNormGuessBinoPMF(x, mu, sig, theta, N, k)
% Gets binomial probability masses for fitting the cumulative normal psychometric function

% SF 2012 - edited by ND 2021 using http://matlaboratory.blogspot.com/2015/05/fitting-better-psychometric-curve.html

for i = 1:length(x)
    
    % get predicted pc for this parameter setting  
    g = 1/(1+exp(-theta));
    pc = g+(1-g)*0.5.*(1 + erf((x(i) - mu)./sqrt(2.*(sig.^2))));
    
    % get binomial pmf relating choices to predicted pc
    pmf(i) = nchoosek(N(i),k(i)).*(pc.^k(i)).*((1-pc).^(N(i)-k(i)));
    
end