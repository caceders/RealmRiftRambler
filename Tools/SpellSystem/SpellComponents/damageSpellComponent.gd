class_name DamageSpellComponent extends SpellComponent

@export var damage_amount: float = 1
@export var knockback: bool = true

@export var target: AffectEntity = AffectEntity.TARGET

func activate(spell_caster: SpellCaster):
	match target:
		AffectEntity.CASTER:
			if spell_caster.parent != null:
				var damagable = spell_caster.parent.get_node("DamageReceiver") as DamageReceiver
				var damager = spell_caster.parent.get_node("DamageDealer") as DamageDealer
				if damagable != null and damager != null:
					damager.deal_damage(damage_amount, knockback, damagable)
		AffectEntity.TARGET:
			if spell_caster.target != null:
				var damagable = spell_caster.target.get_node("DamageReceiver") as DamageReceiver
				var damager = spell_caster.parent.get_node("DamageDealer") as DamageDealer
				if damagable != null and damager != null:
					damager.deal_damage(damage_amount, knockback, damagable)
		_:
			pass
