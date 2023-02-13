class_name worldsave extends Node

onready var loadedCoords = []
onready var dataInChunk = []

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
