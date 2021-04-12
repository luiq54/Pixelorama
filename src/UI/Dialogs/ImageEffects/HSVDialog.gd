extends ImageEffect


onready var hue_slider = $VBoxContainer/HBoxContainer/Sliders/Hue
onready var sat_slider = $VBoxContainer/HBoxContainer/Sliders/Saturation
onready var val_slider = $VBoxContainer/HBoxContainer/Sliders/Value

onready var hue_spinbox = $VBoxContainer/HBoxContainer/TextBoxes/Hue
onready var sat_spinbox = $VBoxContainer/HBoxContainer/TextBoxes/Saturation
onready var val_spinbox = $VBoxContainer/HBoxContainer/TextBoxes/Value


var confirmed: bool = false
func _about_to_show():
	var sm : ShaderMaterial = ShaderMaterial.new()
	sm.shader = load("res://src/Shaders/HSV.shader")
	$VBoxContainer/Preview.set_material(sm)
	._about_to_show()


func set_nodes() -> void:
	preview = $VBoxContainer/Preview
	selection_checkbox = $VBoxContainer/AffectHBoxContainer/SelectionCheckBox
	affect_option_button = $VBoxContainer/AffectHBoxContainer/AffectOptionButton


func _confirmed() -> void:
	confirmed = true
	._confirmed()
	reset()


func commit_action(_cel : Image, _project : Project = Global.current_project) -> void:
	#DrawingAlgos.adjust_hsv(_cel, hue_slider.value, sat_slider.value, val_slider.value, selection_checkbox.pressed, _project)
	var selection = Global.canvas.selection.get_big_bounding_image()
	var selection_tex = ImageTexture.new()
	selection_tex.create_from_image(selection)

	if !confirmed:
		$VBoxContainer/Preview.material.set_shader_param("hue_shift_amount", hue_slider.value /360)
		$VBoxContainer/Preview.material.set_shader_param("sat_shift_amount", sat_slider.value /100)
		$VBoxContainer/Preview.material.set_shader_param("val_shift_amount", val_slider.value /100)
		$VBoxContainer/Preview.material.set_shader_param("selection", selection_tex)
		$VBoxContainer/Preview.material.set_shader_param("affect_selection", selection_checkbox.pressed)
	else:
		var params = {
			"hue_shift_amount": hue_slider.value /360,
			"sat_shift_amount": sat_slider.value /100,
			"val_shift_amount": val_slider.value /100,
			"selection": selection_tex,
			"affect_selection": selection_checkbox.pressed,
		}
		var gen: ShaderImageEffect = ShaderImageEffect.new()
		gen.generate_image(_cel, "res://src/Shaders/HSV.shader", params)
		yield(gen, "done")


func reset() -> void:
	disconnect_signals()
	hue_slider.value = 0
	sat_slider.value = 0
	val_slider.value = 0
	hue_spinbox.value = 0
	sat_spinbox.value = 0
	val_spinbox.value = 0
	reconnect_signals()
	confirmed = false


func disconnect_signals() -> void:
	hue_slider.disconnect("value_changed",self,"_on_Hue_value_changed")
	sat_slider.disconnect("value_changed",self,"_on_Saturation_value_changed")
	val_slider.disconnect("value_changed",self,"_on_Value_value_changed")
	hue_spinbox.disconnect("value_changed",self,"_on_Hue_value_changed")
	sat_spinbox.disconnect("value_changed",self,"_on_Saturation_value_changed")
	val_spinbox.disconnect("value_changed",self,"_on_Value_value_changed")


func reconnect_signals() -> void:
	hue_slider.connect("value_changed",self,"_on_Hue_value_changed")
	sat_slider.connect("value_changed",self,"_on_Saturation_value_changed")
	val_slider.connect("value_changed",self,"_on_Value_value_changed")
	hue_spinbox.connect("value_changed",self,"_on_Hue_value_changed")
	sat_spinbox.connect("value_changed",self,"_on_Saturation_value_changed")
	val_spinbox.connect("value_changed",self,"_on_Value_value_changed")


func _on_Hue_value_changed(value : float) -> void:
	hue_spinbox.value = value
	hue_slider.value = value
	update_preview()


func _on_Saturation_value_changed(value : float) -> void:
	sat_spinbox.value = value
	sat_slider.value = value
	update_preview()


func _on_Value_value_changed(value : float) -> void:
	val_spinbox.value = value
	val_slider.value = value
	update_preview()
