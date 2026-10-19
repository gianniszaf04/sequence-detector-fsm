% TEST_DETECTOR  Verification of both detector implementations.
%
%   1) Exhaustive test: every 12-bit input (2^12 = 4096 sequences) is run
%      through each detector and compared bit-by-bit with REFERENCE_DETECT.
%      12 bits is longer than the 5-bit patterns, so overlapping and repeated
%      occurrences are included.
%   2) Monte Carlo: a long random bit stream is checked against the reference,
%      and coverage is reported as the share of the 32 possible 5-bit windows
%      and of the 16 FSM transitions that were exercised.
%
%   Run from the repository root:  run tests/test_detector.m

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src'));

total_fail = 0;
impls = {'shift', 'fsm'};

%% 1) Exhaustive test
N = 12;
fprintf('==== Exhaustive test: all %d-bit inputs (%d sequences) ====\n', N, 2^N);
for m = 1:numel(impls)
    pass = 0; fail = 0;
    for i = 0:(2^N - 1)
        bits = double(dec2bin(i, N)) - '0';        % MSB first, no toolbox needed
        if isequal(run_detector(bits, impls{m}), reference_detect(bits))
            pass = pass + 1;
        else
            fail = fail + 1;
            if fail <= 5
                fprintf('  mismatch for input %s\n', sprintf('%d', bits));
            end
        end
    end
    fprintf('  %-6s PASS %4d / %d   FAIL %d\n', impls{m}, pass, 2^N, fail);
    total_fail = total_fail + fail;
end

%% 2) Monte Carlo test
L = 100000;
rand('seed', 42); %#ok<RAND> same seed syntax works in MATLAB and Octave
bits = double(rand(1, L) > 0.5);
fprintf('\n==== Monte Carlo test: %d random bits ====\n', L);

ref = reference_detect(bits);
for m = 1:numel(impls)
    out = run_detector(bits, impls{m});
    mism = sum(out ~= ref);
    fprintf('  %-6s detections %d (reference %d)   mismatches %d\n', ...
            impls{m}, sum(out), sum(ref), mism);
    total_fail = total_fail + (mism > 0);
end
fprintf('  expected about L*2/32 = %d detections\n', round(L * 2 / 32));

% Coverage 1: which of the 32 possible 5-bit windows appeared
seen = false(1, 32);
for k = 5:L
    seen(bits(k-4:k) * [16; 8; 4; 2; 1] + 1) = true;
end
fprintf('  5-bit pattern coverage:  %d / 32  (%.1f%%)\n', sum(seen), 100 * mean(seen));

% Coverage 2: which of the 16 FSM transitions (8 states x 2 inputs) were taken
NEXT = [0 1; 5 2; 3 2; 4 1; 0 7; 6 1; 0 7; 5 2];   % same table as detector_fsm.m
taken = false(8, 2);
s = 0;
for k = 1:L
    taken(s + 1, bits(k) + 1) = true;
    s = NEXT(s + 1, bits(k) + 1);
end
fprintf('  FSM transition coverage: %d / 16  (%.1f%%)\n', sum(taken(:)), 100 * mean(taken(:)));

%% Result
if total_fail == 0
    fprintf('\nALL TESTS PASSED\n');
else
    fprintf('\nTESTS FAILED (%d)\n', total_fail);
end
