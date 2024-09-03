extends Node3D

@export var octaves: int = 6
@export var freqency: float = 0.01
@export var lacunarity: float = 2.0
@export var gain: float = 0.5

var noise
var mountainNoise
var plainsNoise
var chunk_size = 64
var chunk_amount = 16
var chunks = {}
var unready_chunks = {}
var thread: Thread

func _ready():
	randomize()
	noise = FastNoiseLite.new()
	mountainNoise = FastNoiseLite.new()
	plainsNoise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	mountainNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	plainsNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = 1
	mountainNoise.seed = 2
	plainsNoise.seed = 3
	plainsNoise.fractal_lacunarity = 1.0
	plainsNoise.fractal_gain = 1.0
	#noise.fractal_octaves = octaves
	#noise.frequency = freqency
	#noise.fractal_lacunarity = lacunarity
	#noise.fractal_gain = gain
	
	thread = Thread.new()
	
func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	if not thread.is_started():
		var callable = Callable(self, "load_chunk")
		thread.start(callable.bind(thread,x,z))
		unready_chunks[key] = 1
	
func load_chunk(thread:Thread, x, z):	
	var chunk = Chunk.new(noise, mountainNoise, plainsNoise, x * chunk_size, z * chunk_size, chunk_size)
	chunk.translate(Vector3(x * chunk_size, 0, z * chunk_size))
	
	call_deferred("load_done", chunk, thread)
	
func load_done(chunk:Chunk, thread:Thread):
	add_child(chunk)
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	thread.wait_to_finish()
	
func get_chunk(x,z):	
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return chunks.get(key)
	
	return null

func _process(delta):	
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	
func update_chunks():
	var player_translation = $Player.position
	var p_x = int(player_translation.x) / chunk_size
	var p_z = int(player_translation.z) / chunk_size
	
	for x in range(p_x - chunk_amount * 0.5, p_x + chunk_amount * 0.5):
		for z in range(p_z - chunk_amount * 0.5, p_z + chunk_amount * 0.5):
			add_chunk(x,z)
	
	pass
	
func clean_up_chunks():
	
	pass
	
func reset_chunks():
	pass







