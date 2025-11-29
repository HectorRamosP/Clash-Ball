extends Control

# ===== REFERENCIAS =====
@onready var team1_score = $Team1Score
@onready var team2_score = $Team2Score
@onready var separator = $Separator

func _ready():
	update_score(0, 0)

func update_score(score1: int, score2: int):
	team1_score.text = str(score1)
	team2_score.text = str(score2)
