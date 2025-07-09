use crimson_fate::models::equipment::{EBaseAttribute, EEquipmentSkill};
use core::panic_with_felt252;

pub fn get_base_attribute(attribute: u8) -> EBaseAttribute {
    match attribute {
        0 => EBaseAttribute::Hp,
        1 => EBaseAttribute::Armour,
        2 => EBaseAttribute::Attack,
        3 => EBaseAttribute::Crit_Rate,
        4 => EBaseAttribute::Crit_Damage,
        5 => EBaseAttribute::Move_Speed,
        6 => EBaseAttribute::Evasion,
        7 => EBaseAttribute::Hp_Recovery,
        8 => EBaseAttribute::Armour_Recovery,
        9 => EBaseAttribute::Damage_Received_Reduction,
        10 => EBaseAttribute::Coin_Increase,
        11 => EBaseAttribute::Drop_Rate_Increase,
        12 => EBaseAttribute::Exp_Gain,
        13 => EBaseAttribute::Skill_Condition_Reduce,
        14 => EBaseAttribute::Hp_Gain,
        15 => EBaseAttribute::Armour_Gain,
        _ => EBaseAttribute::None
    }
}

pub fn get_skill_link(skill: u8) -> EEquipmentSkill {
    if skill == 12 {
        return EEquipmentSkill::Machine_Gun;
    } else if skill == 30 {
        return EEquipmentSkill::Cloak;
    } else if skill == 31 {
        return EEquipmentSkill::Pants;
    } else if skill == 32 {
        return EEquipmentSkill::Gloves;
    } else if skill == 33 {
        return EEquipmentSkill::Boots;
    } else if skill == 34 {
        return EEquipmentSkill::Magic_Ring;
    }
    panic_with_felt252('Equipment skill not found')
}

pub fn cal_upgrade_cost(current_level: u8) -> (u16, u16) {
    let range_level = array![10, 20, 30, 40, 50, 60, 70, 80, 90, 100].span();
    let mut gem_cost: u16 = 0;
    let mut soul_cost: u16 = 0;
    let mut i = 0;
    while i < current_level + 1 {
        if (i < *range_level.at(0)) {
            gem_cost += 100;
            soul_cost += 1;
        } else if (i < *range_level.at(1)) {
            gem_cost += 200;
            soul_cost += 10;
        } else if (i < *range_level.at(2)) {
            gem_cost += 300;
            soul_cost += 20;
        } else if (i < *range_level.at(3)) {
            gem_cost += 400;
            soul_cost += 30;
        } else if (i < *range_level.at(4)) {
            gem_cost += 500;
            soul_cost += 40;
        } else if (i < *range_level.at(5)) {
            gem_cost += 600;
            soul_cost += 50;
        } else if (i < *range_level.at(6)) {
            gem_cost += 700;
            soul_cost += 60;
        } else if (i < *range_level.at(7)) {
            gem_cost += 800;
            soul_cost += 70;
        } else if (i < *range_level.at(8)) {
            gem_cost += 900;
            soul_cost += 80;
        } else if (i < *range_level.at(9)) {
            gem_cost += 1000;
            soul_cost += 100;
        }
        i += 1;
    };

    (gem_cost, soul_cost)
}
