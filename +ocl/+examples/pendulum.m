% Copyright 2019 Jonas Koenemann, Moritz Diehl, University of Freiburg
% Copyright 2015-2018 Jonas Koenemann, Giovanni Licitra
% Redistribution is permitted under the 3-Clause BSD License terms. Please
% ensure the above copyright notice is visible in any derived work.
%
function [solution,times,ocp] = pendulum

conf = struct;
conf.l = 1;
conf.m = 1;

ocp = ocl.Problem(1, ...
  @ocl.examples.pendulum.varsfun, ...
  @(h,x,z,u,p) ocl.examples.pendulum.daefun(h,x,z,u,p,conf), ...
  @ocl.examples.pendulum.pathcosts, ...
  @ocl.examples.pendulum.gridcosts, ...
  'N', 100);

ocp.setBounds('T', 1, 20);

ocp.setBounds('v',       -[3;3], [3;3]);
ocp.setBounds('F',       -18, 18);

ocp.setInitialBounds('p', [0; -conf.l]);
ocp.setInitialBounds('v', [0.5;0]);

ocp.setEndBounds('p',     [0;0.5], [0;2]);
ocp.setEndBounds('v',     [-1;-1], [1;1]);

ig = ocp.getInitialGuess();
ig.states.p.set([0;-1]);
ig.states.v.set([0.1;0]);
ig.controls.F.set(-10);

[solution,times] = ocp.solve(ig);

ocl.examples.pendulum.animate(conf.l, solution.states.p.value, times.value*solution.parameters.T(1).value);

snapnow;
