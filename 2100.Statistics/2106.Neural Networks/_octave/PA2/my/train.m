% This function trains a neural network language model.
function [model] = train(epochs)
% Inputs:
%   epochs: Number of epochs to run.
% Output:
%   model: A struct containing the learned weights and biases and vocabulary.

if size(ver('Octave'),1)
  OctaveMode = 1;
  warning('error', 'Octave:broadcast');
  start_time = time;
else
  OctaveMode = 0;
  start_time = clock;
end

% SET HYPERPARAMETERS HERE.
batchsize = 7;  % Mini-batch size.
learning_rate = 0.1;  % Learning rate; default = 0.1.
momentum = 0.9;  % Momentum; default = 0.9.
numhid1 = 5;  % Dimensionality of embedding space; default = 50.
numhid2 = 11;  % Number of units in hidden layer; default = 200.
init_wt = 0.01;  % Standard deviation of the normal distribution
                 % which is sampled to get the initial weights; default = 0.01

% VARIABLES FOR TRACKING TRAINING PROGRESS.
show_training_CE_after = 10;
show_validation_CE_after = 100;

% LOAD DATA.
[train_input, train_target, valid_input, valid_target, test_input, test_target, vocab] = load_data(batchsize);
[numwords, batchsize, numbatches] = size(train_input); 
vocab_size = size(vocab, 2);


% INITIALIZE WEIGHTS AND BIASES.
word_embedding_weights = init_wt * randn(vocab_size, numhid1);
embed_to_hid_weights = init_wt * randn(numwords * numhid1, numhid2);
hid_to_output_weights = init_wt * randn(numhid2, vocab_size);
hid_bias = zeros(numhid2, 1);
output_bias = zeros(vocab_size, 1);

word_embedding_weights_delta = zeros(vocab_size, numhid1);
word_embedding_weights_gradient = zeros(vocab_size, numhid1);
embed_to_hid_weights_delta = zeros(numwords * numhid1, numhid2);
hid_to_output_weights_delta = zeros(numhid2, vocab_size);
hid_bias_delta = zeros(numhid2, 1);
output_bias_delta = zeros(vocab_size, 1);
expansion_matrix = eye(vocab_size);
count = 0;
tiny = exp(-30);

% TRAINING
for epoch = 1:epochs
  fprintf('-\n');
  
  for m = 1:numbatches
    input_batch = train_input(:, :, m);
    target_batch = train_target(:, :, m);
    
    % FORWARD PROPAGATE.
    % Compute the state of each layer in the network given the input batch
    % and all weights and biases
    [embedding_layer_state, hidden_layer_state, output_layer_state] = ...
      fprop(input_batch, ...
            word_embedding_weights, embed_to_hid_weights, ...
            hid_to_output_weights, hid_bias, output_bias);

end
end




