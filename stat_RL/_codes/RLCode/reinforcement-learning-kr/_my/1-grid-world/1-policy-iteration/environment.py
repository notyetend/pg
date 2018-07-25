import tkinter as tk
from tkinter import Button
from PIL import ImageTk, Image


PhotoImage = ImageTk.PhotoImage
UNIT = 100  # number of pixel
HEIGHT = 5  # height of the grid world
WIDTH = 5  # width of the grid world


class GraphicDisplay(tk.Tk):
    def __init__(self, agent):
        super(GraphicDisplay, self).__init__()
        self.title('Policy Iteration')
        self.geometry('{0}x{1}'.format(HEIGHT * UNIT, HEIGHT * UNIT + 50))

        self.texts = []
        self.arrows = []
        self.env = Env()
        self.agent = agent
        self.evaluation_count = 0
        self.improvement_count = 0
        self.is_moving = 0

        (self.up, self.down, self.left, self.right), self.shapes = self.load_images()

        self.canvas = self._build_canvas()


    def _build_canvas(self):  # 1
        canvas = tk.Canvas(self, bg='white',
                           height=HEIGHT * UNIT,
                           width=WIDTH * UNIT)

        # evaluation button
        iteration_button = Button(self, text="Evaluate", command=self.evaluate_policy)
        iteration_button.configure(width=10, activebackground="#33B5E5")
        canvas.create_window(WIDTH * UNIT * 0.13, HEIGHT * UNIT + 10, window=iteration_button)

        # policy button
        policy_button = Button(self, text="Improve", command=self.improve_policy)
        policy_button.configure(width=10, activebackground="#33B5E5")
        canvas.create_window(WIDTH * UNIT * 0.37, HEIGHT * UNIT + 10, window=policy_button)

        '''
        # move button
        policy_button = Button(self, text="move", command=self.move_by_policy)
        policy_button.configure(width=10, activebackground="#33B5E5")
        canvas.create_window(WIDTH * UNIT * 0.62, HEIGHT * UNIT + 10, window=policy_button)

        # reset button
        policy_button = Button(self, text="reset", command=self.reset)
        policy_button.configure(width=10, activebackground="#33B5E5")
        canvas.create_window(WIDTH * UNIT * 0.87, HEIGHT * UNIT + 10, window=policy_button)
        '''

        # move button
        move_button = Button(self, text="move", command=self.move_by_policy)
        move_button.configure(width=10, activebackground="#33B5E5")
        canvas.create_window(WIDTH * UNIT * 0.62, HEIGHT * UNIT + 10, window=move_button)

        # reset button
        reset_button = Button(self, text="reset", command=self.reset)
        reset_button.configure(width=10, activebackground="#33B5E5")
        canvas.create_window(WIDTH * UNIT * 0.87, HEIGHT * UNIT + 10, window=reset_button)

        # vertical lines of grid
        for col in range(0, WIDTH * UNIT, UNIT):  # 0~400 by 80
            x0, y0, x1, y1 = col, 0, col, HEIGHT * UNIT
            canvas.create_line(x0, y0, x1, y1)

        # horizontal lines of grid
        for row in range(0, HEIGHT * UNIT, UNIT):  # 0~400 by 80
            x0, y0, x1, y1 = 0, row, HEIGHT * UNIT, row
            canvas.create_line(x0, y0, x1, y1)

        self.rectangle = canvas.create_image(50, 50, image=self.shapes[0])  # rectangle
        canvas.create_image(250, 150, image=self.shapes[1])  # triangle
        canvas.create_image(150, 250, image=self.shapes[1])  # triangle
        canvas.create_image(250, 250, image=self.shapes[2])  # circle

        canvas.pack()
        return canvas

    def load_images(self):  # 2
        up = PhotoImage(Image.open("../img/up.png").resize((13, 13)))
        right = PhotoImage(Image.open("../img/right.png").resize((13, 13)))
        left = PhotoImage(Image.open("../img/left.png").resize((13, 13)))
        down = PhotoImage(Image.open("../img/down.png").resize((13, 13)))
        rectangle = PhotoImage(Image.open("../img/rectangle.png").resize((65, 65)))
        triangle = PhotoImage(Image.open("../img/triangle.png").resize((65, 65)))
        circle = PhotoImage(Image.open("../img/circle.png").resize((65, 65)))
        return (up, down, left, right), (rectangle, triangle, circle)

    def reset(self):  # 3
        print('reset')
        pass

    def move_by_policy(self):  # 8
        print('move_by_policy')
        pass

    def evaluate_policy(self):  # 13
        print('evaluate_policy')
        pass

    def improve_policy(self):  # 14
        print('improve_policy')
        pass

class Env:
    def __init__(self):
        pass
