from unittest import TestCase
from SimpleFfnn import SimpleFfnn, relu, sigmoid, forward_propagation, get_random_b_W, backward_propagation
import numpy as np


class TestSimpleFfnn(TestCase):

    def __init__(self, *args, **kwargs):
        super(TestSimpleFfnn, self).__init__(*args, **kwargs)
        print(1)
        self.Z = 10

    def test_relu(self):
        self.assertEqual(10, relu(10), '10 = relu(10)')
        self.assertEqual(0, relu(-1), '0 = relu(-1)')
        self.assertEqual(0, relu(0), '0 = relu(0)')

        self.assertEqual(1, relu(10, False), '1 = d relu(10)')
        self.assertEqual(0, relu(-1, False), '0 = d relu(-1)')
        self.assertEqual(0, relu(0, False), '0 = d relu(0)')

    def test_sigmoid(self):
        self.assertEqual(0.5, sigmoid(0))
        self.assertEqual(0.5*(1-0.5), sigmoid(0, False))

    def test_forward_propagation(self):
        np.random.seed(2)
        A_l_prev = np.random.randn(3, 2)
        W_l = np.random.randn(1, 3)
        b_l = np.random.randn(1, 1)
        A_l_sigmoid, _ = forward_propagation(A_l_prev, W_l, b_l, sigmoid)
        A_l_relu, _ = forward_propagation(A_l_prev, W_l, b_l, relu)

        self.assertEqual(True, np.array_equal(np.round(A_l_sigmoid, 3), np.round(np.array([[0.96890023, 0.11013289]]), 3)))
        self.assertEqual(True, np.array_equal(np.round(A_l_relu, 3), np.round(np.array([[ 3.43896131, 0. ]]), 3)))

    def test_backward_propagation(self):
        np.random.seed(2)
        dA_l = np.random.randn(1, 2)
        A_l_prev = np.random.randn(3, 2)
        W_l = np.random.randn(1, 3)
        Z_l = np.random.randn(1, 2)

        print(A_l_prev)
        dA_l_prev, dW_l, db_l = backward_propagation(dA_l, A_l_prev, W_l, Z_l, g_l=sigmoid)
        print(dA_l_prev, dW_l, db_l)

    def test__initialize_parameters(self):
        self.fail()

    def test_forward_propagation_deep(self):
        self.fail()

    def test_backward_propagation_deep(self):
        self.fail()
