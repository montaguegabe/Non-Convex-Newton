X1 = csvread('~/Desktop/X0.csv');
X2 = csvread('~/Desktop/X1.csv');
X3 = csvread('~/Desktop/X2.csv');
X4 = csvread('~/Desktop/X3.csv');
X5 = csvread('~/Desktop/X4.csv');
X6 = csvread('~/Desktop/X5.csv');
X7 = csvread('~/Desktop/X6.csv');
X8 = csvread('~/Desktop/X7.csv');
X9 = csvread('~/Desktop/X8.csv');
X10 = csvread('~/Desktop/X9.csv');

y1 = csvread('~/Desktop/y0.csv');
y2 = csvread('~/Desktop/y1.csv');
y3 = csvread('~/Desktop/y2.csv');
y4 = csvread('~/Desktop/y3.csv');
y5 = csvread('~/Desktop/y4.csv');
y6 = csvread('~/Desktop/y5.csv');
y7 = csvread('~/Desktop/y6.csv');
y8 = csvread('~/Desktop/y7.csv');
y9 = csvread('~/Desktop/y8.csv');
y10 = csvread('~/Desktop/y9.csv');

X = double([X1; X2; X3; X4; X5; X6; X7; X8; X9; X10])';
y = double([y1; y2; y3; y4; y5; y6; y7; y8; y9; y10])';

