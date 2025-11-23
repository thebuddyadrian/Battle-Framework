extends Resource
class_name CharacterInfo

@export var display_name: String
@export_group("File Paths")
@export_file var portrait_path: String
@export_file var life_icon_path: String
@export_group("Character Stats")
@export var max_hp: int = 300
@export var move_speed: int = 8000
@export var jump_velocity: int = 14000
@export var gravity: int = 650
@export var fall_speed: int = 12000
@export var acceleration: int = 800
@export var deceleration: int = 750
@export var air_acceleration: int = 500
@export var air_deceleration: int = 150
@export var max_air_actions: int = 1
@export var max_air_skills: int = 1
