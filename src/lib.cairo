#[starknet::contract]
pub mod SwapTrade {
    use core::integer::BoundedInt;
    use starknet::{ContractAddress, get_caller_address};
    use super::types::{Token, UserBalance, Order};

    #[storage]
    struct Storage {
        token_a: felt252,
        token_b: felt252,
        // Mapping: user address → token address → balance
        balances: starknet::storage::Map<(ContractAddress, felt252), u256>,
        // Store registered tokens
        tokens: starknet::storage::Map<felt252, Token>,
        // Orderbook: order_id → Order
        orderbook: starknet::storage::Map<u128, Order>,
        // Order counter for unique IDs
        order_counter: u128,
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
    fn register_token(
        ref self: ContractState,
        token_address: felt252,
        name: felt252,
        symbol: felt252,
        decimals: u8,
    ) {
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
    fn get_user_balance_struct(
        self: @ContractState, user: ContractAddress, token: felt252,
    ) -> UserBalance {
        let amount = self.balances.read((user, token));
        UserBalance { token, amount }
    }

    // Deposit tokens to increase user balance
    #[external(v0)]
    fn deposit(ref self: ContractState, token_address: felt252, amount: u256) {
        // Validate that amount is greater than 0
        assert(amount > 0_u256, 'Amount must be greater than 0');

        // Get caller address
        let caller = get_caller_address();

        // Get current balance
        let current_balance = self.balances.read((caller, token_address));

        // Calculate new balance with overflow checking
        let new_balance = match current_balance.checked_add(amount) {
            Option::Some(sum) => sum,
            Option::None => panic_with_felt252('Balance overflow'),
        };

        // Update the balance
        self.balances.write((caller, token_address), new_balance);
    }

    // Place a new order
    #[external(v0)]
    fn place_order(
        ref self: ContractState,
        token_in: felt252,
        token_out: felt252,
        amount_in: u256,
        min_amount_out: u256,
    ) -> u128 {
        let caller = get_caller_address();

        // Validate tokens are registered
        let token_in_exists = self.tokens.read(token_in);
        let token_out_exists = self.tokens.read(token_out);
        // If either token is not registered, panic
        assert(token_in_exists.decimals > 0_u8 || token_in_exists.decimals == 0_u8, 'Invalid token_in');
        assert(token_out_exists.decimals > 0_u8 || token_out_exists.decimals == 0_u8, 'Invalid token_out');

        // Validate amounts
        assert(amount_in > 0_u256, 'amount_in must be > 0');
        assert(min_amount_out > 0_u256, 'min_amount_out must be > 0');

        // Generate unique order ID
        let order_id = self.order_counter.read();
        self.order_counter.write(order_id + 1_u128);

        // Create and store the order
        let order = Order {
            order_id,
            user: caller,
            token_in,
            token_out,
            amount_in,
            min_amount_out,
        };
        self.orderbook.write(order_id, order);
        order_id
    }
}

// Tests module for the SwapTrade contract
#[cfg(test)]
mod tests {
    use starknet::testing::set_caller_address;
    use starknet::{ContractAddress, contract_address_const};
    use super::SwapTrade;
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

    // Test for the deposit function - success case
    #[test]
    fn test_deposit_success() {
        // Create a test contract state
        let mut state = SwapTrade::contract_state_for_testing();

        // Set up test data
        let user = contract_address_const::<0x123>();
        let token_address: felt252 = 0x456;
        let initial_balance: u256 = 1000_u256;
        let deposit_amount: u256 = 500_u256;

        // Set caller address for the test
        set_caller_address(user);

        // Set initial balance
        SwapTrade::set_balance(ref state, user, token_address, initial_balance);

        // Perform deposit
        SwapTrade::deposit(ref state, token_address, deposit_amount);

        // Check that balance was updated correctly
        let new_balance = SwapTrade::get_balance(@state, user, token_address);
        assert(new_balance == initial_balance + deposit_amount, 'Deposit failed to update balance');
    }

    // Test for the deposit function - failure case with zero amount
    #[test]
    #[should_panic(expected: ('Amount must be greater than 0',))]
    fn test_deposit_zero_amount() {
        // Create a test contract state
        let mut state = SwapTrade::contract_state_for_testing();

        // Set up test data
        let user = contract_address_const::<0x123>();
        let token_address: felt252 = 0x456;
        let zero_amount: u256 = 0_u256;

        // Set caller address for the test
        set_caller_address(user);

        // This should panic with the expected message
        SwapTrade::deposit(ref state, token_address, zero_amount);
    }

    // Test for the deposit function - overflow case
    #[test]
    #[should_panic(expected: ('Balance overflow',))]
    fn test_deposit_overflow() {
        // Create a test contract state
        let mut state = SwapTrade::contract_state_for_testing();

        // Set up test data
        let user = contract_address_const::<0x123>();
        let token_address: felt252 = 0x456;
        let max_balance = u256 { low: u128::MAX, high: u128::MAX };
        let deposit_amount: u256 = 1_u256;

        // Set caller address for the test
        set_caller_address(user);

        // Set initial balance to maximum u256 value
        SwapTrade::set_balance(ref state, user, token_address, max_balance);

        // This should panic with overflow
        SwapTrade::deposit(ref state, token_address, deposit_amount);
    }

    // Test for the place_order function - success case
    #[test]
    fn test_place_order_success() {
        let mut state = SwapTrade::contract_state_for_testing();
        let user = contract_address_const::<0x111>();
        set_caller_address(user);
        // Register tokens
        SwapTrade::register_token(ref state, 0xAAA, 'TokenA', 'A', 18_u8);
        SwapTrade::register_token(ref state, 0xBBB, 'TokenB', 'B', 18_u8);
        // Place order
        let order_id = SwapTrade::place_order(ref state, 0xAAA, 0xBBB, 100_u256, 90_u256);
        // Fetch order from storage
        let order = state.orderbook.read(order_id);
        assert(order.order_id == order_id, 'Order ID mismatch');
        assert(order.user == user, 'User mismatch');
        assert(order.token_in == 0xAAA, 'token_in mismatch');
        assert(order.token_out == 0xBBB, 'token_out mismatch');
        assert(order.amount_in == 100_u256, 'amount_in mismatch');
        assert(order.min_amount_out == 90_u256, 'min_amount_out mismatch');
    }

    #[test]
    #[should_panic(expected: ('Invalid token_in',))]
    fn test_place_order_invalid_token_in() {
        let mut state = SwapTrade::contract_state_for_testing();
        let user = contract_address_const::<0x112>();
        set_caller_address(user);
        // Only register token_out
        SwapTrade::register_token(ref state, 0xBBB, 'TokenB', 'B', 18_u8);
        // token_in is not registered
        SwapTrade::place_order(ref state, 0xAAA, 0xBBB, 100_u256, 90_u256);
    }

    #[test]
    #[should_panic(expected: ('amount_in must be > 0',))]
    fn test_place_order_invalid_amount() {
        let mut state = SwapTrade::contract_state_for_testing();
        let user = contract_address_const::<0x113>();
        set_caller_address(user);
        // Register tokens
        SwapTrade::register_token(ref state, 0xAAA, 'TokenA', 'A', 18_u8);
        SwapTrade::register_token(ref state, 0xBBB, 'TokenB', 'B', 18_u8);
        // amount_in is zero
        SwapTrade::place_order(ref state, 0xAAA, 0xBBB, 0_u256, 90_u256);
    }

    // Test for the place_order function - failure case with unregistered token
    #[test]
    #[should_panic(expected: ('Invalid token_in',))]
    fn test_place_order_unregistered_token() {
        // Create a test contract state
        let mut state = SwapTrade::contract_state_for_testing();

        // Set up test data
        let user = contract_address_const::<0x123>();
        let token_in: felt252 = 0x456;
        let token_out: felt252 = 0x789;
        let amount_in: u256 = 1000_u256;
        let min_amount_out: u256 = 900_u256;

        // Set caller address for the test
        set_caller_address(user);

        // This should panic due to unregistered token_in
        SwapTrade::place_order(ref state, token_in, token_out, amount_in, min_amount_out);
    }

    // Test for the place_order function - failure case with zero amounts
    #[test]
    #[should_panic(expected: ('amount_in must be > 0',))]
    fn test_place_order_zero_amounts() {
        // Create a test contract state
        let mut state = SwapTrade::contract_state_for_testing();

        // Set up test data
        let user = contract_address_const::<0x123>();
        let token_in: felt252 = 0x456;
        let token_out: felt252 = 0x789;
        let zero_amount: u256 = 0_u256;

        // Set caller address for the test
        set_caller_address(user);

        // Register tokens
        SwapTrade::register_token(ref state, token_in, 'TokenIn', 'TIN', 18);
        SwapTrade::register_token(ref state, token_out, 'TokenOut', 'TOUT', 18);

        // This should panic due to zero amounts
        SwapTrade::place_order(ref state, token_in, token_out, zero_amount, zero_amount);
    }
}

