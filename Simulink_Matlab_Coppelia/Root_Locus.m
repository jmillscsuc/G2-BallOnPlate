m = 0.111;
R = 0.015;
g = -9.8;
L = 1.0;
d = 0.03;
J = 9.99e-6;
s = tf('s');
sys = -m*g*d/L/(J/R^2+m)/s^2;

rlocus(sys);

sgrid(.667, 1.9986);

axis([-5 5 -2 2]);

zo = 0.01;
po = 4;
C=tf([1 zo],[1 po]);

rlocus(C*sys)
sgrid(0.667, 1.9986)

[k,poles]=rlocfind(C*sys)

sys_cl=feedback(k*C*sys,1);
t=0:0.01:5;
figure
step(0.25*sys_cl,t)