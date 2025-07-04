// SPDX-License-Identifier: MIT
// Reentrancy guard for Cairo contracts

@storage_var
def reentrancy_status() -> felt252:
end

const NOT_ENTERED: felt252 = 1;
const ENTERED: felt252 = 2;

macro non_reentrant {
    let status = reentrancy_status.read();
    assert status != ENTERED, 'ReentrancyGuard: reentrant call';
    reentrancy_status.write(ENTERED);
    // function body will be inserted here
    reentrancy_status.write(NOT_ENTERED);
}
