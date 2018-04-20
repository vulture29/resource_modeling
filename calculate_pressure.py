count = 0
sum_pressure = 0

with open("/home/centos/resource_model/pressure_data", "r") as ins:
    for line in ins:
        if len(line) > 0:
            pressure = int(line)
            if pressure > 0:
                count += 1
                sum_pressure += pressure

print(1.0 * sum_pressure / count)