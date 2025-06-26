#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Token {
    pub name: felt252,
    pub symbol: felt252,
    pub decimals: u8,
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct UserBalance {
    pub token: felt252, // Token address as felt252
    pub amount: u256 // Amount with support for large numbers
}

#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct Order {
    pub order_id: u128, // Unique order ID
    pub user: starknet::ContractAddress, // Who placed the order
    pub token_in: felt252,
    pub token_out: felt252,
    pub amount_in: u256,
    pub min_amount_out: u256,
}

