function detectOut = detector_fsm(inputBit, reset)
%DETECTOR_FSM  Serial detector for 11001 and 10010 as an explicit Mealy FSM.
%
%   y = detector_fsm(bit, reset) has exactly the same behaviour as DETECTOR,
%   but instead of storing the last five bits it keeps one of 8 states, i.e.
%   the minimum number of flip-flops a hardware version would need is 3
%   (the shift register needs 5). Each state is the longest suffix of the
%   input seen so far that is still the beginning of one of the patterns:
%
%     S0 = ""     S1 = "1"     S2 = "11"    S3 = "110"
%     S4 = "1100" S5 = "10"    S6 = "100"   S7 = "1001"
%
%   The output is 1 on the transitions S4 --1--> S7 (11001 completed) and
%   S7 --0--> S5 (10010 completed); after a detection the FSM keeps the
%   overlapping suffix, so back-to-back / overlapping patterns are found.
%
%   See also DETECTOR, RUN_DETECTOR.

    % Transition table: NEXT(state+1, bit+1) and OUT(state+1, bit+1)
    %          bit=0  bit=1
    NEXT = [   0      1  ;   % S0  ""
               5      2  ;   % S1  "1"
               3      2  ;   % S2  "11"
               4      1  ;   % S3  "110"
               0      7  ;   % S4  "1100"
               6      1  ;   % S5  "10"
               0      7  ;   % S6  "100"
               5      2  ];  % S7  "1001"
    OUT  = [   0      0  ;
               0      0  ;
               0      0  ;
               0      0  ;
               0      1  ;   % S4 + 1 -> 11001
               0      0  ;
               0      0  ;
               1      0  ];  % S7 + 0 -> 10010

    persistent state

    if isempty(state) || (nargin > 1 && reset)
        state = 0;
    end

    b = double(inputBit ~= 0);
    detectOut = OUT(state + 1, b + 1);
    state     = NEXT(state + 1, b + 1);
end
