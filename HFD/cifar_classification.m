function options = cifar_classification(method, hs_sub, delta, alpha, init, maxNP, seed)
% cifar10 classification using 1-hidden layer network.
%
% Input:
%       method      ---- TR-CG, GN, SGD
%       hs_sub      ---- sampling ratio of the training set, e.g. 0.1
%       init        ---- initialization schemes
%                       0: zeros initialization
%                       1: normalized random initialization
%                       2: random intialization
%       delta       ---- initial trust-region radius for TR methods
%       alpha       ---- step size for SGD algorithm
%       maxNP       ---- maximum propagations
%
% Output:
%       options     ---- contain all the training information and results;
%                        see each algorithm function for details.
%
%           options.params:     weights of the model
%           options.tr_times:   training timestamp at each iteration
%           options.tr_losses:  training loss at each iteration
%           options.tr_grads:   training gradient norm at each iteration
%           opitons.tr_errs:    training error at each iteration
%           options.te_errs:    test error at each iteration
%           options.cur_ter:    current itertion number(if not 0, resume
%                               training    
%
% written by Peng Xu, Fred Roosta, 6/8/2017, updated (2/8/2018)
                        
%%
if nargin < 7
    seed = 0;
end
if nargin < 6
    maxNP = 1e8;
end
if nargin < 5
    init = 0;
end
if nargin < 4
    alpha = 0.05;
end
if nargin < 3
    delta = 1000;
end
if nargin < 2
    hs_sub = 0.05;
end
if nargin < 1
    method = 'TR-CG';
end
addpath(genpath(pwd));
% seed = 1234;
% randn('state', seed );
% rand('twister', seed+1 );
rng(seed);

%% Read the data --- X: d x n, y: c x n
load('./datasets/cifar-10-batches-mat/data_batch_1.mat'); data1 = data; labels1 = labels;
load('./datasets/cifar-10-batches-mat/data_batch_2.mat'); data2 = data; labels2 = labels;
load('./datasets/cifar-10-batches-mat/data_batch_3.mat'); data3 = data; labels3 = labels;
load('./datasets/cifar-10-batches-mat/data_batch_4.mat'); data4 = data; labels4 = labels;
load('./datasets/cifar-10-batches-mat/data_batch_5.mat'); data5 = data; labels5 = labels;
X = double([data1; data2; data3; data4; data5])';
y = getClassLabels([labels1; labels2; labels3; labels4; labels5])';
load('./datasets/cifar-10-batches-mat/test_batch.mat'); X_test = double(data)'; y_test = getClassLabels(labels)';

%% Preprocess the images
[inputd, n] = size(X);
%mean_data = mean(X, 2);
%std_data = std(X,0,2);
%std_data(std_data==0) = 1;
mean_data = 0.5;
std_data = 0.5;
X = bsxfun(@minus, X, mean_data);
X = bsxfun(@rdivide,X, std_data);
X_test = bsxfun(@minus, X_test, mean_data);
X_test = bsxfun(@rdivide,X_test, std_data);

%% Specify the Neural Network Model
outputd = size(y,1);
model.layersizes = [inputd, 512, outputd];
model.layertypes = {'logistic', 'softmax'};
model.numlayers = length(model.layertypes);
model.type = 'classification';
psize = model.layersizes(1,2:(model.numlayers+1))*model.layersizes(1,1:model.numlayers)' + sum(model.layersizes(2:(model.numlayers+1)));
lambda = 0; % l2 regularization

%% Initialize the Model
if init == 0
    initial_guess = zeros(psize,1); sub_dir = ['/zeros_', num2str(seed)];
    fprintf('\n\nZero Initialization! \n\n');
elseif init == 1
    initial_guess = randn(psize,1); initial_guess = initial_guess/norm(initial_guess); sub_dir = ['/randn_normalized_', num2str(seed)];
    fprintf('\n\nNormalized Random Initialization! \n\n');
else
    initial_guess = randn(psize,1); sub_dir = ['/randn_', num2str(seed)];
    fprintf('\n\nRandom Initialization! \n\n');
end
options.params = initial_guess;

%% Specify the algorithm
options.name = 'cifar10_classification';
options.inner_iters = 250;
options.max_delta = Inf;
options.alpha = alpha;
options.delta = delta;
options.max_iters = 1e6;
options.cur_iter = 0;
options.hs = floor(hs_sub*n); % Hessian batch size for 2nd-order Methods, gradient batch size for SGD.
options.maxMVPs = Inf;
options.maxNoProps = maxNP;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir_name = ['./results/',options.name,sub_dir];
if ~exist(dir_name, 'dir')
    mkdir(dir_name);
end

file_name = [dir_name,'/',options.name,'_lambda_', num2str(lambda), '_hess_', num2str(hs_sub)];

%% Start Training
switch method
    case 'GN'
        fprintf('\n\n------------------- GN %g ----------------\n\n',delta);
        file_name_gn = [file_name,'_gn.mat'];
        if exist(file_name_gn, 'file')
            load(file_name_gn, 'options'); % resume training
        end
        [params, options] = subsampled_gn(model,X,y,X_test,y_test,lambda,options);
        parsave(file_name_gn, options);
        
    case 'TR-CG'
        fprintf('\n\n------------------- TR: delta = %g ----------------\n\n',options.delta);
        file_name_tr_cg = [file_name,'_tr_cg','_delta_',num2str(delta),'.mat'];
        if exist(file_name_tr_cg, 'file')
            load(file_name_tr_cg, 'options'); % resume training
        end
        [params, options] = subsampled_tr_cg(model,X,y,X_test,y_test,lambda,options);
        parsave(file_name_tr_cg, options);
        
    case 'SGD'
        fprintf('\n\n------------------- SGD: alpha = %g ----------------\n\n',options.alpha);
        file_name_sgd = [file_name,'_step_', num2str(options.alpha), '_sgd.mat'];
        if exist(file_name_sgd, 'file')
            load(file_name_sgd,'options'); % resume training
        end
        [params, options] = momentum_sgd(model,X,y,X_test,y_test,lambda,options);
        parsave(file_name_sgd, options);
        
end

end

