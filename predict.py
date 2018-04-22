import pickle

allow_SLO = 300

with open('resource_model', 'r') as myfile:
    data=myfile.read()

model = pickle.loads(data)

allow_pressure = 0

for i in range(100, 0, -1):
	predict_slo = float(model.predict(i))
	if predict_slo < allow_SLO:
		allow_pressure = i
		break

print("Allowed pressure is " + str(allow_pressure))

with open('allow_pressure', 'w') as myfile:
    myfile.write(str(allow_pressure))