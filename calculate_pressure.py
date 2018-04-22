ori_data = []
data1 = []
data2 = []

with open("~/resource_model/pressure_data", "r") as ins:
    for line in ins:
        ori_data.append(int(line))

flag = True
for item in ori_data:
    if flag and item == 0:
        continue
    else:
        flag = False
        data1.append(item)

flag = True
for item in reversed(data1):
    if flag and item == 0:
        continue
    else:
        flag = False
        data2.append(item)

print(1.0 * sum(data2) / len(data2))