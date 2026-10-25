%% ARM1_geography.m — Topic 6 driver: gravity, market access, tau->1 limit
% =========================================================================
% Uses arm_solve.m (Armington + housing). Seven acts:
%   1. SANITY   symmetric circle, identical fundamentals -> uniform L.
%   2. GRAVITY  bilateral trade shares fall log-linearly with distance
%               (slope = -(sigma-1) x the cost-distance elasticity).
%   3. MARKET ACCESS  identical fundamentals on a LINE -> interior regions
%               are bigger/richer: pure geography (remoteness) at work.
%   4. tau->1   sweep trade costs to frictionless: the dispersion of welfare
%               attributable to LOCATION collapses -> geography vanishes,
%               the model reduces to Topic-3 RR-with-housing.
%   5. SHOCK ON A MAP  the Topic-5 experiment (+20% A in one location) run
%               with and without trade costs. Without, every other location
%               loses the same percentage; with, the response depends on
%               distance. This is the frame that opens the lecture.
%   6. INVERT   recover A and B from (L, w). Amenities are a formula;
%               productivity is a FIXED POINT on trade balance, because A_i
%               enters every price index. The one-shot answer is wrong.
%               Same structure as Topic 7, with commuting in place of trade.
%   7. FROM FILE  act 3 again, but on a geography READ FROM A CSV: 100
%               locations, coordinates and a ready-made distance matrix, plus
%               the three checks to run on any matrix you bring in. This is
%               the act to copy for the lab and for the project.
%
% Runs top-to-bottom unattended; base Matlab only; saves PNGs to ./figures/.
%
% HOW TO READ THIS SCRIPT (and every script of the course library)
%   1. Header (this comment block, before any code): the model in equations,
%      then what the script does, act by act. Read it first; it is the map.
%   2. Parameters at the top, in one block: model parameters and the size of
%      every experiment. No number is typed into a formula further down; to
%      change one, change it here, once.
%   3. Then the seven acts, in the order of the method. Each prints its
%      numbers and saves its figure; every number and figure on the slides
%      comes from here.
%   4. The model's equations are NOT in this file. They live in arm_solve.m
%      (solve) and arm_invert.m (invert), called from here. In Topic 3 the
%      model was small enough to sit in local functions at the bottom of its
%      script; here four callers share one engine: the two drivers, the lab,
%      the projects. Only helpers used by this file alone stay at the bottom.
%   5. A function is a system of equations with a declared choice of knowns
%      and unknowns: arm_solve returns the equilibrium (L,w,P,r,W,pi) for
%      given fundamentals (A,B,H), parameters and tau; arm_invert returns the
%      fundamentals (A,B) for given data (L,w,H). Inputs and outputs travel in
%      structs, so an object can be added without rewriting every call. Names
%      inside a function are local: eq.L is "L" inside, whatever it is called
%      outside (eq39.L, eqW.L).
%   6. So the reading order is not the line order: header, parameters, act 1,
%      jump to the engine when it is first called, come back.
%   7. Run it top to bottom before changing anything; then change one
%      parameter and rerun. Homework and lab scripts have the same shape.
% =========================================================================

clear; clc; close all;
SAVE_FIGS = true;
outdir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if SAVE_FIGS && ~exist(outdir, 'dir'), mkdir(outdir); end

par = struct('sigma', 5, 'mu', 0.7, 'theta_mig', 6);   % Frechet mobility (L4)
Ltot = 100;

%% ==== 1. SANITY: symmetric circle, identical fundamentals ================
n = 12;
ang  = 2*pi*(0:n-1)'/n;
dcirc = min(abs(ang - ang'), 2*pi - abs(ang - ang'));      % arc distance
tau_c = exp(0.5 * dcirc);
fund1 = struct('A', ones(n,1), 'B', ones(n,1), 'H', ones(n,1));
eqc = arm_solve(fund1, par, tau_c, Ltot);
fprintf('=== 1. Symmetric circle: L spread = %.2e (must be ~0) ===\n', ...
        max(eqc.L) - min(eqc.L));
assert(max(eqc.L) - min(eqc.L) < 1e-6, 'symmetry broken!');

%% ==== 2. GRAVITY on the circle ===========================================
% Trade share pi_{ni} vs bilateral distance (off-diagonal pairs).
d = dcirc(:); pv = eqc.pi(:);
keep = d > 0;
bfit = polyfit(d(keep), log(pv(keep)), 1);
fprintf('\n=== 2. Gravity: slope of log(trade share) on distance = %.3f ===\n', bfit(1));
fprintf('    (theory: -(sigma-1) x cost elasticity = %.3f)\n', -(par.sigma-1)*0.5);

fig = figure('Position',[100 100 520 420]); hold on; grid on; box on;
scatter(d(keep), log(pv(keep)), 30, 'filled');
xg = linspace(min(d(keep)), max(d(keep)), 50);
plot(xg, polyval(bfit, xg), 'r-', 'LineWidth', 2);
xlabel('Bilateral distance'); ylabel('log trade share  \pi_{ni}');
title(sprintf('Gravity: trade decays with distance (slope %.2f)', bfit(1)));
save_fig(fig, 'ARM1_gravity', outdir, SAVE_FIGS, 17);

%% ==== 3. MARKET ACCESS: identical fundamentals on a LINE =================
% Every act that uses the model has the same three zones: build the
% experiment, call the engine once, report what came back.
m = 15;                         % the experiment: 15 locations on a line
xs = (1:m)';
dline = abs(xs - xs');          % distance between every pair of them
tau_l = exp(0.5 * dline);       % trade costs built from those distances
fund2 = struct('A', ones(m,1), 'B', ones(m,1), 'H', ones(m,1));  % all alike

eql = arm_solve(fund2, par, tau_l, Ltot);      % the model: one call

remote = sum(dline, 2);         % the output: remoteness, for the right panel

% WHERE THE WAGE COMES FROM, AND WHERE IT DOES NOT. Not from firms sharing a
% bigger market with their workers: here every firm makes ZERO profit, in
% every location, because production is constant returns under perfect
% competition. The mechanism is the opposite one. A central location can
% deliver cheaply to the whole line, so AT A GIVEN WAGE its firms would sell
% more than their wage bill -- profits would be positive, which is not an
% equilibrium. The wage is one of the two margins that compete them away;
% the other is the population that moves in. Firm market access measures how
% much a location can sell at a given cost, and the trade balance turns it
% into the wage, one worker at a time:
%     w_i = ( A_i^(sigma-1) * FMA_i / L_i )^(1/sigma),
%     FMA_i = sum_n tau_ni^(1-sigma) P_n^(sigma-1) X_n.
X_l = eql.w .* eql.L;                       % what each destination spends
FMA = (tau_l.^(1-par.sigma))' * (eql.P.^(par.sigma-1) .* X_l);
cw  = corrcoef(log(FMA), log(eql.w));
ctr = round(m/2);

fprintf('\n=== 3. Market access (identical fundamentals, line) ===\n');
fprintf('    center pop %.2f vs edge pop %.2f (fundamentals are EQUAL)\n', ...
        eql.L(ctr), eql.L(1));
fprintf('    corr(log FMA, log wage) = %+.3f\n', cw(1,2));
fprintf('    center over edge: FMA %.3f, population %.3f, wage %.4f\n', ...
        FMA(ctr)/FMA(1), eql.L(ctr)/eql.L(1), eql.w(ctr)/eql.w(1));
fprintf('      the wage gap is much the smaller: the population that moves in\n');
fprintf('      takes part of the access, and 1/sigma = %.2f flattens the rest\n', 1/par.sigma);

fig = figure('Position',[100 100 870 350]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; bar(eql.L); grid on; box on;
xlabel('Location on the line'); ylabel('Population');
title('Interior wins on pure market access');
nexttile; scatter(remote, eql.W, 40, 'filled'); grid on; box on;
xlabel('Remoteness (\Sigma distance)'); ylabel('Real wage / welfare');
title('Remote = poor, with identical fundamentals');
save_fig(fig, 'ARM1_market_access', outdir, SAVE_FIGS, 20);

% The same act, read on the wage. Both panels have a perfect fit -- on a
% symmetric line every object is monotone in centrality -- so what is worth
% reading is the SLOPE. Left: the wage against access itself, the gradient
% one would measure in data. Right: against access per worker, where the
% slope is exactly 1/sigma because this IS the zero-profit condition and not
% a regression. The left slope is the flatter of the two, and the gap
% between them is the migration that took part of the access away.
gmean_l = @(x) exp(mean(log(x)));
wrel  = log(eql.w / gmean_l(eql.w));
frel  = log(FMA   / gmean_l(FMA));
sell  = FMA ./ eql.L;                       % what one worker can sell
srel  = log(sell / gmean_l(sell));
bw    = polyfit(frel, wrel, 1);             % the measured wage gradient
bL    = polyfit(frel, log(eql.L / gmean_l(eql.L)), 1);
fprintf('    wage gradient in access: measured %.3f, zero profit alone %.3f\n', ...
        bw(1), 1/par.sigma);
fprintf('      the difference is migration: population takes %.0f%% of the access\n', ...
        100*bL(1));

% Both panels have access on the horizontal axis, so the two slopes can be
% compared by eye: the wage carries part of it, the population the rest.
fs = sort(frel);
fig = figure('Position',[100 100 950 390]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; hold on; grid on; box on;
plot(fs, fs/par.sigma, '--', 'LineWidth', 1.5, 'Color', [0.55 0.55 0.55], ...
     'DisplayName', sprintf('zero profit alone, 1/\\sigma = %.2f', 1/par.sigma));
plot(fs, bw(1)*fs + bw(2), 'r-', 'LineWidth', 1.5, ...
     'DisplayName', sprintf('equilibrium, %.2f', bw(1)));
scatter(frel, wrel, 45, 'filled', 'MarkerFaceColor', [0 0.35 0.75], ...
        'HandleVisibility', 'off');
xlabel('log firm market access'); ylabel('log wage');
title('The wage carries part of the access');
legend('Location', 'northwest');
nexttile; hold on; grid on; box on;
scatter(frel, log(eql.L / gmean_l(eql.L)), 45, 'filled');
plot(fs, bL(1)*fs, 'r-', 'LineWidth', 1.5);
xlabel('log firm market access'); ylabel('log population');
title(sprintf('The population carries the rest: %.2f', bL(1)));
%% 
save_fig(fig, 'ARM1_wage_market_access', outdir, SAVE_FIGS, 17);

%% ==== 4. tau->1: the allocation converges to the no-geography benchmark ===
% Random fundamentals. As trade costs fall, market access equalizes and the
% equilibrium must approach the FRICTIONLESS allocation (Topic 3: RR with
% housing, no geography). We measure the DISTANCE of each equilibrium to that
% near-frictionless benchmark -> monotone to zero as kappa -> 0.
rng(5);
A = exp(0.25*randn(m,1)); B = exp(0.15*randn(m,1)); H = ones(m,1);
fund3 = struct('A',A,'B',B,'H',H);
kappa = linspace(0.6, 0.01, 25);
Lall = zeros(m, numel(kappa)); guess = [];
for k = 1:numel(kappa)
    eqk = arm_solve(fund3, par, exp(kappa(k)*dline), Ltot, guess);
    guess = struct('w', eqk.w, 'L', eqk.L);
    Lall(:, k) = eqk.L;
end
Lref = Lall(:, end);                                   % near-frictionless benchmark
dist2ref = sqrt(mean((log(Lall) - log(Lref)).^2, 1));  % RMS distance in log L
fprintf('\n=== 4. tau->1: distance of the allocation to the frictionless benchmark ===\n');
fprintf('    high trade cost: %.4f  ->  near-frictionless: %.4f\n', ...
        dist2ref(1), dist2ref(end));

fig = figure('Position',[100 100 560 420]); hold on; grid on; box on;
plot(kappa, dist2ref, '-o', 'LineWidth', 2);
set(gca,'XDir','reverse');
xlabel('Trade-cost intensity \kappa   (frictionless \rightarrow)');
ylabel('Distance to the no-geography allocation, RMS(\Delta log L)');
title('\tau \rightarrow 1: back to Topic 3 (RR with housing)');
save_fig(fig, 'ARM1_tau_to_one', outdir, SAVE_FIGS, 17);

%% ==== 5. THE LECTURE-4 SHOCK, NOW ON A MAP ===============================
% Topic 5 closed on a fact: with no spatial links, a +20% productivity shock
% in one location costs every other location EXACTLY the same percentage of
% its population -- the neighbour and the far-away place alike. Here the same
% experiment is run on the line, twice: with trade costs, and with tau = 1.
i_sh = round(m/2);
fund3s = fund3;  fund3s.A(i_sh) = 1.20 * fund3s.A(i_sh);
eq0  = arm_solve(fund3,  par, tau_l, Ltot);
eq1  = arm_solve(fund3s, par, tau_l, Ltot, struct('w',eq0.w,'L',eq0.L));
flat = ones(m);
eq0f = arm_solve(fund3,  par, flat, Ltot);
eq1f = arm_solve(fund3s, par, flat, Ltot, struct('w',eq0f.w,'L',eq0f.L));
dgeo  = 100*(eq1.L  ./ eq0.L  - 1);
dflat = 100*(eq1f.L ./ eq0f.L - 1);
dist_sh = abs(xs - i_sh);
oth = setdiff(1:m, i_sh);

fprintf('\n=== 5. The Topic-5 shock on a map (+20%% A in location %d) ===\n', i_sh);
fprintf('    no geography (tau = 1): others lose from %+.3f%% to %+.3f%%  (flat)\n', ...
        min(dflat(oth)), max(dflat(oth)));
fprintf('    with trade costs:       others move from %+.3f%% to %+.3f%%\n', ...
        min(dgeo(oth)), max(dgeo(oth)));
fprintf('    immediate neighbours %+.3f%%, farthest locations %+.3f%%\n', ...
        mean(dgeo(dist_sh == 1)), mean(dgeo(dist_sh == max(dist_sh))));

fig = figure('Position',[100 100 900 400]); hold on; grid on; box on;
plot(dist_sh(oth), dflat(oth), 's', 'MarkerSize', 7, 'LineWidth', 1.5, ...
     'Color', [0.5 0.5 0.5], 'DisplayName', 'no spatial links (\tau = 1): every other location loses the same');
plot(dist_sh(oth), dgeo(oth), 'o', 'MarkerSize', 7, 'MarkerFaceColor', [0 0.35 0.75], ...
     'Color', [0 0.35 0.75], 'DisplayName', 'with trade costs: the response depends on distance');
yline(0, 'k:', 'HandleVisibility', 'off');
xlabel('Distance from the shocked location'); ylabel('\Delta population (%)');
title('The same shock, with and without a map');
legend('Location', 'northeast');
save_fig(fig, 'ARM1_shock_on_a_map', outdir, SAVE_FIGS, 17);

%% ==== 6. INVERT: recover fundamentals -- and meet the fixed point =========
% Hand the baseline equilibrium back as data and recover A and B. The amenity
% step is a formula, as in Topic 2. The productivity step is not: A_i sits in
% every price index, so it can only be found by iterating on trade balance.
% Topic 7 will have exactly this structure, with commuting flows instead.
data = struct('L', eq0.L, 'w', eq0.w, 'H', fund3.H);
inv  = arm_invert(data, par, tau_l, Ltot);
Atrue = fund3.A / exp(mean(log(fund3.A)));
Btrue = fund3.B / exp(mean(log(fund3.B)));
fprintf('\n=== 6. Inversion ===\n');
fprintf('    productivity: fixed point converged in %d iterations (gap %.1e)\n', inv.iter, inv.gap);
fprintf('    max |log error|  A %.1e   B %.1e  -- exact recovery\n', ...
        max(abs(log(inv.A ./ Atrue))), max(abs(log(inv.B ./ Btrue))));
fprintf('    the ONE-SHOT answer (first iteration only): max |log error| A %.3f\n', ...
        max(abs(log(inv.A_oneshot ./ Atrue))));
fprintf('    -> a single pass gets the right ordering and the wrong numbers.\n');
fprintf('       In Topic 2 one pass WAS the answer; here A_i enters every P_n.\n');


%% ==== 7. A GEOGRAPHY READ FROM A FILE: 100 locations =====================
% The experiment: the geography no longer comes out of a formula, it comes out
% of a file -- as it will in the lab and in your project. Two routes into the
% same matrix, both base Matlab (readmatrix reads .xlsx exactly the same way):
%   (a) coordinates -> distances, when the file gives x,y (or lat/lon);
%   (b) a distance matrix someone else already built, read as it is.
datadir = fullfile(fileparts(mfilename('fullpath')), 'data_toy100');
loc   = readtable(fullfile(datadir, 'locations.csv'));      % id,name,x_km,y_km,kind
N     = height(loc);
D     = hypot(loc.x_km - loc.x_km', loc.y_km - loc.y_km');  % (a) from coordinates
Dfile = readmatrix(fullfile(datadir, 'distances_km.csv'));  % (b) ready-made

fprintf('\n=== 7. A geography read from a file: %d locations ===\n', N);
fprintf('    coordinates vs distance file: largest gap %.1e km\n', ...
        max(abs(D(:) - Dfile(:))));
% Three checks to run on ANY distance matrix you bring in, before using it.
assert(max(abs(diag(D))) < 1e-9,        'distances: the diagonal must be zero');
assert(max(max(abs(D - D'))) < 1e-9,    'distances: the matrix must be symmetric');
assert(all(D(:) >= 0),                  'distances: no negative entries');

kap100  = 0.0015;               % per km: 300 km add 57% to the delivered price
tau100  = exp(kap100 * D);      % iceberg costs, tau >= 1 and tau_ii = 1
fund100 = struct('A', ones(N,1), 'B', ones(N,1), 'H', ones(N,1));   % all alike

eq100 = arm_solve(fund100, par, tau100, Ltot);     % the model: one call again

rem100 = mean(D, 2);                               % mean distance to the others
[~, mid] = min(rem100);  [~, edge] = max(rem100);
cc = corrcoef(log(eq100.L), rem100);
fprintf('    most central %s: pop %.2f  |  most remote %s: pop %.2f  (uniform %.2f)\n', ...
        loc.name{mid}, eq100.L(mid), loc.name{edge}, eq100.L(edge), Ltot/N);
fprintf('    corr(log population, remoteness) = %+.3f   [fundamentals are EQUAL]\n', cc(1,2));

fig = figure('Position',[100 100 900 380]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile;
scatter(loc.x_km, loc.y_km, 18 + 150*(eq100.L/max(eq100.L)), eq100.L, 'filled');
colorbar; axis equal tight; grid on; box on;
xlabel('km'); ylabel('km'); title('Population, geography read from a file');
nexttile;
scatter(rem100, eq100.W, 36, 'filled'); grid on; box on;
xlabel('Mean distance to the others (km)'); ylabel('Real wage / welfare');
title('Remote = poor, with identical fundamentals');
save_fig(fig, 'ARM1_geography_from_file', outdir, SAVE_FIGS, 17);

fprintf('\nDone. Figures in %s\n', outdir);

%% ======================== local functions =================================
function save_fig(fig, name, outdir, enable, fs)
    % Export a figure to PNG (150 dpi). No-op if enable is false.
    % fs = font size applied to ALL text before export (default 16).
    % Rule of thumb: with canvas width ~7.6x the slide display width in mm,
    % fs=16 renders ~8pt effective on the slide; raise/lower per figure here.
    if nargin < 5, fs = 16; end
    if enable
        set(findall(fig, '-property', 'FontSize'), 'FontSize', fs);
        set(findall(fig, 'Type', 'Legend'), 'FontSize', max(fs-4, 10));
        exportgraphics(fig, fullfile(outdir, [name '.png']), 'Resolution', 150);
    end
end
