pub trait IStructHash<T> {
    fn get_struct_hash(self: @T) -> felt252;
}

trait IOffChainMessageHash<T> {
    fn get_message_hash(data: T, signer: starknet::ContractAddress) -> felt252;
}

pub mod v0 {
    use core::pedersen::PedersenTrait;
    use core::hash::{HashStateTrait, HashStateExTrait};
    use starknet::{get_tx_info, ContractAddress};

    use crimson_fate::constants::{
        StarknetDomain, ReceiveSkillParams, ReceiveAngelOrEvilParams, ClaimGemParams
    };

    pub const STARKNET_DOMAIN_TYPE_HASH: felt252 =
        selector!("StarkNetDomain(name:felt,version:felt,chainId:felt)",);

    pub const RECEIVE_SKILL_TYPE_HASH: felt252 =
        selector!("ReceiveSkillParams(player:felt,salt_nonce:felt,is_new_game:bool,is_evil:bool)",);

    pub const RECEIVE_ANGEL_OR_EVIL_TYPE_HASH: felt252 =
        selector!("ReceiveAngelOrEvilParams(player:felt,salt_nonce:felt)",);

    pub const CLAIM_GEM_TYPE_HASH: felt252 =
        selector!(
            "ClaimGemParams(player:felt,amount:u256,salt_nonce:felt)u256(low:felt,high:felt)",
        );

    pub const U256_TYPE_HASH: felt252 = selector!("u256(low:felt,high:felt)");

    pub const STARKNET_DOMAIN_VERSION: felt252 = 1;

    pub fn DEFAULT_DOMAIN() -> StarknetDomain {
        StarknetDomain {
            name: 'crimson-fate',
            version: STARKNET_DOMAIN_VERSION,
            chain_id: get_tx_info().unbox().chain_id,
        }
    }

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

    pub fn compute_message_claim_gem_hash(
        data: @ClaimGemParams, prover: ContractAddress
    ) -> felt252 {
        let domain = DEFAULT_DOMAIN();
        let mut state = PedersenTrait::new(0);
        state = state.update_with('StarkNet Message');
        state = state.update_with(hash_domain(@domain));
        state = state.update_with(prover);
        state = state.update_with(hash_claim_gem(data));
        state = state.update_with(4);
        state.finalize()
    }
}

pub mod v1 {
    use core::poseidon::{poseidon_hash_span, PoseidonTrait};
    use core::hash::{HashStateTrait, HashStateExTrait};
    use starknet::{get_tx_info, ContractAddress};

    /// @notice StarknetDomain using SNIP 12
    #[derive(Hash, Drop, Copy)]
    struct StarknetDomain {
        name: felt252,
        version: felt252,
        chain_id: felt252,
        revision: felt252,
    }

    const STARKNET_DOMAIN_TYPE_HASH: felt252 =
        selector!(
            "\"StarknetDomain\"(\"name\":\"shortstring\",\"version\":\"shortstring\",\"chainId\":\"shortstring\",\"revision\":\"shortstring\")"
        );

    pub const RECEIVE_EQUIPMENT_STRUCT_TYPE_HASH: felt252 =
        selector!(
            "\"ReceiveEquipmentStruct\"(\"Id\":\"felt\",\"Skill Link\":\"felt\",\"Rarity\":\"felt\",\"Base Attribute\":\"felt\",\"Sub Attribute\":\"string\")"
        );

    pub impl OffChainMessageHashStruct<
        T, impl TStrucHash: super::IStructHash<T>, impl TDrop: Drop<T>
    > of super::IOffChainMessageHash<T> {
        fn get_message_hash(data: T, signer: ContractAddress) -> felt252 {
            let domain = StarknetDomain {
                name: 'crimson-fate',
                version: '1',
                chain_id: get_tx_info().unbox().chain_id,
                revision: 1
            };
            let mut state = PoseidonTrait::new();
            state = state.update_with('StarkNet Message');
            state = state.update_with(domain.get_struct_hash());
            // This can be a field within the struct, it doesn't have to be get_caller_address().
            state = state.update_with(signer);
            state = state.update_with(data.get_struct_hash());
            // Hashing with the amount of elements being hashed
            state.finalize()
        }
    }

    impl StructHashStarknetDomain of super::IStructHash<StarknetDomain> {
        fn get_struct_hash(self: @StarknetDomain) -> felt252 {
            poseidon_hash_span(
                array![
                    STARKNET_DOMAIN_TYPE_HASH,
                    *self.name,
                    *self.version,
                    *self.chain_id,
                    *self.revision
                ]
                    .span()
            )
        }
    }
}
