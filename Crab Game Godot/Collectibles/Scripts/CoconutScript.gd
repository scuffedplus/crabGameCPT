extends Area2D

"""
Collectible ID Guide:
0 = Dragonfly
1 = Gold Key
2 = Red Key
3 = Blue Key
4 = Gold Coin
5 = Coconut
"""

var CollectibleID = 5
var SecondaryID = 0
var SingleUse = true
var CollectibleInfo = [CollectibleID, SecondaryID, SingleUse]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Coin Spin animation go here
	pass

func GetInfo():
	return(CollectibleInfo)

func Die():
	queue_free()
