extends Node
class_name RemoteTextureCombiner

signal combination_complete(images: Array[Image])

@export var fetcher: ResourceFetcher
@export var input_format: Image.Format
@export var output_format: Image.Format = Image.FORMAT_RGBA8
@export var input_uris: Array[String]

var fetched_images: Array[Image]
var output_images: Array[Image]

var in_progress: bool = false
var worker_thread: Thread

func _init(p_fetcher: ResourceFetcher, p_in_format: Image.Format, p_input_uris):
	fetcher = p_fetcher
	input_format = p_in_format
	input_uris = p_input_uris


func combine():
	if in_progress:
		return
	
	in_progress = true
	fetched_images = []
	fetched_images.resize(input_uris.size())
	fetched_images.fill(null)
	
	for idx in input_uris.size():
		fetcher.fetch_image_callback(input_uris[idx], func(img):
			_load_image(img, idx)
		)


func _load_image(img: Image, index: int):
	img.convert(input_format)
	fetched_images[index] = img
	if _is_all_loaded():
		worker_thread = Thread.new()
		worker_thread.start(_perform_conversion)


func _is_all_loaded() -> bool:
	if fetched_images.is_empty():
		return false
	
	return fetched_images.all(func(img): return img != null)


func _perform_conversion():
	output_images = []
	
	var width = fetched_images[0].get_width()
	var height = fetched_images[0].get_height()
	var in_stride = _get_format_stride(input_format)
	var out_stride = _get_format_stride(output_format)
	
	# Loop over the index of each output image
	for out_index in range(0, ((in_stride * fetched_images.size()) + (out_stride - 1)) / out_stride):
		var image = Image.create(width, height, false, output_format)
		
		# Loop over the *total* output channels that will be included in this output image
		# i.e. 0,1,2,3 for image 0, 4,5,6,7 for image 1
		for in_index in range(out_index * out_stride, (out_index + 1) * out_stride):
			var in_image = fetched_images[in_index / in_stride]
			var from_channel = in_index % in_stride
			var to_channel = in_index % out_stride
			_copy_channel(in_image, from_channel, in_stride, image, to_channel, out_stride)
		
		output_images.append(image)
	
	in_progress = false
	combination_complete.emit(output_images)


func _copy_channel(in_image: Image, from_channel: int, in_stride: int, out_image: Image, to_channel: int, out_stride: int):
	if (in_image.get_height() != out_image.get_height() or
	in_image.get_width() != out_image.get_width()):
		push_error("Given images do not have matching dimensions!")
		return
	
	var in_data = in_image.get_data()
	var data_buffer = out_image.get_data()
	
	for index in range(0, in_image.get_width() * in_image.get_height()):
		data_buffer[(index * out_stride) + to_channel] = in_data[(index * in_stride) + from_channel]
	
	out_image.set_data(out_image.get_width(), out_image.get_height(), out_image.has_mipmaps(), out_image.get_format(), data_buffer)


func _get_channels_stride(used_channels: Image.UsedChannels) -> int:
	if used_channels >= Image.USED_CHANNELS_R:
		return used_channels - 1
	else:
		return used_channels + 1


func _get_format_stride(format: Image.Format) -> int:
	if format >= Image.FORMAT_R8 and format <= Image.FORMAT_RGBA8:
		return format - (Image.FORMAT_R8 - 1)
	elif format >= Image.FORMAT_RF and format <= Image.FORMAT_RGBAF:
		return format - (Image.FORMAT_RF - 1)
	elif format >= Image.FORMAT_RH and format <= Image.FORMAT_RGBAH:
		return format - (Image.FORMAT_RH - 1)
	else:
		return 0


func _exit_tree():
	worker_thread.wait_to_finish()
