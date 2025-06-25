
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

