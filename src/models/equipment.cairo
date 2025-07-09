use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct Equipment {
    #[key]
    pub id: felt252,
    pub owner: ContractAddress,
    pub skill_link: EEquipmentSkill,
    pub rarity: u8,
    pub base_attribute: EBaseAttribute,
    pub sub_attributes: Span<ByteArray>,
    pub level: u8,
}

#[derive(Drop, Serde)]
#[dojo::model]
pub struct MaxEquipmentLevel {
    #[key]
    pub rarity: u8,
    pub level: u8,
}

#[derive(Drop, Serde, Copy, Introspect)]
pub enum EBaseAttribute {
    Hp,
    Armour,
    Attack,
    Crit_Rate,
    Crit_Damage,
    Move_Speed,
    Evasion,
    Hp_Recovery,
    Armour_Recovery,
    Damage_Received_Reduction,
    Coin_Increase,
    Drop_Rate_Increase,
    Exp_Gain,
    Skill_Condition_Reduce,
    Hp_Gain,
    Armour_Gain,
    None,
}

#[derive(Drop, Serde, Copy, Introspect)]
pub enum EEquipmentSkill {
    Machine_Gun,
    Cloak,
    Pants,
    Gloves,
    Boots,
    Magic_Ring,
}

impl IntoResourceType of Into<EEquipmentSkill, felt252> {
    fn into(self: EEquipmentSkill) -> felt252 {
        match self {
            EEquipmentSkill::Machine_Gun => 'Machine_Gun',
            EEquipmentSkill::Cloak => 'Cloak',
            EEquipmentSkill::Pants => 'Pants',
            EEquipmentSkill::Gloves => 'Gloves',
            EEquipmentSkill::Boots => 'Boots',
            EEquipmentSkill::Magic_Ring => 'Magic_Ring',
        }
    }
}

impl PartialEqResourceType of PartialEq<EEquipmentSkill> {
    fn eq(lhs: @EEquipmentSkill, rhs: @EEquipmentSkill) -> bool {
        match (*lhs).into() - (*rhs).into() {
            0 => true,
            _ => false,
        }
    }

    fn ne(lhs: @EEquipmentSkill, rhs: @EEquipmentSkill) -> bool {
        match (*lhs).into() - (*rhs).into() {
            0 => false,
            _ => true,
        }
    }
}
