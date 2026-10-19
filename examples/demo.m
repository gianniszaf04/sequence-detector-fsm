% DEMO  Run the detector on a short bit stream and show where it fires.
%
%   Run from the repository root:  run examples/demo.m

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src'));

% Contains 11001, 10010, an overlap (110010 -> both) and near-misses
bits = [0 1 1 0 0 1 0 0 1 0 1 1 1 0 0 0 1 1 0 0 1 1 0 1 0 0 1 0];

out = run_detector(bits, 'fsm');

fprintf('step : %s\n', sprintf('%3d', 1:numel(bits)));
fprintf('in   : %s\n', sprintf('%3d', bits));
fprintf('out  : %s\n\n', sprintf('%3d', out));

for k = find(out)
    window = bits(k-4:k);
    fprintf('step %2d: [%s] -> %s detected\n', k, sprintf('%d', window), sprintf('%d', window));
end

% Plot input and output on a common time axis (skipped when there is no display)
if exist('OCTAVE_VERSION', 'builtin')
    can_plot = have_window_system();
else
    can_plot = usejava('desktop');
end
if can_plot
    t = 1:numel(bits);
    figure('Name', 'Sequence detector');
    subplot(2, 1, 1);
    stairs(t, bits, 'LineWidth', 1.5); ylim([-0.5 1.5]); grid on;
    title('Input bits'); ylabel('bit');
    subplot(2, 1, 2);
    stem(t, out, 'filled', 'LineWidth', 1.5); ylim([-0.5 1.5]); grid on;
    title('Detector output (1 = 11001 or 10010 just completed)');
    xlabel('step'); ylabel('detect');
end
