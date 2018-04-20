import random
import pickle
import numpy as np
import matplotlib.pyplot as plt

from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import make_pipeline
from sklearn.metrics import mean_squared_error

# read file
with open("/home/centos/resource_model/res_data", "r") as ins:
    read_x = []
    read_y = []
    for line in ins:
        read_x.append(int(line.split()[0]))
        read_y.append(int(line.split()[1]))

if(len(read_x) < 5):
	print("not enough datapoint. Fail to build model.")

# generate points used to plot
test_x = []
test_y = []
ori_x = []
ori_y = []
test_index = random.sample(range(0, len(read_x)-1), 3)
for index,x in enumerate(read_x):
	if index in test_index:
		test_x.append(x)
	else:
		ori_x.append(x)
for index,y in enumerate(read_y):
	if index in test_index:
		test_y.append(y)
	else:
		ori_y.append(y)
x = np.asarray(ori_x)
x_plot = np.linspace(0, 30, 300)

# generate points and keep a subset of them
y = np.asarray(ori_y)

# create matrix versions of these arrays
X = x[:, np.newaxis]
X_plot = x_plot[:, np.newaxis]

colors = ['teal', 'yellowgreen', 'gold']
lw = 2

plt.scatter(ori_x, ori_y, color='red', s=5, marker='o', label="training points")

save_model = None
save_model_error = -1

for count, degree in enumerate([5, 6, 7]):
    model = make_pipeline(PolynomialFeatures(degree), LinearRegression())
    model.fit(X, y)
    y_plot = model.predict(X_plot)
    plt.plot(x_plot, y_plot, color=colors[count], linewidth=lw,
             label="degree %d" % degree)
    predict_test_y = model.predict(np.asarray(test_x)[:, np.newaxis])
    error = mean_squared_error(np.asarray(test_y), predict_test_y)
    print("Degree " + str(degree) + " mean squared error: " + str(error))
    if save_model is None or (error < save_model_error and save_model_error > 0):
    	save_model = model

# test
plt.scatter(test_x, test_y, color='black', s=5, marker='o', label="testing points")

model_str = pickle.dumps(save_model)
with open("resource_model", "w") as text_file:
    text_file.write(model_str)

plt.ylim(ymin=0)
plt.suptitle('cpu resource model', fontsize=16)
plt.legend(loc='lower left')
plt.xlabel('Limited CPU resource usage(%)')
plt.ylabel('SLO - Average Response Time (ms)')
# plt.show()