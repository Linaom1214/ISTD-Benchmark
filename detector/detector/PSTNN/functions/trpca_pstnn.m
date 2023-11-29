function [L,S] = trpca_pstnn(X, lambda, tenW, opts)

tol = 1e-3; 
max_iter = 500;
rho = 1.05;
mu = 2*1e-3;
max_mu = 1e10;
DEBUG = 0;
N = rankN(X,0.1);


if ~exist('opts', 'var')
    opts = [];
end    
if isfield(opts, 'tol');         tol = opts.tol;              end
if isfield(opts, 'max_iter');    max_iter = opts.max_iter;    end
if isfield(opts, 'rho');         rho = opts.rho;              end
if isfield(opts, 'mu');          mu = opts.mu;                end
if isfield(opts, 'max_mu');      max_mu = opts.max_mu;        end
if isfield(opts, 'DEBUG');       DEBUG = opts.DEBUG;          end
if isfield(opts, 'N');           N = opts.N;                  end

dim = size(X);
L = zeros(dim);
S = zeros(dim);
Y = zeros(dim);
weightTen = ones(dim);
for iter = 1 : max_iter
    
    preT = sum(S(:) > 0);
    
    % update L
    R = -S+X-Y/mu;
    L = prox_pstnn(R,N,mu);
    
    % update S
    T = -L+X-Y/mu;
    S = prox_l1(T, weightTen*lambda/mu);    
    weightTen = N./ (abs(S) + 0.01)./tenW;
  
    dY = L+S-X;
    err = norm(dY(:))/norm(X(:));
    if DEBUG
        if iter == 1 || mod(iter, 1) == 0            
            disp(['iter ' num2str(iter) ', mu=' num2str(mu) ...
                   ', err=' num2str(err)...
                    ',|T|0 = ' num2str(sum(S(:) > 0))]); 
        end
    end
    currT = sum(S(:) > 0);
    if err < tol || (preT>0 && currT>0 && preT == currT)
        break;
    end 
    Y = Y + dY*mu;
    mu = min(rho*mu,max_mu);    
end

function N = rankN(X, ratioN)
    [~,~,n3] = size(X);
    D = Unfold(X,n3,1);
    [~, S, ~] = svd(D, 'econ');
    [desS, ~] = sort(diag(S), 'descend');
    ratioVec = desS / desS(1);
    idxArr = find(ratioVec < ratioN);
    if idxArr(1) > 1
        N = idxArr(1) - 1;
    else
        N = 1;
    end