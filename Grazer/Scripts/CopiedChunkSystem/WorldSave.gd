class_name worldsave extends Node

@onready var loadedCoords = []
@onready var dataInChunk = []

#Coordinates are stored in chunk coords, so like (1,0,1) NOT (16,0,16)!

func addChunk(coords):
	loadedCoords.append(coords)
	dataInChunk.append([])

func saveChunk(coords,data):
	dataInChunk[loadedCoords.find(coords)] = data

func retriveData(coords):
	#checkForDuplicates(coords)
	if(loadedCoords.size() < 1):
		return -1
	var data = dataInChunk[loadedCoords.find(coords)]

	return data

func checkForDuplicates(coords):
	var numInstances = 0
	for c in loadedCoords:
		if(c == coords):
			numInstances += 1
	print("There are " + str(numInstances) + " of " + str(coords))
	if(numInstances > 1):
		return true
	return false 

func reset():
	loadedCoords.clear()
	dataInChunk.clear()

func test():
	print("test accessed")
