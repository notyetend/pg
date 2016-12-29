1;

% a3(1, 7, 1, 0.1, 0.3, false, 3)
function a3_s(wd_coefficient, n_hid, n_iters, learning_rate, momentum_multiplier, do_early_stopping, mini_batch_size)
  warning('error', 'Octave:broadcast');
  if exist('page_output_immediately'), page_output_immediately(1); end
  more off;
  model = initial_model(n_hid);
  model
  from_data_file = load('data.mat');
  datas = from_data_file.data;
  n_training_cases = size(datas.training.inputs, 2);
  if n_iters ~= 0, test_gradient(model, datas.training, wd_coefficient); end
  
  
end

function ret = model_to_theta(model)
  % This function takes a model (or gradient in model form), and turns it into one long vector. See also theta_to_model.
  input_to_hid_transpose = transpose(model.input_to_hid);
  hid_to_class_transpose = transpose(model.hid_to_class);
  ret = [input_to_hid_transpose(:); hid_to_class_transpose(:)];
end

function ret = theta_to_model(theta)
  n_input_units = 3 % 256
  n_output_units = 5 % 10
  
  % This function takes a model (or gradient) in the form of one long vector (maybe produced by model_to_theta), and restores it to the structure format, i.e. with fields .input_to_hid and .hid_to_class, both matrices.
  n_hid = size(theta, 1) / (n_input_units + n_output_units);
  ret.input_to_hid = transpose(reshape(theta(1: n_input_units*n_hid), n_input_units, n_hid));
  ret.hid_to_class = reshape(theta(n_input_units * n_hid + 1 : size(theta,1)), n_hid, n_output_units).';
end

function ret = initial_model(n_hid)
  n_input_units = 3 % 256
  n_output_units = 5 % 10
  n_params = (n_input_units + n_output_units) * n_hid;
  as_row_vector = cos(0:(n_params-1));
  ret = theta_to_model(as_row_vector(:) * 0.1); % We don't use random initialization, for this assignment. This way, everybody will get the same results.
end

function test_gradient(model, data, wd_coefficient)
  base_theta = model_to_theta(model);
  h = 1e-2;
  correctness_threshold = 1e-5;
  analytic_gradient = model_to_theta(d_loss_by_d_model(model, data, wd_coefficient));
end

function ret = d_loss_by_d_model(model, data, wd_coefficient)
  % model.input_to_hid is a matrix of size <number of hidden units> by <number of inputs i.e. 256>
  % model.hid_to_class is a matrix of size <number of classes i.e. 10> by <number of hidden units>
  % data.inputs is a matrix of size <number of inputs i.e. 256> by <number of data cases>. Each column describes a different data case. 
  % data.targets is a matrix of size <number of classes i.e. 10> by <number of data cases>. Each column describes a different data case. It contains a one-of-N encoding of the class, i.e. one element in every column is 1 and the others are 0.

  % The returned object is supposed to be exactly like parameter <model>, i.e. it has fields ret.input_to_hid and ret.hid_to_class. However, the contents of those matrices are gradients (d loss by d model parameter), instead of model parameters.
	 
  % This is the only function that you're expected to change. Right now, it just returns a lot of zeros, which is obviously not the correct output. Your job is to replace that by a correct computation.
  ret.input_to_hid = model.input_to_hid * 0;
  ret.hid_to_class = model.hid_to_class * 0;
end




