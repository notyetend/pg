import numpy as np


def relu(Z, is_forward=True):
    """
    ReLU activation function
    """
    if is_forward:
        return np.maximum(0, Z)
    else:  # derivative of ReLU, {1 if x>0, 0 if x <= 0}
        return ((np.sign(Z) + 1) // 2).astype(int)


def sigmoid(Z, is_forward=True):
    """
    sigmoid activation function
    """
    if is_forward:
        return 1 / (1 + np.exp(-Z))
    else:  # derivative of sigmoid, a(1-a)
        return np.multiply(sigmoid(Z), (1 - sigmoid(Z)))


def forward_propagation(A_l_prev, W_l, b_l, g_l):
    Z_l = b_l + np.dot(W_l, A_l_prev)
    A_l = g_l(Z_l)
    return A_l, Z_l


def get_random_b_W(n_l_prev, n_l):
    W_l = np.random.randn(n_l, n_l_prev) * 0.01
    b_l = np.zeros((n_l, 1))
    return b_l, W_l


def backward_propagation(dA_l, A_l_prev, W_l, Z_l, g_l):
    m = dA_l.shape[1]
    assert (m == Z_l.shape[1])

    dZ_l = np.multiply(dA_l, g_l(Z_l, is_forward=False))
    dW_l = np.dot(dZ_l, A_l_prev.T) / m
    db_l = np.sum(dZ_l, axis=1, keepdims=True) / m
    dA_l_prev = np.dot(W_l.T, dZ_l)

    return dA_l_prev, dW_l, db_l


class SimpleFfnn:
    def __init__(self, layer_dims, layer_activations, random_seed=None):
        np.random.seed(random_seed)

        self.layer_dims = layer_dims
        self.layer_activations = layer_activations
        self.n_L = len(layer_dims) - 1  # input layer is not counted.
        self.cache_A = [None] * (self.n_L + 1)
        self.cache_Z = [None] * (self.n_L + 1)  # cache_Z[0] is not used.
        self.cache_W = [None] * (self.n_L + 1)  # cache_W[0] is not used.
        self.cache_b = [None] * (self.n_L + 1)  # cache_b[0] is not used.
        self.cache_dA = [None] * (self.n_L + 1)
        self.cache_dZ = [None] * (self.n_L + 1)  # cache_dZ[0] is not used.
        self.cache_dW = [None] * (self.n_L + 1)  # cache_dW[0] is not used.
        self.cache_db = [None] * (self.n_L + 1)  # cache_db[0] is not used.
        self.X = None
        self.Y = None
        self._initialize_parameters()

    def _initialize_parameters(self):
        for i in range(1, len(self.layer_dims)):  # 1, 2, ..., n_L
            n_l = self.layer_dims[i]
            n_l_prev = self.layer_dims[i - 1]

            self.cache_b[i], self.cache_W[i] = get_random_b_W(n_l_prev, n_l)

    def forward_propagation_deep(self, X_train, Y_train):
        self.X = X_train
        self.Y = Y_train
        assert (self.layer_dims[0] == X_train.shape[0])
        assert (X_train.shape[1] == Y_train.shape[1])
        self.cache_A[0] = self.X

        for i in range(1, len(self.layer_dims)):  # 1, 2, ..., n_L
            A_l_prev = self.cache_A[i - 1]
            W_l = self.cache_W[i]
            b_l = self.cache_b[i]
            g_l = self.layer_activations[i]

            self.cache_A[i], self.cache_Z[i] = forward_propagation(A_l_prev, W_l, b_l, g_l)

    def backward_propagation_deep(self):
        Y_actual = self.Y
        Y_prediction = self.cache_A[self.n_L]

        self.cache_dA[self.n_L] = - (np.divide(Y_actual, Y_prediction) - np.divide(1 - Y_actual, 1 - Y_prediction))

        for i in list(reversed(range(1, len(self.layer_dims)))):  # n_L, n_L-1, ..., 2, 1
            dA_l = self.cache_dA[i]
            A_l_prev = self.cache_A[i - 1]
            W_l = self.cache_W[i]
            Z_l = self.cache_Z[i]
            g_l = self.layer_activations[i]

            self.cache_dA[i - 1], self.cache_W[i], self.cache_b[i] = backward_propagation(dA_l, A_l_prev, W_l, Z_l, g_l)

