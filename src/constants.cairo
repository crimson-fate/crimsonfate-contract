use starknet::ContractAddress;
use crimson_fate::utils::signature::{IStructHash, v1::RECEIVE_EQUIPMENT_STRUCT_TYPE_HASH};
use core::poseidon::PoseidonTrait;
use core::hash::{HashStateTrait, HashStateExTrait};

#[derive(Drop, Copy, Hash)]
pub struct StarknetDomain {
    pub name: felt252,
    pub version: felt252,
    pub chain_id: felt252,
}

#[derive(Drop, Copy, Hash)]
pub struct ReceiveSkillParams {
    pub player: ContractAddress,
    pub salt_nonce: u64,
    pub is_new_game: bool,
    pub is_evil: bool,
}

#[derive(Drop, Copy, Hash)]
pub struct ReceiveAngelOrEvilParams {
    pub player: ContractAddress,
    pub salt_nonce: u64,
}

#[derive(Drop, Copy, Hash)]
pub struct ClaimGemParams {
    pub player: ContractAddress,
    pub amount: u256,
    pub salt_nonce: u64,
}

#[derive(Drop, Serde)]
pub struct ReceiveEquipment {
    pub id: felt252,
    pub skill_link: u8,
    pub rarity: u8,
    pub base_attribute: u8,
    pub sub_attributes: Span<ByteArray>,
}

#[derive(Drop, Serde)]
pub struct ReceiveSoulPieceResource {
    pub resource_type: u8,
    pub amount: u128,
}

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

pub const MAX_INDEX_OF_COMMON_SKILL: u16 = 20;

pub const MAX_INDEX_OF_EVIL_SKILL: u16 = 10;

pub const MAX_RECEIVE_SKILL: u16 = 3;

pub const SYSTEM_VERSION: felt252 = '0.0.1';

pub const GEM_ADDRESS_FELT: felt252 =
    0x5e011552406c5c8e402e478cbf26a17a9dbda8941390741ac61c2b623a5457b;

pub fn DEFAULT_NS() -> ByteArray {
    "cf"
}

#[starknet::interface]
pub trait AccountABI<TState> {
    fn is_valid_signature(self: @TState, hash: felt252, signature: Array<felt252>) -> felt252;

    // ISRC6CamelOnly
    fn isValidSignature(self: @TState, hash: felt252, signature: Array<felt252>) -> felt252;
}

#[starknet::interface]
pub trait GemABI<TState> {
    fn mint(ref self: TState, to: ContractAddress, amount: u256);
    fn burn(ref self: TState, from: ContractAddress, amount: u256);
}
