#[starknet::interface]
pub trait IGem<TState> {
    fn claim_gem(ref self: TState, amount: u256, salt_nonce: u64, key: Array<felt252>);
}

#[dojo::contract]
pub mod Gem {
    use crimson_fate::constants::{
        AccountABIDispatcher, AccountABIDispatcherTrait, ClaimGemParams, DEFAULT_NS,
        GEM_ADDRESS_FELT, GemABIDispatcher, GemABIDispatcherTrait, SYSTEM_VERSION,
    };
    use crimson_fate::models::signature::{Prover, UsedSignature};
    use crimson_fate::utils::signature::v0::compute_message_claim_gem_hash;
    use dojo::model::{ModelStorage, ModelValueStorage};
    use starknet::{ContractAddress, contract_address_const, get_caller_address};

    #[abi(embed_v0)]
    impl GemImpl of super::IGem<ContractState> {
        fn claim_gem(ref self: ContractState, amount: u256, salt_nonce: u64, key: Array<felt252>) {
            let mut world = self.world(@DEFAULT_NS());
            let caller = get_caller_address();

            let claim_gem = ClaimGemParams { player: caller, amount, salt_nonce };
            let prover: Prover = world.read_model(SYSTEM_VERSION);
            let msg_hash = compute_message_claim_gem_hash(@claim_gem, prover.address);
            let mut used_signature: UsedSignature = world.read_model(msg_hash);

            assert(!used_signature.is_used, 'Signature already used');
            let account: AccountABIDispatcher = AccountABIDispatcher {
                contract_address: prover.address,
            };

            assert(account.is_valid_signature(msg_hash, key) == 'VALID', 'Invalid signature');
            used_signature.is_used = true;
            world.write_model(@used_signature);

            let gem_dispatcher = GemABIDispatcher {
                contract_address: contract_address_const::<GEM_ADDRESS_FELT>(),
            };

            gem_dispatcher.mint(caller, amount);
        }
    }
}
