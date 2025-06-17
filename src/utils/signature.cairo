use core::pedersen::PedersenTrait;
use core::hash::{HashStateTrait, HashStateExTrait};
use starknet::ContractAddress;
use crimson_fate::constants::{
    StarknetDomain, STARKNET_DOMAIN_TYPE_HASH, ReceiveSkillParams, RECEIVE_SKILL_TYPE_HASH,
    DEFAULT_DOMAIN, ReceiveAngelOrEvilParams, RECEIVE_ANGEL_OR_EVIL_TYPE_HASH, U256_TYPE_HASH,
    CLAIM_GEM_TYPE_HASH, ClaimGemParams
};


pub fn hash_domain(domain: @StarknetDomain) -> felt252 {
    let mut state = PedersenTrait::new(0);
    state = state.update_with(STARKNET_DOMAIN_TYPE_HASH);
    state = state.update_with(*domain);
    state = state.update_with(4);
    state.finalize()
}

pub fn hash_receive_skill(receive_skill: @ReceiveSkillParams) -> felt252 {
    let mut state = PedersenTrait::new(0);
    state = state.update_with(RECEIVE_SKILL_TYPE_HASH);
    state = state.update_with(*receive_skill);
    state = state.update_with(5);
    state.finalize()
}

pub fn hash_u256(value: @u256) -> felt252 {
    let mut state = PedersenTrait::new(0);
    state = state.update_with(U256_TYPE_HASH);
    state = state.update_with(*value);
    state = state.update_with(3);
    state.finalize()
}

pub fn hash_claim_gem(claim_gem: @ClaimGemParams) -> felt252 {
    let mut state = PedersenTrait::new(0);
    state = state.update_with(CLAIM_GEM_TYPE_HASH);
    state = state.update_with(*claim_gem.player);
    state = state.update_with(hash_u256(claim_gem.amount));
    state = state.update_with(*claim_gem.salt_nonce);
    state = state.update_with(4);
    state.finalize()
}

pub fn compute_message_receive_skill_hash(
    data: @ReceiveSkillParams, prover: ContractAddress
) -> felt252 {
    let domain = DEFAULT_DOMAIN();
    let mut state = PedersenTrait::new(0);
    state = state.update_with('StarkNet Message');
    state = state.update_with(hash_domain(@domain));
    state = state.update_with(prover);
    state = state.update_with(hash_receive_skill(data));
    state = state.update_with(4);
    state.finalize()
}

pub fn hash_receive_angel_or_evil(receive_angel_or_evil: @ReceiveAngelOrEvilParams) -> felt252 {
    let mut state = PedersenTrait::new(0);
    state = state.update_with(RECEIVE_ANGEL_OR_EVIL_TYPE_HASH);
    state = state.update_with(*receive_angel_or_evil);
    state = state.update_with(3);
    state.finalize()
}

pub fn compute_message_receive_angel_or_evil_hash(
    data: @ReceiveAngelOrEvilParams, prover: ContractAddress
) -> felt252 {
    let domain = DEFAULT_DOMAIN();
    let mut state = PedersenTrait::new(0);
    state = state.update_with('StarkNet Message');
    state = state.update_with(hash_domain(@domain));
    state = state.update_with(prover);
    state = state.update_with(hash_receive_angel_or_evil(data));
    state = state.update_with(4);
    state.finalize()
}

pub fn compute_message_claim_gem_hash(data: @ClaimGemParams, prover: ContractAddress) -> felt252 {
    let domain = DEFAULT_DOMAIN();
    let mut state = PedersenTrait::new(0);
    state = state.update_with('StarkNet Message');
    state = state.update_with(hash_domain(@domain));
    state = state.update_with(prover);
    state = state.update_with(hash_claim_gem(data));
    state = state.update_with(4);
    state.finalize()
}
