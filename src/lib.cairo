#[starknet::contract]
mod SwapTrade {
    #[storage]
    struct Storage {
        token_a: felt252,
        token_b: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, token_a: felt252, token_b: felt252) {
        self.token_a.write(token_a);
        self.token_b.write(token_b);
    }

    // ❌ no #[view] needed — it's auto-detected as a view function
    fn get_tokens(self: @ContractState) -> (felt252, felt252) {
        (self.token_a.read(), self.token_b.read())
    }

}
