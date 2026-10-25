function eq = arm_solve(fund, par, tau, Ltot, guess)
%ARM_SOLVE  n-region Armington GE with housing (the Topic-6 geography engine).
%
%   eq = arm_solve(fund, par, tau, Ltot)
%   eq = arm_solve(fund, par, tau, Ltot, guess)   % warm start
%
% The cumulative-ladder model once GEOGRAPHY enters: constant returns,
% PERFECT COMPETITION, one Armington variety per location, iceberg trade
% costs. Dispersion comes from HOUSING (fixed stock, as in Topic 3), not
% from decreasing returns to labor. This is the standard QSE convention and
% the clean object behind "the model is a measuring stick": it equals the
% Helpman/Krugman engine (qse_solve) up to the firm-mass term.
%
% MODEL
%   - Good of location i sold everywhere; delivered price p_{ni}=tau_{ni} w_i/A_i.
%   - CES demand across origins, elasticity sigma>1:
%       P_n = ( sum_i (tau_{ni} w_i/A_i)^(1-sigma) )^(1/(1-sigma))
%       pi_{ni} = (tau_{ni} w_i/A_i)^(1-sigma) / P_n^(1-sigma)   (cols=origin)
%   - Cobb-Douglas: share mu on goods, 1-mu on housing (fixed H_i), amenity B_i.
%     Rents redistributed locally => per-capita income = w_i/mu, and goods
%     expenditure in n equals w_n L_n. Trade balance:
%       w_i L_i = sum_n pi_{ni} w_n L_n
%   - Housing market: r_i = ((1-mu)/mu) w_i L_i / H_i
%   - Welfare: W_i = B_i (w_i/mu) / (P_i^mu r_i^(1-mu))
%   - Mobility: utility equalization W_i = W (the eps->inf limit of Topic 5;
%     set par.theta_mig for a finite Frechet elasticity instead).
%   FRICTIONLESS LIMIT tau->1: all P_n equalize, market access is uniform,
%   geography drops out and only fundamentals + housing matter (Topic 3).
%
% INPUTS  fund: struct A,B,H (n x 1). par: sigma, mu, optional theta_mig.
%         tau: n x n iceberg (tau(n,i): origin i -> destination n). Ltot: total pop.
% OUTPUT  eq: L,w,P,r,W (n x 1), Wlevel, pi (n x n), iter, gap.
%
% REQUIRES base Matlab only.
%
% HOW TO READ THIS FUNCTION (and every engine of the course library)
%   1. This is a FUNCTION, not a script: it computes and returns. It never
%      clears the workspace, never prints, never plots. The drivers
%      (ARM1_geography.m, ARM2_german_division.m) and the lab do that.
%   2. The block above is the model in equations plus the meaning of every
%      input and output; "help arm_solve" prints it. Read it first.
%   3. A function is a system of equations with a declared choice of knowns
%      and unknowns. Here the knowns are the fundamentals,
%      the parameters and tau; the unknowns are the equilibrium objects.
%      arm_invert declares the opposite choice on the same equations.
%   4. Inputs and outputs travel in structs, so an object can be added without
%      rewriting every call. Names inside are local and matching is by
%      position: the first argument is "fund" in here, whatever it is
%      called outside.
%   5. The solution is a FIXED POINT, not a formula: the loop corrects a guess
%      until the equilibrium conditions hold. It returns iter and gap so that
%      the caller can check that it converged; converged is not the same as
%      correct, but nothing is right without it.

A = fund.A(:); B = fund.B(:); H = fund.H(:);
n = numel(A); sigma = par.sigma; mu = par.mu;
% Frechet migration elasticity (Topic 5). A finite value is the stable,
% consistent default; make it large to approach utility equalization.
if isfield(par, 'theta_mig'), th = par.theta_mig; else, th = 4; end
if isfield(par, 'lambda'), lam = par.lambda; else, lam = 0; end

damp = 0.3; tol = 1e-11; maxit = 100000;
% Mobility step: with a large Frechet elasticity the population response to
% rents (elasticity -th(1-mu)) overshoots, so the outer step must shrink.
% For th <= 1/(1-mu)*(1/0.3 - 1) (th = 6 at mu = 2/3) this is the plain 0.3.
dampL = min(damp, 1 / (1 + th * (1 - mu)));
if nargin < 5 || isempty(guess)
    w = ones(n, 1); L = Ltot / n * ones(n, 1);
else
    w = guess.w(:); L = guess.L(:);
end

for it = 1:maxit
    Ae = A .* L.^lam;                       % productivity incl. spillover (given L)
    % --- inner: wages from trade balance given L ---
    for itw = 1:5000
        cost = tau .* (w ./ Ae)';           % (n x i): delivered marginal cost
        K    = cost.^(1 - sigma);           % (n x i)
        Pnp  = sum(K, 2);                   % P_n^(1-sigma)
        pai  = K ./ Pnp;                    % trade shares, rows sum to 1
        X    = w .* L;                      % goods expenditure by destination
        sales = pai' * X;                   % sum_n pi_{ni} X_n  (origin i)
        ratio = sales ./ (w .* L);
        w = w .* ratio.^(damp / sigma);
        w = w / exp(mean(log(w)));          % numeraire: geo-mean wage = 1
        if max(abs(ratio - 1)) < 1e-12, break; end
    end

    % --- outer: prices, rents, welfare, mobility ---
    cost = tau .* (w ./ Ae)'; Pnp = sum(cost.^(1 - sigma), 2);
    P = Pnp.^(1 / (1 - sigma));
    r = ((1 - mu) / mu) * (w .* L) ./ H;
    W = B .* (w / mu) ./ (P.^mu .* r.^(1 - mu));

    Wn = W / exp(mean(log(W)));             % normalize to keep W.^th in range
    Lnew = Ltot * Wn.^th / sum(Wn.^th);     % Frechet mobility (Topic 5)
    gap = max(abs(Lnew - L) ./ L);
    L = (1 - dampL) * L + dampL * Lnew;
    if gap < tol, break; end
end
if gap >= tol
    error('arm_solve:noconvergence', 'not converged after %d iters (gap %.1e)', maxit, gap);
end

Ae = A .* L.^lam;
cost = tau .* (w ./ Ae)'; Pnp = sum(cost.^(1 - sigma), 2);
eq = struct('L', L, 'w', w, 'P', Pnp.^(1/(1-sigma)), 'r', r, 'W', W, ...
            'Wlevel', mean(W), 'pi', cost.^(1-sigma) ./ Pnp, ...
            'iter', it, 'gap', gap, 'Aeff', Ae);
end
