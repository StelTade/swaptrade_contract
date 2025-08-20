// SPDX-License-Identifier: MIT
// Unit tests for SwapTrade swap logic (Cairo 2 style)

use starknet::testing::{set_caller_address};
use starknet::{ContractAddress, contract_address_const};
use super::SwapTrade;

#[test]
fn test_swap_success() {
    // Prepare an isolated contract state for unit testing
    let mut state = SwapTrade::contract_state_for_testing();

    // example user and counterparty addresses
    let user = contract_address_const::<0x111>();
    let recipient = contract_address_const::<0x222>();

    // set the caller for the following ops
    set_caller_address(user);

    // Register tokens used in the test (adjust names to match real API)
    SwapTrade::register_token(ref state, 0xAAA, 'TokenA', 'TKA', 18_u8);
    SwapTrade::register_token(ref state, 0xBBB, 'TokenB', 'TKB', 18_u8);

    // Seed balances for user and recipient
    SwapTrade::set_balance(ref state, user, 0xAAA, 1000_u256);
    SwapTrade::set_balance(ref state, recipient, 0xBBB, 500_u256);

    // Create a swap/order: user swaps 100 TokenA for 50 TokenB
    let tx = SwapTrade::create_swap(ref state, user, 0xAAA, 0xBBB, 100_u256, 50_u256);
    assert(tx.is_ok());

    // Simulate the counterparty accepting/filling the swap
    set_caller_address(recipient);
    let fill = SwapTrade::fill_swap(ref state, recipient, tx.unwrap());
    assert(fill.is_ok());

    // Assert final balances (adjust function names to real API)
    let user_balance_a = SwapTrade::get_balance(ref state, user, 0xAAA);
    let user_balance_b = SwapTrade::get_balance(ref state, user, 0xBBB);
    let recipient_balance_a = SwapTrade::get_balance(ref state, recipient, 0xAAA);
    let recipient_balance_b = SwapTrade::get_balance(ref state, recipient, 0xBBB);

    // user spent 100 TokenA and received 50 TokenB
    assert_eq!(user_balance_a, 900_u256);
    assert_eq!(user_balance_b, 50_u256);

    // recipient spent 50 TokenB and received 100 TokenA
    assert_eq!(recipient_balance_b, 450_u256);
    assert_eq!(recipient_balance_a, 100_u256);
}
