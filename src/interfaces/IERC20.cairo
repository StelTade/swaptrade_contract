// SPDX-License-Identifier: MIT
// Interface for ERC20 token in Cairo

@contract_interface
trait IERC20 {
    fn transfer(recipient: felt252, amount: u256) -> bool;
    fn transfer_from(sender: felt252, recipient: felt252, amount: u256) -> bool;
    fn approve(spender: felt252, amount: u256) -> bool;
    fn balance_of(account: felt252) -> u256;
    fn allowance(owner: felt252, spender: felt252) -> u256;
}
