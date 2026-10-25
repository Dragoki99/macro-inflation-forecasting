function inv = arm_invert(data, par, tau, Ltot)
%ARM_INVERT  Recover fundamentals from data in the Armington geography model.
%
%   inv = arm_invert(data, par, tau, Ltot)
%
% The Topic-6 inversion: given observed populations and wages, and the
% trade-cost matrix, recover the productivity A_i and amenity B_i of every
% location. Two steps, and they are NOT alike -- that is the lesson.
%
%   step 1  PRODUCTIVITY is a FIXED POINT. A_i sets the delivered price of
%           i's good in every market n, hence every price index P_n, hence
%           every location's spending on i. Raising A_i changes sales
%           everywhere, and everyone else's A does the same to i. There is no
%           formula: guess, compute where spending goes, raise A where the
%           model sells too little, repeat.
%   step 2  AMENITIES are a FORMULA. Once A (and so P) is known, the mobility
%           condition pins B_i location by location, no interaction.
%
% Compare with Topic 2, where BOTH steps were formulas, and Topic 7, where
% the same two-step structure returns with commuting flows in place of trade
% flows: wages by fixed point, then productivity and amenities in closed form.
% The fixed point appears exactly when the data to be rationalized are a
% NETWORK -- bilateral flows -- rather than a list of location-level numbers.
%
% IDENTIFICATION. Scale all A by a constant and every trade share is unchanged;
% scale all B and every population share is unchanged. Both are recovered up
% to a geometric-mean normalization, as in every inversion of this course.
%
% SPILLOVER. With par.lambda > 0 the fixed point recovers the EFFECTIVE
% productivity A_i L_i^lambda; the fundamental is then A_i = Aeff_i / L_i^lambda,
% exactly as Topic 7 strips the externality from the inverted productivity.
%
% INPUTS  data: struct L, w, H (n x 1).  par: sigma, mu, theta_mig, lambda (opt).
%         tau: n x n iceberg, tau(n,i) origin i -> destination n.  Ltot.
% OUTPUT  inv: A, B, P, r, c (competitiveness), iter, gap, A_oneshot
%         (A after ONE iteration from a flat guess -- the closed-form-looking
%         answer that is wrong, kept to show why iterating is needed).
%
% Base Matlab only.
%
% HOW TO READ THIS FUNCTION (and every engine of the course library)
%   1. This is a FUNCTION, not a script: it computes and returns. It never
%      clears the workspace, never prints, never plots. The drivers
%      (ARM1_geography.m, ARM2_german_division.m) and the lab do that.
%   2. The block above is the model in equations plus the meaning of every
%      input and output; "help arm_invert" prints it. Read it first.
%   3. A function is a system of equations with a declared choice of knowns
%      and unknowns. Here the knowns are the data (L,w,H),
%      the parameters and tau; the unknowns are the fundamentals A and B.
%      arm_solve declares the opposite choice on the same equations.
%   4. Inputs and outputs travel in structs, so an object can be added without
%      rewriting every call. Names inside are local and matching is by
%      position: the first argument is "data" in here, whatever it is
%      called outside.
%   5. The solution is a FIXED POINT, not a formula: the loop corrects a guess
%      until the equilibrium conditions hold. It returns iter and gap so that
%      the caller can check that it converged; converged is not the same as
%      correct, but nothing is right without it.

    L = data.L(:); w = data.w(:); H = data.H(:);
    n = numel(L); sigma = par.sigma; mu = par.mu;
    if isfield(par, 'theta_mig'), th = par.theta_mig; else, th = 4; end
    if isfield(par, 'lambda'), lam = par.lambda; else, lam = 0; end
    gmean = @(x) exp(mean(log(x)));

    % ---------------------------------------------------------------- step 1
    % Competitiveness c_i = (w_i/A_i)^(1-sigma). Trade shares depend on c only
    % through ratios, so c is identified up to scale.
    T = tau.^(1 - sigma);                 % (n x i)
    X = w .* L;                           % spending by destination
    c = ones(n, 1);
    damp = 0.5; tol = 1e-12; maxit = 20000;
    for it = 1:maxit
        K     = T .* c';                  % (n x i)
        pai   = K ./ sum(K, 2);           % trade shares, rows sum to 1
        sales = pai' * X;                 % what the model says i sells
        gap   = max(abs(log(sales ./ X)));
        if it == 1                        % the one-shot answer, for the record
            c1 = c .* (X ./ sales);
            A_oneshot = w ./ c1.^(1/(1-sigma));
            A_oneshot = A_oneshot / gmean(A_oneshot);
        end
        if gap < tol, break; end
        c = c .* (X ./ sales).^damp;      % sell too little -> more competitive
        c = c / gmean(c);
    end
    if it == maxit
        warning('arm_invert:noconv', 'trade balance not solved: gap %.1e', gap);
    end
    Aeff = w ./ c.^(1/(1-sigma));  Aeff = Aeff / gmean(Aeff);
    A = Aeff ./ L.^lam;  A = A / gmean(A);      % strip the spillover

    % ---------------------------------------------------------------- step 2
    % Prices and rents follow from A and the data; amenities from mobility.
    K   = T .* c';
    P   = sum(K, 2).^(1/(1-sigma));
    r   = ((1 - mu)/mu) * (w .* L) ./ H;
    Wn  = (L / Ltot).^(1/th);             % W_i up to scale, from the share
    B   = Wn .* P.^mu .* r.^(1-mu) * mu ./ w;
    B   = B / gmean(B);

    inv = struct('A',A,'Aeff',Aeff,'B',B,'P',P,'r',r,'c',c,'iter',it,'gap',gap, ...
                 'A_oneshot',A_oneshot);
end
