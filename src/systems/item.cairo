use crimson_fate::constants::{ReceiveEquipment, ReceiveSoulPieceResource};

#[starknet::interface]
trait IItemSystem<TState> {
    fn set_max_equipment_level(ref self: TState, rarity: u8, level: u8);
    fn claim_new_equipments(ref self: TState, items: Array<ReceiveEquipment>, key: Array<felt252>);
    fn claim_soul_piece_resources(
        ref self: TState, resources: Array<ReceiveSoulPieceResource>, key: Array<felt252>,
    );
    fn upgrade_equipment(ref self: TState, item_id: felt252);
    fn reforge_equipment(
        ref self: TState, item_id: felt252, sub_attributes: Span<ByteArray>, key: Array<felt252>,
    );
    fn merge_equipment(
        ref self: TState,
        main_item_id: felt252,
        sub_item_ids: Span<felt252>,
        new_sub_attribute: ByteArray,
    );
}

#[dojo::contract]
mod ItemSystem {
    use crimson_fate::constants::{
        DEFAULT_NS, SYSTEM_VERSION, AccountABIDispatcher, AccountABIDispatcherTrait,
        ReceiveEquipment, ReceiveSoulPieceResource, GemABIDispatcher, GemABIDispatcherTrait,
        GEM_ADDRESS_FELT, WEI_UNIT,
    };
    use crimson_fate::utils::signature::{
        IStructHash, v1::OffChainMessageHashStruct, v1::RECEIVE_EQUIPMENT_STRUCT_TYPE_HASH,
    };
    use crimson_fate::utils::equipment::{get_base_attribute, get_skill_link, cal_upgrade_cost};
    use crimson_fate::utils::resource::{get_resource_type};
    use crimson_fate::models::signature::{Prover, UsedSignature};
    use crimson_fate::models::equipment::{Equipment, MaxEquipmentLevel, EEquipmentSkill};
    use crimson_fate::models::resource::{PlayerSoulPieceResource, ResourceType};
    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::world::{IWorldDispatcherTrait, WorldStorageTrait};
    use core::poseidon::PoseidonTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use core::num::traits::Zero;
    use core::array::ArrayTrait;
    use core::panic_with_felt252;
    use starknet::{get_caller_address, contract_address_const};


    // impl StructHashReceiveEquipment of IStructHash<ReceiveEquipment> {
    //     fn get_struct_hash(self: @ReceiveEquipment) -> felt252 {
    //         let mut state = PoseidonTrait::new();
    //         state = state.update_with(RECEIVE_EQUIPMENT_STRUCT_TYPE_HASH);
    //         state = state.update_with(*self.id);
    //         state = state.update_with(*self.skill_link);
    //         state = state.update_with(*self.rarity);
    //         state = state.update_with(*self.base_attribute);
    //         state = state.update_with(self.sub_attribute.get_struct_hash());
    //         state.finalize()
    //     }
    // }

    impl StructHashByteArray of IStructHash<ByteArray> {
        fn get_struct_hash(self: @ByteArray) -> felt252 {
            let mut state = PoseidonTrait::new();
            let mut output = array![];
            Serde::serialize(self, ref output);
            for e in output.span() {
                state = state.update_with(*e);
            };
            state.finalize()
        }
    }


    #[abi(embed_v0)]
    impl ItemSystemImpl of super::IItemSystem<ContractState> {
        fn set_max_equipment_level(ref self: ContractState, rarity: u8, level: u8) {
            let mut world = self.world(@DEFAULT_NS());
            let caller = get_caller_address();
            let selector = world.resource_selector(@"MaxEquipmentLevel");
            assert(world.dispatcher.is_owner(selector, caller), 'only owner of model');
            let mut max_equipment_level: MaxEquipmentLevel = world.read_model(rarity);
            max_equipment_level.level = level;
            world.write_model(@max_equipment_level);
        }

        fn claim_new_equipments(
            ref self: ContractState, items: Array<ReceiveEquipment>, key: Array<felt252>,
        ) {
            let mut world = self.world(@DEFAULT_NS());
            // let prover: Prover = world.read_model(SYSTEM_VERSION);

            // let msg_hash = OffChainMessageHashStruct::get_message_hash(
            //     ReceiveEquipment {
            //         id,
            //         skill_link: skill_link.into(),
            //         rarity: rarity.into(),
            //         base_attribute: base_attribute.into(),
            //         sub_attribute: sub_attribute.clone(),
            //     },
            //     prover.address
            // );

            // let account: AccountABIDispatcher = AccountABIDispatcher {
            //     contract_address: prover.address,
            // };

            // assert(account.is_valid_signature(msg_hash, key) == 'VALID', 'Invalid signature');
            // let mut used_signature: UsedSignature = world.read_model(msg_hash);
            // assert(!used_signature.is_used, 'signature already used');
            // used_signature.is_used = true;
            // world.write_model(@used_signature);

            for equip in items.span() {
                let mut equipment: Equipment = world.read_model(*equip.id);
                assert(equipment.owner.is_zero(), 'equipment already claimed');
                assert(
                    (*equip.sub_attributes).len() > 0 && (*equip.sub_attributes).len()
                        - 1 == (*equip.rarity).into(),
                    'sub attributes length not match',
                );
                equipment.owner = get_caller_address();
                equipment.skill_link = get_skill_link(*equip.skill_link);
                equipment.rarity = *equip.rarity;
                equipment.base_attribute = get_base_attribute(*equip.base_attribute);
                equipment.sub_attributes = *equip.sub_attributes;
                world.write_model(@equipment);
            }
        }

        fn claim_soul_piece_resources(
            ref self: ContractState,
            resources: Array<ReceiveSoulPieceResource>,
            key: Array<felt252>,
        ) {
            let mut world = self.world(@DEFAULT_NS());
            let caller = get_caller_address();
            let mut playerResource: PlayerSoulPieceResource = world.read_model(caller);

            for rs in resources.span() {
                let rs_type = get_resource_type(*rs.resource_type);
                match rs_type {
                    ResourceType::Mechanic => { playerResource.mechanic_soul += *rs.amount; },
                    ResourceType::Fire => { playerResource.fire_soul += *rs.amount; },
                    ResourceType::Lightning => { playerResource.lightning_soul += *rs.amount; },
                    ResourceType::Mythic => { playerResource.mythic_soul += *rs.amount; },
                    ResourceType::Pollute => { playerResource.pollute_soul += *rs.amount; },
                    ResourceType::Five_Element => {
                        panic_with_felt252('Five_Element not supported');
                    },
                }
            };

            world.write_model(@playerResource);
        }

        fn upgrade_equipment(ref self: ContractState, item_id: felt252) {
            let mut world = self.world(@DEFAULT_NS());
            let caller = get_caller_address();
            let mut equipment: Equipment = world.read_model(item_id);
            assert(equipment.owner == caller, 'only owner of equipment');
            let max_equipment_level: MaxEquipmentLevel = world.read_model(equipment.rarity);
            assert(equipment.level + 1 <= max_equipment_level.level, 'equipment level is max');

            let (gem_cost, soul_cost) = cal_upgrade_cost(equipment.level);
            let gem_dispatcher = GemABIDispatcher {
                contract_address: contract_address_const::<GEM_ADDRESS_FELT>(),
            };

            gem_dispatcher.burn(caller, (gem_cost.into() * WEI_UNIT));
            let mut playerResource: PlayerSoulPieceResource = world.read_model(caller);
            match equipment.skill_link {
                EEquipmentSkill::Machine_Gun => {
                    assert(playerResource.fire_soul >= soul_cost.into(), 'not enough soul');
                    playerResource.fire_soul -= soul_cost.into();
                },
                EEquipmentSkill::Cloak => {
                    assert(playerResource.mythic_soul >= soul_cost.into(), 'not enough soul');
                    playerResource.mythic_soul -= soul_cost.into();
                },
                EEquipmentSkill::Pants => {
                    assert(playerResource.mechanic_soul >= soul_cost.into(), 'not enough soul');
                    playerResource.mechanic_soul -= soul_cost.into();
                },
                EEquipmentSkill::Gloves => {
                    assert(playerResource.pollute_soul >= soul_cost.into(), 'not enough soul');
                    playerResource.pollute_soul -= soul_cost.into();
                },
                EEquipmentSkill::Boots => {
                    assert(playerResource.lightning_soul >= soul_cost.into(), 'not enough soul');
                    playerResource.lightning_soul -= soul_cost.into();
                },
                EEquipmentSkill::Magic_Ring => {
                    assert(
                        playerResource.fire_soul >= soul_cost.into()
                            && playerResource.mythic_soul >= soul_cost.into()
                            && playerResource.mechanic_soul >= soul_cost.into()
                            && playerResource.pollute_soul >= soul_cost.into()
                            && playerResource.lightning_soul >= soul_cost.into(),
                        'not enough soul',
                    );
                    playerResource.fire_soul -= soul_cost.into();
                    playerResource.mythic_soul -= soul_cost.into();
                    playerResource.mechanic_soul -= soul_cost.into();
                    playerResource.pollute_soul -= soul_cost.into();
                    playerResource.lightning_soul -= soul_cost.into();
                },
            }

            world.write_model(@playerResource);
            equipment.level += 1;
            world.write_model(@equipment);
        }

        fn reforge_equipment(
            ref self: ContractState,
            item_id: felt252,
            sub_attributes: Span<ByteArray>,
            key: Array<felt252>,
        ) {
            let mut world = self.world(@DEFAULT_NS());
            let caller = get_caller_address();
            let mut equipment: Equipment = world.read_model(item_id);
            assert(equipment.owner == caller, 'only owner of equipment');

            assert(
                sub_attributes.len() > 0 && sub_attributes.len() - 1 == equipment.rarity.into(),
                'sub attributes length not match',
            );
            let gem_dispatcher = GemABIDispatcher {
                contract_address: contract_address_const::<GEM_ADDRESS_FELT>(),
            };
            let mut gem_cost: u256 = 0;
            match equipment.rarity {
                0 => { gem_cost = 1000; },
                1 => { gem_cost = 3000; },
                2 => { gem_cost = 10_000; },
                3 => { gem_cost = 30_000; },
                4 => { gem_cost = 100_000; },
                5 => { gem_cost = 300_000; },
                _ => panic_with_felt252('invalid rarity'),
            }
            gem_dispatcher.burn(caller, (gem_cost * WEI_UNIT));
            // TODO: check signature
            equipment.sub_attributes = sub_attributes;
            world.write_model(@equipment);
        }

        fn merge_equipment(
            ref self: ContractState,
            main_item_id: felt252,
            sub_item_ids: Span<felt252>,
            new_sub_attribute: ByteArray,
        ) {
            let mut world = self.world(@DEFAULT_NS());
            let caller = get_caller_address();
            let mut main_equipment: Equipment = world.read_model(main_item_id);
            assert(main_equipment.owner == caller, 'only owner of equipment');
            assert(sub_item_ids.len() == 2, 'must have 2 sub equipments');
            for sub_item_id in sub_item_ids {
                let sub_equipment: Equipment = world.read_model(*sub_item_id);
                assert(sub_equipment.owner == caller, 'only owner of equipment');
                assert(
                    sub_equipment.skill_link == main_equipment.skill_link, 'equipment not match',
                );
                assert(sub_equipment.rarity == main_equipment.rarity, 'equipment rarity not match');
                world.erase_model(@sub_equipment);
            };

            let gem_dispatcher = GemABIDispatcher {
                contract_address: contract_address_const::<GEM_ADDRESS_FELT>(),
            };
            let mut gem_cost: u256 = 0;
            match main_equipment.rarity {
                0 => { gem_cost = 300; },
                1 => { gem_cost = 400; },
                2 => { gem_cost = 500; },
                3 => { gem_cost = 690; },
                4 => { gem_cost = 900; },
                5 => panic_with_felt252('max rarity reached'),
                _ => panic_with_felt252('invalid rarity'),
            }
            gem_dispatcher.burn(caller, (gem_cost * WEI_UNIT));

            let mut new_sub_attributes = ArrayTrait::<ByteArray>::new();
            new_sub_attributes.append_span(main_equipment.sub_attributes);
            new_sub_attributes.append(new_sub_attribute);
            main_equipment.sub_attributes = new_sub_attributes.span();
            main_equipment.rarity += 1;
            world.write_model(@main_equipment);
        }
    }
}
