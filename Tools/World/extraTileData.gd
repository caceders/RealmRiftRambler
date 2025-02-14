class_name ExtraTileData extends Resource

enum BIOME {
	NONE,
	SPECIAL,
	PLAINS,
}

enum ENVIRONMENT {
	NONE,
	SPECIAL,
	FOREST,
	POND,
}

enum FEATURE {
	NONE,
	SPECIAL,
}

enum OBJECT {
	NONE,
	SPECIAL,
}

@export var biome: BIOME
@export var environment: ENVIRONMENT
@export var feature: FEATURE
@export var object: OBJECT