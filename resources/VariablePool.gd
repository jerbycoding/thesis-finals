# VariablePool.gd
extends Resource
class_name VariablePool

@export var departments: Array[String] = []
@export var employees: Array[Dictionary] = [] # [{"name": "...", "dept": "...", "role": "..."}]
@export var attacker_ips: Array[String] = []
@export var malicious_domains: Array[String] = []
@export var partners: Array[Dictionary] = [] # [{"name": "...", "service": "...", "contact": "..."}]
