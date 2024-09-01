extends StaticBody2D

onready var text = get_node("RichTextLabel")
onready var timer = get_node("RichTextLabel/Timer")

var msg_length 
var  visible_char = 0

func _ready():
	msg_length = text.bbcode_text.length()
	print(msg_length)

func _on_Area2D_area_entered(area):
	print(area)
	$CanvasLayer/RichTextLabel/Timer.start(0.5)

func _on_Area2D_area_exited(area):
	print(area)
	$CanvasLayer/RichTextLabel/Timer.stop()
	visible_char = 0

func _on_Timer_timeout():
	if visible_char <= msg_length:
		visible_char += 1
	else:
		$CanvasLayer/RichTextLabel/Timer.stop()
	
