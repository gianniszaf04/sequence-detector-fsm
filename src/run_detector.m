function out = run_detector(bits, impl)
%RUN_DETECTOR  Feed a whole bit vector through a detector, one bit per step.
%
%   out = run_detector(bits)          uses the shift-register DETECTOR
%   out = run_detector(bits, 'fsm')   uses the Mealy FSM DETECTOR_FSM
%
%   The detector is reset on the first bit, so every call starts clean.
%   out(k) is 1 when a pattern ends at bits(k).

    if nargin < 2
        impl = 'shift';
    end
    switch lower(impl)
        case {'shift', 'shiftreg', 'register'}
            step = @detector;
        case 'fsm'
            step = @detector_fsm;
        otherwise
            error('run_detector:impl', 'Unknown implementation "%s" (use ''shift'' or ''fsm'').', impl);
    end

    out = zeros(1, numel(bits));
    for k = 1:numel(bits)
        out(k) = step(bits(k), k == 1);
    end
end
