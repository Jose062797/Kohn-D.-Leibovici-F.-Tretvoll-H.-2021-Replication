function [sim_array]=get_simul_replications(DynareModel,options_)
% function [sim_array]=get_simul_replications(DynareModel,options_)
% reads the simulation replications into a three-dimensional array with
% endogenous variables along the first, simulation periods along the
% second, and replications along the third dimension.
%
% Adapted for Dynare 6.x: when simul_replic > 1, simulations are stored
% in a binary file at: M_.dname/Output/M_.fname_simul
% (In Dynare 4.x the file was at: M_.fname_simul in the working directory)
%
% INPUTS
%   DynareModel:  Dynare structure describing the model (M_)
%   options_:     Dynare structure describing the options
%
% OUTPUTS
%   sim_array:   [endo_nbr by periods by replic] array of simulations

replic   = options_.simul_replic;
periods  = options_.periods;
endo_nbr = DynareModel.endo_nbr;

% In Dynare 6.x the file is stored in M_.dname/Output/
fname = [DynareModel.dname filesep 'Output' filesep DynareModel.fname '_simul'];

fid = fopen(fname, 'r');
if fid < 3
    error(['Cannot open ', fname]);
end
simulations = fread(fid, [endo_nbr*periods replic], 'float64');
fclose(fid);

while size(simulations,2) < replic
    fid = fopen(fname, 'r');
    simulations = fread(fid, [endo_nbr*periods replic], 'float64');
    fclose(fid);
end

sim_array = reshape(simulations, [endo_nbr periods replic]);
