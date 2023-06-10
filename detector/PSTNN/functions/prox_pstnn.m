function [X] = prox_pstnn(Y,N,mu)

[n1,n2,n3] = size(Y);
X = zeros(n1,n2,n3);
Y = fft(Y,[],3);
tau = 1/mu;


% first frontal slice
[U,S,V] = svd(Y(:,:,1),'econ');
diagS = diag(S);
[desS, sIdx] = sort(diagS, 'descend');
[desU, desV] = deal(U(:, sIdx), V(:, sIdx));
[U1, diagS1, V1] = deal(desU(:, 1:N), desS(1:N), desV(:, 1:N));
[U2, diagS2, V2] = deal(desU(:, N+1:end), desS(N+1:end), desV(:, N+1:end));    
threshS2 = max(diagS2-tau, 0);    
X(:,:,1) = U1*diag(diagS1)*V1' + U2*diag(threshS2)*V2';


% i=2,...,halfn3
halfn3 = round(n3/2);
for i = 2 : halfn3
    [U,S,V] = svd(Y(:,:,i),'econ');
    diagS = diag(S);
    [desS, sIdx] = sort(diagS, 'descend');
    [desU, desV] = deal(U(:, sIdx), V(:, sIdx));
    [U1, diagS1, V1] = deal(desU(:, 1:N), desS(1:N), desV(:, 1:N));
    [U2, diagS2, V2] = deal(desU(:, N+1:end), desS(N+1:end), desV(:, N+1:end));    
    threshS2 = max(diagS2-tau, 0);    
    X(:,:,i) = U1*diag(diagS1)*V1' + U2*diag(threshS2)*V2';
    X(:,:,n3+2-i) = conj(X(:,:,i));
end
  
% if n3 is even
if mod(n3,2) == 0
    i = halfn3+1;
    [U,S,V] = svd(Y(:,:,i),'econ');
    diagS = diag(S);
    [desS, sIdx] = sort(diagS, 'descend');
    [desU, desV] = deal(U(:, sIdx), V(:, sIdx));
    [U1, diagS1, V1] = deal(desU(:, 1:N), desS(1:N), desV(:, 1:N));
    [U2, diagS2, V2] = deal(desU(:, N+1:end), desS(N+1:end), desV(:, N+1:end));    
    threshS2 = max(diagS2-tau, 0);    
    X(:,:,i) = U1*diag(diagS1)*V1' + U2*diag(threshS2)*V2';
end

X = ifft(X,[],3);