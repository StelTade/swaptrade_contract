pub mod types;

#[starknet::contract]
pub mod SwapTrade {
    use super::types::{Token, UserBalance};
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        token_a: felt252,
        token_b: felt252,
        // Mapping: user address → token address → balance
        balances: starknet::storage::Map::<(ContractAddress, felt252), u256>,
        // Store registered tokens
        tokens: starknet::storage::Map::<felt252, Token>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, token_a: felt252, token_b: felt252) {
        self.token_a.write(token_a);
        self.token_b.write(token_b);
    }

    // View function to get the tokens
    fn get_tokens(self: @ContractState) -> (felt252, felt252) {
        (self.token_a.read(), self.token_b.read())
    }

    // Get user balance for a specific token
    #[external(v0)]
    fn get_balance(self: @ContractState, user: ContractAddress, token: felt252) -> u256 {
        self.balances.read((user, token))
    }

    // Get current user's balance for a specific token
    #[external(v0)]
    fn get_my_balance(self: @ContractState, token: felt252) -> u256 {
        let caller = get_caller_address();
        self.balances.read((caller, token))
    }

    // Update user balance (for testing and admin purposes)
    #[external(v0)]
    fn set_balance(ref self: ContractState, user: ContractAddress, token: felt252, amount: u256) {
        // In a real implementation, this would have access controls
        self.balances.write((user, token), amount);
    }

    // Register a new token
    #[external(v0)]
    fn register_token(ref self: ContractState, token_address: felt252, name: felt252, symbol: felt252, decimals: u8) {
        // In a real implementation, this would have access controls
        let token = Token { name, symbol, decimals };
        self.tokens.write(token_address, token);
    }

    // Get token details
    #[external(v0)]
    fn get_token_details(self: @ContractState, token_address: felt252) -> Token {
        self.tokens.read(token_address)
    }

    // Get user balance as a UserBalance struct
    #[external(v0)]
    fn get_user_balance_struct(self: @ContractState, user: ContractAddress, token: felt252) -> UserBalance {
        let amount = self.balances.read((user, token));
        UserBalance { token, amount }
    }
}

// Tests module for the SwapTrade contract
#[cfg(test)]
mod tests {
    use super::types::{Token, UserBalance};

    // We don't need to create contract addresses for our basic struct tests


    #[test]
    fn test_token_struct() {
        // Test creating a Token struct
        let name: felt252 = 'TestToken';
        let symbol: felt252 = 'TT';
        let decimals: u8 = 18;
        
        let token = Token { name, symbol, decimals };
        
        assert(token.name == name, 'Token name mismatch');
        assert(token.symbol == symbol, 'Token symbol mismatch');
        assert(token.decimals == decimals, 'Token decimals mismatch');
    }

    #[test]
    fn test_user_balance_struct() {
        // Test creating a UserBalance struct
        let token: felt252 = 0x123;
        let amount: u256 = 1000_u256;
        
        let user_balance = UserBalance { token, amount };
        
        assert(user_balance.token == token, 'Token mismatch in struct');
        assert(user_balance.amount == amount, 'Amount mismatch in struct');
    }
}
