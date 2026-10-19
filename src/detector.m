function detectOut = detector(inputBit, reset)
%DETECTOR  Serial detector for the bit patterns 11001 and 10010 (shift-register version).
%
%   y = detector(bit, reset) processes ONE input bit per call and returns 1 on
%   the clock step where either 11001 or 10010 has just been completed, else 0.
%   Overlapping occurrences are detected (e.g. 110010 -> 11001 and 10010).
%
%   The function models a 5-bit shift register: a persistent buffer keeps the
%   last five bits, the new bit is shifted in on every call and the window is
%   compared with both patterns. Pass reset = true (normally together with the
%   first bit of a new stream) to clear the register.
%
%   See also DETECTOR_FSM, RUN_DETECTOR.

    persistent buffer

    if isempty(buffer) || (nargin > 1 && reset)
        buffer = zeros(1, 5);       % both patterns start with 1, so a zero
    end                             % pre-fill can never cause a false match

    buffer = [buffer(2:end), inputBit];   % shift left, new bit enters on the right

    detectOut = double(isequal(buffer, [1 1 0 0 1]) || ...
                       isequal(buffer, [1 0 0 1 0]));
end
