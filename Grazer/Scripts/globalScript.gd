extends Node
func findHerdCenter() -> Vector3:
	var nodePath = "/Level"
	var level = get_node(nodePath)
	
	var herd = get_tree().get_nodes_in_group("herd")
	var loc = Vector3(0,0,0)
	var numCows = 0
	for x in herd:
		numCows += 1
		loc += x.transform.origin
	loc /= numCows
	print("numCows: " + str(numCows))
	print(str(loc))
	return loc
