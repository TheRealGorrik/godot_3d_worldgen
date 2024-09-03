extends Node3D
class_name Chunk

var mesh_instance
#var noise: FastNoiseLite
var x: float
var z: float
var chunk_size

var myNoise: MyNoise
var mountainNoise: MyNoise
var plainsNoise: MyNoise

func _init(noise, mountainNoise, plainsNoise, x, z, chunk_size):
	#self.noise = noise;
	self.x = x
	self.z = z
	self.chunk_size = chunk_size
	self.myNoise = MyNoise.new(noise)
	self.mountainNoise = MyNoise.new(mountainNoise)
	self.plainsNoise = MyNoise.new(plainsNoise)

func _ready():
	generate_chunk();
	
func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.5
	plane_mesh.subdivide_width = chunk_size * 0.5
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)		
		var baseNoiseValue = myNoise.get_noise_2d(vertex.x+x, vertex.z+z)		
		var mountainNoiseValue = mountainNoise.get_noise_2d(vertex.x+x, vertex.z+z) * 10
		var plainsNoiseValue = plainsNoise.get_noise_2d(vertex.x+x, vertex.z+z) * -10
		
		var values = [baseNoiseValue, mountainNoiseValue, plainsNoiseValue]
		var sum = values.reduce(func(acc,num): return acc+num, 0)
		var ave = sum / values.size();
		
		vertex.y = ave
		#vertex.y = baseNoiseValue
		
		#vertex.y = myNoise.get_noise_3d(vertex.x+x, vertex.y, vertex.z+z);
		#vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 80
		data_tool.set_vertex(i, vertex)
		
	array_plane.clear_surfaces()
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
		
