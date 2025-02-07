class_name DamageSpellComponent extends SpellComponent

@export var damage_amount: float = 1
@export var knockback: bool = true

@export var target: AffectEntity = AffectEntity.TARGET

func activate(spell_caster: SpellCaster):
	var damagable: DamageReceiver
	var damager: DamageDealer
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				damagable = spell_caster.parent.get_node("DamageReceiver") as DamageReceiver
				damager = spell_caster.parent.get_node("DamageDealer") as DamageDealer
		AffectEntity.TARGET:
			if spell_caster.target != null:
				damagable = spell_caster.target.get_node("DamageReceiver") as DamageReceiver
				damager = spell_caster.parent.get_node("DamageDealer") as DamageDealer
	
	if damagable != null and damager != null:
		damager.deal_damage(damage_amount, knockback, damagable)
	
