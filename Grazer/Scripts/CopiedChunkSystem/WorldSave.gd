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
	var data = dataInChunk[loadedCoords.find(coords)]
	return data

func test():
	print("test accessed")
