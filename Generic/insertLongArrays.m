function out = insertLongArrays(A, B, insertLoc)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Forces a unit to accept a spike without matching
% 
% INPUT
% A = array to insert into
% B = array to insert
% insertLoc = range of indices in A to replace and insert B into
%		FORMAT [insert location start, insert location end]
% 
% OUTPUT
% out = new combined array

out = [A(1:insertLoc(1)-1), B, A(insertLoc(2)+1:end)];

end