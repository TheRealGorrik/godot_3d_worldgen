extends Node

class_name MyNoise

var noise

@export var noise_scale = 64.0
@export var octaves: int = 8
@export var presistance: float = 0.025
@export var lacunarity: float = 1.5
@export var exponentiation: float = 3.7
@export var noise_height: float = 256.0

func _init(noise):
	self.noise = noise
	pass
	
func get_noise_2d(x,y):
	var xs = x / noise_scale
	var ys = y / noise_scale
	
	var G = 2.0 ** (-presistance)
	var amplitude = 1.0
	var frequency = 1.0
	var normalization = 0
	var total = 0
	
	for o in range(octaves):
		var noiseValue = noise.get_noise_2d(xs*frequency, ys*frequency) * 0.5 + 0.5
		total += noiseValue * amplitude
		normalization += amplitude
		amplitude *= G
		frequency *= lacunarity
		
	total /= normalization
	return (total ** exponentiation) * noise_height
	
func get_noise_3d(x,y,z):
	var xs = x / noise_scale
	var ys = y / noise_scale
	var zs = z / noise_scale
	
	var G = 2.0 ** (-presistance)
	var amplitude = 1.0
	var frequency = 1.0
	var normalization = 0
	var total = 0
	
	for o in range(octaves):
		var noiseValue = noise.get_noise_3d(xs*frequency, ys*frequency, zs*frequency) * 0.5 + 0.5
		total += noiseValue * amplitude
		normalization += amplitude
		amplitude *= G
		frequency *= lacunarity
		
	total /= normalization
	var retVal = (total ** exponentiation) * noise_height
	return retVal
