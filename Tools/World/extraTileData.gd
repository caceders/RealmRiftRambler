class_name ExtraTileData extends Resource

enum BIOME {
	NONE,
	SPECIAL,
	PLAINS,
}

enum ENVIRONMENT {
	NONE,
	SPECIAL,
	PLAINS,
	FOREST,
	POND,
}

enum FEATURE {
	NONE,
	SPECIAL,
	ROAD,
}

enum OBJECT {
	NONE,
	SPECIAL,
	PLANT,
	ROCK,
}

@export var biome: BIOME
@export var environment: ENVIRONMENT
@export var feature: FEATURE
@export var object: OBJECT