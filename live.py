#!/bin/python3

import random
from itertools import count
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

plt.style.use('fivethirtyeight')

x_values = []
y_values = []

index = count()


def animate(i):
    data = pd.read_csv('192.168.1.232.resourse_log.csv')
    x_values = data['time']
    y_values = data['cpu']
    plt.cla()
    plt.plot(x_values, y_values)
    plt.xlabel('Time')
    plt.ylabel('Price')
    plt.title('Infosys')
    plt.gcf().autofmt_xdate()
    plt.tight_layout()

ani = FuncAnimation(plt.gcf(), animate, 5000)

plt.tight_layout()
plt.show()
