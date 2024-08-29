extends AnimatedSprite

func play_particles():
	play("idle")


func _on_RunParticles_animation_finished():
	queue_free()
