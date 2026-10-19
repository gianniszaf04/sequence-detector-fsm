function out = reference_detect(bits)
%REFERENCE_DETECT  Independent reference model used by the tests.
%
%   Finds every (overlapping) occurrence of 11001 and 10010 with STRFIND on
%   the whole sequence and marks the position of the LAST bit of each match.

    seq = sprintf('%d', bits);
    out = zeros(1, numel(bits));
    hits = [strfind(seq, '11001'), strfind(seq, '10010')];
    out(hits + 4) = 1;
end
