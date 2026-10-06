%% RR1_hw_amenities_panel.m — Homework: the population-amenities panel
% =========================================================================
% Spatial and Regional Economics, Module A (2026-27) — Topic 3: Rosen-Roback
%
% THE PUZZLE
%   Look again at the population-amenities panel of the lecture figure
%   (RR1_no_housing.m, Part 4): locations with higher recovered amenities do
%   not host more people. Utility is U = w*B, so people value amenities.
%   Something is going on.
%
% TASKS (diagnosis; the resolution comes with Topic 3 and its own script)
%   (a) Run the script as it is: (L,w) are drawn as in the lecture script
%       and the four panels are rebuilt. Describe the anomaly in the
%       population-amenities panel precisely (which slope, why it is
%       surprising given U = w*B).
%   (b) Identify the assumption in the way the random (L,w) are drawn that
%       is at odds with a fact documented in Topic 1. Which assumption?
%       Which fact? MODIFY the data-generating block below so as to remove
%       it, with a magnitude you can justify from the Topic-1 evidence.
%       Predict the sign of the population-amenities panel before running,
%       using only the inversion formula B_i proportional to 1/w_i; then
%       verify. What do you conclude about the model without housing as a
%       measurement device?
%   (c) Suppose amenities had a spillover, B_i = b_i * L_i^eta with b_i
%       exogenous. Would the population-amenities panel (TOTAL B) change?
%       And a panel built with the exogenous component b_i? Justify using
%       the inversion formulas.
%   (d) Bonus: derive the OLS slope of the population-amenities panel as a
%       function of cov(log L, log w) and var(log w), and verify your
%       formula numerically against the printed slopes.
%
% MODEL (the one of RR1_no_housing.m; no land, no spillovers)
%   Labor demand:   w_i = A_i * K_i^gamma * L_i^(-gamma)
%   Utility:        U_i = w_i * B_i = W  for every inhabited i
%   Inversion:      A_i = w_i L_i^gamma K_i^(-gamma),   B_i = W / w_i
%                   (W pinned by the normalization mean(B) = 1)
%
% HOW THIS FILE IS BUILT (same shape as every course script; the reading
%   guide is in the header of RR1_no_housing.m and on the Topic-2 slides):
%   header (this block) -> parameters, one block -> sections in the order
%   of the task: draw the data, invert, plot -> local functions at the
%   bottom: rr_invert is the inversion, the same two lines as in the
%   lecture; corr2v and save_fig are utilities. The only block you are
%   asked to change is marked  STUDENTS: MODIFY THIS BLOCK.
%
% TEAM CHANGES (Homework 1, Part A)
%   1. Data-generating block: switch ORIGINAL_DGP selects the original draw
%      (Part A(a)) or log w = phi*log L + noise (Part A(b)); sig_e = 0 gives
%      the zero-noise case of Part A(d).
%   2. After the panels: prints -cov(log L,log w)/var(log w) and -1/phi, to
%      check the formula of Part A(d) against the printed slope.
%   3. The figure name gets a suffix _a, _b or _d, so runs do not overwrite
%      each other.
%
% HOW TO RUN:  runs top-to-bottom; prints OLS slopes and saves the figure
%              to ./figures/ as PNG.
% REQUIRES:    base Matlab only (no toolboxes).
% =========================================================================

clear; clc; close all;
rng(7);                                   % same seed as the lecture script
SAVE_FIGS = true;
outdir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if SAVE_FIGS && ~exist(outdir, 'dir'), mkdir(outdir); end

%% ---------------------- Parameters ---------------------------------------
Ltot  = 1e5;             % total population
n     = 60;              % number of locations
gamma = 0.3;             % labor-demand curvature
K     = ones(1, n);      % capital endowment (normalized)

%% ---------------------- Draw the random (L, w) ----------------------------
% ======================= STUDENTS: MODIFY THIS BLOCK =======================
% Part A(a): ORIGINAL_DGP = true   (L and w drawn independently)
% Part A(b): ORIGINAL_DGP = false, sig_e = 0.15
% Part A(d): ORIGINAL_DGP = false, sig_e = 0
ORIGINAL_DGP = false;
phi   = 0.08;            % elasticity of wages to city size (Fact 4, Topic 1)
sig_e = 0.15;            % sd of the wage noise (set to 0 for Part A(d))

L_obs = rand(1, n);                      % same L draw in every case
L_obs = Ltot * L_obs / sum(L_obs);       % rescale so that sum(L) = Ltot
if ORIGINAL_DGP
    w_obs = 0.5 + 1.5 * rand(1, n);      % original: w uniform on [0.5, 2], independent of L
else
    lL    = log(L_obs);
    w_obs = exp(phi * (lL - mean(lL)) + sig_e * randn(1, n));  % log w = phi*(log L - mean) + noise
end
% ===========================================================================

fprintf('corr(log L, log w) in the drawn data: %.2f\n\n', corr2v(log(L_obs), log(w_obs)));

%% ---------------------- Invert, exactly as in the lecture -----------------
[A_hat, B_hat] = rr_invert(L_obs, w_obs, K, gamma);

%% ---------------------- The four panels -----------------------------------
lA = log(A_hat); lB = log(B_hat); lL = log(L_obs); lw = log(w_obs);

fig = figure('Position', [100 100 620 480]);
tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
panels = { lA, lL, 'log A_i (recovered)', 'log L_i (observed)', 'Population vs productivity';
           lB, lL, 'log B_i (recovered)', 'log L_i (observed)', 'Population vs amenities';
           lA, lw, 'log A_i (recovered)', 'log w_i (observed)', 'Wages vs productivity';
           lB, lw, 'log B_i (recovered)', 'log w_i (observed)', 'Wages vs amenities' };
fprintf('OLS slopes (outcome on recovered fundamental, logs):\n');
for p = 1:4
    nexttile; hold on; grid on; box on;
    scatter(panels{p,1}, panels{p,2}, 40, 'filled');
    b = polyfit(panels{p,1}, panels{p,2}, 1);
    xg = linspace(min(panels{p,1}), max(panels{p,1}), 50);
    plot(xg, polyval(b, xg), 'r-', 'LineWidth', 1.5);
    xlabel(panels{p,3}); ylabel(panels{p,4}); title(panels{p,5});
    fprintf('  %-28s %6.3f\n', panels{p,5}, b(1));
end
sgtitle('Outcomes vs recovered fundamentals (solid: OLS)');

% Part A(d): population-amenities slope = -cov(log L, log w) / var(log w)
cLw = cov(lL, lw);                       % 2x2 covariance matrix of (log L, log w)
fprintf('\n-cov(log L, log w)/var(log w) %6.3f   (= population-amenities slope)\n', -cLw(1,2) / cLw(2,2));
if ~ORIGINAL_DGP
    fprintf('-1/phi                        %6.3f   (slope when sig_e = 0)\n', -1/phi);
end

if ORIGINAL_DGP, tag = 'a'; elseif sig_e == 0, tag = 'd'; else, tag = 'b'; end
save_fig(fig, ['RR1_hw_scatter_' tag], outdir, SAVE_FIGS, 12);

fprintf('\nDone. Figure in %s\n', outdir);

%% ======================== Local functions =================================
function [A_hat, B_hat] = rr_invert(L, w, K, gamma)
    % Exact inversion (identical to the lecture script).
    A_hat = w .* L.^gamma .* K.^(-gamma);  % labor demand
    B_hat = 1 ./ w;                        % utility equalization (up to scale)
    B_hat = B_hat / mean(B_hat);           % normalization mean(B) = 1
end

function r = corr2v(x, y)
    % Correlation of two vectors (base Matlab, no Statistics Toolbox).
    cm = cov(x, y);  r = cm(1,2) / sqrt(cm(1,1) * cm(2,2));
end

function save_fig(fig, name, outdir, enable, fs)
    % Export a figure to PNG (150 dpi). No-op if enable is false.
    if nargin < 5, fs = 16; end
    if enable
        set(findall(fig, '-property', 'FontSize'), 'FontSize', fs);
        exportgraphics(fig, fullfile(outdir, [name '.png']), 'Resolution', 150);
    end
end
