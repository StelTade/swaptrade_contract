use super::utils::{is_supported_token, get_token_info};
use super::types::Token;

#[test]
fn test_is_supported_token_valid() {
    // TokenA and TokenB are supported
    assert(is_supported_token('TKA'));
    assert(is_supported_token('TKB'));
}

#[test]
fn test_is_supported_token_invalid() {
    // TokenC is not supported
    assert(!is_supported_token('TKC'));
}

#[test]
fn test_get_token_info_valid() {
    let token = get_token_info('TKA');
    match token {
        Option::Some(t) => {
            assert(t.symbol == 'TKA');
            assert(t.decimals == 18_u8);
        },
        Option::None => panic('Token not found'),
    }
}

#[test]
fn test_get_token_info_invalid() {
    let token = get_token_info('TKC');
    match token {
        Option::Some(_) => panic('Should not find unsupported token'),
        Option::None => (),
    }
}
