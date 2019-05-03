function waveresponse345(a, beta,T_0, U, L, B, T, ship)
% waveresponse345(a, beta,T_0, U, L, B, T, ship) computes the steady-state 
% heave, roll and pitch responses for a ship in regular waves using 
% closed-form formulae. 
%
% Inputs:
%
% a = wave amplitude (m)
% beta = wave direction (rad) where beta = pi (i.e. 180 deg) is head seas
% T_0 = wave periode (s) corresponding to the wave frequency w_0 = 2 pi/T_0
% U = ship speed (m/s)
%
% Optionally ship data: ship = [zeta4, T4, GM_T, Cb]
% 
% zeta4      Relative damping factor in roll
% T4         Natural roll periode (s)
% GM_T       Transver metacentric height (m)
% Cb         Block coefficeint 
%
% xdot = waveresponse345(a, beta, T_0, U, L, B, T, ship) allows the 
% user to specify the ship parameters. 
%
% xdot = waveresponse345(a, beta, T_0, U, L, B, T) uses the default 
% values  = [0.2, 6, 1, 0.65].
%
% waveresponse345(a, beta, T0, U, L, B, T,ship) plots the steady-state
% heave, roll and pitch response for 20 seconds. 
% 
% Ex: waveresponse345(2, 45*pi/180, 10, 5, 82.8, 19.2, 6);
%
% Reference: 
% J. Juncher Jensen, A. E. Mansour and A. S. Olsen. Estimation of 
% Ship Motions using Closed-form Expressions. Ocean Eng. 31, 2004, pp. 61-85
% 
% Author:    Thor I. Fossen
% Date:      2018-07-21  Based on the method of Jensen et al. (2005)
% Revisions: 2019-05-03  Bug fixes

% Default roll parameters
if nargin == 7
    ship = [0.2, 6, 1, 0.65];
end

% Hydrodynamic parameters
zeta4   = ship(1);    % Relative damping factor in roll
T4      = ship(2);    % Natural roll periode (s)
GM_T    = ship(3);    % Transver metacentric height (m)
Cb      = ship(4);    % Block coefficeint 

% Constants
g = 9.81;                 % acceleration of gravity (m/s^2)
rho = 1025;               % density of water (kg/m^3)

% Ship parameters
nabla = Cb * L * B * T;        % volume displacement (m^3) 
w_0 = 2 * pi / T_0;            % wave peak frequency (rad/s)
k = w_0^2/g;                   % wave number
w_e = w_0 - k * U * cos(beta); % frequency of encounter
k_e = abs(k * cos(beta));      % effective wave number
sigma = k_e * L/2;
kappa = exp(-k_e * T);

% Heave and pitch models (Jensen et al., 2004)
alpha = w_e/w_0;
A = 2 * sin(k*B*alpha^2/2) * exp(-k*T*alpha^2); 
f = sqrt( (1-k*T)^2  + (A^2/(k*B*alpha^3))^2 );
F = kappa * f * sin(sigma)/sigma;
G = kappa * f * (6/L) * (1/sigma) * ( sin(sigma)/sigma - cos(sigma) );

% Natural frequency in Jensen et al. (2004) uses: w3 = w5 = sqrt(g/(2*T))
% Solution below uses spring stiffness and mass/added mass while relative
% damping ratio is based on Jensen et al. (2004)
wn  = sqrt(g/2*T);
zeta = (A^2/(B*alpha^3)) * sqrt(1/(8*k^3*T));

% Roll model (simplifed version of Jensen et al., 2004)
w4 = 2*pi/T4;                    % natural frequency
C44 = rho * g * nabla * GM_T;    % spring coeffient
M44 = C44/w4^2;                  % moment of inertia including added mass
B44 = 2 * zeta4 * w4 * M44;      % damping coefficient
M = sin(beta) * sqrt( B44 * rho*g^2/w_e );   % roll moment amplitude

% The solution of the ODE is valid for all frequencies 
% including the resonance where w_0 is equal to the natural frequency.
% URL: https://en.wikipedia.org/wiki/Harmonic_oscillator
t = 0:0.1:20;    % time vector for plotting
        
% Heave
Z3 = sqrt( (2*wn*zeta)^2 + (1/w_e^2)*(wn^2-w_e^2)^2 );
eps3 = atan( 2*w_e*wn*zeta/(wn^2-w_e^2) );
z = (a*F*wn^2/(Z3*w_e)) * cos(w_e*t+eps3);
    
% Pitch
Z5 = sqrt( (2*wn*zeta)^2 + (1/w_e^2)*(wn^2-w_e^2)^2 );
eps5 = atan( 2*w_e*wn*zeta/(wn^2-w_e^2) );
theta = (180/pi) * (a*G*wn^2/(Z5*w_e)) * sin(w_e*t+eps5);
    
% Roll
Z4 = sqrt( (2*w4*zeta4)^2 + (1/w_e^2)*(w4^2-w_e^2)^2 );
eps4 = atan( 2*w_e*w4*zeta4/(w4^2-w_e^2) );
phi = (180/pi) * ((M/C44)*w4^2/(Z4*w_e)) * cos(w_e*t+eps4);
    
% Plots 
figure(gcf)
subplot(311)
plot(t,z,'-k','linewidth',2),xlabel('time (s)'), grid
title(sprintf('Steady-state heave response (m) for a = %2.1f m and beta %2.1f deg',a,(180/pi)*beta))
subplot(312)
plot(t,phi,'-k','linewidth',2),xlabel('time (s)'), grid
title(sprintf('Steady-state roll response (deg) for a = %2.1f m and beta %2.1f deg',a,(180/pi)*beta))
subplot(313)
plot(t,theta,'-k','linewidth',2),xlabel('time (s)'),grid
title(sprintf('Steady-state pitch response (deg) for a = %2.1f m and beta %2.1f deg',a,(180/pi)*beta))



