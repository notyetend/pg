from SimpleFfnn import *
import numpy as np
# import matplotlib.pyplot as plt
import h5py


# 'Shift + F10' to run test
#     def __init__(self, *args, **kwargs):
#        super(TestSimpleFfnn, self).__init__(*args, **kwargs)

def np_array_equal(left, right, precision=5):
    if np.array_equal(np.round(left, precision), np.round(right, precision)):
        return True
    else:
        return False


def load_data():
    train_dataset = h5py.File('datasets/train_catvnoncat.h5', "r")
    train_set_x_orig = np.array(train_dataset["train_set_x"][:])  # your train set features
    train_set_y_orig = np.array(train_dataset["train_set_y"][:])  # your train set labels

    test_dataset = h5py.File('datasets/test_catvnoncat.h5', "r")
    test_set_x_orig = np.array(test_dataset["test_set_x"][:])  # your test set features
    test_set_y_orig = np.array(test_dataset["test_set_y"][:])  # your test set labels

    classes = np.array(test_dataset["list_classes"][:])  # the list of classes

    train_set_y_orig = train_set_y_orig.reshape((1, train_set_y_orig.shape[0]))
    test_set_y_orig = test_set_y_orig.reshape((1, test_set_y_orig.shape[0]))

    return train_set_x_orig, train_set_y_orig, test_set_x_orig, test_set_y_orig, classes


def test_relu():
    assert relu(10) == 10
    assert relu(-1) == 0
    assert relu(0) == 0

    assert relu(10, False) == 1
    assert relu(-1, False) == 0
    assert relu(0, False) == 0


def test_sigmoid():
    assert sigmoid(0) == 0.5
    assert sigmoid(0, False) == (0.5 * (1 - 0.5))


def test_forward_propagation():
    np.random.seed(1)
    A_l_prev = np.random.randn(4, 2)
    W_l = np.random.randn(5, 4)
    b_l = np.random.randn(5, 1)
    A_l, Z_l = forward_propagation(A_l_prev, W_l, b_l, relu)
    print(A_l, Z_l)


def test_get_random_b_W():
    pass


def test_backward_propagation():
    np.random.seed(2)
    dA_l = np.random.randn(1, 2)
    A_l_prev = np.random.randn(3, 2)
    W_l = np.random.randn(1, 3)
    b_l = np.random.randn(1, 1)  # Do not delete this line, or random state will be wired.
    Z_l = np.random.randn(1, 2)

    dA_l_prev, dW_l, db_l = backward_propagation(A_l_prev, W_l, Z_l, g_l=sigmoid, dA_l=dA_l)
    assert np_array_equal(dA_l_prev, np.array([[0.11017994, 0.01105339],
                                               [0.09466817, 0.00949723],
                                               [-0.05743092, -0.00576154]])) is True
    assert np_array_equal(dW_l, np.array([[0.10266786, 0.09778551, -0.01968084]])) is True
    assert np_array_equal(db_l, np.array([[-0.05729622]])) is True

    dA_l_prev, dW_l, db_l = backward_propagation(A_l_prev, W_l, Z_l, g_l=relu, dA_l=dA_l)
    assert np_array_equal(dA_l_prev, np.array([[0.44090989, -0.],
                                               [0.37883606, -0.],
                                               [-0.2298228, 0.]])) is True
    assert np_array_equal(dW_l, np.array([[0.44513824, 0.37371418, -0.10478989]])) is True
    assert np_array_equal(db_l, np.array([[-0.20837892]])) is True


def test_get_cross_entropy_cost():
    Y_actual = np.array([[1, 1, 1]]).reshape(1, -1)
    Y_prediction = np.array([[.8, .9, 0.4]]).reshape(1, -1)
    assert round(get_cross_entropy_cost(Y_actual, Y_prediction), 5) == round(0.414931599615, 5)


def test_update_parameters():
    pass


class TestSimpleFfnn():
    def test_forward_propagation_deep(self):
        np.random.seed(1)
        X = np.random.randn(4, 2)
        W1 = np.random.randn(3, 4)
        b1 = np.random.randn(3, 1)
        W2 = np.random.randn(1, 3)
        b2 = np.random.randn(1, 1)

        s = SimpleFfnn([4, 3, 1], [None, relu, sigmoid], 1)
        s.cache_W[2] = W2
        s.cache_b[2] = b2
        s.cache_W[1] = W1
        s.cache_b[1] = b1

        s.forward_propagation_deep(X, X)

        assert np_array_equal(s.cache_A[-1], np.array([[0.17007265, 0.2524272]])) is True

    def test_backward_propagation_deep(self):
        np.random.seed(3)
        A_last = np.random.randn(1, 2)
        Y = np.array([[1, 0]])

        A0 = np.random.randn(4, 2)
        W1 = np.random.randn(3, 4)
        b1 = np.random.randn(3, 1)
        Z1 = np.random.randn(3, 2)

        A1 = np.random.randn(3, 2)
        W2 = np.random.randn(1, 3)
        b2 = np.random.randn(1, 1)
        Z2 = np.random.randn(1, 2)

        s = SimpleFfnn([4, 3, 1], [None, relu, sigmoid])
        s.cache_A[2] = A_last
        s.Y = Y

        s.cache_A[0] = A0
        s.cache_W[1] = W1
        s.cache_b[1] = b1
        s.cache_Z[1] = Z1

        s.cache_A[1] = A1
        s.cache_W[2] = W2
        s.cache_b[2] = b2
        s.cache_Z[2] = Z2

        s.backward_propagation_deep()

        assert np_array_equal(s.cache_dW[1], np.array([[0.41010002, 0.07807203, 0.13798444, 0.10502167],
                                                       [0., 0., 0., 0.],
                                                       [0.05283652, 0.01005865, 0.01777766, 0.0135308]])) is True
        assert np_array_equal(s.cache_db[1], np.array([[-0.22007063],
                                                       [0.],
                                                       [-0.02835349]])) is True
        assert np_array_equal(s.cache_dA[0], np.array([[0., 0.52257901],
                                                       [0., -0.3269206],
                                                       [0., -0.32070404],
                                                       [0., -0.74079187]])) is True

    def test_update_parameters_deep(self):
        np.random.seed(2)
        W1 = np.random.randn(3, 4)
        b1 = np.random.randn(3, 1)
        W2 = np.random.randn(1, 3)
        b2 = np.random.randn(1, 1)
        np.random.seed(3)
        dW1 = np.random.randn(3, 4)
        db1 = np.random.randn(3, 1)
        dW2 = np.random.randn(1, 3)
        db2 = np.random.randn(1, 1)

        s = SimpleFfnn([4, 3, 1], [None, relu, sigmoid])
        s.cache_W[1], s.cache_W[2] = W1, W2
        s.cache_b[1], s.cache_b[2] = b1, b2
        s.cache_dW[1], s.cache_dW[2] = dW1, dW2
        s.cache_db[1], s.cache_db[2] = db1, db2

        s.update_parameters_deep(0.1)

        assert np_array_equal(s.cache_W[1], np.array([[-0.59562069, -0.09991781, -2.14584584, 1.82662008],
                                                      [-1.76569676, -0.80627147, 0.51115557, -1.18258802],
                                                      [-1.0535704, -0.86128581, 0.68284052, 2.20374577]]))

        assert np_array_equal(s.cache_b[1], np.array([[-0.04659241],
                                                      [-1.28888275],
                                                      [0.53405496]]))

        assert np_array_equal(s.cache_W[2], np.array([[-0.55569196, 0.0354055, 1.32964895]]))

        assert np_array_equal(s.cache_b[2], np.array([[-0.84610769]]))

    def test_training(self):
        train_x_orig, train_y, test_x_orig, test_y, classes = load_data()

        # index = 10
        # plt.imshow(train_x_orig[index])
        # print("y = " + str(train_y[0, index]) + ". It's a " + classes[train_y[0, index]].decode("utf-8") + " picture.")

        # Reshape the training and test examples
        train_x_flatten = train_x_orig.reshape(train_x_orig.shape[0],
                                               -1).T  # The "-1" makes reshape flatten the remaining dimensions
        test_x_flatten = test_x_orig.reshape(test_x_orig.shape[0], -1).T

        # Standardize data to have feature values between 0 and 1.
        train_x = train_x_flatten / 255.
        test_x = test_x_flatten / 255.

        s1 = SimpleFfnn([train_x.shape[0], 7, 1], [None, relu, sigmoid], 1)
        learning_rate = 0.0075
        num_iteration = 2500
        s1.training(train_x, train_y, learning_rate, num_iteration)

        Y_prediction, Y_prediction_probability, accuracy = s1.predict(test_x, test_y)
        if accuracy is not None:
            assert round(accuracy, 5) == round(0.71999999999999997, 5)

        '''
        plt.plot(s1.costs)
        plt.ylabel('cost')
        plt.xlabel('iterations (per tens)')
        plt.title("Learning rate =" + str(learning_rate))
        plt.show()
        '''