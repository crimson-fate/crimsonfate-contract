use core::hash::{HashStateExTrait, HashStateTrait};
use core::poseidon::PoseidonTrait;
use crimson_fate::utils::signature::IStructHash;
use crimson_fate::utils::signature::v1::RECEIVE_EQUIPMENT_STRUCT_TYPE_HASH;
use starknet::ContractAddress;

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

#[derive(Drop, Copy, Hash)]
pub struct ClaimValorGemParams {
    pub player: ContractAddress,
    pub multiplier: u32,
    pub progress_id: u128,
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

pub const WEI_UNIT: u256 = 1000000000000000000;

pub const GEM_ADDRESS_FELT: felt252 =
    0x006f237ac6c6d144181b077ca8d69430ae44b29e06f9acf0300e8b0593d83a69;

pub const VALOR_VAULT_ADDRESS_FELT: felt252 =
    0x07b123e848c57f3200032d6bd992cecb9f33d62a906cb5b65c5dd8220bd6b27c;

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

#[starknet::interface]
pub trait ValorVaultABI<TState> {
    fn stake(ref self: TState, player: ContractAddress, amount: u256);
    fn claim(ref self: TState, player: ContractAddress, multiplier: u32);
}
