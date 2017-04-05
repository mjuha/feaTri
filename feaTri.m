% feaTri.m
% This is the main file that implement a linear triangular
% element in plain stress condition.
%
% Author: Dr. Mario J. Juha
% Date: 31/03/2017
% Mechanical Engineering
% Universidad de La Sabana
% Chia -  Colombia
%
% Clear variables from workspace
clearvars

% Specify file name
filename = '\Users\marioju\Documents\Work\feaTri\example.inp';
%filename = '\Users\marioju\Downloads\plateWithHole.msh';
%outfiledest = '\\Client\C$\Users\marioju\Downloads\';
%filename = '\Users\mario\Documents\work\plateWithHole.msh';
%outfiledest = '\\Client\C$\Users\mario\Documents\work\';

% read data
readData(filename);

%WriteVTKFile(outfiledest,0)
