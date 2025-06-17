use starknet::{get_tx_info, ContractAddress};

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

pub const MAX_INDEX_OF_COMMON_SKILL: u16 = 20;

pub const MAX_INDEX_OF_EVIL_SKILL: u16 = 10;

pub const MAX_RECEIVE_SKILL: u16 = 3;

pub const STARKNET_DOMAIN_TYPE_HASH: felt252 =
    selector!("StarkNetDomain(name:felt,version:felt,chainId:felt)",);

pub const RECEIVE_SKILL_TYPE_HASH: felt252 =
    selector!("ReceiveSkillParams(player:felt,salt_nonce:felt,is_new_game:bool,is_evil:bool)",);

pub const RECEIVE_ANGEL_OR_EVIL_TYPE_HASH: felt252 =
    selector!("ReceiveAngelOrEvilParams(player:felt,salt_nonce:felt)",);

pub const CLAIM_GEM_TYPE_HASH: felt252 =
    selector!("ClaimGemParams(player:felt,amount:u256,salt_nonce:felt)u256(low:felt,high:felt)",);

pub const U256_TYPE_HASH: felt252 = selector!("u256(low:felt,high:felt)");

pub const STARKNET_DOMAIN_VERSION: felt252 = 1;

pub const SYSTEM_VERSION: felt252 = '0.0.1';

pub const GEM_ADDRESS_FELT: felt252 =
    0x2ff629398bcc13b2f71e329bc3c1336a7a71e8d2d90eba1109b000158e5a707;

pub fn DEFAULT_DOMAIN() -> StarknetDomain {
    StarknetDomain {
        name: 'crimson-fate',
        version: STARKNET_DOMAIN_VERSION,
        chain_id: get_tx_info().unbox().chain_id,
    }
}

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
    fn mint(ref self: TState, to: ContractAddress, amount: u256,);
}
