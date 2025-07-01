use super::types::Token;

// Define a constant array of supported tokens
const SUPPORTED_TOKENS: Array<Token> = Array::<Token>::from([
    Token { name: 'TokenA', symbol: 'TKA', decimals: 18_u8 },
    Token { name: 'TokenB', symbol: 'TKB', decimals: 18_u8 },
]);

// Checks if a token symbol is supported
fn is_supported_token(symbol: felt252) -> bool {
    let mut i = 0;
    while i < SUPPORTED_TOKENS.len() {
        if SUPPORTED_TOKENS[i].symbol == symbol {
            return true;
        }
        i += 1;
    }
    false
}

// Retrieves token info for a given symbol
fn get_token_info(symbol: felt252) -> Option<Token> {
    let mut i = 0;
    while i < SUPPORTED_TOKENS.len() {
        if SUPPORTED_TOKENS[i].symbol == symbol {
            return Option::Some(SUPPORTED_TOKENS[i]);
        }
        i += 1;
    }
    Option::None
}
