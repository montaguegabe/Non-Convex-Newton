% Create model and params
outputd = 10;
model.layersizes = [32 * 32 * 3, 512, outputd];
model.layertypes = {'logistic', 'softmax'};
model.numlayers = length(model.layertypes);
model.type = 'classification';
psize = model.layersizes(1,2:(model.numlayers+1))*model.layersizes(1,1:model.numlayers)' + sum(model.layersizes(2:(model.numlayers+1)));
assert(psize == 1578506);
params = zeros(psize,1);

% Make toy X and y
sub_data = ones(32 * 32 * 3, 1);
sub_target = zeros(10, 1);
sub_target(1, 1) = 1.0;

% They are both double type

[loss, grad, hess, perr] = compute_model(model, params, sub_data, sub_target);

steihaug_x = ones(psize, 1) * 0.25;
H_x = hess(steihaug_x);

dlmwrite('~/Desktop/Experiments/hessian_stability/ml_loss.csv', loss, 'delimiter', ',', 'precision', 16); 
dlmwrite('~/Desktop/Experiments/hessian_stability/ml_grad.csv', grad, 'delimiter', ',', 'precision', 16); 
