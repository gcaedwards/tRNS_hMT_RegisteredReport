function [extrArray] = extractRows (inputArray, column, value);
%this function extracts those rows from inputArray that have a
%specified value in a specified column. It returns a matrix with the
%relevant rows as extrArray.

extrArray = inputArray((inputArray(:,column)==value),:);
%the inner brackets will produce a logical vector returning which row
%equals the value in the specified column or not
%this logical vector is then used to index the relevant rows (where the logical
%is true)and all columns of the relevant rows will be saved as extrArray