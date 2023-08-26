**Note:** There is a section for disputed findings below the usual findings sections

## Summary

### Low Risk Issues

| |Issue|Instances|
|-|:-|:-:|
| [[L&#x2011;01](#l01-direct-supportsinterface-calls-may-cause-caller-to-revert)] | Direct `supportsInterface()` calls may cause caller to revert | 3 | 
| [[L&#x2011;02](#l02-unsafe-downcast)] | Unsafe downcast | 7 | 
| [[L&#x2011;03](#l03-loss-of-precision)] | Loss of precision | 7 | 
| [[L&#x2011;04](#l04-receivepayable-fallback-function-does-not-authorize-requests)] | `receive()`/`payable fallback()` function does not authorize requests | 1 | 
| [[L&#x2011;05](#l05-missing-contract-existence-checks-before-low-level-calls)] | Missing contract-existence checks before low-level calls | 1 | 
| [[L&#x2011;06](#l06-external-call-recipient-may-consume-all-transaction-gas)] | External call recipient may consume all transaction gas | 1 | 
| [[L&#x2011;07](#l07-empty-receivefallback-function)] | Empty `receive()`/`fallback()` function | 1 | 
| [[L&#x2011;08](#l08-state-variables-not-capped-at-reasonable-values)] | State variables not capped at reasonable values | 1 | 
| [[L&#x2011;09](#l09-code-does-not-follow-the-best-practice-of-check-effects-interaction)] | Code does not follow the best practice of check-effects-interaction | 1 | 
| [[L&#x2011;10](#l10-consider-implementing-two-step-procedure-for-updating-protocol-addresses)] | Consider implementing two-step procedure for updating protocol addresses | 6 | 

Total: 29 instances over 10 issues

### Non-critical Issues

| |Issue|Instances|
|-|:-|:-:|
| [[N&#x2011;01](#n01-public-functions-not-called-by-the-contract-should-be-declared-external-instead)] | `public` functions not called by the contract should be declared `external` instead | 6 | 
| [[N&#x2011;02](#n02-constants-should-be-defined-rather-than-using-magic-numbers)] | `constant`s should be defined rather than using magic numbers | 10 | 
| [[N&#x2011;03](#n03-event-is-not-properly-indexed)] | Event is not properly `indexed` | 3 | 
| [[N&#x2011;04](#n04-duplicated-requirerevert-checks-should-be-refactored-to-a-modifier-or-function)] | Duplicated `require()`/`revert()` checks should be refactored to a modifier or function | 3 | 
| [[N&#x2011;05](#n05-common-functions-should-be-refactored-to-a-common-base-contract)] | Common functions should be refactored to a common base contract | 1 | 
| [[N&#x2011;06](#n06-vulnerable-versions-of-packages-are-being-used)] | Vulnerable versions of packages are being used | 1 | 
| [[N&#x2011;07](#n07-events-that-mark-critical-parameter-changes-should-contain-both-the-old-and-the-new-value)] | Events that mark critical parameter changes should contain both the old and the new value | 2 | 
| [[N&#x2011;08](#n08-constant-redefined-elsewhere)] | Constant redefined elsewhere | 4 | 
| [[N&#x2011;09](#n09-long-functions-should-be-refactored-into-multiple-smaller-functions)] | Long functions should be refactored into multiple, smaller, functions | 4 | 
| [[N&#x2011;10](#n10-typos)] | Typos | 10 | 
| [[N&#x2011;11](#n11-natspec-param-is-missing)] | NatSpec `@param` is missing | 6 | 
| [[N&#x2011;12](#n12-natspec-return-argument-is-missing)] | NatSpec `@return` argument is missing | 2 | 
| [[N&#x2011;13](#n13-function-ordering-does-not-follow-the-solidity-style-guide)] | Function ordering does not follow the Solidity style guide | 26 | 
| [[N&#x2011;14](#n14-contract-does-not-follow-the-solidity-style-guides-suggested-layout-ordering)] | Contract does not follow the Solidity style guide's suggested layout ordering | 13 | 
| [[N&#x2011;15](#n15-control-structures-do-not-follow-the-solidity-style-guide)] | Control structures do not follow the Solidity Style Guide | 124 | 
| [[N&#x2011;16](#n16-top-level-declarations-should-be-separated-by-at-least-two-lines)] | Top-level declarations should be separated by at least two lines | 28 | 
| [[N&#x2011;17](#n17-imports-should-use-double-quotes-rather-than-single-quotes)] | Imports should use double quotes rather than single quotes | 58 | 
| [[N&#x2011;18](#n18-strings-should-use-double-quotes-rather-than-single-quotes)] | Strings should use double quotes rather than single quotes | 8 | 
| [[N&#x2011;19](#n19-consider-using-delete-rather-than-assigning-zerofalse-to-clear-values)] | Consider using `delete` rather than assigning zero/false to clear values | 2 | 
| [[N&#x2011;20](#n20-contracts-should-have-full-test-coverage)] | Contracts should have full test coverage | 1 | 
| [[N&#x2011;21](#n21-consider-adding-formal-verification-proofs)] | Consider adding formal verification proofs | 1 | 
| [[N&#x2011;22](#n22-multiple-addressid-mappings-can-be-combined-into-a-single-mapping-of-an-addressid-to-a-struct-for-readability)] | Multiple `address`/ID mappings can be combined into a single `mapping` of an `address`/ID to a `struct`, for readability | 2 | 
| [[N&#x2011;23](#n23-custom-errors-should-be-used-rather-than-revertrequire)] | Custom errors should be used rather than `revert()`/`require()` | 8 | 
| [[N&#x2011;24](#n24-array-indicies-should-be-referenced-via-enums-rather-than-via-numeric-literals)] | Array indicies should be referenced via `enum`s rather than via numeric literals | 3 | 
| [[N&#x2011;25](#n25-events-are-missing-sender-information)] | Events are missing sender information | 49 | 
| [[N&#x2011;26](#n26-variable-names-for-immutables-should-use-constant_case)] | Variable names for `immutable`s should use CONSTANT_CASE | 13 | 
| [[N&#x2011;27](#n27-consider-using-named-mappings)] | Consider using named mappings | 11 | 
| [[N&#x2011;28](#n28-non-externalpublic-variable-names-should-begin-with-an-underscore)] | Non-`external`/`public` variable names should begin with an underscore | 44 | 
| [[N&#x2011;29](#n29-use-of-override-is-unnecessary)] | Use of `override` is unnecessary | 61 | 
| [[N&#x2011;30](#n30-array-is-pushed-but-not-poped)] | Array is `push()`ed but not `pop()`ed | 1 | 
| [[N&#x2011;31](#n31-unused-error-definition)] | Unused `error` definition | 2 | 
| [[N&#x2011;32](#n32-unused-import)] | Unused import | 7 | 
| [[N&#x2011;33](#n33-consider-using-descriptive-constants-when-passing-zero-as-a-function-argument)] | Consider using descriptive `constant`s when passing zero as a function argument | 7 | 
| [[N&#x2011;34](#n34-constants-in-comparisons-should-appear-on-the-left-side)] | Constants in comparisons should appear on the left side | 68 | 
| [[N&#x2011;35](#n35-expressions-for-constant-values-should-use-immutable-rather-than-constant)] | Expressions for constant values should use `immutable` rather than `constant` | 8 | 
| [[N&#x2011;36](#n36-contract-should-expose-an-interface)] | Contract should expose an `interface` | 51 | 
| [[N&#x2011;37](#n37-custom-error-has-no-error-details)] | Custom error has no error details | 35 | 
| [[N&#x2011;38](#n38-events-should-use-parameters-to-convey-information)] | Events should use parameters to convey information | 1 | 
| [[N&#x2011;39](#n39-events-may-be-emitted-out-of-order-due-to-reentrancy)] | Events may be emitted out of order due to reentrancy | 1 | 
| [[N&#x2011;40](#n40-empty-function-body)] | Empty function body | 1 | 
| [[N&#x2011;41](#n41-consider-bounding-input-array-length)] | Consider bounding input array length | 13 | 
| [[N&#x2011;42](#n42-if-statement-can-be-converted-to-a-ternary)] | `if`-statement can be converted to a ternary | 2 | 
| [[N&#x2011;43](#n43-contract-declarations-should-have-natspec-descriptions)] | Contract declarations should have NatSpec descriptions | 2 | 
| [[N&#x2011;44](#n44-contract-declarations-should-have-natspec-author-annotations)] | Contract declarations should have NatSpec `@author` annotations | 10 | 
| [[N&#x2011;45](#n45-contract-declarations-should-have-natspec-title-annotations)] | Contract declarations should have NatSpec `@title` annotations | 10 | 
| [[N&#x2011;46](#n46-function-declarations-should-have-natspec-descriptions)] | Function declarations should have NatSpec descriptions | 6 | 
| [[N&#x2011;47](#n47-missing-checks-for-empty-bytes-when-updating-bytes-state-variables)] | Missing checks for empty bytes when updating bytes state variables | 1 | 
| [[N&#x2011;48](#n48-consider-moving-msgsender-checks-to-a-common-authorization-modifier)] | Consider moving `msg.sender` checks to a common authorization `modifier` | 1 | 
| [[N&#x2011;49](#n49-setters-should-prevent-re-setting-of-the-same-value)] | Setters should prevent re-setting of the same value | 7 | 
| [[N&#x2011;50](#n50-polymorphic-functions-make-security-audits-more-time-consuming-and-error-prone)] | Polymorphic functions make security audits more time-consuming and error-prone | 3 | 
| [[N&#x2011;51](#n51-complex-casting)] | Complex casting | 2 | 

Total: 743 instances over 51 issues

### Gas Optimizations

| |Issue|Instances|Total Gas Saved|
|-|:-|:-:|:-:|
| [[G&#x2011;01](#g01-enable-ir-based-code-generation)] | Enable IR-based code generation | 1 |  - |
| [[G&#x2011;02](#g02-multiple-addressid-mappings-can-be-combined-into-a-single-mapping-of-an-addressid-to-a-struct-where-appropriate)] | Multiple `address`/ID mappings can be combined into a single `mapping` of an `address`/ID to a `struct`, where appropriate | 2 |  - |
| [[G&#x2011;03](#g03-structs-can-be-packed-into-fewer-storage-slots)] | Structs can be packed into fewer storage slots | 2 |  4000 |
| [[G&#x2011;04](#g04-structs-can-be-packed-into-fewer-storage-slots-by-truncating-timestamp-bytes)] | Structs can be packed into fewer storage slots by truncating timestamp bytes | 2 |  4000 |
| [[G&#x2011;05](#g05-state-variables-should-be-cached-in-stack-variables-rather-than-re-reading-them-from-storage)] | State variables should be cached in stack variables rather than re-reading them from storage | 73 |  7081 |
| [[G&#x2011;06](#g06-multiple-accesses-of-a-mappingarray-should-use-a-local-variable-cache)] | Multiple accesses of a mapping/array should use a local variable cache | 2 |  84 |
| [[G&#x2011;07](#g07-arraylength-should-not-be-looked-up-in-every-loop-of-a-for-looparray)] | `<array>.length` should not be looked up in every loop of a `for`-loop | 7 |  21 |
| [[G&#x2011;08](#g08-ii-should-be-uncheckediuncheckedi-when-it-is-not-possible-for-them-to-overflow-as-is-the-case-when-used-in-for--and-while-loops)] | `++i`/`i++` should be `unchecked{++i}`/`unchecked{i++}` when it is not possible for them to overflow, as is the case when used in `for`- and `while`-loops | 14 |  840 |
| [[G&#x2011;09](#g09-requirerevert-strings-longer-than-32-bytes-cost-extra-gas)] | `require()`/`revert()` strings longer than 32 bytes cost extra gas | 3 |  9 |
| [[G&#x2011;10](#g10-optimize-names-to-save-gas)] | Optimize names to save gas | 5 |  110 |
| [[G&#x2011;11](#g11-usage-of-uintsints-smaller-than-32-bytes-256-bits-incurs-overhead)] | Usage of `uints`/`ints` smaller than 32 bytes (256 bits) incurs overhead | 4 |  88 |
| [[G&#x2011;12](#g12-using-private-rather-than-public-for-constants-saves-gas)] | Using `private` rather than `public` for constants, saves gas | 7 |  - |
| [[G&#x2011;13](#g13-stack-variable-used-as-a-cheaper-cache-for-a-state-variable-is-only-used-once)] | Stack variable used as a cheaper cache for a state variable is only used once | 6 |  18 |
| [[G&#x2011;14](#g14-use-custom-errors-rather-than-revertrequire-strings-to-save-gas)] | Use custom errors rather than `revert()`/`require()` strings to save gas | 8 |  - |
| [[G&#x2011;15](#g15-functions-guaranteed-to-revert-when-called-by-normal-users-can-be-marked-payable)] | Functions guaranteed to revert when called by normal users can be marked `payable` | 41 |  861 |
| [[G&#x2011;16](#g16-constructors-can-be-marked-payable)] | Constructors can be marked `payable` | 9 |  189 |
| [[G&#x2011;17](#g17-dont-use-_msgsender-if-not-supporting-eip-2771)] | Don't use `_msgSender()` if not supporting EIP-2771 | 1 |  16 |
| [[G&#x2011;18](#g18-use-assembly-to-emit-events-in-order-to-save-gas)] | Use assembly to emit events, in order to save gas | 32 |  1216 |
| [[G&#x2011;19](#g19-use-assembly-for-small-keccak256-hashes-in-order-to-save-gas)] | Use assembly for small keccak256 hashes, in order to save gas | 2 |  160 |
| [[G&#x2011;20](#g20-avoid-fetching-a-low-level-calls-return-data-by-using-assembly)] | Avoid fetching a low-level call's return data by using assembly | 1 |  159 |
| [[G&#x2011;21](#g21-events-should-be-emitted-outside-of-loops)] | Events should be emitted outside of loops | 7 |  2625 |
| [[G&#x2011;22](#g22--costs-less-gas-than-)] | `>=` costs less gas than `>` | 4 |  12 |
| [[G&#x2011;23](#g23-nesting-if-statements-is-cheaper-than-using-)] | Nesting `if`-statements is cheaper than using `&&` | 16 |  96 |
| [[G&#x2011;24](#g24-avoid-updating-storage-when-the-value-hasnt-changed)] | Avoid updating storage when the value hasn't changed | 7 |  5600 |
| [[G&#x2011;25](#g25-x--y-costs-more-gas-than-x--x--y-for-state-variablesyxxyx)] | `<x> += <y>` costs more gas than `<x> = <x> + <y>` for state variables | 9 |  1017 |
| [[G&#x2011;26](#g26-state-variable-read-in-a-loop)] | State variable read in a loop | 1 |  97 |
| [[G&#x2011;27](#g27-using-bools-for-storage-incurs-overhead)] | Using `bool`s for storage incurs overhead | 1 |  100 |
| [[G&#x2011;28](#g28-use-uint2561uint2562-instead-of-truefalse-to-save-gas-for-changes)] | Use `uint256(1)`/`uint256(2)` instead of `true`/`false` to save gas for changes | 1 |  17100 |
| [[G&#x2011;29](#g29-using-this-to-access-functions-results-in-an-external-call-wasting-gas)] | Using `this` to access functions results in an external call, wasting gas | 3 |  300 |
| [[G&#x2011;30](#g30-unchecked---can-be-used-on-the-division-of-two-uints-in-order-to-save-gas)] | `unchecked {}`  can be used on the division of two `uint`s in order to save gas | 5 |  100 |
| [[G&#x2011;31](#g31-simple-checks-for-zero-can-be-done-using-assembly-to-save-gas)] | Simple checks for zero can be done using assembly to save gas | 51 |  306 |

Total: 327 instances over 31 issues with **46205 gas** saved

Gas totals are estimates based on data from the Ethereum Yellowpaper. The estimates use the lower bounds of ranges and count two iterations of each `for`-loop. All values above are runtime, not deployment, values; deployment values are listed in the individual issue descriptions. The table above as well as its gas numbers do not include any of the excluded findings.

### Disputed Issues

The issues below may be reported by other bots/wardens, but can be penalized/ignored since either the rule or the specified instances are invalid

| |Issue|Instances|
|-|:-|:-:|
| [[D&#x2011;01](#d01-insufficient-oracle-validation)] | ~~Insufficient oracle validation~~ | 1 | 
| [[D&#x2011;02](#d02-missing-checks-for-whether-the-l2-sequencer-is-active)] | ~~Missing checks for whether the L2 Sequencer is active~~ | 1 | 
| [[D&#x2011;03](#d03-unsafe-downcast)] | ~~Unsafe downcast~~ | 5 | 
| [[D&#x2011;04](#d04-signature-use-at-deadlines-should-be-allowed)] | ~~Signature use at deadlines should be allowed~~ | 1 | 
| [[D&#x2011;05](#d05-external-calls-in-an-un-bounded-for-loop-may-result-in-a-dos)] | ~~External calls in an un-bounded `for-`loop may result in a DOS~~ | 3 | 
| [[D&#x2011;06](#d06-large-or-complicated-code-bases-should-implement-invariant-tests)] | ~~Large or complicated code bases should implement invariant tests~~ | 1 | 
| [[D&#x2011;07](#d07-setters-should-prevent-re-setting-of-the-same-value)] | ~~Setters should prevent re-setting of the same value~~ | 1 | 
| [[D&#x2011;08](#d08-the-result-of-function-calls-should-be-cached-rather-than-re-calling-the-function)] | ~~The result of function calls should be cached rather than re-calling the function~~ | 1 | 
| [[D&#x2011;09](#d09-require-or-revert-statements-that-check-input-arguments-should-be-at-the-top-of-the-function)] | ~~`require()` or `revert()` statements that check input arguments should be at the top of the function~~ | 1 | 
| [[D&#x2011;10](#d10-avoid-updating-storage-when-the-value-hasnt-changed)] | ~~Avoid updating storage when the value hasn't changed~~ | 1 | 
| [[D&#x2011;11](#d11-duplicated-requirerevert-checks-should-be-refactored-to-a-modifier-or-function)] | ~~Duplicated `require()`/`revert()` checks should be refactored to a modifier or function~~ | 6 | 
| [[D&#x2011;12](#d12-spdx-identifier-should-be-the-in-the-first-line-of-a-solidity-file)] | ~~SPDX identifier should be the in the first line of a solidity file~~ | 10 | 
| [[D&#x2011;13](#d13-prefer-double-quotes-for-string-quoting)] | ~~Prefer double quotes for string quoting~~ | 4 | 
| [[D&#x2011;14](#d14-public-functions-not-used-internally-can-be-marked-as-external-to-save-gas)] | ~~Public functions not used internally can be marked as external to save gas~~ | 6 | 
| [[D&#x2011;15](#d15-must-approve-or-increase-allowance-first)] | ~~Must approve or increase allowance first~~ | 2 | 
| [[D&#x2011;16](#d16-array-lengths-not-checked)] | ~~Array lengths not checked~~ | 17 | 
| [[D&#x2011;17](#d17-shorten-the-array-rather-than-copying-to-a-new-one)] | ~~Shorten the array rather than copying to a new one~~ | 2 | 
| [[D&#x2011;18](#d18-bad-bot-rules)] | ~~Bad bot rules~~ | 1 | 
| [[D&#x2011;19](#d19-the-result-of-function-calls-should-be-cached-rather-than-re-calling-the-function)] | ~~The result of function calls should be cached rather than re-calling the function~~ | 2 | 
| [[D&#x2011;20](#d20-require--revert-statements-should-have-descriptive-reason-strings)] | ~~`require()` / `revert()` statements should have descriptive reason strings~~ | 112 | 
| [[D&#x2011;21](#d21-default-bool-values-are-manually-reset)] | ~~Default `bool` values are manually reset~~ | 7 | 
| [[D&#x2011;22](#d22-use-delete-instead-of-setting-mappingstate-variable-to-zero-to-save-gas)] | ~~Use delete instead of setting mapping/state variable to zero, to save gas~~ | 1 | 
| [[D&#x2011;23](#d23-events-that-mark-critical-parameter-changes-should-contain-both-the-old-and-the-new-value)] | ~~Events that mark critical parameter changes should contain both the old and the new value~~ | 40 | 
| [[D&#x2011;24](#d24-empty-function-body)] | ~~Empty function body~~ | 1 | 
| [[D&#x2011;25](#d25-abiencode-is-less-efficient-than-abiencodepacked)] | ~~`abi.encode()` is less efficient than `abi.encodepacked()`~~ | 2 | 
| [[D&#x2011;26](#d26-event-names-should-use-camelcase)] | ~~Event names should use CamelCase~~ | 40 | 
| [[D&#x2011;27](#d27-internal-functions-not-called-by-the-contract-should-be-removed)] | ~~`internal` functions not called by the contract should be removed~~ | 7 | 
| [[D&#x2011;28](#d28-change-public-to-external-for-functions-that-are-not-called-internally)] | ~~Change `public` to `external` for functions that are not called internally~~ | 1 | 
| [[D&#x2011;29](#d29-function-names-not-in-mixedcase)] | ~~Function Names Not in mixedCase~~ | 66 | 
| [[D&#x2011;30](#d30-use-multiple-require-and-if-statements-instead-of-)] | ~~Use multiple `require()` and `if` statements instead of `&&`~~ | 16 | 
| [[D&#x2011;31](#d31-use-inheritdoc-rather-than-using-a-non-standard-annotation)] | ~~Use `@inheritdoc` rather than using a non-standard annotation~~ | 4 | 
| [[D&#x2011;32](#d32-using-storage-instead-of-memory-for-structsarrays-saves-gas)] | ~~Using `storage` instead of `memory` for structs/arrays saves gas~~ | 3 | 
| [[D&#x2011;33](#d33-state-variables-not-capped-at-reasonable-values)] | ~~State variables not capped at reasonable values~~ | 2 | 
| [[D&#x2011;34](#d34-contracts-are-not-using-their-oz-upgradeable-counterparts)] | ~~Contracts are not using their OZ Upgradeable counterparts~~ | 18 | 
| [[D&#x2011;35](#d35-unnecessary-look-up-in-if-condition)] | ~~Unnecessary look up in if condition~~ | 27 | 
| [[D&#x2011;36](#d36-it-is-standard-for-all-external-and-public-functions-to-be-override-from-an-interface)] | ~~It is standard for all external and public functions to be override from an interface~~ | 61 | 
| [[D&#x2011;37](#d37-use-replace-and-pop-instead-of-the-delete-keyword-to-removing-an-item-from-an-array)] | ~~Use replace and pop instead of the delete keyword to removing an item from an array~~ | 4 | 
| [[D&#x2011;38](#d38-its-not-standard-to-end-and-begin-a-code-object-on-the-same-line)] | ~~It's not standard to end and begin a code object on the same line~~ | 70 | 
| [[D&#x2011;39](#d39-state-variable-read-in-a-loop)] | ~~State variable read in a loop~~ | 11 | 
| [[D&#x2011;40](#d40-functions-calling-contractsaddresses-with-transfer-hooks-are-missing-reentrancy-guards)] | ~~Functions calling contracts/addresses with transfer hooks are missing reentrancy guards~~ | 9 | 
| [[D&#x2011;41](#d41-return-values-of-transfertransferfrom-not-checked)] | ~~Return values of transfer()/transferFrom() not checked~~ | 9 | 
| [[D&#x2011;42](#d42-unsafe-erc20-operations)] | ~~Unsafe ERC20 operation(s)~~ | 9 | 
| [[D&#x2011;43](#d43-unused-import)] | ~~Unused import~~ | 70 | 
| [[D&#x2011;44](#d44-unused-modifier)] | ~~Unused modifier~~ | 3 | 
| [[D&#x2011;45](#d45-unusual-loop-variable)] | ~~Unusual loop variable~~ | 14 | 
| [[D&#x2011;46](#d46-some-tokens-may-revert-when-zero-value-transfers-are-made)] | ~~Some tokens may revert when zero value transfers are made~~ | 9 | 
| [[D&#x2011;47](#d47-safetransfer-should-be-used-in-place-of-transfer)] | ~~SafeTransfer should be used in place of transfer~~ | 7 | 

Total: 689 instances over 47 issues




## Low Risk Issues


### [L&#x2011;01] Direct `supportsInterface()` calls may cause caller to revert
Calling `supportsInterface()` on a contract that doesn't implement the ERC-165 standard will result in the call reverting. Even if the caller does support the function, the contract may be malicious and consume all of the transaction's available gas. Call it via a low-level [staticcall()](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L119), with a fixed amount of gas, and check the return code, or use OpenZeppelin's [`ERC165Checker.supportsInterface()`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/f959d7e4e6ee0b022b41e5b644c79369869d8411/contracts/utils/introspection/ERC165Checker.sol#L36-L39).

In the example below, the function call to `supportsInterface()` may cause `_validateMigrationTarget()` to revert, even though the contract may otherwise be fully functional, and fallback checks would have allowed the targeted operation.

*There are 3 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

421      Migratable._validateMigrationTarget(newMigrationTarget);
422      if (
423        !IERC165(newMigrationTarget).supportsInterface(
424          IMigrationDataReceiver.receiveMigrationData.selector
425        )
426      ) {
427        revert InvalidMigrationTarget();
428:     }

```
*GitHub*: [421](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L421-L428)

```solidity
File: src/pools/StakingPoolBase.sol

263      Migratable._validateMigrationTarget(newMigrationTarget);
264      if (
265        !IERC165(newMigrationTarget).supportsInterface(
266          ERC677ReceiverInterface.onTokenTransfer.selector
267        )
268      ) {
269        revert InvalidMigrationTarget();
270:     }

```
*GitHub*: [263](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L263-L270)

```solidity
File: src/rewards/RewardVault.sol

493      Migratable._validateMigrationTarget(newMigrationTarget);
494      if (
495        !IERC165(newMigrationTarget).supportsInterface(
496          ERC677ReceiverInterface.onTokenTransfer.selector
497        )
498      ) {
499        revert InvalidMigrationTarget();
500:     }

```
*GitHub*: [493](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L493-L500)


### [L&#x2011;02] Unsafe downcast
When a type is downcast to a smaller type, the higher order bits are truncated, effectively applying a modulo to the original value. Without any other checks, this wrapping will lead to unexpected behavior and bugs

*There are 7 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit uint224 history -> uint112
323:        uint256 stakerStakedAtTime = uint112(history);

/// @audit uint224 history -> uint112
490:        uint256 stakedAtTime = uint112(history);

```
*GitHub*: [323](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L323), [490](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L490)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit uint224 history -> uint112
242:      uint112 stakerStakedAtTime = uint112(history);

/// @audit uint224 history -> uint112
357:      uint256 stakedAt = uint112(history);

/// @audit uint224 history -> uint112
473:      uint256 stakedAt = uint112(history);

/// @audit uint224 history -> uint112
534:      uint112 stakerStakedAtTime = uint112(history);

/// @audit uint224 history -> uint112
546:      uint112 stakerStakedAtTime = uint112(history);

```
*GitHub*: [242](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L242), [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L357), [473](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L473), [534](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L534), [546](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L546)


### [L&#x2011;03] Loss of precision
Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator

*There are 7 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

291:        principalAmount = remainingSlashCapacity / stakers.length;

```
*GitHub*: [291](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L291)

```solidity
File: src/rewards/RewardVault.sol

398:        : communityRateWithoutDelegation / newDelegationRateDenominator;

431:        uint256 delegatedRewards = unvestedRewards / newDelegationRateDenominator;

938:        forfeitedRewardAmount = forfeitedRewardAmountTimesUnstakedAmount / oldPrincipal;

1181:     bucket.rewardDurationEndsAt = (block.timestamp + (rewardAmount / emissionRate)).toUint80();

1243:       operatorDelegatedReward = communityReward / s_vaultConfig.delegationRateDenominator;

1247:       delegatedRate = communityRate / s_vaultConfig.delegationRateDenominator;

```
*GitHub*: [398](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L398), [431](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L431), [938](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L938), [1181](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1181), [1243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1243), [1247](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1247)


### [L&#x2011;04] `receive()`/`payable fallback()` function does not authorize requests
Having no access control on the function (e.g. `require(msg.sender == address(weth))`) means that someone may send Ether to the contract, and have no way to get anything back out, which is a loss of funds. If the concern is having to spend a small amount of gas to check the sender against an immutable address, the code should at least have a function to rescue mistakenly-sent Ether.

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

217:    receive() external payable {}

```
*GitHub*: [217](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L217)


### [L&#x2011;05] Missing contract-existence checks before low-level calls
Low-level calls return success if there is no code present at the specified address. In addition to the zero-address checks, add a check to verify that `<address>.code.length > 0`

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

423      (bool success,) = call.target.call{value: call.value}(call.data);
424      require(success, 'Timelock: underlying transaction reverted');
425:   }

```
*GitHub*: [423](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L423-L425)


### [L&#x2011;06] External call recipient may consume all transaction gas
There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

/// @audit `_execute()`
423:     (bool success,) = call.target.call{value: call.value}(call.data);

```
*GitHub*: [423](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L423-L423)


### [L&#x2011;07] Empty `receive()`/`fallback()` function
If the intention is for Ether sent by a caller to be used for an actual purpose (i.e. the function is not just a WETH `withdraw()` handler), the function should call another function (e.g. call `weth.deposit()` and use the token on the caller's behalf) or at least emit an event to track that funds were sent directly to it.

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

217:   receive() external payable {}

```
*GitHub*: [217](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L217-L217)


### [L&#x2011;08] State variables not capped at reasonable values
Consider adding minimum/maximum value checks to ensure that the state variables below can never be used to excessively harm users, including via griefing

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

461:     s_minDelay = newDelay;

```
*GitHub*: [461](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L461-L461)


### [L&#x2011;09] Code does not follow the best practice of check-effects-interaction
Code should follow the best-practice of [check-effects-interaction](https://blockchain-academy.hs-mittweida.de/courses/solidity-coding-beginners-to-intermediate/lessons/solidity-11-coding-patterns/topic/checks-effects-interactions/), where state variables are updated before any external calls are made. Doing so prevents a large class of reentrancy bugs.

*There is one instance of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit latestRoundData() called prior to this assignment
542:     returnValues.canAlert = s_operatorStakingPool.isOperator(alerter);

```
*GitHub*: [542](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L542-L542)


### [L&#x2011;10] Consider implementing two-step procedure for updating protocol addresses
A copy-paste error or a typo may end up bricking protocol functionality, or sending tokens to an address with no known private key. Consider implementing a two-step procedure for updating protocol addresses, where the recipient is set as pending, and must 'accept' the assignment by making an affirmative call. A straight forward way of doing this would be to have the target contracts implement [EIP-165](https://eips.ethereum.org/EIPS/eip-165), and to have the 'set' functions ensure that the recipient is of the right interface type.

*There are 6 instances of this issue:*

```solidity
File: src/Migratable.sol

11     function setMigrationTarget(address newMigrationTarget) external virtual override {
12       _validateMigrationTarget(newMigrationTarget);
13   
14       address oldMigrationTarget = s_migrationTarget;
15       s_migrationTarget = newMigrationTarget;
16   
17       emit MigrationTargetSet(oldMigrationTarget, newMigrationTarget);
18:    }

```
*GitHub*: [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L11-L18)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

261    function setCommunityStakingPool(CommunityStakingPool newCommunityStakingPool)
262      external
263      onlyRole(DEFAULT_ADMIN_ROLE)
264    {
265      if (address(newCommunityStakingPool) == address(0)) revert InvalidZeroAddress();
266  
267      CommunityStakingPool oldCommunityStakingPool = s_communityStakingPool;
268      s_communityStakingPool = newCommunityStakingPool;
269      emit CommunityStakingPoolSet(address(oldCommunityStakingPool), address(newCommunityStakingPool));
270:   }

274    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
275      external
276      onlyRole(DEFAULT_ADMIN_ROLE)
277    {
278      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();
279  
280      OperatorStakingPool oldOperatorStakingPool = s_operatorStakingPool;
281      s_operatorStakingPool = newOperatorStakingPool;
282      emit OperatorStakingPoolSet(address(oldOperatorStakingPool), address(newOperatorStakingPool));
283:   }

```
*GitHub*: [261](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L261-L270), [274](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L274-L283)

```solidity
File: src/pools/CommunityStakingPool.sol

133    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
134      external
135      onlyRole(DEFAULT_ADMIN_ROLE)
136    {
137      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();
138      address oldOperatorStakingPool = address(s_operatorStakingPool);
139      s_operatorStakingPool = newOperatorStakingPool;
140      emit OperatorStakingPoolChanged(oldOperatorStakingPool, address(newOperatorStakingPool));
141:   }

```
*GitHub*: [133](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L133-L141)

```solidity
File: src/pools/StakingPoolBase.sol

315    function setRewardVault(IRewardVault newRewardVault) external onlyRole(DEFAULT_ADMIN_ROLE) {
316      if (address(newRewardVault) == address(0)) revert InvalidZeroAddress();
317      address oldRewardVault = address(s_rewardVault);
318      s_rewardVault = newRewardVault;
319      emit RewardVaultSet(oldRewardVault, address(newRewardVault));
320:   }

```
*GitHub*: [315](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L315-L320)

```solidity
File: src/rewards/RewardVault.sol

467    function setMigrationSource(address newMigrationSource) external onlyRole(DEFAULT_ADMIN_ROLE) {
468      if (address(newMigrationSource) == address(0) || address(newMigrationSource) == address(this)) {
469        revert InvalidMigrationSource();
470      }
471      address oldMigrationSource = s_migrationSource;
472      s_migrationSource = newMigrationSource;
473      emit MigrationSourceSet(oldMigrationSource, newMigrationSource);
474:   }

```
*GitHub*: [467](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L467-L474)

## Non-critical Issues


### [N&#x2011;01] `public` functions not called by the contract should be declared `external` instead
Contracts [are allowed](https://docs.soliditylang.org/en/latest/contracts.html#function-overriding) to override their parents' functions and change the visibility from `external` to `public`.

*There are 6 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

156:    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

```
*GitHub*: [156](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L156)

```solidity
File: src/pools/OperatorStakingPool.sol

204     function grantRole(
205       bytes32 role,
206:      address account

567:    function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

```
*GitHub*: [204](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L204-L206), [567](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L567)

```solidity
File: src/rewards/RewardVault.sol

552:    function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

```
*GitHub*: [552](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L552)

```solidity
File: src/timelock/Timelock.sol

332     function scheduleBatch(
333       Call[] calldata calls,
334       bytes32 predecessor,
335       bytes32 salt,
336       uint256 delay
337:    ) public virtual onlyRoleOrAdminRole(PROPOSER_ROLE) {

401     function executeBatch(
402       Call[] calldata calls,
403       bytes32 predecessor,
404       bytes32 salt
405:    ) public payable virtual onlyRoleOrAdminRole(EXECUTOR_ROLE) {

```
*GitHub*: [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L332-L337), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L401-L405)


### [N&#x2011;02] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*There are 10 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit 112
322:        uint256 operatorPrincipal = uint112(history >> 112);

/// @audit 112
489:        uint256 principal = uint256(history >> 112);

```
*GitHub*: [322](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L322), [489](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L489)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit 112
241:      uint112 stakerPrincipal = uint112(history >> 112);

/// @audit 112
280:      uint112 stakerPrincipal = uint112(history >> 112);

/// @audit 112
356:      uint256 stakerPrincipal = uint256(history >> 112);

/// @audit 112
472:      uint256 stakerPrincipal = uint256(history >> 112);

/// @audit 112
515:      uint112 stakerPrincipal = uint112(history >> 112);

/// @audit 112
527:      uint112 stakerPrincipal = uint112(history >> 112);

/// @audit 112
744:        (uint224(uint112(latestPrincipal)) << 112) | uint224(uint112(latestStakedAtTime))

```
*GitHub*: [241](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L241), [280](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L280), [356](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L356), [472](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L472), [515](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L515), [527](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L527), [744](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L744)

```solidity
File: src/timelock/Timelock.sol

/// @audit 4
292:        uint256 selectorDelay = getMinDelay(calls[i].target, bytes4(calls[i].data[:4]));

```
*GitHub*: [292](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L292)


### [N&#x2011;03] Event is not properly `indexed`
Index event fields make the field more quickly accessible [to off-chain tools](https://ethereum.stackexchange.com/questions/40396/can-somebody-please-explain-the-concept-of-event-indexing) that parse events. This is especially useful when it comes to filtering based on an address. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Where applicable, each `event` should use three `indexed` fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three applicable fields, all of the applicable fields should be indexed.

*There are 3 instances of this issue:*

```solidity
File: src/rewards/RewardVault.sol

198:    event RewardFinalized(address staker, bool shouldForfeit);

```
*GitHub*: [198](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L198)

```solidity
File: src/timelock/Timelock.sol

56      event CallScheduled(
57        bytes32 indexed id,
58        uint256 indexed index,
59        address target,
60        uint256 value,
61        bytes data,
62        bytes32 predecessor,
63        bytes32 salt,
64        uint256 delay
65:     );

76      event CallExecuted(
77        bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data
78:     );

```
*GitHub*: [56](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L56-L65), [76](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L76-L78)


### [N&#x2011;04] Duplicated `require()`/`revert()` checks should be refactored to a modifier or function
The compiler will inline the function, which will avoid `JUMP` instructions usually associated with functions

*There are 3 instances of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

281:      if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

779:      if (s_pool.state.closedAt != 0) revert PoolHasBeenClosed();

```
*GitHub*: [281](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L281), [779](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L779)

```solidity
File: src/timelock/Timelock.sol

444:      require(isOperationReady(id), 'Timelock: operation is not ready');

```
*GitHub*: [444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L444)


### [N&#x2011;05] Common functions should be refactored to a common base contract
The functions below have the same implementation as is seen in other files. The functions should be refactored into functions of a common base contract

*There is one instance of this issue:*

```solidity
File: src/rewards/RewardVault.sol

/// @audit seen in src/pools/StakingPoolBase.sol
488     function _validateMigrationTarget(address newMigrationTarget)
489       internal
490       override(Migratable)
491       onlyRole(DEFAULT_ADMIN_ROLE)
492     {
493       Migratable._validateMigrationTarget(newMigrationTarget);
494       if (
495         !IERC165(newMigrationTarget).supportsInterface(
496           ERC677ReceiverInterface.onTokenTransfer.selector
497         )
498       ) {
499         revert InvalidMigrationTarget();
500       }
501:    }

```
*GitHub*: [488](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L488-L501)


### [N&#x2011;06] Vulnerable versions of packages are being used
This project's specific package versions are vulnerable to the specific CVEs listed below. While the CVEs may involve code not in use by your project, consider switching to more recent versions of these packages that don't have these vulnerabilities, to avoid reviewers wasting time trying to determine whether there is vulnerable code from these packages in use.

*There is one instance of this issue:*

```solidity
File: Various Files

/// @audit Vulnerabilities:
///          
```



- [CVE-2022-31170](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-31170) - HIGH -  (@openzeppelin/contracts >=4.0.0 <4.7.1) - OpenZeppelin Contracts is a library for smart contract development. Versions 4.0.0 until 4.7.1 are vulnerable to ERC165Checker reverting instead of returning `false`. `ERC165Checker.supportsInterface` is designed to always successfully return a boolean, and under no circumstance revert. However, an incorrect assumption about Solidity 0.8's `abi.decode` allows some cases to revert, given a target contract that doesn't implement EIP-165 as expected, specifically if it returns a value other than 0 or 1. The contracts that may be affected are those that use `ERC165Checker` to check for support for an interface and then handle the lack of support in a way other than reverting. The issue was patched in version 4.7.1.
- [CVE-2022-31172](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-31172) - HIGH -  (@openzeppelin/contracts >=4.1.0 <4.7.1) - OpenZeppelin Contracts is a library for smart contract development. Versions 4.1.0 until 4.7.1 are vulnerable to the SignatureChecker reverting. `SignatureChecker.isValidSignatureNow` is not expected to revert. However, an incorrect assumption about Solidity 0.8's `abi.decode` allows some cases to revert, given a target contract that doesn't implement EIP-1271 as expected. The contracts that may be affected are those that use `SignatureChecker` to check the validity of a signature and handle invalid signatures in a way other than reverting. The issue was patched in version 4.7.1.
- [CVE-2022-31198](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-31198) - HIGH -  (@openzeppelin/contracts >=4.3.0 <4.7.2) - OpenZeppelin Contracts is a library for secure smart contract development. This issue concerns instances of Governor that use the module `GovernorVotesQuorumFraction`, a mechanism that determines quorum requirements as a percentage of the voting token's total supply. In affected instances, when a proposal is passed to lower the quorum requirements, past proposals may become executable if they had been defeated only due to lack of quorum, and the number of votes it received meets the new quorum requirement. Analysis of instances on chain found only one proposal that met this condition, and we are actively monitoring for new occurrences of this particular issue. This issue has been patched in v4.7.2. Users are advised to upgrade. Users unable to upgrade should consider avoiding lowering quorum requirements if a past proposal was defeated for lack of quorum.
- [CVE-2022-35915](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-35915) - MEDIUM -  (@openzeppelin/contracts >= 2.0.0 <4.7.2) - OpenZeppelin Contracts is a library for secure smart contract development. The target contract of an EIP-165 `supportsInterface` query can cause unbounded gas consumption by returning a lot of data, while it is generally assumed that this operation has a bounded cost. The issue has been fixed in v4.7.2. Users are advised to upgrade. There are no known workarounds for this issue.
- [CVE-2022-35961](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-35961) - MEDIUM -  (@openzeppelin/contracts >=4.1.0 <4.7.3) - OpenZeppelin Contracts is a library for secure smart contract development. The functions `ECDSA.recover` and `ECDSA.tryRecover` are vulnerable to a kind of signature malleability due to accepting EIP-2098 compact signatures in addition to the traditional 65 byte signature format. This is only an issue for the functions that take a single `bytes` argument, and not the functions that take `r, v, s` or `r, vs` as separate arguments. The potentially affected contracts are those that implement signature reuse or replay protection by marking the signature itself as used rather than the signed message or a nonce included in it. A user may take a signature that has already been submitted, submit it again in a different form, and bypass this protection. The issue has been patched in 4.7.3.
- [CVE-2022-39384](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-39384) - MEDIUM -  (@openzeppelin/contracts >=3.2.0 <4.4.1) - OpenZeppelin Contracts is a library for secure smart contract development. Before version 4.4.1 but after 3.2.0, initializer functions that are invoked separate from contract creation (the most prominent example being minimal proxies) may be reentered if they make an untrusted non-view external call. Once an initializer has finished running it can never be re-executed. However, an exception put in place to support multiple inheritance made reentrancy possible in the scenario described above, breaking the expectation that there is a single execution. Note that upgradeable proxies are commonly initialized together with contract creation, where reentrancy is not feasible, so the impact of this issue is believed to be minor. This issue has been patched, please upgrade to version 4.4.1. As a workaround, avoid untrusted external calls during initialization.
- [CVE-2023-30541](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-30541) - MEDIUM -  (@openzeppelin/contracts >=3.2.0 <4.8.3) - OpenZeppelin Contracts is a library for secure smart contract development. A function in the implementation contract may be inaccessible if its selector clashes with one of the proxy's own selectors. Specifically, if the clashing function has a different signature with incompatible ABI encoding, the proxy could revert while attempting to decode the arguments from calldata. The probability of an accidental clash is negligible, but one could be caused deliberately and could cause a reduction in availability. The issue has been fixed in version 4.8.3. As a workaround if a function appears to be inaccessible for this reason, it may be possible to craft the calldata such that ABI decoding does not fail at the proxy and the function is properly proxied through.
- [CVE-2023-30542](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2023-30542) - HIGH -  (@openzeppelin/contracts >=4.3.0 <4.8.3) - OpenZeppelin Contracts is a library for secure smart contract development. The proposal creation entrypoint (`propose`) in `GovernorCompatibilityBravo` allows the creation of proposals with a `signatures` array shorter than the `calldatas` array. This causes the additional elements of the latter to be ignored, and if the proposal succeeds the corresponding actions would eventually execute without any calldata. The `ProposalCreated` event correctly represents what will eventually execute, but the proposal parameters as queried through `getActions` appear to respect the original intended calldata. This issue has been patched in 4.8.3. As a workaround, ensure that all proposals that pass through governance have equal length `signatures` and `calldatas` parameters.
```

```


### [N&#x2011;07] Events that mark critical parameter changes should contain both the old and the new value
This should especially be done if the new value is not required to be different from the old value

*There are 2 instances of this issue:*

```solidity
File: src/pools/CommunityStakingPool.sol

/// @audit setMerkleRoot()
122:      emit MerkleRootChanged(newMerkleRoot);

```
*GitHub*: [122](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L122)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit setMigrationProxy()
441:      emit MigrationProxySet(migrationProxy);

```
*GitHub*: [441](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L441)


### [N&#x2011;08] Constant redefined elsewhere
Consider defining in only one contract so that values cannot become out of sync when only one location is updated. A [cheap way](https://medium.com/coinmonks/gas-cost-of-solidity-library-functions-dbe0cedd4678) to store constants in a single location is to create an `internal constant` in a `library`. If the variable is a local cache of another contract's value, consider making the cache variable internal or private, which will require external users to query the contract with the source of truth, so that callers don't get out of sync.

*There are 4 instances of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit seen in src/MigrationProxy.sol 
173:    LinkTokenInterface internal immutable i_LINK;

```
*GitHub*: [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L173)

```solidity
File: src/rewards/RewardVault.sol

/// @audit seen in src/pools/StakingPoolBase.sol 
290:    LinkTokenInterface private immutable i_LINK;

/// @audit seen in src/MigrationProxy.sol 
292:    CommunityStakingPool private immutable i_communityStakingPool;

/// @audit seen in src/MigrationProxy.sol 
294:    OperatorStakingPool private immutable i_operatorStakingPool;

```
*GitHub*: [290](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L290), [292](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L292), [294](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L294)


### [N&#x2011;09] Long functions should be refactored into multiple, smaller, functions


*There are 4 instances of this issue:*

```solidity
File: src/rewards/RewardVault.sol

/// @audit 65 lines (60 in the body)
384     function setDelegationRateDenominator(uint256 newDelegationRateDenominator)
385       external
386:      onlyRole(DEFAULT_ADMIN_ROLE)

/// @audit 67 lines (59 in the body)
721     function finalizeReward(
722       address staker,
723       uint256 oldPrincipal,
724       uint256 stakedAt,
725       uint256 unstakedAmount,
726       bool shouldClaim
727:    ) external override onlyStakingPool returns (uint256) {

/// @audit 69 lines (62 in the body)
1193    function _getBucketRewardAndEmissionRateSplit(
1194      address pool,
1195      uint256 amount,
1196      uint256 emissionRate,
1197      bool isDelegated
1198:   ) private view returns (BucketRewardEmissionSplit memory) {

```
*GitHub*: [384](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L384-L386), [721](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L721-L727), [1193](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1193-L1198)

```solidity
File: src/timelock/StakingTimelock.sol

/// @audit 77 lines (73 in the body)
52      constructor(ConstructorParams memory params)
53:       Timelock(params.minDelay, params.admin, params.proposers, params.executors, params.cancellers)

```
*GitHub*: [52](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L52-L53)


### [N&#x2011;10] Typos


*There are 10 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit greated
143:      /// max value of uint96 is greated than total supply of LINK

/// @audit greated
147:      /// max value of uint96 is greated than total supply of LINK

/// @audit greated
169:      /// max value of uint96 is greated than total supply of LINK

/// @audit greated
173:      /// max value of uint96 is greated than total supply of LINK

/// @audit greated
191:      /// max value of uint96 is greated than total supply of LINK

/// @audit greated
195:      /// max value of uint96 is greated than total supply of LINK

```
*GitHub*: [143](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L143), [147](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L147), [169](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L169), [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L173), [191](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L191), [195](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L195)

```solidity
File: src/pools/CommunityStakingPool.sol

/// @audit acccess
43:     /// of staker addresses with early acccess.

```
*GitHub*: [43](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L43)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit currenct
608:    /// @notice Returns the currenct checkpoint ID

```
*GitHub*: [608](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L608)

```solidity
File: src/rewards/RewardVault.sol

/// @audit emited
113:    /// @notice This event is emited when the vault is opened.

/// @audit previoud
164:    /// @param oldMigrationSource The previoud migration source

```
*GitHub*: [113](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L113), [164](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L164)


### [N&#x2011;11] NatSpec `@param` is missing


*There are 6 instances of this issue:*

```solidity
File: src/rewards/RewardVault.sol

/// @audit Missing: '@param staker'
1697    /// @notice Returns whether or not an address is currently an operator or
1698    /// is a removed operator, if the vault is closed.
1699    /// @return bool True if the vault is open and the staker is an operator; if the vault is closed,
1700    /// returns True if the staker is either an operator or a removed operator.
1701:   function _isOperator(address staker) private view returns (bool) {

```
*GitHub*: [1697](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1697-L1701)

```solidity
File: src/timelock/Timelock.sol

/// @audit Missing: '@param minDelay'
/// @audit Missing: '@param admin'
/// @audit Missing: '@param proposers'
/// @audit Missing: '@param executors'
/// @audit Missing: '@param cancellers'
153     /**
154      * @dev Initializes the contract with the following parameters:
155      *
156      * - `minDelay`: initial minimum delay for operations
157      * - `admin`: account to be granted admin role
158      * - `proposers`: accounts to be granted proposer role
159      * - `executors`: accounts to be granted executor role
160      * - `cancellers`: accounts to be granted canceller role
161      *
162      * The admin is the most powerful role. Only an admin can manage membership
163      * of all roles.
164      */
165     constructor(
166       uint256 minDelay,
167       address admin,
168       address[] memory proposers,
169       address[] memory executors,
170:      address[] memory cancellers

```
*GitHub*: [153](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L153-L170), [153](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L153-L170), [153](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L153-L170), [153](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L153-L170), [153](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L153-L170)


### [N&#x2011;12] NatSpec `@return` argument is missing


*There are 2 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit Missing: '@return'
546     /// @notice Helper function for checking if this contract has the slasher role
547:    function _hasSlasherRole() private view returns (bool) {

```
*GitHub*: [546](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L546-L547)

```solidity
File: src/rewards/RewardVault.sol

/// @audit Missing: '@return'
1498    /// operator will also forfeit any unclaimed rewards if they are removed
1499    /// before they reach the maximum ramp up period multiplier.
1500    function _calculateStakerReward(
1501      address staker,
1502      bool isOperator,
1503      uint256 stakerPrincipal
1504:   ) private view returns (StakerReward memory) {

```
*GitHub*: [1498](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1498-L1504)


### [N&#x2011;13] Function ordering does not follow the Solidity style guide
According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*There are 26 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

/// @audit _validateMigrationTarget() came earlier
32:     function getMigrationTarget() external view virtual override returns (address) {

```
*GitHub*: [32](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L32)

```solidity
File: src/MigrationProxy.sol

/// @audit _migrateToPool() came earlier
137:    function getConfig() external view returns (address, address, address, address) {

/// @audit supportsInterface() came earlier
165:    function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [137](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L137), [165](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L165)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit _validateMigrationTarget() came earlier
436     function sendMigrationData(address[] calldata feeds)
437       external
438       onlyRole(DEFAULT_ADMIN_ROLE)
439:      validateMigrationTargetSet

/// @audit _setSlashableOperators() came earlier
580:    function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L436-L439), [580](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L580)

```solidity
File: src/pools/CommunityStakingPool.sol

/// @audit _handleOpen() came earlier
96      function hasAccess(
97        address staker,
98        bytes32[] calldata proof
99:     ) external view override returns (bool) {

/// @audit _hasAccess() came earlier
120:    function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE) {

```
*GitHub*: [96](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L96-L99), [120](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L120)

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit grantRole() came earlier
218     function addSlasher(
219       address slasher,
220       SlasherConfig calldata config
221:    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

/// @audit _setSlasherConfig() came earlier
257:    function getSlasherConfig(address slasher) external view override returns (SlasherConfig memory) {

/// @audit _getRemainingSlashCapacity() came earlier
393:    function _validateOnTokenTransfer(address, address staker, bytes calldata) internal view override {

/// @audit _validateOnTokenTransfer() came earlier
400     function setPoolConfig(
401       uint256 maxPoolSize,
402       uint256 maxPrincipalPerStaker
403     )
404       external
405       override
406       validatePoolSpace(maxPoolSize, maxPrincipalPerStaker, s_numOperators)
407       whenOpen
408:      onlyRole(DEFAULT_ADMIN_ROLE)

/// @audit _handleOpen() came earlier
426     function addOperators(address[] calldata operators)
427       external
428       validateRewardVaultSet
429       validatePoolSpace(
430         s_pool.configs.maxPoolSize,
431         s_pool.configs.maxPrincipalPerStaker,
432         s_numOperators + operators.length
433       )
434:      onlyRole(DEFAULT_ADMIN_ROLE)

/// @audit supportsInterface() came earlier
602:    function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [218](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L218-L221), [257](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L257), [393](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L393), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L400-L408), [426](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L426-L434), [602](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L602)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit _validateMigrationTarget() came earlier
277     function unbond() external {
278:      Staker storage staker = s_stakers[msg.sender];

/// @audit _validateOnTokenTransfer() came earlier
390:    function getClaimPeriodLimits() external view returns (uint256, uint256) {

/// @audit _handleOpen() came earlier
436:    function setMigrationProxy(address migrationProxy) external override onlyRole(DEFAULT_ADMIN_ROLE) {

/// @audit isActive() came earlier
576:    function getStakerLimits() external view override returns (uint256, uint256) {

/// @audit _setClaimPeriod() came earlier
672:    function _increaseStake(address sender, uint256 newPrincipal, uint256 amount) internal {

/// @audit _inClaimPeriod() came earlier
737     function _updateStakerHistory(
738       Staker storage staker,
739       uint256 latestPrincipal,
740:      uint256 latestStakedAtTime

```
*GitHub*: [277](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L277-L278), [390](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L390), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L436), [576](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L576), [672](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L672), [737](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L737-L740)

```solidity
File: src/rewards/RewardVault.sol

/// @audit _validateMigrationTarget() came earlier
509     function migrate(bytes calldata data)
510       external
511       override(IMigratable)
512       onlyRole(DEFAULT_ADMIN_ROLE)
513       whenOpen
514:      validateMigrationTargetSet

/// @audit supportsInterface() came earlier
566:    function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external override {

/// @audit _transferRewards() came earlier
687:    function updateReward(address staker, uint256 stakerPrincipal) external override onlyStakingPool {

/// @audit _isOperator() came earlier
1741:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [509](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L509-L514), [566](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L566), [687](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L687), [1741](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1741)

```solidity
File: src/timelock/Timelock.sol

/// @audit getTimestamp() came earlier
272:    function getMinDelay() external view virtual returns (uint256) {

/// @audit _schedule() came earlier
374:    function cancel(bytes32 id) external virtual onlyRoleOrAdminRole(CANCELLER_ROLE) {

/// @audit _afterCall() came earlier
459:    function updateDelay(uint256 newDelay) external virtual onlyRole(ADMIN_ROLE) {

```
*GitHub*: [272](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L272), [374](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L374), [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L459)

</details>

### [N&#x2011;14] Contract does not follow the Solidity style guide's suggested layout ordering
The [style guide](https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout) says that, within a contract, the ordering should be 1) Type declarations, 2) State variables, 3) Events, 4) Modifiers, and 5) Functions, but the contract(s) below do not follow this ordering

*There are 13 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

/// @audit function getMigrationTarget came earlier
37      modifier validateMigrationTargetSet() {
38        if (s_migrationTarget == address(0)) {
39          revert InvalidMigrationTarget();
40        }
41        _;
42:     }

```
*GitHub*: [37](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L37-L42)

```solidity
File: src/MigrationProxy.sol

/// @audit function typeAndVersion came earlier
170     modifier validateFromLINK() {
171       if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();
172       _;
173:    }

```
*GitHub*: [170](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L170-L173)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit event AlertsControllerMigrated came earlier
220:    CommunityStakingPool private s_communityStakingPool;

/// @audit function _setSlashableOperators came earlier
574     modifier withSlasherRole() {
575       if (!_hasSlasherRole()) revert DoesNotHaveSlasherRole();
576       _;
577:    }

```
*GitHub*: [220](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L220), [574](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L574-L577)

```solidity
File: src/pools/CommunityStakingPool.sol

/// @audit event OperatorStakingPoolChanged came earlier
41:     OperatorStakingPool private s_operatorStakingPool;

```
*GitHub*: [41](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L41)

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit event Slashed came earlier
126     mapping(address => Operator) private s_operators;
127     /// @notice Mapping of the slashers to slasher config struct.
128     mapping(address => ISlashable.SlasherConfig) private s_slasherConfigs;
129     /// @notice Mapping of slashers to slasher state struct.
130:    mapping(address => ISlashable.SlasherState) private s_slasherState;

/// @audit function supportsInterface came earlier
572     modifier onlySlasher() {
573       if (!hasRole(SLASHER_ROLE, msg.sender)) {
574         revert AccessForbidden();
575       }
576       _;
577:    }

```
*GitHub*: [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L126-L130), [572](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L572-L577)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit event StakerMigrated came earlier
173:    LinkTokenInterface internal immutable i_LINK;

/// @audit function _updateStakerHistory came earlier
753     modifier validateFromLINK() {
754       if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();
755       _;
756:    }

```
*GitHub*: [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L173), [753](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L753-L756)

```solidity
File: src/rewards/RewardVault.sol

/// @audit event RewardFinalized came earlier
285:    bytes32 public constant REWARDER_ROLE = keccak256('REWARDER_ROLE');

/// @audit function _isOperator came earlier
1713    modifier onlyRewarder() {
1714      if (!hasRole(REWARDER_ROLE, msg.sender)) {
1715        revert AccessForbidden();
1716      }
1717      _;
1718:   }

```
*GitHub*: [285](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L285), [1713](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1713-L1718)

```solidity
File: src/timelock/Timelock.sol

/// @audit event MinDelayChange came earlier
127:    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

/// @audit function constructor came earlier
206     modifier onlyRoleOrAdminRole(bytes32 role) {
207       address sender = _msgSender();
208       if (!hasRole(ADMIN_ROLE, sender)) {
209         _checkRole(role, sender);
210       }
211       _;
212:    }

```
*GitHub*: [127](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L127), [206](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L206-L212)

</details>

### [N&#x2011;15] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*There are 124 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

23        if (
24:         newMigrationTarget == address(0) || newMigrationTarget == address(this)

```
*GitHub*: [23](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L23-L24)

```solidity
File: src/MigrationProxy.sol

66:       if (address(params.LINKAddress) == address(0)) revert InvalidZeroAddress();

67:       if (address(params.v01StakingAddress) == address(0)) {

70:       if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();

71:       if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();

96:       if (source != i_v01StakingAddress) revert InvalidSourceAddress();

171:      if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();

91      function onTokenTransfer(
92:       address source,

```
*GitHub*: [66](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L66), [67](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L67), [70](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L70), [71](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L71), [96](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L96), [171](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L171), [91](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L91-L92)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

422       if (
423:        !IERC165(newMigrationTarget).supportsInterface(

522       if (
523:        !_hasSlasherRole() || feedConfig.priorityPeriodThreshold == 0

483         if (configParams.slashableAmount == 0 || configParams.slashableAmount > operatorMaxPrincipal)
484:        {

233:      if (address(params.communityStakingPool) == address(0)) {

236:      if (address(params.operatorStakingPool) == address(0)) {

265:      if (address(newCommunityStakingPool) == address(0)) revert InvalidZeroAddress();

278:      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();

332:      if (!returnValues.canAlert) revert AlertInvalid();

375:      if (feed == address(0)) revert InvalidZeroAddress();

378:      if (config.priorityPeriodThreshold == 0) revert FeedDoesNotExist();

476:        if (configParams.feed == address(0)) revert InvalidZeroAddress();

530:      if (principalInOperatorPool == 0 && principalInCommunityStakingPool == 0) return returnValues;

533:      if (block.timestamp < updatedAt + feedConfig.priorityPeriodThreshold) return returnValues;

561:        if (operator == address(0)) revert InvalidZeroAddress();

575:      if (!_hasSlasherRole()) revert DoesNotHaveSlasherRole();

371     function setSlashableOperators(
372:      address[] calldata operators,

513     function _canAlert(
514:      address alerter,

```
*GitHub*: [422](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L422-L423), [522](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L522-L523), [483](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L483-L484), [233](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L233), [236](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L236), [265](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L265), [278](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L278), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L332), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L375), [378](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L378), [476](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L476), [530](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L530), [533](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L533), [561](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L561), [575](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L575), [371](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L371-L372), [513](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L513-L514)

```solidity
File: src/pools/CommunityStakingPool.sol

71        if (
72:         sender != address(s_migrationProxy) && s_merkleRoot != bytes32(0)

47:       if (address(params.operatorStakingPool) == address(0)) {

79:       if (s_operatorStakingPool.isOperator(staker) || s_operatorStakingPool.isRemoved(staker)) {

110:      if (s_merkleRoot == bytes32(0)) return true;

137:      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();

59      function _validateOnTokenTransfer(
60:       address sender,

96      function hasAccess(
97:       address staker,

```
*GitHub*: [71](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L71-L72), [47](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L47), [79](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L79), [110](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L110), [137](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L137), [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L59-L60), [96](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L96-L97)

```solidity
File: src/pools/OperatorStakingPool.sol

159:      if (amount == 0) revert InvalidAlerterRewardFundAmount();

174:      if (s_isOpen) revert PoolNotClosed();

208:      if (role == SLASHER_ROLE) revert InvalidRole();

395:      if (!s_operators[staker].isOperator) revert StakerNotOperator();

204     function grantRole(
205:      bytes32 role,

218     function addSlasher(
219:      address slasher,

228     function setSlasherConfig(
229:      address slasher,

277     function slashAndReward(
278:      address[] calldata stakers,

312     function _slashOperators(
313:      address[] calldata operators,

350     function _payAlerter(
351:      address alerter,

375     function _getRemainingSlashCapacity(
376:      SlasherConfig memory slasherConfig,

400     function setPoolConfig(
401:      uint256 maxPoolSize,

```
*GitHub*: [159](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L159), [174](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L174), [208](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L208), [395](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L395), [204](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L204-L205), [218](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L218-L219), [228](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L228-L229), [277](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L277-L278), [312](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L312-L313), [350](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L350-L351), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L375-L376), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L400-L401)

```solidity
File: src/pools/StakingPoolBase.sol

264       if (
265:        !IERC165(newMigrationTarget).supportsInterface(

629       if (
630:        maxPrincipalPerStaker == 0 || maxPrincipalPerStaker > maxPoolSize

200:      if (address(params.LINKAddress) == address(0)) revert InvalidZeroAddress();

201:      if (params.minPrincipalPerStaker == 0) revert InvalidMinStakeAmount();

243:      if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

281:      if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

316:      if (address(newRewardVault) == address(0)) revert InvalidZeroAddress();

345:      if (amount == 0) return;

349:      if (staker == address(0)) revert InvalidZeroAddress();

437:      if (migrationProxy == address(0)) revert InvalidZeroAddress();

464:      if (paused() && shouldClaimReward) {

469:      if (amount == 0) revert UnstakeZeroAmount();

475:      if (amount > stakerPrincipal) revert UnstakeExceedsPrincipal();

704:      if (data.length == 0) revert InvalidData();

754:      if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();

760:      if (s_migrationProxy == address(0)) revert MigrationProxyNotSet();

766:      if (address(s_rewardVault) == address(0)) revert RewardVaultNotSet();

772:      if (s_isOpen) revert PoolHasBeenOpened();

773:      if (s_pool.state.closedAt != 0) revert PoolHasBeenClosed();

779:      if (s_pool.state.closedAt != 0) revert PoolHasBeenClosed();

785:      if (!s_isOpen) revert PoolNotOpen();

791:      if (!isActive()) revert PoolNotActive();

797:      if (s_pool.state.closedAt == 0) revert PoolNotClosed();

803:      if (!s_rewardVault.isOpen() || s_rewardVault.isPaused()) revert RewardVaultNotActive();

332     function onTokenTransfer(
333:      address sender,

381     function _validateOnTokenTransfer(
382:      address sender,

400     function setPoolConfig(
401:      uint256 maxPoolSize,

522     function getStakerPrincipalAt(
523:      address staker,

541     function getStakerStakedAtTimeAt(
542:      address staker,

737     function _updateStakerHistory(
738:      Staker storage staker,

```
*GitHub*: [264](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L264-L265), [629](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L629-L630), [200](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L200), [201](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L201), [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L243), [281](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L281), [316](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L316), [345](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L345), [349](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L349), [437](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L437), [464](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L464), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L469), [475](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L475), [704](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L704), [754](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L754), [760](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L760), [766](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L766), [772](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L772), [773](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L773), [779](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L779), [785](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L785), [791](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L791), [797](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L797), [803](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L803), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L332-L333), [381](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L381-L382), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L400-L401), [522](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L522-L523), [541](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L541-L542), [737](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L737-L738)

```solidity
File: src/rewards/RewardVault.sol

353       if (
354:        pool != address(0) && pool != address(i_communityStakingPool)

400       if (
401:        delegatedRate == 0 && newDelegationRateDenominator != 0 && communityRateWithoutDelegation != 0

494       if (
495:        !IERC165(newMigrationTarget).supportsInterface(

1275      if (
1276:       rewardAmount != 0

1304      if (
1305:       (

1722      if (
1723:       msg.sender != address(i_operatorStakingPool) && msg.sender != address(i_communityStakingPool)

312:      if (address(params.linkToken) == address(0)) revert InvalidZeroAddress();

313:      if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();

314:      if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();

468:      if (address(newMigrationSource) == address(0) || address(newMigrationSource) == address(this)) {

567:      if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();

568:      if (sender != s_migrationSource) revert AccessForbidden();

589:      if (totalUnvestedRewards != amount) revert InvalidRewardAmount();

693:      if (staker == address(0)) return;

728:      if (paused() && shouldClaim) revert CannotClaimRewardWhenPaused();

1025:     if (stakedAt == 0) return 0;

1028:     if (multiplierDuration == 0) return MAX_MULTIPLIER;

1161:     if (amount + remainingRewards < emissionRate) revert RewardDurationTooShort();

1180:     if (emissionRate == 0) return;

1386:     if (totalPrincipal == 0) return rewardBucket.vestedRewardPerToken;

1583:     if (forfeitedReward == 0) return (0, 0, 0);

1732:     if (!s_vaultConfig.isOpen) revert VaultAlreadyClosed();

346     function addReward(
347:      address pool,

664     function _transferRewards(
665:      address staker,

721     function finalizeReward(
722:      address staker,

920     function _forfeitStakerBaseReward(
921:      StakerReward memory stakerReward,

1012    function _getStakerPrincipal(
1013:     address staker,

1042    function _getStakerStakedAtTime(
1043:     address staker,

1152    function _updateRewardBucket(
1153:     RewardBucket storage bucket,

1175    function _updateRewardDurationEndsAt(
1176:     RewardBucket storage bucket,

1193    function _getBucketRewardAndEmissionRateSplit(
1194:     address pool,

1269    function _checkForRoundingToZeroRewardAmountSplit(
1270:     uint256 rewardAmount,

1298    function _checkForRoundingToZeroEmissionRateSplit(
1299:     uint256 emissionRate,

1323    function _checkForRoundingToZeroDelegationSplit(
1324:     uint256 communityReward,

1382    function _calculateVestedRewardPerToken(
1383:     RewardBucket memory rewardBucket,

1404    function _calculateEarnedBaseReward(
1405:     StakerReward memory stakerReward,

1423    function _calculateEarnedDelegatedReward(
1424:     StakerReward memory stakerReward,

1444    function _applyMultiplier(
1445:     StakerReward memory stakerReward,

1484    function _calculateAccruedReward(
1485:     uint256 principal,

1500    function _calculateStakerReward(
1501:     address staker,

1546    function _distributeForfeitedReward(
1547:     uint256 forfeitedReward,

1579    function _calculateForfeitedRewardDistribution(
1580:     uint256 forfeitedReward,

1604    function _updateStakerRewardPerToken(
1605:     StakerReward memory stakerReward,

```
*GitHub*: [353](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L353-L354), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L400-L401), [494](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L494-L495), [1275](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1275-L1276), [1304](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1304-L1305), [1722](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1722-L1723), [312](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L312), [313](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L313), [314](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L314), [468](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L468), [567](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L567), [568](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L568), [589](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L589), [693](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L693), [728](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L728), [1025](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1025), [1028](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1028), [1161](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1161), [1180](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1180), [1386](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1386), [1583](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1583), [1732](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1732), [346](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L346-L347), [664](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L664-L665), [721](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L721-L722), [920](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L920-L921), [1012](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1012-L1013), [1042](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1042-L1043), [1152](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1152-L1153), [1175](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1175-L1176), [1193](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1193-L1194), [1269](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1269-L1270), [1298](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1298-L1299), [1323](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1323-L1324), [1382](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1382-L1383), [1404](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1404-L1405), [1423](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1423-L1424), [1444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1444-L1445), [1484](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1484-L1485), [1500](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1500-L1501), [1546](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1546-L1547), [1579](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1579-L1580), [1604](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1604-L1605)

```solidity
File: src/timelock/StakingTimelock.sol

55:       if (params.rewardVault == address(0)) revert InvalidZeroAddress();

56:       if (params.communityStakingPool == address(0)) revert InvalidZeroAddress();

57:       if (params.operatorStakingPool == address(0)) revert InvalidZeroAddress();

58:       if (params.alertsController == address(0)) revert InvalidZeroAddress();

```
*GitHub*: [55](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L55), [56](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L56), [57](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L57), [58](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L58)

```solidity
File: src/timelock/Timelock.sol

308     function hashOperationBatch(
309:      Call[] calldata calls,

332     function scheduleBatch(
333:      Call[] calldata calls,

401     function executeBatch(
402:      Call[] calldata calls,

```
*GitHub*: [308](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L308-L309), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L332-L333), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L401-L402)

</details>

### [N&#x2011;16] Top-level declarations should be separated by at least two lines


*There are 28 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

18      }
19    
20:     /// @notice Helper function for validating the migration target

```
*GitHub*: [18](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L18-L20)

```solidity
File: src/MigrationProxy.sol

77      }
78    
79:     /// @notice LINK transfer callback function called when transferAndCall is called with this

```
*GitHub*: [77](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L77-L79)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

316     }
317   
318:    /// @notice This function creates an alert for an unhealthy Chainlink feed

345     }
346   
347:    /// @notice This function returns true if the alerter may raise an alert

355     }
356   
357:    /// @notice This function returns the staking pools connected to this alerts controller

505     }
506   
507:    /// @notice Helper function to check whether an alerter can raise an alert

544     }
545   
546:    /// @notice Helper function for checking if this contract has the slasher role

549     }
550   
551:    /// @notice Helper function for setting the slashable operators of a feed

```
*GitHub*: [316](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L316-L318), [345](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L345-L347), [355](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L355-L357), [505](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L505-L507), [544](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L544-L546), [549](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L549-L551)

```solidity
File: src/pools/CommunityStakingPool.sol

101     }
102   
103:    /// @notice Util function that validates if a community staker has access to an

128     }
129   
130:    /// @notice This function sets the operator staking pool

```
*GitHub*: [101](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L101-L103), [128](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L128-L130)

```solidity
File: src/pools/OperatorStakingPool.sol

236     }
237   
238:    /// @notice Helper function to set the slasher config

305     }
306   
307:    /// @notice Helper function to slash operators

344     }
345   
346:    /// @notice Helper function to reward the alerter

369     }
370   
371:    /// @notice Helper function to return the current remaining slash capacity for a slasher

511     }
512   
513:    /// @notice Getter function to check if an address is registered as an operator

518     }
519   
520:    /// @notice Getter function to check if an address is a removed operator

525     }
526   
527:    /// @notice Getter function for a removed operator's total staked LINK amount

559     }
560   
561:    /// @notice This function allows the calling contract to

```
*GitHub*: [236](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L236-L238), [305](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L305-L307), [344](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L344-L346), [369](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L369-L371), [511](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L511-L513), [518](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L518-L520), [525](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L525-L527), [559](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L559-L561)

```solidity
File: src/pools/StakingPoolBase.sol

320     }
321   
322:    /// @notice LINK transfer callback function called when transferAndCall is called with this

642     }
643   
644:    /// @notice Util function for setting the unbonding period

654     }
655   
656:    /// @notice Util function for setting the claim period

```
*GitHub*: [320](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L320-L322), [642](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L642-L644), [654](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L654-L656)

```solidity
File: src/rewards/RewardVault.sol

263     }
264   
265:    /// @notice This struct is used for aggregating the return values of a function that calculates

1019    }
1020  
1021:   /// @notice Helper function to get a staker's current multiplier

1335    }
1336  
1337:   /// @notice Private util function for updateRewardPerToken

1360    }
1361  
1362:   /// @notice Util function for calculating the current reward per token for the pools

1567    }
1568  
1569:   /// @notice Helper function for calculating the available reward per token and the reclaimable

```
*GitHub*: [263](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L263-L265), [1019](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1019-L1021), [1335](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1335-L1337), [1360](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1360-L1362), [1567](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1567-L1569)

```solidity
File: src/timelock/Timelock.sol

274     }
275   
276:    /// @notice Returns the delay for an operation with a specific function selector to become valid.

478     }
479   
480:    /// @notice Sets the minimum timelock duration for a specific function selector

```
*GitHub*: [274](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L274-L276), [478](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L478-L480)

</details>

### [N&#x2011;17] Imports should use double quotes rather than single quotes


*There are 58 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

4:    import {IMigratable} from './interfaces/IMigratable.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L4)

```solidity
File: src/MigrationProxy.sol

6:    import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

10:   import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

12:   import {PausableWithAccessControl} from './PausableWithAccessControl.sol';

13:   import {CommunityStakingPool} from './pools/CommunityStakingPool.sol';

14:   import {OperatorStakingPool} from './pools/OperatorStakingPool.sol';

```
*GitHub*: [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L6), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L14)

```solidity
File: src/PausableWithAccessControl.sol

6:    import {Pausable} from '@openzeppelin/contracts/security/Pausable.sol';

8:    import {IPausable} from './interfaces/IPausable.sol';

```
*GitHub*: [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L6), [8](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L8)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

9:    import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

10:   import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

12:   import {IMigratable} from '../interfaces/IMigratable.sol';

13:   import {IMigrationDataReceiver} from '../interfaces/IMigrationDataReceiver.sol';

14:   import {Migratable} from '../Migratable.sol';

15:   import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';

16:   import {CommunityStakingPool} from '../pools/CommunityStakingPool.sol';

17:   import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

```
*GitHub*: [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L14), [15](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L15), [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L16), [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L17)

```solidity
File: src/pools/CommunityStakingPool.sol

9:    import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

11:   import {IMerkleAccessController} from '../interfaces/IMerkleAccessController.sol';

12:   import {OperatorStakingPool} from './OperatorStakingPool.sol';

13:   import {StakingPoolBase} from './StakingPoolBase.sol';

```
*GitHub*: [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L9), [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L11), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L13)

```solidity
File: src/pools/OperatorStakingPool.sol

9:    import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

10:   import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

12:   import {ISlashable} from '../interfaces/ISlashable.sol';

13:   import {IRewardVault} from '../interfaces/IRewardVault.sol';

14:   import {RewardVault} from '../rewards/RewardVault.sol';

15:   import {StakingPoolBase} from './StakingPoolBase.sol';

```
*GitHub*: [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L14), [15](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L15)

```solidity
File: src/pools/StakingPoolBase.sol

6:    import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

8:    import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

9:    import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

10:   import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

12:   import {IMigratable} from '../interfaces/IMigratable.sol';

13:   import {IRewardVault} from '../interfaces/IRewardVault.sol';

14:   import {IStakingOwner} from '../interfaces/IStakingOwner.sol';

15:   import {IStakingPool} from '../interfaces/IStakingPool.sol';

16:   import {Migratable} from '../Migratable.sol';

17:   import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';

```
*GitHub*: [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L6), [8](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L8), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L14), [15](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L15), [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L16), [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L17)

```solidity
File: src/rewards/RewardVault.sol

6:    import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

10:   import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

11:   import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

12:   import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

14:   import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';

16:   import {IMigratable} from '../interfaces/IMigratable.sol';

17:   import {IRewardVault} from '../interfaces/IRewardVault.sol';

18:   import {IStakingPool} from '../interfaces/IStakingPool.sol';

19:   import {Migratable} from '../Migratable.sol';

20:   import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';

21:   import {CommunityStakingPool} from '../pools/CommunityStakingPool.sol';

22:   import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

```
*GitHub*: [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L6), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L10), [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L11), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L12), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L14), [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L16), [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L17), [18](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L18), [19](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L19), [20](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L20), [21](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L21), [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L22)

```solidity
File: src/timelock/StakingTimelock.sol

4:    import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';

6:    import {Timelock} from './Timelock.sol';

7:    import {PriceFeedAlertsController} from '../alerts/PriceFeedAlertsController.sol';

8:    import {IMigratable} from '../interfaces/IMigratable.sol';

9:    import {ISlashable} from '../interfaces/ISlashable.sol';

10:   import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

11:   import {StakingPoolBase} from '../pools/StakingPoolBase.sol';

12:   import {RewardVault} from '../rewards/RewardVault.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L4), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L6), [7](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L7), [8](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L8), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L10), [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L11), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L12)

```solidity
File: src/timelock/Timelock.sol

4:    import {AccessControlEnumerable} from '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

5:    import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L4), [5](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L5)

</details>

### [N&#x2011;18] Strings should use double quotes rather than single quotes
See the Solidity Style [Guide](https://docs.soliditylang.org/en/v0.8.20/style-guide.html#other-recommendations)

*There are 8 instances of this issue:*

```solidity
File: src/timelock/Timelock.sol

357:      require(!isOperation(id), 'Timelock: operation already scheduled');

358:      require(delay >= getMinDelay(calls), 'Timelock: insufficient delay');

375:      require(isOperationPending(id), 'Timelock: operation cannot be cancelled');

424:      require(success, 'Timelock: underlying transaction reverted');

433:      require(isOperationReady(id), 'Timelock: operation is not ready');

435:        predecessor == bytes32(0) || isOperationDone(predecessor), 'Timelock: missing dependency'

444:      require(isOperationReady(id), 'Timelock: operation is not ready');

486:      require(newDelay >= s_minDelay, 'Timelock: insufficient delay');

```
*GitHub*: [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L357), [358](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L358), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L375), [424](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L424), [433](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L433), [435](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L435), [444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L444), [486](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L486)


### [N&#x2011;19] Consider using `delete` rather than assigning zero/false to clear values
The `delete` keyword more closely matches the semantics of what is being done, and draws more attention to the changing of state, which may lead to a more thorough audit of its associated logic

*There are 2 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

500:        operator.isOperator = false;

547:      s_operators[msg.sender].removedPrincipal = 0;

```
*GitHub*: [500](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L500), [547](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L547)


### [N&#x2011;20] Contracts should have full test coverage
While 100% code coverage does not guarantee that there are no bugs, it often will catch easy-to-find bugs, and will ensure that there are fewer regressions when the code invariably has to be modified. Furthermore, in order to get full coverage, code authors will often have to re-organize their code so that it is more modular, so that each component can be tested separately, which reduces interdependencies between modules and layers, and makes for code that is easier to reason about and audit.

*There is one instance of this issue:*

```solidity
File: Various Files


```


### [N&#x2011;21] Consider adding formal verification proofs
Consider using formal verification to mathematically prove that your code does what is intended, and does not have any edge cases with unexpected behavior. The solidity compiler itself has this functionality [built in](https://docs.soliditylang.org/en/latest/smtchecker.html#smtchecker-and-formal-verification)

*There is one instance of this issue:*

```solidity
File: Various Files


```


### [N&#x2011;22] Multiple `address`/ID mappings can be combined into a single `mapping` of an `address`/ID to a `struct`, for readability
Well-organized data structures make code reviews easier, which may lead to fewer bugs. Consider combining related mappings into mappings to structs, so it's clear what data is related

*There are 2 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

224     mapping(address => FeedConfig) private s_feedConfigs;
225     /// @notice The slashable operators of each feed
226     mapping(address => address[]) private s_feedSlashableOperators;
227     /// @notice The round ID of the last feed round an alert was raised
228:    mapping(address => uint256) private s_lastAlertedRoundIds;

```
*GitHub*: [224](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L224-L228)

```solidity
File: src/pools/OperatorStakingPool.sol

126     mapping(address => Operator) private s_operators;
127     /// @notice Mapping of the slashers to slasher config struct.
128     mapping(address => ISlashable.SlasherConfig) private s_slasherConfigs;
129     /// @notice Mapping of slashers to slasher state struct.
130:    mapping(address => ISlashable.SlasherState) private s_slasherState;

```
*GitHub*: [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L126-L130)


### [N&#x2011;23] Custom errors should be used rather than `revert()`/`require()`
Custom errors are available from solidity version 0.8.4. Custom errors are more easily processed in `try`-`catch` blocks, and are easier to re-use and maintain.

*There are 8 instances of this issue:*

```solidity
File: src/timelock/Timelock.sol

357:      require(!isOperation(id), 'Timelock: operation already scheduled');

358:      require(delay >= getMinDelay(calls), 'Timelock: insufficient delay');

375:      require(isOperationPending(id), 'Timelock: operation cannot be cancelled');

424:      require(success, 'Timelock: underlying transaction reverted');

433:      require(isOperationReady(id), 'Timelock: operation is not ready');

434       require(
435         predecessor == bytes32(0) || isOperationDone(predecessor), 'Timelock: missing dependency'
436:      );

444:      require(isOperationReady(id), 'Timelock: operation is not ready');

486:      require(newDelay >= s_minDelay, 'Timelock: insufficient delay');

```
*GitHub*: [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L357), [358](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L358), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L375), [424](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L424), [433](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L433), [434](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L434-L436), [444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L444), [486](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L486)


### [N&#x2011;24] Array indicies should be referenced via `enum`s rather than via numeric literals


*There are 3 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

246:       setFeedConfigParams[0] = SetFeedConfigParams({

361:     pools[0] = address(s_operatorStakingPool);

362:     pools[1] = address(s_communityStakingPool);

```
*GitHub*: [246](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L246-L246), [361](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L361-L361), [362](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L362-L362)


### [N&#x2011;25] Events are missing sender information
When an action is triggered based on a user's action, not being able to filter based on who triggered the action makes event processing a lot more cumbersome. Including the `msg.sender` the events of these types of action will make events much more useful to end users, especially when `msg.sender` is not `tx.origin`.

*There are 49 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

17:      emit MigrationTargetSet(oldMigrationTarget, newMigrationTarget);

```
*GitHub*: [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L17-L17)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

269:     emit CommunityStakingPoolSet(address(oldCommunityStakingPool), address(newCommunityStakingPool));

282:     emit OperatorStakingPoolSet(address(oldOperatorStakingPool), address(newOperatorStakingPool));

308:     emit FeedConfigRemoved(feed);

408:     emit AlertsControllerMigrated(s_migrationTarget);

453:       emit FeedConfigRemoved(feed);

460:     emit MigrationDataSent(s_migrationTarget, feeds, migrationData);

497        emit FeedConfigSet(
498          configParams.feed,
499          configParams.priorityPeriodThreshold,
500          configParams.regularPeriodThreshold,
501          configParams.slashableAmount,
502          configParams.alerterRewardAmount
503:       );

565:     emit SlashableOperatorsSet(feed, operators);

```
*GitHub*: [269](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L269-L269), [282](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L282-L282), [308](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L308-L308), [408](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L408-L408), [453](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L453-L453), [460](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L460-L460), [497](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L497-L503), [565](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L565-L565)

```solidity
File: src/pools/CommunityStakingPool.sol

122:     emit MerkleRootChanged(newMerkleRoot);

140:     emit OperatorStakingPoolChanged(oldOperatorStakingPool, address(newOperatorStakingPool));

```
*GitHub*: [122](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L122-L122), [140](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L140-L140)

```solidity
File: src/pools/OperatorStakingPool.sol

164:     emit AlerterRewardDeposited(amount, s_alerterRewardFunds);

182:     emit AlerterRewardWithdrawn(amount, s_alerterRewardFunds);

253:     emit SlasherConfigSet(slasher, config.refillRate, config.slashCapacity);

338:       emit Slashed(operators[i], slashedAmount, updatedPrincipal);

364:     emit AlertingRewardPaid(alerter, alerterRewardActual, alerterRewardAmount);

454:       emit OperatorAdded(operatorAddress);

507:       emit OperatorRemoved(operatorAddress, principal);

```
*GitHub*: [164](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L164-L164), [182](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L182-L182), [253](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L253-L253), [338](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L338-L338), [364](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L364-L364), [454](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L454-L454), [507](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L507-L507)

```solidity
File: src/pools/StakingPoolBase.sol

252:     emit StakerMigrated(s_migrationTarget, stakerPrincipal, migrationData);

319:     emit RewardVaultSet(oldRewardVault, address(newRewardVault));

362:       emit UnbondingPeriodReset(staker);

418:     emit PoolOpened();

428:     emit PoolClosed();

441:     emit MigrationProxySet(migrationProxy);

636:       emit PoolSizeIncreased(maxPoolSize);

640:       emit MaxPrincipalAmountIncreased(maxPrincipalPerStaker);

653:     emit UnbondingPeriodSet(oldUnbondingPeriod, unbondingPeriod);

665:     emit ClaimPeriodSet(oldClaimPeriod, claimPeriod);

```
*GitHub*: [252](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L252-L252), [319](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L319-L319), [362](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L362-L362), [418](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L418-L418), [428](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L428-L428), [441](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L441-L441), [636](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L636-L636), [640](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L640-L640), [653](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L653-L653), [665](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L665-L665)

```solidity
File: src/rewards/RewardVault.sol

321:     emit DelegationRateDenominatorSet(0, params.delegationRateDenominator);

324:     emit MultiplierDurationSet(0, params.initialMultiplierDuration);

327:     emit VaultOpened();

372:     emit RewardAdded(pool, amount, emissionRate);

447:     emit DelegationRateDenominatorSet(oldDelegationRateDenominator, newDelegationRateDenominator);

461:     emit MultiplierDurationSet(oldMultiplierDuration, newMultiplierDuration);

473:     emit MigrationSourceSet(oldMigrationSource, newMigrationSource);

539:     emit VaultMigrated(s_migrationTarget, totalUnvestedRewards, totalEmissionRate);

680:     emit RewardClaimed(staker, claimableReward);

704      emit StakerRewardUpdated(
705        staker,
706        stakerReward.finalizedBaseReward,
707        stakerReward.finalizedDelegatedReward,
708        stakerReward.baseRewardPerToken,
709        stakerReward.operatorDelegatedRewardPerToken,
710        stakerReward.claimedBaseRewardsInPeriod
711:     );

776:     emit RewardFinalized(staker, shouldForfeit);

777      emit StakerRewardUpdated(
778        staker,
779        stakerReward.finalizedBaseReward,
780        stakerReward.finalizedDelegatedReward,
781        stakerReward.baseRewardPerToken,
782        stakerReward.operatorDelegatedRewardPerToken,
783        stakerReward.claimedBaseRewardsInPeriod
784:     );

799:     emit VaultClosed(totalUnvestedRewards);

1354       emit PoolRewardUpdated(
1355         s_rewardBuckets.communityBase.vestedRewardPerToken,
1356         s_rewardBuckets.operatorBase.vestedRewardPerToken,
1357         s_rewardBuckets.operatorDelegated.vestedRewardPerToken
1358:      );

1562     emit ForfeitedRewardDistributed(
1563       vestedReward, vestedRewardPerToken, reclaimableReward, toOperatorPool
1564:    );

```
*GitHub*: [321](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L321-L321), [324](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L324-L324), [327](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L327-L327), [372](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L372-L372), [447](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L447-L447), [461](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L461-L461), [473](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L473-L473), [539](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L539-L539), [680](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L680-L680), [704](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L704-L711), [776](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L776-L776), [777](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L777-L784), [799](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L799-L799), [1354](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1354-L1358), [1562](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1562-L1564)

```solidity
File: src/timelock/Timelock.sol

198:     emit MinDelayChange(0, minDelay);

342        emit CallScheduled(
343          id, i, calls[i].target, calls[i].value, calls[i].data, predecessor, salt, delay
344:       );

378:     emit Cancelled(id);

412:       emit CallExecuted(id, i, calls[i].target, calls[i].value, calls[i].data);

462:     emit MinDelayChange(oldDelay, newDelay);

489:     emit MinDelayChange(target, selector, oldDelay, newDelay);

```
*GitHub*: [198](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L198-L198), [342](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L342-L344), [378](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L378-L378), [412](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L412-L412), [462](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L462-L462), [489](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L489-L489)

</details>

### [N&#x2011;26] Variable names for `immutable`s should use CONSTANT_CASE
For `immutable` variable names, each word should use all capital letters, with underscores separating each word (CONSTANT_CASE)

*There are 13 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

55:    LinkTokenInterface private immutable i_LINK;

57:    address private immutable i_v01StakingAddress;

59:    OperatorStakingPool private immutable i_operatorStakingPool;

61:    CommunityStakingPool private immutable i_communityStakingPool;

```
*GitHub*: [55](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L55-L55), [57](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L57-L57), [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L59-L59), [61](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L61-L61)

```solidity
File: src/pools/OperatorStakingPool.sol

138:   uint256 private immutable i_minInitialOperatorCount;

```
*GitHub*: [138](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L138-L138)

```solidity
File: src/pools/StakingPoolBase.sol

173:   LinkTokenInterface internal immutable i_LINK;

185:   uint96 internal immutable i_minPrincipalPerStaker;

187:   uint32 private immutable i_minClaimPeriod;

189:   uint32 private immutable i_maxClaimPeriod;

191:   uint32 private immutable i_maxUnbondingPeriod;

```
*GitHub*: [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L173-L173), [185](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L185-L185), [187](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L187-L187), [189](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L189-L189), [191](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L191-L191)

```solidity
File: src/rewards/RewardVault.sol

290:   LinkTokenInterface private immutable i_LINK;

292:   CommunityStakingPool private immutable i_communityStakingPool;

294:   OperatorStakingPool private immutable i_operatorStakingPool;

```
*GitHub*: [290](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L290-L290), [292](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L292-L292), [294](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L294-L294)


### [N&#x2011;27] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/a/145555) to make it easier to understand the purpose of each mapping

*There are 11 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

224:   mapping(address => FeedConfig) private s_feedConfigs;

226:   mapping(address => address[]) private s_feedSlashableOperators;

228:   mapping(address => uint256) private s_lastAlertedRoundIds;

```
*GitHub*: [224](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L224-L224), [226](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L226-L226), [228](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L228-L228)

```solidity
File: src/pools/OperatorStakingPool.sol

126:   mapping(address => Operator) private s_operators;

128:   mapping(address => ISlashable.SlasherConfig) private s_slasherConfigs;

130:   mapping(address => ISlashable.SlasherState) private s_slasherState;

```
*GitHub*: [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L126-L126), [128](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L128-L128), [130](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L130-L130)

```solidity
File: src/pools/StakingPoolBase.sol

179:   mapping(address => IStakingPool.Staker) internal s_stakers;

```
*GitHub*: [179](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L179-L179)

```solidity
File: src/rewards/RewardVault.sol

307:   mapping(address => StakerReward) private s_rewards;

```
*GitHub*: [307](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L307-L307)

```solidity
File: src/timelock/Timelock.sol

142:   mapping(bytes32 => uint256) private s_timestamps;

151:   mapping(address => mapping(bytes4 => uint256)) private s_delays;

```
*GitHub*: [142](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L142-L142), [151](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L151-L151), [151](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L151-L151)


### [N&#x2011;28] Non-`external`/`public` variable names should begin with an underscore
According to the Solidity Style Guide, non-`external`/`public` variable names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)

*There are 44 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

8:     address internal s_migrationTarget;

```
*GitHub*: [8](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L8-L8)

```solidity
File: src/MigrationProxy.sol

55:    LinkTokenInterface private immutable i_LINK;

57:    address private immutable i_v01StakingAddress;

59:    OperatorStakingPool private immutable i_operatorStakingPool;

61:    CommunityStakingPool private immutable i_communityStakingPool;

```
*GitHub*: [55](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L55-L55), [57](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L57-L57), [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L59-L59), [61](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L61-L61)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

220:   CommunityStakingPool private s_communityStakingPool;

222:   OperatorStakingPool private s_operatorStakingPool;

224:   mapping(address => FeedConfig) private s_feedConfigs;

226:   mapping(address => address[]) private s_feedSlashableOperators;

228:   mapping(address => uint256) private s_lastAlertedRoundIds;

```
*GitHub*: [220](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L220-L220), [222](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L222-L222), [224](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L224-L224), [226](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L226-L226), [228](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L228-L228)

```solidity
File: src/pools/CommunityStakingPool.sol

41:    OperatorStakingPool private s_operatorStakingPool;

44:    bytes32 private s_merkleRoot;

```
*GitHub*: [41](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L41-L41), [44](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L44-L44)

```solidity
File: src/pools/OperatorStakingPool.sol

126:   mapping(address => Operator) private s_operators;

128:   mapping(address => ISlashable.SlasherConfig) private s_slasherConfigs;

130:   mapping(address => ISlashable.SlasherState) private s_slasherState;

132:   uint256 private s_numOperators;

135:   uint256 private s_alerterRewardFunds;

138:   uint256 private immutable i_minInitialOperatorCount;

```
*GitHub*: [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L126-L126), [128](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L128-L128), [130](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L130-L130), [132](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L132-L132), [135](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L135-L135), [138](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L138-L138)

```solidity
File: src/pools/StakingPoolBase.sol

173:   LinkTokenInterface internal immutable i_LINK;

175:   uint32 private constant MIN_UNBONDING_PERIOD = 1;

177:   Pool internal s_pool;

179:   mapping(address => IStakingPool.Staker) internal s_stakers;

181:   address internal s_migrationProxy;

183:   IRewardVault internal s_rewardVault;

185:   uint96 internal immutable i_minPrincipalPerStaker;

187:   uint32 private immutable i_minClaimPeriod;

189:   uint32 private immutable i_maxClaimPeriod;

191:   uint32 private immutable i_maxUnbondingPeriod;

193:   uint32 private s_checkpointId;

195:   bool internal s_isOpen;

```
*GitHub*: [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L173-L173), [175](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L175-L175), [177](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L177-L177), [179](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L179-L179), [181](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L181-L181), [183](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L183-L183), [185](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L185-L185), [187](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L187-L187), [189](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L189-L189), [191](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L191-L191), [193](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L193-L193), [195](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L195-L195)

```solidity
File: src/rewards/RewardVault.sol

288:   uint256 private constant MAX_MULTIPLIER = 1e18;

290:   LinkTokenInterface private immutable i_LINK;

292:   CommunityStakingPool private immutable i_communityStakingPool;

294:   OperatorStakingPool private immutable i_operatorStakingPool;

296:   RewardBuckets private s_rewardBuckets;

298:   VaultConfig private s_vaultConfig;

301:   VestingCheckpointData private s_finalVestingCheckpointData;

303:   uint256 private s_rewardPerTokenUpdatedAt;

305:   address private s_migrationSource;

307:   mapping(address => StakerReward) private s_rewards;

```
*GitHub*: [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L288-L288), [290](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L290-L290), [292](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L292-L292), [294](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L294-L294), [296](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L296-L296), [298](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L298-L298), [301](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L301-L301), [303](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L303-L303), [305](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L305-L305), [307](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L307-L307)

```solidity
File: src/timelock/StakingTimelock.sol

50:    uint256 private constant DELAY_ONE_MONTH = 31 days;

```
*GitHub*: [50](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L50-L50)

```solidity
File: src/timelock/Timelock.sol

142:   mapping(bytes32 => uint256) private s_timestamps;

146:   uint256 private s_minDelay;

151:   mapping(address => mapping(bytes4 => uint256)) private s_delays;

```
*GitHub*: [142](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L142-L142), [146](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L146-L146), [151](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L151-L151)

</details>

### [N&#x2011;29] Use of `override` is unnecessary
Starting with Solidity version [0.8.8](https://docs.soliditylang.org/en/v0.8.20/contracts.html#function-overriding), using the `override` keyword when the function solely overrides an interface function, and the function doesn't exist in multiple base contracts, is unnecessary.

*There are 61 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

11:    function setMigrationTarget(address newMigrationTarget) external virtual override {

32:    function getMigrationTarget() external view virtual override returns (address) {

```
*GitHub*: [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L11-L11), [32](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L32-L32)

```solidity
File: src/MigrationProxy.sol

91     function onTokenTransfer(
92       address source,
93       uint256 amount,
94       bytes calldata data
95:    ) external override whenNotPaused validateFromLINK {

156:   function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

165:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [91](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L91-L95), [156](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L156-L156), [165](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L165-L165)

```solidity
File: src/PausableWithAccessControl.sol

22:    function emergencyPause() external override onlyRole(PAUSER_ROLE) {

27:    function emergencyUnpause() external override onlyRole(PAUSER_ROLE) {

```
*GitHub*: [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L22-L22), [27](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L27-L27)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

399    function migrate(bytes calldata)
400      external
401      override(IMigratable)
402      onlyRole(DEFAULT_ADMIN_ROLE)
403      withSlasherRole
404      validateMigrationTargetSet
405:   {

416    function _validateMigrationTarget(address newMigrationTarget)
417      internal
418      override(Migratable)
419      onlyRole(DEFAULT_ADMIN_ROLE)
420:   {

580:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [399](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L399-L405), [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L416-L420), [580](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L580-L580)

```solidity
File: src/pools/CommunityStakingPool.sol

59     function _validateOnTokenTransfer(
60       address sender,
61       address staker,
62       bytes calldata data
63:    ) internal view override {

85:    function _handleOpen() internal view override(StakingPoolBase) {

96     function hasAccess(
97       address staker,
98       bytes32[] calldata proof
99:    ) external view override returns (bool) {

120:   function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE) {

126:   function getMerkleRoot() external view override returns (bytes32) {

148:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L59-L63), [85](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L85-L85), [96](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L96-L99), [120](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L120-L120), [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L126-L126), [148](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L148-L148)

```solidity
File: src/pools/OperatorStakingPool.sol

204    function grantRole(
205      bytes32 role,
206      address account
207:   ) public virtual override(AccessControlDefaultAdminRules) {

218    function addSlasher(
219      address slasher,
220      SlasherConfig calldata config
221:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

228    function setSlasherConfig(
229      address slasher,
230      SlasherConfig calldata config
231:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

257:   function getSlasherConfig(address slasher) external view override returns (SlasherConfig memory) {

262:   function getSlashCapacity(address slasher) external view override returns (uint256) {

277    function slashAndReward(
278      address[] calldata stakers,
279      address alerter,
280      uint256 principalAmount,
281      uint256 alerterRewardAmount
282:   ) external override onlySlasher whenActive {

393:   function _validateOnTokenTransfer(address, address staker, bytes calldata) internal view override {

400    function setPoolConfig(
401      uint256 maxPoolSize,
402      uint256 maxPrincipalPerStaker
403    )
404      external
405      override
406      validatePoolSpace(maxPoolSize, maxPrincipalPerStaker, s_numOperators)
407      whenOpen
408      onlyRole(DEFAULT_ADMIN_ROLE)
409:   {

414:   function _handleOpen() internal view override(StakingPoolBase) {

567:   function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

602:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [204](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L204-L207), [218](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L218-L221), [228](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L228-L231), [257](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L257-L257), [262](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L262-L262), [277](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L277-L282), [393](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L393-L393), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L400-L409), [414](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L414-L414), [567](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L567-L567), [602](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L602-L602)

```solidity
File: src/pools/StakingPoolBase.sol

230    function migrate(bytes calldata data)
231      external
232      override(IMigratable)
233      whenClosed
234      validateMigrationTargetSet
235      validateRewardVaultSet
236:   {

258    function _validateMigrationTarget(address newMigrationTarget)
259      internal
260      override(Migratable)
261      onlyRole(DEFAULT_ADMIN_ROLE)
262:   {

332    function onTokenTransfer(
333      address sender,
334      uint256 amount,
335      bytes calldata data
336    )
337      external
338      override
339      validateFromLINK
340      validateMigrationProxySet
341      whenOpen
342      whenRewardVaultOpen
343      whenNotPaused
344:   {

400    function setPoolConfig(
401      uint256 maxPoolSize,
402      uint256 maxPrincipalPerStaker
403:   ) external virtual override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

409    function open()
410      external
411      override(IStakingOwner)
412      onlyRole(DEFAULT_ADMIN_ROLE)
413      whenBeforeOpening
414      validateRewardVaultSet
415      whenRewardVaultOpen
416:   {

425:   function close() external override(IStakingOwner) onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

436:   function setMigrationProxy(address migrationProxy) external override onlyRole(DEFAULT_ADMIN_ROLE) {

459:   function unstake(uint256 amount, bool shouldClaimReward) external override {

508:   function getTotalPrincipal() external view override returns (uint256) {

513:   function getStakerPrincipal(address staker) external view override returns (uint256) {

522    function getStakerPrincipalAt(
523      address staker,
524      uint256 checkpointId
525:   ) external view override returns (uint256) {

532:   function getStakerStakedAtTime(address staker) external view override returns (uint256) {

541    function getStakerStakedAtTimeAt(
542      address staker,
543      uint256 checkpointId
544:   ) external view override returns (uint256) {

551:   function getRewardVault() external view override returns (IRewardVault) {

556:   function getChainlinkToken() external view override returns (address) {

561:   function getMigrationProxy() external view override returns (address) {

566:   function isOpen() external view override returns (bool) {

571:   function isActive() public view override returns (bool) {

576:   function getStakerLimits() external view override returns (uint256, uint256) {

581:   function getMaxPoolSize() external view override returns (uint256) {

```
*GitHub*: [230](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L230-L236), [258](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L258-L262), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L332-L344), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L400-L403), [409](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L409-L416), [425](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L425-L425), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L436-L436), [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L459-L459), [508](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L508-L508), [513](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L513-L513), [522](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L522-L525), [532](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L532-L532), [541](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L541-L544), [551](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L551-L551), [556](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L556-L556), [561](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L561-L561), [566](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L566-L566), [571](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L571-L571), [576](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L576-L576), [581](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L581-L581)

```solidity
File: src/rewards/RewardVault.sol

488    function _validateMigrationTarget(address newMigrationTarget)
489      internal
490      override(Migratable)
491      onlyRole(DEFAULT_ADMIN_ROLE)
492:   {

509    function migrate(bytes calldata data)
510      external
511      override(IMigratable)
512      onlyRole(DEFAULT_ADMIN_ROLE)
513      whenOpen
514      validateMigrationTargetSet
515:   {

552:   function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

566:   function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external override {

623:   function claimReward() external override whenNotPaused returns (uint256) {

687:   function updateReward(address staker, uint256 stakerPrincipal) external override onlyStakingPool {

721    function finalizeReward(
722      address staker,
723      uint256 oldPrincipal,
724      uint256 stakedAt,
725      uint256 unstakedAmount,
726      bool shouldClaim
727:   ) external override onlyStakingPool returns (uint256) {

793:   function close() external override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

803:   function getReward(address staker) external view override returns (uint256) {

819:   function isOpen() external view override returns (bool) {

824:   function hasRewardDurationEnded(address stakingPool) external view override returns (bool) {

837:   function getStoredReward(address staker) external view override returns (StakerReward memory) {

904:   function isPaused() external view override(IRewardVault) returns (bool) {

1741:  function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [488](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L488-L492), [509](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L509-L515), [552](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L552-L552), [566](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L566-L566), [623](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L623-L623), [687](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L687-L687), [721](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L721-L727), [793](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L793-L793), [803](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L803-L803), [819](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L819-L819), [824](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L824-L824), [837](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L837-L837), [904](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L904-L904), [1741](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1741-L1741)

</details>

### [N&#x2011;30] Array is `push()`ed but not `pop()`ed
Array entries are added but are never removed. Consider whether this should be the case, or whether there should be a maximum, or whether old entries should be removed. Cases where there are specific potential problems will be flagged separately under a different issue.

*There is one instance of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

742      staker.history.push(
743        s_checkpointId++,
744        (uint224(uint112(latestPrincipal)) << 112) | uint224(uint112(latestStakedAtTime))
745:     );

```
*GitHub*: [742](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L742-L745)


### [N&#x2011;31] Unused `error` definition
Note that there may be cases where an error superficially appears to be used, but this is only because there are multiple definitions of the error in different files. In such cases, the error definition should be moved into a separate file. The instances below are the unused definitions.

*There are 2 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

47:    error InvalidPoolStatus(bool currentStatus, bool requiredStatus);

```
*GitHub*: [47](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L47-L47)

```solidity
File: src/rewards/RewardVault.sol

92:    error InvalidStaker(address stakerArg, address msgSender);

```
*GitHub*: [92](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L92-L92)


### [N&#x2011;32] Unused import
The identifier is imported but never used within the file

*There are 7 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

/// @audit IERC165
10:  import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

```
*GitHub*: [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L10-L10)

```solidity
File: src/pools/CommunityStakingPool.sol

/// @audit ERC677ReceiverInterface
4:   import {ERC677ReceiverInterface} from

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L4-L4)

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit RewardVault
14:  import {RewardVault} from '../rewards/RewardVault.sol';

```
*GitHub*: [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L14-L14)

```solidity
File: src/timelock/StakingTimelock.sol

/// @audit IAccessControl
4:   import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';

/// @audit PriceFeedAlertsController
7:   import {PriceFeedAlertsController} from '../alerts/PriceFeedAlertsController.sol';

/// @audit OperatorStakingPool
10:  import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

/// @audit RewardVault
12:  import {RewardVault} from '../rewards/RewardVault.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L4-L4), [7](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L7-L7), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L10-L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L12-L12)


### [N&#x2011;33] Consider using descriptive `constant`s when passing zero as a function argument
Passing zero as a function argument can sometimes result in a security issue (e.g. passing zero as the slippage parameter). Consider using a `constant` variable with a descriptive name, so it's clear that the argument is intentionally being used, and for the right reasons.

*There are 7 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

503:       _updateStakerHistory({staker: staker, latestPrincipal: 0, latestStakedAtTime: 0});

552:     emit Unstaked(msg.sender, withdrawableAmount, 0);

```
*GitHub*: [503](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L503-L503), [552](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L552-L552)

```solidity
File: src/pools/StakingPoolBase.sol

248:     _updateStakerHistory({staker: staker, latestPrincipal: 0, latestStakedAtTime: 0});

365      s_rewardVault.finalizeReward({
366        staker: staker,
367        oldPrincipal: stakerPrincipal,
368        unstakedAmount: 0,
369        shouldClaim: false,
370        stakedAt: stakedAt
371:     });

```
*GitHub*: [248](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L248-L248), [365](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L365-L371)

```solidity
File: src/rewards/RewardVault.sol

321:     emit DelegationRateDenominatorSet(0, params.delegationRateDenominator);

324:     emit MultiplierDurationSet(0, params.initialMultiplierDuration);

```
*GitHub*: [321](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L321-L321), [324](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L324-L324)

```solidity
File: src/timelock/Timelock.sol

198:     emit MinDelayChange(0, minDelay);

```
*GitHub*: [198](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L198-L198)


### [N&#x2011;34] Constants in comparisons should appear on the left side
Doing so will prevent [typo bugs](https://www.moserware.com/2008/01/constants-on-left-are-better-but-this.html)

*There are 68 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

25:          || newMigrationTarget == s_migrationTarget || newMigrationTarget.code.length == 0

```
*GitHub*: [25](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L25-L25)

```solidity
File: src/MigrationProxy.sol

101:     if (stakerData.length == 0) {

```
*GitHub*: [101](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L101-L101)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

300:     if (s_feedConfigs[feed].priorityPeriodThreshold == 0) {

378:     if (config.priorityPeriodThreshold == 0) revert FeedDoesNotExist();

444:       if (s_feedConfigs[feed].priorityPeriodThreshold == 0) {

477:       if (configParams.priorityPeriodThreshold == 0) {

483:       if (configParams.slashableAmount == 0 || configParams.slashableAmount > operatorMaxPrincipal)

487:       if (configParams.alerterRewardAmount == 0) {

523:       !_hasSlasherRole() || feedConfig.priorityPeriodThreshold == 0

530:     if (principalInOperatorPool == 0 && principalInCommunityStakingPool == 0) return returnValues;

```
*GitHub*: [300](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L300-L300), [378](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L378-L378), [444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L444-L444), [477](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L477-L477), [483](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L483-L483), [487](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L487-L487), [523](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L523-L523), [530](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L530-L530), [530](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L530-L530)

```solidity
File: src/pools/OperatorStakingPool.sol

159:     if (amount == 0) revert InvalidAlerterRewardFundAmount();

242:     if (config.slashCapacity == 0 || config.refillRate == 0) {

544:     if (withdrawableAmount == 0) {

```
*GitHub*: [159](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L159-L159), [242](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L242-L242), [242](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L242-L242), [544](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L544-L544)

```solidity
File: src/pools/StakingPoolBase.sol

201:     if (params.minPrincipalPerStaker == 0) revert InvalidMinStakeAmount();

208:     if (params.minClaimPeriod == 0 || params.minClaimPeriod >= params.maxClaimPeriod) {

243:     if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

281:     if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

283:     if (staker.unbondingPeriodEndsAt != 0 && block.timestamp <= staker.claimPeriodEndsAt) {

345:     if (amount == 0) return;

359:     if (stakerState.unbondingPeriodEndsAt != 0) {

469:     if (amount == 0) revert UnstakeZeroAmount();

498:       latestStakedAtTime: updatedPrincipal == 0 ? 0 : block.timestamp

625:     if (maxPoolSize == 0 || maxPoolSize < configs.maxPoolSize) {

630:       maxPrincipalPerStaker == 0 || maxPrincipalPerStaker > maxPoolSize

704:     if (data.length == 0) revert InvalidData();

718:     return s_pool.state.closedAt != 0 || _inClaimPeriod(staker) || paused();

726:     if (staker.unbondingPeriodEndsAt == 0 || block.timestamp < staker.unbondingPeriodEndsAt) {

773:     if (s_pool.state.closedAt != 0) revert PoolHasBeenClosed();

779:     if (s_pool.state.closedAt != 0) revert PoolHasBeenClosed();

797:     if (s_pool.state.closedAt == 0) revert PoolNotClosed();

```
*GitHub*: [201](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L201-L201), [208](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L208-L208), [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L243-L243), [281](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L281-L281), [283](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L283-L283), [345](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L345-L345), [359](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L359-L359), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L469-L469), [498](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L498-L498), [625](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L625-L625), [630](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L630-L630), [704](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L704-L704), [718](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L718-L718), [726](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L726-L726), [773](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L773-L773), [779](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L779-L779), [797](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L797-L797)

```solidity
File: src/rewards/RewardVault.sol

396:     uint256 delegatedRate = newDelegationRateDenominator == 0

401:       delegatedRate == 0 && newDelegationRateDenominator != 0 && communityRateWithoutDelegation != 0

416:     if (newDelegationRateDenominator == 0) {

423:     } else if (newDelegationRateDenominator == 1) {

430:     } else if (unvestedRewards != 0) {

670:     if (claimableReward == 0) {

743:     bool shouldForfeit = unstakedAmount != 0;

755:     if (fullForfeitedRewardAmount != 0) {

951:     if (redistributedReward != 0) {

954:     if (reclaimableReward != 0) {

1025:    if (stakedAt == 0) return 0;

1028:    if (multiplierDuration == 0) return MAX_MULTIPLIER;

1091:    if (operatorPoolCheckpointId != 0) {

1095:    if (communityPoolCheckpointId != 0) {

1119:      isDelegated: s_vaultConfig.delegationRateDenominator != 0

1125:    if (emissionSplitData.communityRate != 0) {

1132:    if (emissionSplitData.operatorRate != 0) {

1139:    if (emissionSplitData.delegatedRate != 0) {

1180:    if (emissionRate == 0) return;

1234:    if (isDelegated && communityPoolShare != 0) {

1276:      rewardAmount != 0

1279:            operatorPoolShare != 0

1283:              communityPoolShare != 0

1306:        operatorPoolShare != 0

1310:          communityPoolShare != 0

1328:    if (communityReward != 0 && communityReward < delegationDenominator) {

1332:    if (communityRate != 0 && communityRate < delegationDenominator) {

1386:    if (totalPrincipal == 0) return rewardBucket.vestedRewardPerToken;

1554:    if (vestedRewardPerToken != 0) {

1583:    if (forfeitedReward == 0) return (0, 0, 0);

1589:    if (amountOfRecipientTokens != 0) {

1685:    if (addedRewardAmount != 0 && addedRewardAmount < s_vaultConfig.delegationRateDenominator) {

1692:    if (totalEmissionRate == 0 || totalEmissionRate < s_vaultConfig.delegationRateDenominator) {

```
*GitHub*: [396](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L396-L396), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L401-L401), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L401-L401), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L401-L401), [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L416-L416), [423](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L423-L423), [430](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L430-L430), [670](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L670-L670), [743](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L743-L743), [755](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L755-L755), [951](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L951-L951), [954](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L954-L954), [1025](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1025-L1025), [1028](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1028-L1028), [1091](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1091-L1091), [1095](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1095-L1095), [1119](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1119-L1119), [1125](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1125-L1125), [1132](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1132-L1132), [1139](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1139-L1139), [1180](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1180-L1180), [1234](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1234-L1234), [1276](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1276-L1276), [1279](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1279-L1279), [1283](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1283-L1283), [1306](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1306-L1306), [1310](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1310-L1310), [1328](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1328-L1328), [1332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1332-L1332), [1386](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1386-L1386), [1554](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1554-L1554), [1583](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1583-L1583), [1589](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1589-L1589), [1685](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1685-L1685), [1692](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1692-L1692)

```solidity
File: src/timelock/Timelock.sol

226:     return getTimestamp(id) != 0;

```
*GitHub*: [226](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L226-L226)

</details>

### [N&#x2011;35] Expressions for constant values should use `immutable` rather than `constant`
While it does not save gas for some simple binary expressions because the compiler knows that developers often make this mistake, it's still best to use the right tool for the task at hand. There is a difference between `constant` variables and `immutable` variables, and they should each be used in their appropriate contexts. `constants` should be used for literal values written into the code, and `immutable` variables should be used for expressions, or values calculated in, or passed into the constructor.

*There are 8 instances of this issue:*

```solidity
File: src/PausableWithAccessControl.sol

14:    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');

```
*GitHub*: [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L14-L14)

```solidity
File: src/pools/OperatorStakingPool.sol

142:   bytes32 public constant SLASHER_ROLE = keccak256('SLASHER_ROLE');

```
*GitHub*: [142](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L142-L142)

```solidity
File: src/rewards/RewardVault.sol

285:   bytes32 public constant REWARDER_ROLE = keccak256('REWARDER_ROLE');

```
*GitHub*: [285](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L285-L285)

```solidity
File: src/timelock/Timelock.sol

127:   bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

130:   bytes32 public constant PROPOSER_ROLE = keccak256('PROPOSER_ROLE');

133:   bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');

136:   bytes32 public constant CANCELLER_ROLE = keccak256('CANCELLER_ROLE');

139:   uint256 private constant _DONE_TIMESTAMP = uint256(1);

```
*GitHub*: [127](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L127-L127), [130](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L130-L130), [133](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L133-L133), [136](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L136-L136), [139](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L139-L139)


### [N&#x2011;36] Contract should expose an `interface`
The `contract`s should expose an `interface` so that other projects can more easily integrate with it, without having to develop their own non-standard variants.

*There are 51 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

137:   function getConfig() external view returns (address, address, address, address) {

```
*GitHub*: [137](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L137-L137)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

261    function setCommunityStakingPool(CommunityStakingPool newCommunityStakingPool)
262      external
263      onlyRole(DEFAULT_ADMIN_ROLE)
264:   {

274    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
275      external
276      onlyRole(DEFAULT_ADMIN_ROLE)
277:   {

288    function setFeedConfigs(SetFeedConfigParams[] calldata configs)
289      external
290      onlyRole(DEFAULT_ADMIN_ROLE)
291:   {

299:   function removeFeedConfig(address feed) external onlyRole(DEFAULT_ADMIN_ROLE) {

314:   function getFeedConfig(address feed) external view returns (FeedConfig memory) {

330:   function raiseAlert(address feed) external whenNotPaused {

352:   function canAlert(address alerter, address feed) external view returns (bool) {

359:   function getStakingPools() external view returns (address[] memory) {

371    function setSlashableOperators(
372      address[] calldata operators,
373      address feed
374:   ) external onlyRole(DEFAULT_ADMIN_ROLE) {

386:   function getSlashableOperators(address feed) external view returns (address[] memory) {

436    function sendMigrationData(address[] calldata feeds)
437      external
438      onlyRole(DEFAULT_ADMIN_ROLE)
439      validateMigrationTargetSet
440:   {

```
*GitHub*: [261](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L261-L264), [274](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L274-L277), [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L288-L291), [299](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L299-L299), [314](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L314-L314), [330](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L330-L330), [352](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L352-L352), [359](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L359-L359), [371](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L371-L374), [386](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L386-L386), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L436-L440)

```solidity
File: src/pools/CommunityStakingPool.sol

133    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
134      external
135      onlyRole(DEFAULT_ADMIN_ROLE)
136:   {

```
*GitHub*: [133](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L133-L136)

```solidity
File: src/pools/OperatorStakingPool.sol

154    function depositAlerterReward(uint256 amount)
155      external
156      onlyRole(DEFAULT_ADMIN_ROLE)
157      whenBeforeClosing
158:   {

173:   function withdrawAlerterReward(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {

187:   function getAlerterRewardFunds() external view returns (uint256) {

426    function addOperators(address[] calldata operators)
427      external
428      validateRewardVaultSet
429      validatePoolSpace(
430        s_pool.configs.maxPoolSize,
431        s_pool.configs.maxPrincipalPerStaker,
432        s_numOperators + operators.length
433      )
434      onlyRole(DEFAULT_ADMIN_ROLE)
435:   {

473    function removeOperators(address[] calldata operators)
474      external
475      onlyRole(DEFAULT_ADMIN_ROLE)
476      whenOpen
477:   {

516:   function isOperator(address staker) external view returns (bool) {

523:   function isRemoved(address staker) external view returns (bool) {

530:   function getRemovedPrincipal(address staker) external view returns (uint256) {

538:   function unstakeRemovedPrincipal() external {

557:   function getNumOperators() external view returns (uint256) {

```
*GitHub*: [154](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L154-L158), [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L173-L173), [187](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L187-L187), [426](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L426-L435), [473](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L473-L477), [516](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L516-L516), [523](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L523-L523), [530](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L530-L530), [538](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L538-L538), [557](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L557-L557)

```solidity
File: src/rewards/RewardVault.sol

346    function addReward(
347      address pool,
348      uint256 amount,
349      uint256 emissionRate
350:   ) external onlyRewarder whenOpen whenNotPaused {

377:   function getDelegationRateDenominator() external view returns (uint256) {

384    function setDelegationRateDenominator(uint256 newDelegationRateDenominator)
385      external
386      onlyRole(DEFAULT_ADMIN_ROLE)
387:   {

454    function setMultiplierDuration(uint256 newMultiplierDuration)
455      external
456      onlyRole(DEFAULT_ADMIN_ROLE)
457:   {

467:   function setMigrationSource(address newMigrationSource) external onlyRole(DEFAULT_ADMIN_ROLE) {

478:   function getMigrationSource() external view returns (address) {

843:   function getRewardBuckets() external view returns (RewardBuckets memory) {

849:   function getRewardPerTokenUpdatedAt() external view returns (uint256) {

855:   function getMultiplierDuration() external view returns (uint256) {

864:   function getMultiplier(address staker) external view returns (uint256) {

876    function calculateLatestStakerReward(address staker)
877      external
878      view
879      returns (StakerReward memory, uint256)
880:   {

886:   function getVestingCheckpointData() external view returns (VestingCheckpointData memory) {

894:   function getUnvestedRewards() external view returns (uint256, uint256, uint256) {

```
*GitHub*: [346](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L346-L350), [377](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L377-L377), [384](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L384-L387), [454](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L454-L457), [467](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L467-L467), [478](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L478-L478), [843](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L843-L843), [849](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L849-L849), [855](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L855-L855), [864](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L864-L864), [876](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L876-L880), [886](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L886-L886), [894](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L894-L894)

```solidity
File: src/timelock/Timelock.sol

217:   receive() external payable {}

225:   function isOperation(bytes32 id) public view virtual returns (bool) {

234:   function isOperationPending(bytes32 id) public view virtual returns (bool) {

243:   function isOperationReady(bytes32 id) public view virtual returns (bool) {

253:   function isOperationDone(bytes32 id) public view virtual returns (bool) {

263:   function getTimestamp(bytes32 id) public view virtual returns (uint256) {

272:   function getMinDelay() external view virtual returns (uint256) {

280:   function getMinDelay(address target, bytes4 selector) public view returns (uint256) {

288:   function getMinDelay(Call[] calldata calls) public view returns (uint256) {

308    function hashOperationBatch(
309      Call[] calldata calls,
310      bytes32 predecessor,
311      bytes32 salt
312:   ) public pure virtual returns (bytes32) {

332    function scheduleBatch(
333      Call[] calldata calls,
334      bytes32 predecessor,
335      bytes32 salt,
336      uint256 delay
337:   ) public virtual onlyRoleOrAdminRole(PROPOSER_ROLE) {

374:   function cancel(bytes32 id) external virtual onlyRoleOrAdminRole(CANCELLER_ROLE) {

401    function executeBatch(
402      Call[] calldata calls,
403      bytes32 predecessor,
404      bytes32 salt
405:   ) public payable virtual onlyRoleOrAdminRole(EXECUTOR_ROLE) {

459:   function updateDelay(uint256 newDelay) external virtual onlyRole(ADMIN_ROLE) {

469:   function updateDelay(UpdateDelayParams[] calldata params) external virtual onlyRole(ADMIN_ROLE) {

```
*GitHub*: [217](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L217-L217), [225](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L225-L225), [234](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L234-L234), [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L243-L243), [253](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L253-L253), [263](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L263-L263), [272](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L272-L272), [280](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L280-L280), [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L288-L288), [308](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L308-L312), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L332-L337), [374](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L374-L374), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L401-L405), [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L459-L459), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L469-L469)


### [N&#x2011;37] Custom error has no error details
Consider adding parameters to the error to indicate which user or values caused the failure

*There are 35 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/MigrationProxy.sol

29:    error InvalidZeroAddress();

32:    error InvalidSourceAddress();

37:    error SenderNotLinkToken();

```
*GitHub*: [29](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L29-L29), [32](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L32-L32), [37](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L37-L37)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

35:    error InvalidZeroAddress();

37:    error InvalidPriorityPeriodThreshold();

39:    error InvalidRegularPeriodThreshold();

42:    error DoesNotHaveSlasherRole();

49:    error FeedDoesNotExist();

51:    error InvalidOperatorList();

54:    error InvalidSlashableAmount();

56:    error InvalidAlerterRewardAmount();

59:    error AlertInvalid();

```
*GitHub*: [35](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L35-L35), [37](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L37-L37), [39](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L39-L39), [42](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L42-L42), [49](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L49-L49), [51](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L51-L51), [54](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L54-L54), [56](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L56-L56), [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L59-L59)

```solidity
File: src/pools/CommunityStakingPool.sol

22:    error MerkleRootNotSet();

```
*GitHub*: [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L22-L22)

```solidity
File: src/pools/OperatorStakingPool.sol

27:    error InvalidOperatorList();

29:    error StakerNotOperator();

59:    error InvalidAlerterRewardFundAmount();

```
*GitHub*: [27](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L27-L27), [29](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L29-L29), [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L59-L59)

```solidity
File: src/pools/StakingPoolBase.sol

44:    error PoolNotActive();

47:    error InvalidUnbondingPeriod();

50:    error InvalidClaimPeriod();

74:    error RewardVaultNotActive();

78:    error CannotClaimRewardWhenPaused();

```
*GitHub*: [44](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L44-L44), [47](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L47-L47), [50](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L50-L50), [74](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L74-L74), [78](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L78-L78)

```solidity
File: src/rewards/RewardVault.sol

49:    error InvalidPool();

52:    error InvalidRewardAmount();

55:    error InvalidEmissionRate();

58:    error InvalidDelegationRateDenominator();

62:    error InvalidMigrationSource();

67:    error AccessForbidden();

71:    error InvalidZeroAddress();

74:    error RewardDurationTooShort();

78:    error InsufficentRewardsForDelegationRate();

82:    error VaultAlreadyClosed();

86:    error NoRewardToClaim();

95:    error SenderNotLinkToken();

98:    error CannotClaimRewardWhenPaused();

```
*GitHub*: [49](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L49-L49), [52](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L52-L52), [55](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L55-L55), [58](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L58-L58), [62](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L62-L62), [67](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L67-L67), [71](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L71-L71), [74](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L74-L74), [78](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L78-L78), [82](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L82-L82), [86](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L86-L86), [95](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L95-L95), [98](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L98-L98)

```solidity
File: src/timelock/StakingTimelock.sol

24:    error InvalidZeroAddress();

```
*GitHub*: [24](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L24-L24)

</details>

### [N&#x2011;38] Events should use parameters to convey information
For example, rather than using `event Paused()` and `event Unpaused()`, use `event PauseState(address indexed whoChangedIt, bool wasPaused, bool isNowPaused)`

*There is one instance of this issue:*

```solidity
File: src/rewards/RewardVault.sol

114:   event VaultOpened();

```
*GitHub*: [114](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L114-L114)


### [N&#x2011;39] Events may be emitted out of order due to reentrancy
Ensure that events follow the best practice of check-effects-interaction, and are emitted before external calls

*There is one instance of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit receiveMigrationData() prior to emission
460:     emit MigrationDataSent(s_migrationTarget, feeds, migrationData);

```
*GitHub*: [460](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L460-L460)


### [N&#x2011;40] Empty function body
Consider adding a comment about why the function body is empty

*There is one instance of this issue:*

```solidity
File: src/PausableWithAccessControl.sol

16     constructor(
17       uint48 adminRoleTransferDelay,
18       address defaultAdmin
19:    ) AccessControlDefaultAdminRules(adminRoleTransferDelay, defaultAdmin) {}

```
*GitHub*: [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L16-L19)


### [N&#x2011;41] Consider bounding input array length
The functions below take in an unbounded array, and make function calls for entries in the array. While the function will revert if it eventually runs out of gas, it may be a nicer user experience to `require()` that the length of the array is below some reasonable maximum, so that the user doesn't have to use up a full transaction's gas only to see that the transaction reverts.

*There are 13 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

442      for (uint256 i; i < feeds.length; ++i) {
443        address feed = feeds[i];
444        if (s_feedConfigs[feed].priorityPeriodThreshold == 0) {
445          revert FeedDoesNotExist();
446        }
447        lastAlertedRoundIds[i] =
448          LastAlertedRoundId({feed: feed, roundId: s_lastAlertedRoundIds[feed]});
449  
450        // remove the feed config so future alerts can't be raised, and keep the last alerted round ID
451        // of the feed for reference
452        delete s_feedConfigs[feed];
453        emit FeedConfigRemoved(feed);
454:     }

474      for (uint256 i; i < configs.length; ++i) {
475        SetFeedConfigParams memory configParams = configs[i];
476        if (configParams.feed == address(0)) revert InvalidZeroAddress();
477        if (configParams.priorityPeriodThreshold == 0) {
478          revert InvalidPriorityPeriodThreshold();
479        }
480        if (configParams.regularPeriodThreshold < configParams.priorityPeriodThreshold) {
481          revert InvalidRegularPeriodThreshold();
482        }
483        if (configParams.slashableAmount == 0 || configParams.slashableAmount > operatorMaxPrincipal)
484        {
485          revert InvalidSlashableAmount();
486        }
487        if (configParams.alerterRewardAmount == 0) {
488          revert InvalidAlerterRewardAmount();
489        }
490  
491        FeedConfig storage config = s_feedConfigs[configParams.feed];
492        config.priorityPeriodThreshold = configParams.priorityPeriodThreshold;
493        config.regularPeriodThreshold = configParams.regularPeriodThreshold;
494        config.slashableAmount = configParams.slashableAmount;
495        config.alerterRewardAmount = configParams.alerterRewardAmount;
496  
497        emit FeedConfigSet(
498          configParams.feed,
499          configParams.priorityPeriodThreshold,
500          configParams.regularPeriodThreshold,
501          configParams.slashableAmount,
502          configParams.alerterRewardAmount
503        );
504:     }

555      for (uint256 i; i < operators.length; ++i) {
556        address operator = operators[i];
557        // verify input list is sorted and addresses are unique
558        if (i < operators.length - 1 && operator >= operators[i + 1]) {
559          revert InvalidOperatorList();
560        }
561        if (operator == address(0)) revert InvalidZeroAddress();
562:     }

```
*GitHub*: [442](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L442-L454), [474](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L474-L504), [555](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L555-L562)

```solidity
File: src/pools/OperatorStakingPool.sol

319      for (uint256 i; i < operators.length; ++i) {
320        staker = s_stakers[operators[i]];
321        uint224 history = staker.history.latest();
322        uint256 operatorPrincipal = uint112(history >> 112);
323        uint256 stakerStakedAtTime = uint112(history);
324        uint256 slashedAmount =
325          principalAmount > operatorPrincipal ? operatorPrincipal : principalAmount;
326        uint256 updatedPrincipal = operatorPrincipal - slashedAmount;
327  
328        // update the staker's rewards
329        s_rewardVault.updateReward(operators[i], operatorPrincipal);
330        _updateStakerHistory({
331          staker: staker,
332          latestPrincipal: updatedPrincipal,
333          latestStakedAtTime: stakerStakedAtTime
334        });
335  
336        totalSlashedAmount += slashedAmount;
337  
338        emit Slashed(operators[i], slashedAmount, updatedPrincipal);
339:     }

436      for (uint256 i; i < operators.length; ++i) {
437        address operatorAddress = operators[i];
438        IRewardVault.StakerReward memory stakerReward = s_rewardVault.getStoredReward(operatorAddress);
439        if (stakerReward.stakerType == IRewardVault.StakerType.COMMUNITY) {
440          revert OperatorCannotBeCommunityStaker(operatorAddress);
441        }
442        // verify input list is sorted and addresses are unique
443        if (i < operators.length - 1 && operatorAddress >= operators[i + 1]) {
444          revert InvalidOperatorList();
445        }
446        Operator storage operator = s_operators[operatorAddress];
447        if (operator.isOperator) {
448          revert OperatorAlreadyExists(operatorAddress);
449        }
450        if (operator.isRemoved) {
451          revert OperatorHasBeenRemoved(operatorAddress);
452        }
453        operator.isOperator = true;
454        emit OperatorAdded(operatorAddress);
455:     }

480      for (uint256 i; i < operators.length; ++i) {
481        address operatorAddress = operators[i];
482        operator = s_operators[operatorAddress];
483        if (!operator.isOperator) {
484          revert OperatorDoesNotExist(operatorAddress);
485        }
486  
487        staker = s_stakers[operatorAddress];
488        uint224 history = staker.history.latest();
489        uint256 principal = uint256(history >> 112);
490        uint256 stakedAtTime = uint112(history);
491        s_rewardVault.finalizeReward({
492          staker: operatorAddress,
493          oldPrincipal: principal,
494          unstakedAmount: principal,
495          shouldClaim: false,
496          stakedAt: stakedAtTime
497        });
498  
499        s_pool.state.totalPrincipal -= principal;
500        operator.isOperator = false;
501        operator.isRemoved = true;
502        // Reset the staker's stakedAtTime to 0 so their multiplier resets to 0.
503        _updateStakerHistory({staker: staker, latestPrincipal: 0, latestStakedAtTime: 0});
504        // move the operator's staked LINK amount to removedPrincipal that stops earning rewards
505        operator.removedPrincipal = principal;
506  
507        emit OperatorRemoved(operatorAddress, principal);
508:     }

```
*GitHub*: [319](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L319-L339), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L436-L455), [480](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L480-L508)

```solidity
File: src/timelock/Timelock.sol

181      for (uint256 i; i < proposersLength; ++i) {
182        _grantRole(PROPOSER_ROLE, proposers[i]);
183:     }

187      for (uint256 i; i < executorsLength; ++i) {
188        _grantRole(EXECUTOR_ROLE, executors[i]);
189:     }

193      for (uint256 i; i < cancellersLength; ++i) {
194        _grantRole(CANCELLER_ROLE, cancellers[i]);
195:     }

291      for (uint256 i; i < callsLength; ++i) {
292        uint256 selectorDelay = getMinDelay(calls[i].target, bytes4(calls[i].data[:4]));
293        if (selectorDelay > largestDelay) {
294          largestDelay = selectorDelay;
295        }
296:     }

341      for (uint256 i; i < callsLength; ++i) {
342        emit CallScheduled(
343          id, i, calls[i].target, calls[i].value, calls[i].data, predecessor, salt, delay
344        );
345:     }

410      for (uint256 i; i < callsLength; ++i) {
411        _execute(calls[i]);
412        emit CallExecuted(id, i, calls[i].target, calls[i].value, calls[i].data);
413:     }

471      for (uint256 i; i < paramsLength; ++i) {
472        _setDelay({
473          target: params[i].target,
474          selector: params[i].selector,
475          newDelay: params[i].newDelay
476        });
477:     }

```
*GitHub*: [181](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L181-L183), [187](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L187-L189), [193](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L193-L195), [291](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L291-L296), [341](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L341-L345), [410](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L410-L413), [471](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L471-L477)


### [N&#x2011;42] `if`-statement can be converted to a ternary
The code can be made more compact while also increasing readability by converting the following `if`-statements to ternaries (e.g. `foo += (x > y) ? a : b`)

*There are 2 instances of this issue:*

```solidity
File: src/rewards/RewardVault.sol

935      if (forfeitedRewardAmountTimesUnstakedAmount < oldPrincipal) {
936        forfeitedRewardAmount = fullForfeitedRewardAmount;
937      } else {
938        forfeitedRewardAmount = forfeitedRewardAmountTimesUnstakedAmount / oldPrincipal;
939:     }

1555       if (toOperatorPool) {
1556         s_rewardBuckets.operatorBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();
1557       } else {
1558         s_rewardBuckets.communityBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();
1559:      }

```
*GitHub*: [935](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L935-L939), [1555](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1555-L1559)


### [N&#x2011;43] Contract declarations should have NatSpec descriptions
e.g. `@dev` or `@notice`, and it must appear above the contract definition braces in order to be identified by the compiler as NatSpec

*There are 2 instances of this issue:*

```solidity
File: src/Migratable.sol

6    abstract contract Migratable is IMigratable {
7:     /// @notice The address of the new contract that this contract will be upgraded to.

```
*GitHub*: [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L6-L7)

```solidity
File: src/PausableWithAccessControl.sol

10   abstract contract PausableWithAccessControl is IPausable, Pausable, AccessControlDefaultAdminRules {
11     /// @notice This is the ID for the pauser role, which is given to the addresses that can pause and
12     /// unpause the contract.
13:    /// @dev Hash: 65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a

```
*GitHub*: [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L10-L13)


### [N&#x2011;44] Contract declarations should have NatSpec `@author` annotations


*There are 10 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

6    abstract contract Migratable is IMigratable {
7:     /// @notice The address of the new contract that this contract will be upgraded to.

```
*GitHub*: [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L6-L7)

```solidity
File: src/MigrationProxy.sol

22   contract MigrationProxy is
23     ERC677ReceiverInterface,
24     PausableWithAccessControl,
25     TypeAndVersionInterface
26   {
27     /// @notice This error is thrown whenever a zero-address is supplied when
28:    /// a non-zero address is required

```
*GitHub*: [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L22-L28)

```solidity
File: src/PausableWithAccessControl.sol

10   abstract contract PausableWithAccessControl is IPausable, Pausable, AccessControlDefaultAdminRules {
11     /// @notice This is the ID for the pauser role, which is given to the addresses that can pause and
12     /// unpause the contract.
13:    /// @dev Hash: 65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a

```
*GitHub*: [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L10-L13)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

26   contract PriceFeedAlertsController is
27     Migratable,
28     PausableWithAccessControl,
29     TypeAndVersionInterface
30:  {

```
*GitHub*: [26](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L26-L30)

```solidity
File: src/pools/CommunityStakingPool.sol

19   contract CommunityStakingPool is StakingPoolBase, IMerkleAccessController, TypeAndVersionInterface {
20     /// @notice This error is thrown when the pool is opened with an empty
21:    /// merkle root

```
*GitHub*: [19](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L19-L21)

```solidity
File: src/pools/OperatorStakingPool.sol

23:  contract OperatorStakingPool is ISlashable, StakingPoolBase, TypeAndVersionInterface {

```
*GitHub*: [23](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L23-L23)

```solidity
File: src/pools/StakingPoolBase.sol

33   abstract contract StakingPoolBase is
34     ERC677ReceiverInterface,
35     IStakingPool,
36     IStakingOwner,
37     Migratable,
38     PausableWithAccessControl
39:  {

```
*GitHub*: [33](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L33-L39)

```solidity
File: src/rewards/RewardVault.sol

38   contract RewardVault is
39     ERC677ReceiverInterface,
40     IRewardVault,
41     Migratable,
42     PausableWithAccessControl,
43     TypeAndVersionInterface
44:  {

```
*GitHub*: [38](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L38-L44)

```solidity
File: src/timelock/StakingTimelock.sol

21   contract StakingTimelock is Timelock {
22     /// @notice This error is thrown whenever a zero-address is supplied when
23:    /// a non-zero address is required

```
*GitHub*: [21](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L21-L23)

```solidity
File: src/timelock/Timelock.sol

41:  contract Timelock is AccessControlEnumerable {

```
*GitHub*: [41](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L41-L41)

</details>

### [N&#x2011;45] Contract declarations should have NatSpec `@title` annotations


*There are 10 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

6    abstract contract Migratable is IMigratable {
7:     /// @notice The address of the new contract that this contract will be upgraded to.

```
*GitHub*: [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L6-L7)

```solidity
File: src/MigrationProxy.sol

22   contract MigrationProxy is
23     ERC677ReceiverInterface,
24     PausableWithAccessControl,
25     TypeAndVersionInterface
26   {
27     /// @notice This error is thrown whenever a zero-address is supplied when
28:    /// a non-zero address is required

```
*GitHub*: [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L22-L28)

```solidity
File: src/PausableWithAccessControl.sol

10   abstract contract PausableWithAccessControl is IPausable, Pausable, AccessControlDefaultAdminRules {
11     /// @notice This is the ID for the pauser role, which is given to the addresses that can pause and
12     /// unpause the contract.
13:    /// @dev Hash: 65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a

```
*GitHub*: [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L10-L13)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

26   contract PriceFeedAlertsController is
27     Migratable,
28     PausableWithAccessControl,
29     TypeAndVersionInterface
30:  {

```
*GitHub*: [26](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L26-L30)

```solidity
File: src/pools/CommunityStakingPool.sol

19   contract CommunityStakingPool is StakingPoolBase, IMerkleAccessController, TypeAndVersionInterface {
20     /// @notice This error is thrown when the pool is opened with an empty
21:    /// merkle root

```
*GitHub*: [19](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L19-L21)

```solidity
File: src/pools/OperatorStakingPool.sol

23:  contract OperatorStakingPool is ISlashable, StakingPoolBase, TypeAndVersionInterface {

```
*GitHub*: [23](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L23-L23)

```solidity
File: src/pools/StakingPoolBase.sol

33   abstract contract StakingPoolBase is
34     ERC677ReceiverInterface,
35     IStakingPool,
36     IStakingOwner,
37     Migratable,
38     PausableWithAccessControl
39:  {

```
*GitHub*: [33](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L33-L39)

```solidity
File: src/rewards/RewardVault.sol

38   contract RewardVault is
39     ERC677ReceiverInterface,
40     IRewardVault,
41     Migratable,
42     PausableWithAccessControl,
43     TypeAndVersionInterface
44:  {

```
*GitHub*: [38](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L38-L44)

```solidity
File: src/timelock/StakingTimelock.sol

21   contract StakingTimelock is Timelock {
22     /// @notice This error is thrown whenever a zero-address is supplied when
23:    /// a non-zero address is required

```
*GitHub*: [21](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L21-L23)

```solidity
File: src/timelock/Timelock.sol

41:  contract Timelock is AccessControlEnumerable {

```
*GitHub*: [41](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L41-L41)

</details>

### [N&#x2011;46] Function declarations should have NatSpec descriptions


*There are 6 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

63     constructor(ConstructorParams memory params)
64       PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)
65:    {

```
*GitHub*: [63](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L63-L65)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

230    constructor(ConstructorParams memory params)
231      PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)
232:   {

```
*GitHub*: [230](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L230-L232)

```solidity
File: src/pools/CommunityStakingPool.sol

46:    constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams) {

```
*GitHub*: [46](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L46-L46)

```solidity
File: src/pools/OperatorStakingPool.sol

144:   constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams) {

```
*GitHub*: [144](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L144-L144)

```solidity
File: src/rewards/RewardVault.sol

309    constructor(ConstructorParams memory params)
310      PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)
311:   {

```
*GitHub*: [309](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L309-L311)

```solidity
File: src/timelock/StakingTimelock.sol

52     constructor(ConstructorParams memory params)
53       Timelock(params.minDelay, params.admin, params.proposers, params.executors, params.cancellers)
54:    {

```
*GitHub*: [52](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L52-L54)


### [N&#x2011;47] Missing checks for empty bytes when updating bytes state variables
Unless the code is attempting to 'delete' the state variable, the caller shouldn't have to write `""` to the state variable

*There is one instance of this issue:*

```solidity
File: src/pools/CommunityStakingPool.sol

121:     s_merkleRoot = newMerkleRoot;

```
*GitHub*: [121](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L121-L121)


### [N&#x2011;48] Consider moving `msg.sender` checks to a common authorization `modifier`


*There is one instance of this issue:*

```solidity
File: src/rewards/RewardVault.sol

699:       isOperator: msg.sender == address(i_operatorStakingPool),

```
*GitHub*: [699](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L699-L699)


### [N&#x2011;49] Setters should prevent re-setting of the same value
This especially problematic when the setter also emits the same value, which may be confusing to offline parsers

*There are 7 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

261    function setCommunityStakingPool(CommunityStakingPool newCommunityStakingPool)
262      external
263      onlyRole(DEFAULT_ADMIN_ROLE)
264    {
265      if (address(newCommunityStakingPool) == address(0)) revert InvalidZeroAddress();
266  
267      CommunityStakingPool oldCommunityStakingPool = s_communityStakingPool;
268      s_communityStakingPool = newCommunityStakingPool;
269      emit CommunityStakingPoolSet(address(oldCommunityStakingPool), address(newCommunityStakingPool));
270:   }

274    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
275      external
276      onlyRole(DEFAULT_ADMIN_ROLE)
277    {
278      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();
279  
280      OperatorStakingPool oldOperatorStakingPool = s_operatorStakingPool;
281      s_operatorStakingPool = newOperatorStakingPool;
282      emit OperatorStakingPoolSet(address(oldOperatorStakingPool), address(newOperatorStakingPool));
283:   }

```
*GitHub*: [261](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L261-L270), [274](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L274-L283)

```solidity
File: src/pools/CommunityStakingPool.sol

120    function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE) {
121      s_merkleRoot = newMerkleRoot;
122      emit MerkleRootChanged(newMerkleRoot);
123:   }

133    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
134      external
135      onlyRole(DEFAULT_ADMIN_ROLE)
136    {
137      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();
138      address oldOperatorStakingPool = address(s_operatorStakingPool);
139      s_operatorStakingPool = newOperatorStakingPool;
140      emit OperatorStakingPoolChanged(oldOperatorStakingPool, address(newOperatorStakingPool));
141:   }

```
*GitHub*: [120](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L120-L123), [133](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L133-L141)

```solidity
File: src/pools/StakingPoolBase.sol

315    function setRewardVault(IRewardVault newRewardVault) external onlyRole(DEFAULT_ADMIN_ROLE) {
316      if (address(newRewardVault) == address(0)) revert InvalidZeroAddress();
317      address oldRewardVault = address(s_rewardVault);
318      s_rewardVault = newRewardVault;
319      emit RewardVaultSet(oldRewardVault, address(newRewardVault));
320:   }

```
*GitHub*: [315](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L315-L320)

```solidity
File: src/rewards/RewardVault.sol

467    function setMigrationSource(address newMigrationSource) external onlyRole(DEFAULT_ADMIN_ROLE) {
468      if (address(newMigrationSource) == address(0) || address(newMigrationSource) == address(this)) {
469        revert InvalidMigrationSource();
470      }
471      address oldMigrationSource = s_migrationSource;
472      s_migrationSource = newMigrationSource;
473      emit MigrationSourceSet(oldMigrationSource, newMigrationSource);
474:   }

```
*GitHub*: [467](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L467-L474)

```solidity
File: src/timelock/Timelock.sol

459    function updateDelay(uint256 newDelay) external virtual onlyRole(ADMIN_ROLE) {
460      uint256 oldDelay = s_minDelay;
461      s_minDelay = newDelay;
462      emit MinDelayChange(oldDelay, newDelay);
463:   }

```
*GitHub*: [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L459-L463)


### [N&#x2011;50] Polymorphic functions make security audits more time-consuming and error-prone
The instances below point to one of two functions with the same name. Consider naming each function differently, in order to make code navigation and analysis easier.

*There are 3 instances of this issue:*

```solidity
File: src/timelock/Timelock.sol

280:   function getMinDelay(address target, bytes4 selector) public view returns (uint256) {

288:   function getMinDelay(Call[] calldata calls) public view returns (uint256) {

469:   function updateDelay(UpdateDelayParams[] calldata params) external virtual onlyRole(ADMIN_ROLE) {

```
*GitHub*: [280](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L280-L280), [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L288-L288), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L469-L469)


### [N&#x2011;51] Complex casting
Consider whether the number of casts is really necessary, or whether using a different type would be more appropriate. Alternatively, add comments to explain in detail why the casts are necessary, and any implicit reasons why the cast does not introduce an overflow.

*There are 2 instances of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

743        s_checkpointId++,
744:       (uint224(uint112(latestPrincipal)) << 112) | uint224(uint112(latestStakedAtTime))

```
*GitHub*: [743](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L743-L744), [743](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L743-L744)

## Gas Optimizations


### [G&#x2011;01] Enable IR-based code generation
By using `--via-ir` or `{"viaIR": true}`, the compiler is able to use more advanced [multi-function optimizations](https://docs.soliditylang.org/en/v0.8.17/ir-breaking-changes.html#solidity-ir-based-codegen-changes), for extra gas savings.

*There is one instance of this issue:*

```solidity
File: Various Files


```


### [G&#x2011;02] Multiple `address`/ID mappings can be combined into a single `mapping` of an `address`/ID to a `struct`, where appropriate
Saves a storage slot for the mapping. Depending on the circumstances and sizes of types, can avoid a Gsset (**20000 gas**) per mapping combined. Reads and subsequent writes can also be cheaper when a function requires both values and they both fit in the same storage slot. Finally, if both fields are accessed in the same function, can save **~42 gas per access** due to [not having to recalculate the key's keccak256 hash](https://gist.github.com/IllIllI000/ec23a57daa30a8f8ca8b9681c8ccefb0) (Gkeccak256 - 30 gas) and that calculation's associated stack operations.

*There are 2 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

224     mapping(address => FeedConfig) private s_feedConfigs;
225     /// @notice The slashable operators of each feed
226     mapping(address => address[]) private s_feedSlashableOperators;
227     /// @notice The round ID of the last feed round an alert was raised
228:    mapping(address => uint256) private s_lastAlertedRoundIds;

```
*GitHub*: [224](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L224-L228)

```solidity
File: src/pools/OperatorStakingPool.sol

126     mapping(address => Operator) private s_operators;
127     /// @notice Mapping of the slashers to slasher config struct.
128     mapping(address => ISlashable.SlasherConfig) private s_slasherConfigs;
129     /// @notice Mapping of slashers to slasher state struct.
130:    mapping(address => ISlashable.SlasherState) private s_slasherState;

```
*GitHub*: [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L126-L130)


### [G&#x2011;03] Structs can be packed into fewer storage slots
Each slot saved can avoid an extra Gsset (**20000 gas**) for the first setting of the struct. Subsequent reads as well as writes have smaller gas savings

*There are 2 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit Variable ordering with 3 slots instead of the current 4:
///           user-defined[](32):feedConfigs, user-defined(20):communityStakingPool, uint48(6):adminRoleTransferDelay, user-defined(20):operatorStakingPool
116     struct ConstructorParams {
117       /// @notice The community staking pool contract
118       CommunityStakingPool communityStakingPool;
119       /// @notice The operator staking pool contract
120       OperatorStakingPool operatorStakingPool;
121       /// @notice The feed configs and slashable operators
122       ConstructorFeedConfigParams[] feedConfigs;
123       /// @notice The time it requires to transfer admin role
124       uint48 adminRoleTransferDelay;
125:    }

```
*GitHub*: [116](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L116-L125)

```solidity
File: src/rewards/RewardVault.sol

/// @audit Variable ordering with 3 slots instead of the current 4:
///           user-defined(20):linkToken, uint48(6):adminRoleTransferDelay, uint32(4):delegationRateDenominator, user-defined(20):communityStakingPool, uint32(4):initialMultiplierDuration, user-defined(20):operatorStakingPool
201     struct ConstructorParams {
202       /// @notice The LINK token.
203       LinkTokenInterface linkToken;
204       /// @notice The community staking pool.
205       CommunityStakingPool communityStakingPool;
206       /// @notice The operator staking pool.
207       OperatorStakingPool operatorStakingPool;
208       /// @notice The delegation rate denominator.
209       uint32 delegationRateDenominator;
210       /// @notice The initial time it takes for a multiplier to reach its max value in seconds.
211       uint32 initialMultiplierDuration;
212       /// @notice The time it requires to transfer admin role
213       uint48 adminRoleTransferDelay;
214:    }

```
*GitHub*: [201](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L201-L214)


### [G&#x2011;04] Structs can be packed into fewer storage slots by truncating timestamp bytes
By using a `uint32` rather than a larger type for variables that track timestamps, one can save gas by using fewer storage slots per struct, at the expense of the protocol breaking after the year 2106 (when `uint32` wraps). If this is an acceptable tradeoff, each slot saved can avoid an extra Gsset (**20000 gas**) for the first setting of the struct. Subsequent reads as well as writes have smaller gas savings

*There are 2 instances of this issue:*

```solidity
File: src/timelock/StakingTimelock.sol

/// @audit Variable ordering with 8 slots instead of the current 9:
///           address[](32):proposers, address[](32):executors, address[](32):cancellers, address(20):rewardVault, uint32(4):minDelay, address(20):communityStakingPool, address(20):operatorStakingPool, address(20):alertsController, address(20):admin
28      struct ConstructorParams {
29        /// @notice The reward vault address
30        address rewardVault;
31        /// @notice The Community Staker Staking Pool
32        address communityStakingPool;
33        /// @notice The Operator Staking Pool
34        address operatorStakingPool;
35        /// @notice The PriceFeedAlertsController address
36        address alertsController;
37        /// @notice initial minimum delay for operations
38        uint256 minDelay;
39        /// @notice account to be granted admin role
40        address admin;
41        /// @notice accounts to be granted proposer role
42        address[] proposers;
43        /// @notice accounts to be granted executor role
44        address[] executors;
45        /// @notice accounts to be granted canceller role
46        address[] cancellers;
47:     }

```
*GitHub*: [28](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L28-L47)

```solidity
File: src/timelock/Timelock.sol

/// @audit Variable ordering with 1 slots instead of the current 2:
///           address(20):target, bytes4(4):selector, uint32(4):newDelay
116     struct UpdateDelayParams {
117       /// @notice target contract address called by the Timelock
118       address target;
119       /// @notice selector is the first four bytes of a function signature
120       bytes4 selector;
121       /// @notice Number of seconds to set as the minimum timelock delay when
122       uint256 newDelay;
123:    }

```
*GitHub*: [116](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L116-L123)


### [G&#x2011;05] State variables should be cached in stack variables rather than re-reading them from storage
The instances below point to the second+ access of a state variable within a function. Caching of a state variable replaces each Gwarmaccess (**100 gas**) with a much cheaper stack read. Other less obvious fixes/optimizations include having local memory caches of state variable structs, or having local caches of state variable contracts/addresses.

*There are 73 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit s_operatorStakingPool on line 406
406:      s_operatorStakingPool.renounceRole(s_operatorStakingPool.SLASHER_ROLE(), address(this));

/// @audit s_operatorStakingPool on line 528
542:      returnValues.canAlert = s_operatorStakingPool.isOperator(alerter);

/// @audit s_operatorStakingPool on line 548
548:      return s_operatorStakingPool.hasRole(s_operatorStakingPool.SLASHER_ROLE(), address(this));

/// @audit s_migrationTarget on line 458
460:      emit MigrationDataSent(s_migrationTarget, feeds, migrationData);

```
*GitHub*: [406](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L406), [542](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L542), [548](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L548), [460](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L460)

```solidity
File: src/pools/CommunityStakingPool.sol

/// @audit s_operatorStakingPool on line 79
79:       if (s_operatorStakingPool.isOperator(staker) || s_operatorStakingPool.isRemoved(staker)) {

/// @audit s_merkleRoot on line 110
113:        root: s_merkleRoot,

```
*GitHub*: [79](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L79), [113](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L113)

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit s_numOperators on line 415
416:        revert InadequateInitialOperatorCount(s_numOperators, i_minInitialOperatorCount);

/// @audit s_alerterRewardFunds on line 160
164:      emit AlerterRewardDeposited(amount, s_alerterRewardFunds);

/// @audit s_alerterRewardFunds on line 175
176:        revert InsufficientAlerterRewardFunds(amount, s_alerterRewardFunds);

/// @audit s_alerterRewardFunds on line 178
182:      emit AlerterRewardWithdrawn(amount, s_alerterRewardFunds);

/// @audit s_pool on line 430
431:        s_pool.configs.maxPrincipalPerStaker,

```
*GitHub*: [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L416), [164](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L164), [176](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L176), [182](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L182), [431](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L431)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit s_pool on line 286
287:      staker.claimPeriodEndsAt = staker.unbondingPeriodEndsAt + s_pool.configs.claimPeriod;

/// @audit s_pool on line 597
597:      return (s_pool.configs.unbondingPeriod, s_pool.configs.claimPeriod);

/// @audit s_pool on line 651
652:      s_pool.configs.unbondingPeriod = unbondingPeriod.toUint32();

/// @audit s_pool on line 662
663:      s_pool.configs.claimPeriod = claimPeriod.toUint32();

/// @audit s_pool on line 679
682:      uint256 newTotalPrincipal = s_pool.state.totalPrincipal + amount;

/// @audit s_pool on line 682
683:      if (newTotalPrincipal > s_pool.configs.maxPoolSize) {

/// @audit s_pool on line 683
688:      s_pool.state.totalPrincipal = newTotalPrincipal;

/// @audit s_migrationTarget on line 251
252:      emit StakerMigrated(s_migrationTarget, stakerPrincipal, migrationData);

```
*GitHub*: [287](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L287), [597](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L597), [652](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L652), [663](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L663), [682](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L682), [683](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L683), [688](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L688), [252](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L252)

```solidity
File: src/rewards/RewardVault.sol

/// @audit s_rewardBuckets on line 394
394:        s_rewardBuckets.communityBase.emissionRate + s_rewardBuckets.operatorDelegated.emissionRate;

/// @audit s_rewardBuckets on line 394
409:      uint256 unvestedRewards = _getUnvestedRewards(s_rewardBuckets.communityBase)

/// @audit s_rewardBuckets on line 409
410:        + _getUnvestedRewards(s_rewardBuckets.operatorDelegated);

/// @audit s_rewardBuckets on line 410
412:      s_rewardBuckets.communityBase.emissionRate = communityRate.toUint80();

/// @audit s_rewardBuckets on line 412
413:      s_rewardBuckets.operatorDelegated.emissionRate = delegatedRate.toUint80();

/// @audit s_rewardBuckets on line 413
417:        delete s_rewardBuckets.operatorDelegated.rewardDurationEndsAt;

/// @audit s_rewardBuckets on line 417
419:          bucket: s_rewardBuckets.communityBase,

/// @audit s_rewardBuckets on line 419
424:        delete s_rewardBuckets.communityBase.rewardDurationEndsAt;

/// @audit s_rewardBuckets on line 424
426:          bucket: s_rewardBuckets.operatorDelegated,

/// @audit s_rewardBuckets on line 426
434:          bucket: s_rewardBuckets.communityBase,

/// @audit s_rewardBuckets on line 434
439:          bucket: s_rewardBuckets.operatorDelegated,

/// @audit s_rewardBuckets on line 525
527:        s_rewardBuckets.communityBase.emissionRate,

/// @audit s_rewardBuckets on line 527
529:        s_rewardBuckets.operatorDelegated.emissionRate,

/// @audit s_rewardBuckets on line 598
603:        bucket: s_rewardBuckets.communityBase,

/// @audit s_rewardBuckets on line 603
608:        bucket: s_rewardBuckets.operatorDelegated,

/// @audit s_rewardBuckets on line 826
827:          && s_rewardBuckets.operatorDelegated.rewardDurationEndsAt <= block.timestamp;

/// @audit s_rewardBuckets on line 827
830:        return s_rewardBuckets.communityBase.rewardDurationEndsAt <= block.timestamp;

/// @audit s_rewardBuckets on line 895
896:      uint256 unvestedOperatorBaseRewards = _getUnvestedRewards(s_rewardBuckets.operatorBase);

/// @audit s_rewardBuckets on line 896
898:        _getUnvestedRewards(s_rewardBuckets.operatorDelegated);

/// @audit s_rewardBuckets on line 974
975:      uint256 unvestedCommunityBaseRewards = _stopVestingBucketRewards(s_rewardBuckets.communityBase);

/// @audit s_rewardBuckets on line 975
977:        _stopVestingBucketRewards(s_rewardBuckets.operatorDelegated);

/// @audit s_rewardBuckets on line 977
/// @audit s_rewardBuckets on line 984
984:        s_rewardBuckets.operatorBase.emissionRate + s_rewardBuckets.communityBase.emissionRate

/// @audit s_rewardBuckets on line 984
985:          + s_rewardBuckets.operatorDelegated.emissionRate,

/// @audit s_rewardBuckets on line 1127
1134:         bucket: s_rewardBuckets.operatorBase,

/// @audit s_rewardBuckets on line 1134
1141:         bucket: s_rewardBuckets.operatorDelegated,

/// @audit s_rewardBuckets on line 1347
1348:       s_rewardBuckets.operatorBase.vestedRewardPerToken = operatorRewardPerToken.toUint80();

/// @audit s_rewardBuckets on line 1348
1349:       s_rewardBuckets.operatorDelegated.vestedRewardPerToken =

/// @audit s_rewardBuckets on line 1349
1355:         s_rewardBuckets.communityBase.vestedRewardPerToken,

/// @audit s_rewardBuckets on line 1355
1356:         s_rewardBuckets.operatorBase.vestedRewardPerToken,

/// @audit s_rewardBuckets on line 1356
1357:         s_rewardBuckets.operatorDelegated.vestedRewardPerToken

/// @audit s_rewardBuckets on line 1371
1372:       _calculateVestedRewardPerToken(s_rewardBuckets.operatorBase, operatorTotalPrincipal),

/// @audit s_rewardBuckets on line 1372
1373:       _calculateVestedRewardPerToken(s_rewardBuckets.operatorDelegated, operatorTotalPrincipal)

/// @audit s_rewardBuckets on line 1518
1519:         : s_rewardBuckets.communityBase.vestedRewardPerToken

/// @audit s_rewardBuckets on line 1519
1529:         operatorDelegatedRewardPerToken: s_rewardBuckets.operatorDelegated.vestedRewardPerToken

/// @audit s_rewardBuckets on line 1556
1558:         s_rewardBuckets.communityBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();

/// @audit s_rewardBuckets on line 1609
1611:         s_rewardBuckets.operatorDelegated.vestedRewardPerToken;

/// @audit s_rewardBuckets on line 1611
1613:       stakerReward.baseRewardPerToken = s_rewardBuckets.communityBase.vestedRewardPerToken;

/// @audit s_vaultConfig on line 320
323:      s_vaultConfig.multiplierDuration = params.initialMultiplierDuration;

/// @audit s_vaultConfig on line 323
326:      s_vaultConfig.isOpen = true;

/// @audit s_vaultConfig on line 388
445:      s_vaultConfig.delegationRateDenominator = newDelegationRateDenominator.toUint32();

/// @audit s_vaultConfig on line 458
459:      s_vaultConfig.multiplierDuration = newMultiplierDuration.toUint32();

/// @audit s_vaultConfig on line 1239
1243:       operatorDelegatedReward = communityReward / s_vaultConfig.delegationRateDenominator;

/// @audit s_vaultConfig on line 1243
1247:       delegatedRate = communityRate / s_vaultConfig.delegationRateDenominator;

/// @audit s_vaultConfig on line 1685
1692:     if (totalEmissionRate == 0 || totalEmissionRate < s_vaultConfig.delegationRateDenominator) {

/// @audit s_finalVestingCheckpointData on line 1057
1058:       : s_finalVestingCheckpointData.communityPoolCheckpointId;

/// @audit s_finalVestingCheckpointData on line 1072
1073:       : s_finalVestingCheckpointData.communityPoolTotalPrincipal;

/// @audit s_finalVestingCheckpointData on line 1080
1082:     s_finalVestingCheckpointData.communityPoolTotalPrincipal =

/// @audit s_finalVestingCheckpointData on line 1082
1092:       s_finalVestingCheckpointData.operatorPoolCheckpointId = operatorPoolCheckpointId - 1;

/// @audit s_finalVestingCheckpointData on line 1092
1096:       s_finalVestingCheckpointData.communityPoolCheckpointId = communityPoolCheckpointId - 1;

/// @audit s_rewardPerTokenUpdatedAt on line 1389
1393:     uint256 elapsedTime = latestRewardEmittedAt - s_rewardPerTokenUpdatedAt;

/// @audit s_migrationSource on line 568
571:      delete s_migrationSource;

/// @audit s_migrationTarget on line 538
539:      emit VaultMigrated(s_migrationTarget, totalUnvestedRewards, totalEmissionRate);

```
*GitHub*: [394](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L394), [409](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L409), [410](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L410), [412](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L412), [413](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L413), [417](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L417), [419](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L419), [424](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L424), [426](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L426), [434](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L434), [439](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L439), [527](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L527), [529](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L529), [603](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L603), [608](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L608), [827](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L827), [830](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L830), [896](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L896), [898](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L898), [975](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L975), [977](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L977), [984](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L984), [984](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L984), [985](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L985), [1134](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1134), [1141](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1141), [1348](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1348), [1349](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1349), [1355](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1355), [1356](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1356), [1357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1357), [1372](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1372), [1373](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1373), [1519](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1519), [1529](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1529), [1558](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1558), [1611](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1611), [1613](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1613), [323](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L323), [326](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L326), [445](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L445), [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L459), [1243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1243), [1247](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1247), [1692](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1692), [1058](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1058), [1073](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1073), [1082](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1082), [1092](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1092), [1096](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1096), [1393](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1393), [571](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L571), [539](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L539)

```solidity
File: src/timelock/Timelock.sol

/// @audit s_minDelay on line 282
282:      return delay >= s_minDelay ? delay : s_minDelay;

```
*GitHub*: [282](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L282)


### [G&#x2011;06] Multiple accesses of a mapping/array should use a local variable cache
The instances below point to the second+ access of a value inside a mapping/array, within a function. Caching a mapping's value in a local `storage` or `calldata` variable when the value is accessed [multiple times](https://gist.github.com/IllIllI000/ec23a57daa30a8f8ca8b9681c8ccefb0), saves **~42 gas per access** due to not having to recalculate the key's keccak256 hash (Gkeccak256 - **30 gas**) and that calculation's associated stack operations. Caching an array's struct avoids recalculating the array offsets into memory/calldata

*There are 2 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit s_slasherState[<etc>] on line 296
298:      s_slasherState[msg.sender].lastSlashTimestamp = block.timestamp;

/// @audit s_operators[<etc>] on line 543
547:      s_operators[msg.sender].removedPrincipal = 0;

```
*GitHub*: [298](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L298), [547](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L547)


### [G&#x2011;07] `<array>.length` should not be looked up in every loop of a `for`-loop
The overheads outlined below are _PER LOOP_, excluding the first loop
* storage arrays incur a Gwarmaccess (**100 gas**)
* memory arrays use `MLOAD` (**3 gas**)
* calldata arrays use `CALLDATALOAD` (**3 gas**)

Caching the length changes each of these to a `DUP<N>` (**3 gas**), and gets rid of the extra `DUP<N>` needed to store the stack offset

*There are 7 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

244:      for (uint256 i; i < params.feedConfigs.length; ++i) {

442:      for (uint256 i; i < feeds.length; ++i) {

474:      for (uint256 i; i < configs.length; ++i) {

555:      for (uint256 i; i < operators.length; ++i) {

```
*GitHub*: [244](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L244), [442](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L442), [474](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L474), [555](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L555)

```solidity
File: src/pools/OperatorStakingPool.sol

319:      for (uint256 i; i < operators.length; ++i) {

436:      for (uint256 i; i < operators.length; ++i) {

480:      for (uint256 i; i < operators.length; ++i) {

```
*GitHub*: [319](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L319), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L436), [480](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L480)


### [G&#x2011;08] `++i`/`i++` should be `unchecked{++i}`/`unchecked{i++}` when it is not possible for them to overflow, as is the case when used in `for`- and `while`-loops
The `unchecked` keyword is new in solidity version 0.8.0, so this only applies to that version or higher, which these instances are. This saves **30-40 gas [per loop](https://gist.github.com/hrkrshnn/ee8fabd532058307229d65dcd5836ddc#the-increment-in-for-loop-post-condition-can-be-made-unchecked)**

*There are 14 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

244:      for (uint256 i; i < params.feedConfigs.length; ++i) {

442:      for (uint256 i; i < feeds.length; ++i) {

474:      for (uint256 i; i < configs.length; ++i) {

555:      for (uint256 i; i < operators.length; ++i) {

```
*GitHub*: [244](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L244), [442](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L442), [474](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L474), [555](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L555)

```solidity
File: src/pools/OperatorStakingPool.sol

319:      for (uint256 i; i < operators.length; ++i) {

436:      for (uint256 i; i < operators.length; ++i) {

480:      for (uint256 i; i < operators.length; ++i) {

```
*GitHub*: [319](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L319), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L436), [480](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L480)

```solidity
File: src/timelock/Timelock.sol

181:      for (uint256 i; i < proposersLength; ++i) {

187:      for (uint256 i; i < executorsLength; ++i) {

193:      for (uint256 i; i < cancellersLength; ++i) {

291:      for (uint256 i; i < callsLength; ++i) {

341:      for (uint256 i; i < callsLength; ++i) {

410:      for (uint256 i; i < callsLength; ++i) {

471:      for (uint256 i; i < paramsLength; ++i) {

```
*GitHub*: [181](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L181), [187](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L187), [193](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L193), [291](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L291), [341](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L341), [410](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L410), [471](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L471)


### [G&#x2011;09] `require()`/`revert()` strings longer than 32 bytes cost extra gas
Each extra memory word of bytes past the original 32 [incurs an MSTORE](https://gist.github.com/hrkrshnn/ee8fabd532058307229d65dcd5836ddc#consider-having-short-revert-strings) which costs **3 gas**

*There are 3 instances of this issue:*

```solidity
File: src/timelock/Timelock.sol

357:      require(!isOperation(id), 'Timelock: operation already scheduled');

375:      require(isOperationPending(id), 'Timelock: operation cannot be cancelled');

424:      require(success, 'Timelock: underlying transaction reverted');

```
*GitHub*: [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L357), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L375), [424](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L424)


### [G&#x2011;10] Optimize names to save gas
`public`/`external` function names and `public` member variable names can be optimized to save gas. See [this](https://gist.github.com/IllIllI000/a5d8b486a8259f9f77891a919febd1a9) link for an example of how it works. Below are the interfaces/abstract contracts that can be optimized so that the most frequently-called functions use the least amount of gas possible during method lookup. Method IDs that have two leading zero bytes can save **128 gas** each during deployment, and renaming functions to have lower method IDs will save **22 gas** per call, [per sorted position shifted](https://medium.com/joyso/solidity-how-does-function-name-affect-gas-consumption-in-smart-contract-47d270d8ac92)

*There are 5 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit setCommunityStakingPool(), setOperatorStakingPool(), setFeedConfigs(), removeFeedConfig(), getFeedConfig(), raiseAlert(), canAlert(), getStakingPools(), setSlashableOperators(), getSlashableOperators(), sendMigrationData()
26:   contract PriceFeedAlertsController is

```
*GitHub*: [26](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L26)

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit depositAlerterReward(), withdrawAlerterReward(), getAlerterRewardFunds(), addOperators(), removeOperators(), isOperator(), isRemoved(), getRemovedPrincipal(), unstakeRemovedPrincipal(), getNumOperators()
23:   contract OperatorStakingPool is ISlashable, StakingPoolBase, TypeAndVersionInterface {

```
*GitHub*: [23](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L23)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit unbond(), setUnbondingPeriod(), getUnbondingPeriodLimits(), setClaimPeriod(), setRewardVault(), getClaimPeriodLimits(), getUnbondingEndsAt(), getUnbondingParams(), getClaimPeriodEndsAt(), getCurrentCheckpointId()
33:   abstract contract StakingPoolBase is

```
*GitHub*: [33](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L33)

```solidity
File: src/rewards/RewardVault.sol

/// @audit addReward(), getDelegationRateDenominator(), setDelegationRateDenominator(), setMultiplierDuration(), setMigrationSource(), getMigrationSource(), getRewardBuckets(), getRewardPerTokenUpdatedAt(), getMultiplierDuration(), getMultiplier(), calculateLatestStakerReward(), getVestingCheckpointData(), getUnvestedRewards()
38:   contract RewardVault is

```
*GitHub*: [38](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L38)

```solidity
File: src/timelock/Timelock.sol

/// @audit isOperation(), isOperationPending(), isOperationReady(), isOperationDone(), getTimestamp(), getMinDelay(), getMinDelay(), getMinDelay(), hashOperationBatch(), scheduleBatch(), cancel(), executeBatch(), updateDelay(), updateDelay()
41:   contract Timelock is AccessControlEnumerable {

```
*GitHub*: [41](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L41)


### [G&#x2011;11] Usage of `uints`/`ints` smaller than 32 bytes (256 bits) incurs overhead
> When using elements that are smaller than 32 bytes, your contract’s gas usage may be higher. This is because the EVM operates on 32 bytes at a time. Therefore, if the element is smaller than that, the EVM must use more operations in order to reduce the size of the element from 32 bytes to the desired size.

https://docs.soliditylang.org/en/v0.8.11/internals/layout_in_storage.html
Each operation involving a `uint8` costs an extra [**22-28 gas**](https://gist.github.com/IllIllI000/9388d20c70f9a4632eb3ca7836f54977) (depending on whether the other operand is also a variable of type `uint8`) as compared to ones involving `uint256`, due to the compiler having to clear the higher bits of the memory word before operating on the `uint8`, as well as the associated stack operations of doing so. Use a larger size then downcast where needed

*There are 4 instances of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit uint96 i_minPrincipalPerStaker
213:      i_minPrincipalPerStaker = params.minPrincipalPerStaker;

/// @audit uint32 i_maxUnbondingPeriod
215:      i_maxUnbondingPeriod = params.maxUnbondingPeriod;

/// @audit uint32 i_minClaimPeriod
220:      i_minClaimPeriod = params.minClaimPeriod;

/// @audit uint32 i_maxClaimPeriod
221:      i_maxClaimPeriod = params.maxClaimPeriod;

```
*GitHub*: [213](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L213), [215](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L215), [220](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L220), [221](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L221)


### [G&#x2011;12] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*There are 7 instances of this issue:*

```solidity
File: src/PausableWithAccessControl.sol

14:     bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');

```
*GitHub*: [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L14)

```solidity
File: src/pools/OperatorStakingPool.sol

142:    bytes32 public constant SLASHER_ROLE = keccak256('SLASHER_ROLE');

```
*GitHub*: [142](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L142)

```solidity
File: src/rewards/RewardVault.sol

285:    bytes32 public constant REWARDER_ROLE = keccak256('REWARDER_ROLE');

```
*GitHub*: [285](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L285)

```solidity
File: src/timelock/Timelock.sol

127:    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

130:    bytes32 public constant PROPOSER_ROLE = keccak256('PROPOSER_ROLE');

133:    bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');

136:    bytes32 public constant CANCELLER_ROLE = keccak256('CANCELLER_ROLE');

```
*GitHub*: [127](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L127), [130](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L130), [133](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L133), [136](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L136)


### [G&#x2011;13] Stack variable used as a cheaper cache for a state variable is only used once
If the variable is only accessed once, it's cheaper to use the state variable directly that one time, and save the **3 gas** the extra stack assignment would spend

*There are 6 instances of this issue:*

```solidity
File: src/Migratable.sol

14:       address oldMigrationTarget = s_migrationTarget;

```
*GitHub*: [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L14)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

267:      CommunityStakingPool oldCommunityStakingPool = s_communityStakingPool;

280:      OperatorStakingPool oldOperatorStakingPool = s_operatorStakingPool;

```
*GitHub*: [267](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L267), [280](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L280)

```solidity
File: src/rewards/RewardVault.sol

458:      uint256 oldMultiplierDuration = s_vaultConfig.multiplierDuration;

471:      address oldMigrationSource = s_migrationSource;

```
*GitHub*: [458](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L458), [471](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L471)

```solidity
File: src/timelock/Timelock.sol

460:      uint256 oldDelay = s_minDelay;

```
*GitHub*: [460](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L460)


### [G&#x2011;14] Use custom errors rather than `revert()`/`require()` strings to save gas
Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

*There are 8 instances of this issue:*

```solidity
File: src/timelock/Timelock.sol

357:      require(!isOperation(id), 'Timelock: operation already scheduled');

358:      require(delay >= getMinDelay(calls), 'Timelock: insufficient delay');

375:      require(isOperationPending(id), 'Timelock: operation cannot be cancelled');

424:      require(success, 'Timelock: underlying transaction reverted');

433:      require(isOperationReady(id), 'Timelock: operation is not ready');

434       require(
435         predecessor == bytes32(0) || isOperationDone(predecessor), 'Timelock: missing dependency'
436:      );

444:      require(isOperationReady(id), 'Timelock: operation is not ready');

486:      require(newDelay >= s_minDelay, 'Timelock: insufficient delay');

```
*GitHub*: [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L357), [358](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L358), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L375), [424](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L424), [433](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L433), [434](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L434-L436), [444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L444), [486](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L486)


### [G&#x2011;15] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided. The extra opcodes avoided are 
`CALLVALUE`(2),`DUP1`(3),`ISZERO`(3),`PUSH2`(3),`JUMPI`(10),`PUSH1`(3),`DUP1`(3),`REVERT`(0),`JUMPDEST`(1),`POP`(2), which costs an average of about **21 gas per call** to the function, in addition to the extra deployment cost

*There are 41 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/PausableWithAccessControl.sol

22:     function emergencyPause() external override onlyRole(PAUSER_ROLE) {

27:     function emergencyUnpause() external override onlyRole(PAUSER_ROLE) {

```
*GitHub*: [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L22), [27](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L27)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

261     function setCommunityStakingPool(CommunityStakingPool newCommunityStakingPool)
262       external
263:      onlyRole(DEFAULT_ADMIN_ROLE)

274     function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
275       external
276:      onlyRole(DEFAULT_ADMIN_ROLE)

288     function setFeedConfigs(SetFeedConfigParams[] calldata configs)
289       external
290:      onlyRole(DEFAULT_ADMIN_ROLE)

299:    function removeFeedConfig(address feed) external onlyRole(DEFAULT_ADMIN_ROLE) {

371     function setSlashableOperators(
372       address[] calldata operators,
373       address feed
374:    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

399     function migrate(bytes calldata)
400       external
401       override(IMigratable)
402       onlyRole(DEFAULT_ADMIN_ROLE)
403       withSlasherRole
404:      validateMigrationTargetSet

416     function _validateMigrationTarget(address newMigrationTarget)
417       internal
418       override(Migratable)
419:      onlyRole(DEFAULT_ADMIN_ROLE)

436     function sendMigrationData(address[] calldata feeds)
437       external
438       onlyRole(DEFAULT_ADMIN_ROLE)
439:      validateMigrationTargetSet

```
*GitHub*: [261](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L261-L263), [274](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L274-L276), [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L288-L290), [299](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L299), [371](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L371-L374), [399](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L399-L404), [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L416-L419), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L436-L439)

```solidity
File: src/pools/CommunityStakingPool.sol

120:    function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE) {

133     function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
134       external
135:      onlyRole(DEFAULT_ADMIN_ROLE)

```
*GitHub*: [120](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L120), [133](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L133-L135)

```solidity
File: src/pools/OperatorStakingPool.sol

154     function depositAlerterReward(uint256 amount)
155       external
156       onlyRole(DEFAULT_ADMIN_ROLE)
157:      whenBeforeClosing

173:    function withdrawAlerterReward(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {

218     function addSlasher(
219       address slasher,
220       SlasherConfig calldata config
221:    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

228     function setSlasherConfig(
229       address slasher,
230       SlasherConfig calldata config
231:    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

277     function slashAndReward(
278       address[] calldata stakers,
279       address alerter,
280       uint256 principalAmount,
281       uint256 alerterRewardAmount
282:    ) external override onlySlasher whenActive {

400     function setPoolConfig(
401       uint256 maxPoolSize,
402       uint256 maxPrincipalPerStaker
403     )
404       external
405       override
406       validatePoolSpace(maxPoolSize, maxPrincipalPerStaker, s_numOperators)
407       whenOpen
408:      onlyRole(DEFAULT_ADMIN_ROLE)

426     function addOperators(address[] calldata operators)
427       external
428       validateRewardVaultSet
429       validatePoolSpace(
430         s_pool.configs.maxPoolSize,
431         s_pool.configs.maxPrincipalPerStaker,
432         s_numOperators + operators.length
433       )
434:      onlyRole(DEFAULT_ADMIN_ROLE)

473     function removeOperators(address[] calldata operators)
474       external
475       onlyRole(DEFAULT_ADMIN_ROLE)
476:      whenOpen

```
*GitHub*: [154](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L154-L157), [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L173), [218](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L218-L221), [228](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L228-L231), [277](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L277-L282), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L400-L408), [426](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L426-L434), [473](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L473-L476)

```solidity
File: src/pools/StakingPoolBase.sol

258     function _validateMigrationTarget(address newMigrationTarget)
259       internal
260       override(Migratable)
261:      onlyRole(DEFAULT_ADMIN_ROLE)

295:    function setUnbondingPeriod(uint256 newUnbondingPeriod) external onlyRole(DEFAULT_ADMIN_ROLE) {

308:    function setClaimPeriod(uint256 claimPeriod) external onlyRole(DEFAULT_ADMIN_ROLE) {

315:    function setRewardVault(IRewardVault newRewardVault) external onlyRole(DEFAULT_ADMIN_ROLE) {

400     function setPoolConfig(
401       uint256 maxPoolSize,
402       uint256 maxPrincipalPerStaker
403:    ) external virtual override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

409     function open()
410       external
411       override(IStakingOwner)
412       onlyRole(DEFAULT_ADMIN_ROLE)
413       whenBeforeOpening
414       validateRewardVaultSet
415:      whenRewardVaultOpen

425:    function close() external override(IStakingOwner) onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

436:    function setMigrationProxy(address migrationProxy) external override onlyRole(DEFAULT_ADMIN_ROLE) {

```
*GitHub*: [258](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L258-L261), [295](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L295), [308](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L308), [315](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L315), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L400-L403), [409](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L409-L415), [425](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L425), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L436)

```solidity
File: src/rewards/RewardVault.sol

346     function addReward(
347       address pool,
348       uint256 amount,
349       uint256 emissionRate
350:    ) external onlyRewarder whenOpen whenNotPaused {

384     function setDelegationRateDenominator(uint256 newDelegationRateDenominator)
385       external
386:      onlyRole(DEFAULT_ADMIN_ROLE)

454     function setMultiplierDuration(uint256 newMultiplierDuration)
455       external
456:      onlyRole(DEFAULT_ADMIN_ROLE)

467:    function setMigrationSource(address newMigrationSource) external onlyRole(DEFAULT_ADMIN_ROLE) {

488     function _validateMigrationTarget(address newMigrationTarget)
489       internal
490       override(Migratable)
491:      onlyRole(DEFAULT_ADMIN_ROLE)

509     function migrate(bytes calldata data)
510       external
511       override(IMigratable)
512       onlyRole(DEFAULT_ADMIN_ROLE)
513       whenOpen
514:      validateMigrationTargetSet

687:    function updateReward(address staker, uint256 stakerPrincipal) external override onlyStakingPool {

721     function finalizeReward(
722       address staker,
723       uint256 oldPrincipal,
724       uint256 stakedAt,
725       uint256 unstakedAmount,
726       bool shouldClaim
727:    ) external override onlyStakingPool returns (uint256) {

793:    function close() external override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

```
*GitHub*: [346](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L346-L350), [384](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L384-L386), [454](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L454-L456), [467](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L467), [488](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L488-L491), [509](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L509-L514), [687](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L687), [721](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L721-L727), [793](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L793)

```solidity
File: src/timelock/Timelock.sol

332     function scheduleBatch(
333       Call[] calldata calls,
334       bytes32 predecessor,
335       bytes32 salt,
336       uint256 delay
337:    ) public virtual onlyRoleOrAdminRole(PROPOSER_ROLE) {

374:    function cancel(bytes32 id) external virtual onlyRoleOrAdminRole(CANCELLER_ROLE) {

459:    function updateDelay(uint256 newDelay) external virtual onlyRole(ADMIN_ROLE) {

469:    function updateDelay(UpdateDelayParams[] calldata params) external virtual onlyRole(ADMIN_ROLE) {

```
*GitHub*: [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L332-L337), [374](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L374), [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L459), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L469)

</details>

### [G&#x2011;16] Constructors can be marked `payable`
Payable functions cost less gas to execute, since the compiler does not have to add extra checks to ensure that a payment wasn't provided. A constructor can safely be marked as payable, since only the deployer would be able to pass funds, and the project itself would not pass any funds.

*There are 9 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/MigrationProxy.sol

63      constructor(ConstructorParams memory params)
64:       PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)

```
*GitHub*: [63](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L63-L64)

```solidity
File: src/PausableWithAccessControl.sol

16      constructor(
17        uint48 adminRoleTransferDelay,
18        address defaultAdmin
19:     ) AccessControlDefaultAdminRules(adminRoleTransferDelay, defaultAdmin) {}

```
*GitHub*: [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L16-L19)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

230     constructor(ConstructorParams memory params)
231:      PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)

```
*GitHub*: [230](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L230-L231)

```solidity
File: src/pools/CommunityStakingPool.sol

46:     constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams) {

```
*GitHub*: [46](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L46)

```solidity
File: src/pools/OperatorStakingPool.sol

144:    constructor(ConstructorParams memory params) StakingPoolBase(params.baseParams) {

```
*GitHub*: [144](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L144)

```solidity
File: src/pools/StakingPoolBase.sol

197     constructor(ConstructorParamsBase memory params)
198:      PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)

```
*GitHub*: [197](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L197-L198)

```solidity
File: src/rewards/RewardVault.sol

309     constructor(ConstructorParams memory params)
310:      PausableWithAccessControl(params.adminRoleTransferDelay, msg.sender)

```
*GitHub*: [309](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L309-L310)

```solidity
File: src/timelock/StakingTimelock.sol

52      constructor(ConstructorParams memory params)
53:       Timelock(params.minDelay, params.admin, params.proposers, params.executors, params.cancellers)

```
*GitHub*: [52](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L52-L53)

```solidity
File: src/timelock/Timelock.sol

165     constructor(
166       uint256 minDelay,
167       address admin,
168       address[] memory proposers,
169       address[] memory executors,
170:      address[] memory cancellers

```
*GitHub*: [165](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L165-L170)

</details>

### [G&#x2011;17] Don't use `_msgSender()` if not supporting EIP-2771
Use `msg.sender` if the code does not implement [EIP-2771 trusted forwarder](https://eips.ethereum.org/EIPS/eip-2771) support

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

207:      address sender = _msgSender();

```
*GitHub*: [207](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L207)


### [G&#x2011;18] Use assembly to emit events, in order to save gas
Using the [scratch space](https://github.com/Vectorized/solady/blob/30558f5402f02351b96eeb6eaf32bcea29773841/src/tokens/ERC1155.sol#L501-L504) for event arguments (two words or fewer) will save gas over needing Solidity's full abi memory expansion used for emitting normally.

*There are 32 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

17:      emit MigrationTargetSet(oldMigrationTarget, newMigrationTarget);

```
*GitHub*: [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L17-L17)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

269:     emit CommunityStakingPoolSet(address(oldCommunityStakingPool), address(newCommunityStakingPool));

282:     emit OperatorStakingPoolSet(address(oldOperatorStakingPool), address(newOperatorStakingPool));

308:     emit FeedConfigRemoved(feed);

408:     emit AlertsControllerMigrated(s_migrationTarget);

453:       emit FeedConfigRemoved(feed);

565:     emit SlashableOperatorsSet(feed, operators);

```
*GitHub*: [269](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L269-L269), [282](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L282-L282), [308](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L308-L308), [408](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L408-L408), [453](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L453-L453), [565](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L565-L565)

```solidity
File: src/pools/CommunityStakingPool.sol

122:     emit MerkleRootChanged(newMerkleRoot);

140:     emit OperatorStakingPoolChanged(oldOperatorStakingPool, address(newOperatorStakingPool));

```
*GitHub*: [122](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L122-L122), [140](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L140-L140)

```solidity
File: src/pools/OperatorStakingPool.sol

164:     emit AlerterRewardDeposited(amount, s_alerterRewardFunds);

182:     emit AlerterRewardWithdrawn(amount, s_alerterRewardFunds);

454:       emit OperatorAdded(operatorAddress);

507:       emit OperatorRemoved(operatorAddress, principal);

```
*GitHub*: [164](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L164-L164), [182](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L182-L182), [454](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L454-L454), [507](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L507-L507)

```solidity
File: src/pools/StakingPoolBase.sol

288:     emit UnbondingPeriodStarted(msg.sender);

319:     emit RewardVaultSet(oldRewardVault, address(newRewardVault));

362:       emit UnbondingPeriodReset(staker);

441:     emit MigrationProxySet(migrationProxy);

636:       emit PoolSizeIncreased(maxPoolSize);

640:       emit MaxPrincipalAmountIncreased(maxPrincipalPerStaker);

653:     emit UnbondingPeriodSet(oldUnbondingPeriod, unbondingPeriod);

665:     emit ClaimPeriodSet(oldClaimPeriod, claimPeriod);

```
*GitHub*: [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L288-L288), [319](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L319-L319), [362](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L362-L362), [441](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L441-L441), [636](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L636-L636), [640](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L640-L640), [653](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L653-L653), [665](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L665-L665)

```solidity
File: src/rewards/RewardVault.sol

321:     emit DelegationRateDenominatorSet(0, params.delegationRateDenominator);

324:     emit MultiplierDurationSet(0, params.initialMultiplierDuration);

447:     emit DelegationRateDenominatorSet(oldDelegationRateDenominator, newDelegationRateDenominator);

461:     emit MultiplierDurationSet(oldMultiplierDuration, newMultiplierDuration);

473:     emit MigrationSourceSet(oldMigrationSource, newMigrationSource);

680:     emit RewardClaimed(staker, claimableReward);

776:     emit RewardFinalized(staker, shouldForfeit);

799:     emit VaultClosed(totalUnvestedRewards);

```
*GitHub*: [321](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L321-L321), [324](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L324-L324), [447](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L447-L447), [461](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L461-L461), [473](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L473-L473), [680](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L680-L680), [776](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L776-L776), [799](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L799-L799)

```solidity
File: src/timelock/Timelock.sol

198:     emit MinDelayChange(0, minDelay);

378:     emit Cancelled(id);

462:     emit MinDelayChange(oldDelay, newDelay);

```
*GitHub*: [198](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L198-L198), [378](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L378-L378), [462](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L462-L462)

</details>

### [G&#x2011;19] Use assembly for small keccak256 hashes, in order to save gas
If the arguments to the encode call can fit into the scratch space (two words or fewer), then it's more efficient to use assembly to generate the hash (**80 gas**):
`keccak256(abi.encodePacked(x, y))` -> `assembly {mstore(0x00, a); mstore(0x20, b); let hash := keccak256(0x00, 0x40); }`

*There are 2 instances of this issue:*

```solidity
File: src/pools/CommunityStakingPool.sol

114:       leaf: keccak256(bytes.concat(keccak256(abi.encode(staker))))

```
*GitHub*: [114](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L114-L114), [114](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L114-L114)


### [G&#x2011;20] Avoid fetching a low-level call's return data by using assembly
Even if you don't assign the call's second return value, it still gets copied to memory. Use assembly instead to prevent this and save **159 [gas](https://gist.github.com/IllIllI000/0e18a40f3afb0b83f9a347b10ee89ad2)**:

`(bool success,) = payable(receiver).call{gas: gas, value: value}("");` -> `bool success; assembly { success := call(gas, receiver, value, 0, 0, 0, 0) }`

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

423:     (bool success,) = call.target.call{value: call.value}(call.data);

```
*GitHub*: [423](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L423-L423)


### [G&#x2011;21] Events should be emitted outside of loops
Emitting an event has an overhead of **375 gas**, which will be incurred on every iteration of the loop. It is cheaper to `emit` only [once](https://github.com/ethereum/EIPs/blob/adad5968fd6de29902174e0cb51c8fc3dceb9ab5/EIPS/eip-1155.md?plain=1#L68) after the loop has finished.

*There are 7 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

453:       emit FeedConfigRemoved(feed);

497        emit FeedConfigSet(
498          configParams.feed,
499          configParams.priorityPeriodThreshold,
500          configParams.regularPeriodThreshold,
501          configParams.slashableAmount,
502          configParams.alerterRewardAmount
503:       );

```
*GitHub*: [453](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L453-L453), [497](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L497-L503)

```solidity
File: src/pools/OperatorStakingPool.sol

338:       emit Slashed(operators[i], slashedAmount, updatedPrincipal);

454:       emit OperatorAdded(operatorAddress);

507:       emit OperatorRemoved(operatorAddress, principal);

```
*GitHub*: [338](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L338-L338), [454](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L454-L454), [507](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L507-L507)

```solidity
File: src/timelock/Timelock.sol

342        emit CallScheduled(
343          id, i, calls[i].target, calls[i].value, calls[i].data, predecessor, salt, delay
344:       );

412:       emit CallExecuted(id, i, calls[i].target, calls[i].value, calls[i].data);

```
*GitHub*: [342](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L342-L344), [412](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L412-L412)


### [G&#x2011;22] `>=` costs less gas than `>`
The compiler uses opcodes `GT` and `ISZERO` for solidity code that uses `>`, but only requires `LT` for `>=`, [which saves **3 gas**](https://gist.github.com/IllIllI000/3dc79d25acccfa16dee4e83ffdc6ffde). If `<` is being used, the condition can be inverted.

*There are 4 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

325:         principalAmount > operatorPrincipal ? operatorPrincipal : principalAmount;

357:       newAlerterRewardFunds < alerterRewardAmount ? newAlerterRewardFunds : alerterRewardAmount;

```
*GitHub*: [325](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L325-L325), [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L357-L357)

```solidity
File: src/rewards/RewardVault.sol

935:     if (forfeitedRewardAmountTimesUnstakedAmount < oldPrincipal) {

1460:    uint112 newlyEarnedBaseRewards = claimableBaseRewards > stakerReward.claimedBaseRewardsInPeriod

```
*GitHub*: [935](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L935-L935), [1460](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1460-L1460)


### [G&#x2011;23] Nesting `if`-statements is cheaper than using `&&`
Nesting `if`-statements avoids the stack operations of setting up and using an extra `jumpdest`, and saves **6 [gas](https://gist.github.com/IllIllI000/7f3b818abecfadbef93b894481ae7d19)**

*There are 16 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

530:     if (principalInOperatorPool == 0 && principalInCommunityStakingPool == 0) return returnValues;

558        if (i < operators.length - 1 && operator >= operators[i + 1]) {
559          revert InvalidOperatorList();
560:       }

```
*GitHub*: [530](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L530-L530), [558](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L558-L560)

```solidity
File: src/pools/CommunityStakingPool.sol

71       if (
72         sender != address(s_migrationProxy) && s_merkleRoot != bytes32(0)
73           && !_hasAccess(staker, abi.decode(data, (bytes32[])))
74       ) {
75         revert AccessForbidden();
76:      }

```
*GitHub*: [71](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L71-L76)

```solidity
File: src/pools/OperatorStakingPool.sol

443        if (i < operators.length - 1 && operatorAddress >= operators[i + 1]) {
444          revert InvalidOperatorList();
445:       }

```
*GitHub*: [443](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L443-L445)

```solidity
File: src/pools/StakingPoolBase.sol

283      if (staker.unbondingPeriodEndsAt != 0 && block.timestamp <= staker.claimPeriodEndsAt) {
284        revert UnbondingPeriodActive(staker.unbondingPeriodEndsAt);
285:     }

464      if (paused() && shouldClaimReward) {
465        revert CannotClaimRewardWhenPaused();
466:     }

479      if (amount < stakerPrincipal && updatedPrincipal < i_minPrincipalPerStaker) {
480        revert UnstakePrincipalBelowMinAmount();
481:     }

```
*GitHub*: [283](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L283-L285), [464](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L464-L466), [479](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L479-L481)

```solidity
File: src/rewards/RewardVault.sol

353      if (
354        pool != address(0) && pool != address(i_communityStakingPool)
355          && pool != address(i_operatorStakingPool)
356      ) {
357        revert InvalidPool();
358:     }

400      if (
401        delegatedRate == 0 && newDelegationRateDenominator != 0 && communityRateWithoutDelegation != 0
402      ) {
403        // delegated rate has rounded down to zero
404        revert InsufficentRewardsForDelegationRate();
405:     }

728:     if (paused() && shouldClaim) revert CannotClaimRewardWhenPaused();

1234     if (isDelegated && communityPoolShare != 0) {
1235       // prevent a possible rounding to zero error by validating inputs
1236       _checkForRoundingToZeroDelegationSplit({
1237         communityReward: communityReward,
1238         communityRate: communityRate,
1239         delegationDenominator: s_vaultConfig.delegationRateDenominator
1240       });
1241 
1242       // calculate the delegated pool reward and remove from community reward
1243       operatorDelegatedReward = communityReward / s_vaultConfig.delegationRateDenominator;
1244       communityReward -= operatorDelegatedReward;
1245 
1246       // calculate the delegated pool aggregate reward rate and remove from community rate
1247       delegatedRate = communityRate / s_vaultConfig.delegationRateDenominator;
1248       communityRate -= delegatedRate;
1249:    }

1275     if (
1276       rewardAmount != 0
1277         && (
1278           (
1279             operatorPoolShare != 0
1280               && rewardAmount.mulWadDown(operatorPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1281           )
1282             || (
1283               communityPoolShare != 0
1284                 && rewardAmount.mulWadDown(communityPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1285             )
1286         )
1287     ) {
1288       revert InvalidRewardAmount();
1289:    }

1328     if (communityReward != 0 && communityReward < delegationDenominator) {
1329       revert InvalidRewardAmount();
1330:    }

1332     if (communityRate != 0 && communityRate < delegationDenominator) {
1333       revert InvalidEmissionRate();
1334:    }

1685     if (addedRewardAmount != 0 && addedRewardAmount < s_vaultConfig.delegationRateDenominator) {
1686       revert InvalidRewardAmount();
1687:    }

1722     if (
1723       msg.sender != address(i_operatorStakingPool) && msg.sender != address(i_communityStakingPool)
1724     ) {
1725       revert AccessForbidden();
1726:    }

```
*GitHub*: [353](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L353-L358), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L400-L405), [728](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L728-L728), [1234](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1234-L1249), [1275](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1275-L1289), [1328](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1328-L1330), [1332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1332-L1334), [1685](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1685-L1687), [1722](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1722-L1726)


### [G&#x2011;24] Avoid updating storage when the value hasn't changed
If the old value is equal to the new value, not re-storing the value will avoid a Gsreset (**2900 gas**), potentially at the expense of a Gcoldsload (**2100 gas**) or a Gwarmaccess (**100 gas**)

*There are 7 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

261    function setCommunityStakingPool(CommunityStakingPool newCommunityStakingPool)
262      external
263      onlyRole(DEFAULT_ADMIN_ROLE)
264    {
265      if (address(newCommunityStakingPool) == address(0)) revert InvalidZeroAddress();
266  
267      CommunityStakingPool oldCommunityStakingPool = s_communityStakingPool;
268      s_communityStakingPool = newCommunityStakingPool;
269      emit CommunityStakingPoolSet(address(oldCommunityStakingPool), address(newCommunityStakingPool));
270:   }

274    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
275      external
276      onlyRole(DEFAULT_ADMIN_ROLE)
277    {
278      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();
279  
280      OperatorStakingPool oldOperatorStakingPool = s_operatorStakingPool;
281      s_operatorStakingPool = newOperatorStakingPool;
282      emit OperatorStakingPoolSet(address(oldOperatorStakingPool), address(newOperatorStakingPool));
283:   }

```
*GitHub*: [261](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L261-L270), [274](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L274-L283)

```solidity
File: src/pools/CommunityStakingPool.sol

120    function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE) {
121      s_merkleRoot = newMerkleRoot;
122      emit MerkleRootChanged(newMerkleRoot);
123:   }

133    function setOperatorStakingPool(OperatorStakingPool newOperatorStakingPool)
134      external
135      onlyRole(DEFAULT_ADMIN_ROLE)
136    {
137      if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();
138      address oldOperatorStakingPool = address(s_operatorStakingPool);
139      s_operatorStakingPool = newOperatorStakingPool;
140      emit OperatorStakingPoolChanged(oldOperatorStakingPool, address(newOperatorStakingPool));
141:   }

```
*GitHub*: [120](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L120-L123), [133](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L133-L141)

```solidity
File: src/pools/StakingPoolBase.sol

315    function setRewardVault(IRewardVault newRewardVault) external onlyRole(DEFAULT_ADMIN_ROLE) {
316      if (address(newRewardVault) == address(0)) revert InvalidZeroAddress();
317      address oldRewardVault = address(s_rewardVault);
318      s_rewardVault = newRewardVault;
319      emit RewardVaultSet(oldRewardVault, address(newRewardVault));
320:   }

```
*GitHub*: [315](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L315-L320)

```solidity
File: src/rewards/RewardVault.sol

467    function setMigrationSource(address newMigrationSource) external onlyRole(DEFAULT_ADMIN_ROLE) {
468      if (address(newMigrationSource) == address(0) || address(newMigrationSource) == address(this)) {
469        revert InvalidMigrationSource();
470      }
471      address oldMigrationSource = s_migrationSource;
472      s_migrationSource = newMigrationSource;
473      emit MigrationSourceSet(oldMigrationSource, newMigrationSource);
474:   }

```
*GitHub*: [467](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L467-L474)

```solidity
File: src/timelock/Timelock.sol

459    function updateDelay(uint256 newDelay) external virtual onlyRole(ADMIN_ROLE) {
460      uint256 oldDelay = s_minDelay;
461      s_minDelay = newDelay;
462      emit MinDelayChange(oldDelay, newDelay);
463:   }

```
*GitHub*: [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L459-L463)


### [G&#x2011;25] `<x> += <y>` costs more gas than `<x> = <x> + <y>` for state variables
Using the addition operator instead of plus-equals saves **[113 gas](https://gist.github.com/IllIllI000/cbbfb267425b898e5be734d4008d4fe8)**

*There are 9 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

160:     s_alerterRewardFunds += amount;

178:     s_alerterRewardFunds -= amount;

341:     s_pool.state.totalPrincipal -= totalSlashedAmount;

457:     s_numOperators += operators.length;

499:       s_pool.state.totalPrincipal -= principal;

510:     s_numOperators -= operators.length;

```
*GitHub*: [160](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L160-L160), [178](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L178-L178), [341](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L341-L341), [457](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L457-L457), [499](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L499-L499), [510](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L510-L510)

```solidity
File: src/pools/StakingPoolBase.sol

491:     s_pool.state.totalPrincipal -= amount;

```
*GitHub*: [491](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L491-L491)

```solidity
File: src/rewards/RewardVault.sol

1558:        s_rewardBuckets.communityBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();

1556:        s_rewardBuckets.operatorBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();

```
*GitHub*: [1558](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1558-L1558), [1556](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1556-L1556)


### [G&#x2011;26] State variable read in a loop
The state variable should be cached in a local variable rather than reading it on every iteration of the for-loop, which will replace each Gwarmaccess (**100 gas**) with a much cheaper stack read.

*There is one instance of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit s_pool
499:       s_pool.state.totalPrincipal -= principal;

```
*GitHub*: [499](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L499-L499)


### [G&#x2011;27] Using `bool`s for storage incurs overhead
```solidity
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.
```
https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27
Use `uint256(0)` and `uint256(1)` for true/false to avoid a Gwarmaccess (**[100 gas](https://gist.github.com/IllIllI000/1b70014db712f8572a72378321250058)**) for the extra SLOAD

*There is one instance of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

195:   bool internal s_isOpen;

```
*GitHub*: [195](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L195-L195)


### [G&#x2011;28] Use `uint256(1)`/`uint256(2)` instead of `true`/`false` to save gas for changes
Avoids a Gsset (**20000 gas**) when changing from `false` to `true`, after having been `true` in the past

*There is one instance of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

195:   bool internal s_isOpen;

```
*GitHub*: [195](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L195-L195)


### [G&#x2011;29] Using `this` to access functions results in an external call, wasting gas
External calls have an overhead of **100 gas**, which can be avoided by not referencing the function using `this`. Contracts [are allowed](https://docs.soliditylang.org/en/latest/contracts.html#function-overriding) to override their parents' functions and change the visibility from `external` to `public`, so make this change if it's required in order to call the function internally.

*There are 3 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

157:     return interfaceId == this.onTokenTransfer.selector || super.supportsInterface(interfaceId);

```
*GitHub*: [157](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L157-L157)

```solidity
File: src/pools/OperatorStakingPool.sol

568:     return interfaceID == this.onTokenTransfer.selector || super.supportsInterface(interfaceID);

```
*GitHub*: [568](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L568-L568)

```solidity
File: src/rewards/RewardVault.sol

553:     return interfaceID == this.onTokenTransfer.selector || super.supportsInterface(interfaceID);

```
*GitHub*: [553](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L553-L553)


### [G&#x2011;30] `unchecked {}`  can be used on the division of two `uint`s in order to save gas
The division cannot overflow, since both the numerator and the denominator are non-negative

*There are 5 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

291:       principalAmount = remainingSlashCapacity / stakers.length;

```
*GitHub*: [291](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L291-L291)

```solidity
File: src/rewards/RewardVault.sol

398:       : communityRateWithoutDelegation / newDelegationRateDenominator;

431:       uint256 delegatedRewards = unvestedRewards / newDelegationRateDenominator;

938:       forfeitedRewardAmount = forfeitedRewardAmountTimesUnstakedAmount / oldPrincipal;

1181:    bucket.rewardDurationEndsAt = (block.timestamp + (rewardAmount / emissionRate)).toUint80();

```
*GitHub*: [398](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L398-L398), [431](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L431-L431), [938](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L938-L938), [1181](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1181-L1181)


### [G&#x2011;31] Simple checks for zero can be done using assembly to save gas


*There are 51 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

38:      if (s_migrationTarget == address(0)) {

```
*GitHub*: [38](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L38-L38)

```solidity
File: src/MigrationProxy.sol

66:      if (address(params.LINKAddress) == address(0)) revert InvalidZeroAddress();

67:      if (address(params.v01StakingAddress) == address(0)) {

70:      if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();

71:      if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();

101:     if (stakerData.length == 0) {

```
*GitHub*: [66](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L66-L66), [67](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L67-L67), [70](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L70-L70), [71](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L71-L71), [101](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L101-L101)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

233:     if (address(params.communityStakingPool) == address(0)) {

236:     if (address(params.operatorStakingPool) == address(0)) {

265:     if (address(newCommunityStakingPool) == address(0)) revert InvalidZeroAddress();

278:     if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();

300:     if (s_feedConfigs[feed].priorityPeriodThreshold == 0) {

375:     if (feed == address(0)) revert InvalidZeroAddress();

378:     if (config.priorityPeriodThreshold == 0) revert FeedDoesNotExist();

444:       if (s_feedConfigs[feed].priorityPeriodThreshold == 0) {

476:       if (configParams.feed == address(0)) revert InvalidZeroAddress();

477:       if (configParams.priorityPeriodThreshold == 0) {

487:       if (configParams.alerterRewardAmount == 0) {

561:       if (operator == address(0)) revert InvalidZeroAddress();

```
*GitHub*: [233](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L233-L233), [236](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L236-L236), [265](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L265-L265), [278](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L278-L278), [300](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L300-L300), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L375-L375), [378](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L378-L378), [444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L444-L444), [476](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L476-L476), [477](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L477-L477), [487](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L487-L487), [561](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L561-L561)

```solidity
File: src/pools/CommunityStakingPool.sol

47:      if (address(params.operatorStakingPool) == address(0)) {

86:      if (s_merkleRoot == bytes32(0)) {

110:     if (s_merkleRoot == bytes32(0)) return true;

137:     if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();

```
*GitHub*: [47](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L47-L47), [86](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L86-L86), [110](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L110-L110), [137](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L137-L137)

```solidity
File: src/pools/OperatorStakingPool.sol

159:     if (amount == 0) revert InvalidAlerterRewardFundAmount();

544:     if (withdrawableAmount == 0) {

```
*GitHub*: [159](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L159-L159), [544](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L544-L544)

```solidity
File: src/pools/StakingPoolBase.sol

200:     if (address(params.LINKAddress) == address(0)) revert InvalidZeroAddress();

201:     if (params.minPrincipalPerStaker == 0) revert InvalidMinStakeAmount();

243:     if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

281:     if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

316:     if (address(newRewardVault) == address(0)) revert InvalidZeroAddress();

345:     if (amount == 0) return;

349:     if (staker == address(0)) revert InvalidZeroAddress();

437:     if (migrationProxy == address(0)) revert InvalidZeroAddress();

469:     if (amount == 0) revert UnstakeZeroAmount();

704:     if (data.length == 0) revert InvalidData();

760:     if (s_migrationProxy == address(0)) revert MigrationProxyNotSet();

766:     if (address(s_rewardVault) == address(0)) revert RewardVaultNotSet();

797:     if (s_pool.state.closedAt == 0) revert PoolNotClosed();

```
*GitHub*: [200](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L200-L200), [201](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L201-L201), [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L243-L243), [281](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L281-L281), [316](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L316-L316), [345](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L345-L345), [349](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L349-L349), [437](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L437-L437), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L469-L469), [704](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L704-L704), [760](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L760-L760), [766](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L766-L766), [797](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L797-L797)

```solidity
File: src/rewards/RewardVault.sol

312:     if (address(params.linkToken) == address(0)) revert InvalidZeroAddress();

313:     if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();

314:     if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();

670:     if (claimableReward == 0) {

693:     if (staker == address(0)) return;

1025:    if (stakedAt == 0) return 0;

1028:    if (multiplierDuration == 0) return MAX_MULTIPLIER;

1180:    if (emissionRate == 0) return;

1386:    if (totalPrincipal == 0) return rewardBucket.vestedRewardPerToken;

1583:    if (forfeitedReward == 0) return (0, 0, 0);

```
*GitHub*: [312](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L312-L312), [313](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L313-L313), [314](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L314-L314), [670](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L670-L670), [693](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L693-L693), [1025](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1025-L1025), [1028](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1028-L1028), [1180](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1180-L1180), [1386](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1386-L1386), [1583](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1583-L1583)

```solidity
File: src/timelock/StakingTimelock.sol

55:      if (params.rewardVault == address(0)) revert InvalidZeroAddress();

56:      if (params.communityStakingPool == address(0)) revert InvalidZeroAddress();

57:      if (params.operatorStakingPool == address(0)) revert InvalidZeroAddress();

58:      if (params.alertsController == address(0)) revert InvalidZeroAddress();

```
*GitHub*: [55](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L55-L55), [56](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L56-L56), [57](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L57-L57), [58](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L58-L58)

</details>
## Disputed Issues

The issues below may be reported by other bots/wardens, but can be penalized/ignored since either the rule or the specified instances are invalid


### [D&#x2011;01] ~~Insufficient oracle validation~~
The general rule is valid, but the instances below are invalid

*There is one instance of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

517:     (uint256 roundId,,, uint256 updatedAt,) = AggregatorV3Interface(feed).latestRoundData();

```
*GitHub*: [517](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L517-L517)


### [D&#x2011;02] ~~Missing checks for whether the L2 Sequencer is active~~
The general rule is valid, but the instances below are invalid

*There is one instance of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

517:     (uint256 roundId,,, uint256 updatedAt,) = AggregatorV3Interface(feed).latestRoundData();

```
*GitHub*: [517](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L517-L517)


### [D&#x2011;03] ~~Unsafe downcast~~
When a type is downcast to a smaller type, the higher order bits are truncated, effectively applying a modulo to the original value. Without any other checks, this wrapping will lead to unexpected behavior and bugs

*There are 5 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit uint112
322:        uint256 operatorPrincipal = uint112(history >> 112);

```
*GitHub*: [322](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L322)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit uint112
241:      uint112 stakerPrincipal = uint112(history >> 112);

/// @audit uint112
280:      uint112 stakerPrincipal = uint112(history >> 112);

/// @audit uint112
515:      uint112 stakerPrincipal = uint112(history >> 112);

/// @audit uint112
527:      uint112 stakerPrincipal = uint112(history >> 112);

```
*GitHub*: [241](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L241), [280](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L280), [515](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L515), [527](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L527)


### [D&#x2011;04] ~~Signature use at deadlines should be allowed~~
The general rule is valid, but the instances below are invalid

*There is one instance of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

726:     if (staker.unbondingPeriodEndsAt == 0 || block.timestamp < staker.unbondingPeriodEndsAt) {

```
*GitHub*: [726](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L726-L726)


### [D&#x2011;05] ~~External calls in an un-bounded `for-`loop may result in a DOS~~
The general rule is valid, but the instances below are invalid

*There are 3 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

329:       s_rewardVault.updateReward(operators[i], operatorPrincipal);

438:       IRewardVault.StakerReward memory stakerReward = s_rewardVault.getStoredReward(operatorAddress);

491        s_rewardVault.finalizeReward({
492          staker: operatorAddress,
493          oldPrincipal: principal,
494          unstakedAmount: principal,
495          shouldClaim: false,
496          stakedAt: stakedAtTime
497:       });

```
*GitHub*: [329](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L329-L329), [438](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L438-L438), [491](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L491-L497)


### [D&#x2011;06] ~~Large or complicated code bases should implement invariant tests~~
Large code bases, or code with lots of inline-assembly, complicated math, or complicated interactions between multiple contracts, should implement [invariant fuzzing tests](https://medium.com/coinmonks/smart-contract-fuzzing-d9b88e0b0a05). Invariant fuzzers such as Echidna require the test writer to come up with invariants which should not be violated under any circumstances, and the fuzzer tests various inputs and function calls to ensure that the invariants always hold. Even code with 100% code coverage can still have bugs due to the order of the operations a user performs, and invariant fuzzers, with properly and extensively-written invariants, can close this testing gap significantly.

*There is one instance of this issue:*

```solidity
File: Various Files


```


### [D&#x2011;07] ~~Setters should prevent re-setting of the same value~~
The general rule is valid, but the instances below are invalid

*There is one instance of this issue:*

```solidity
File: src/Migratable.sol

11     function setMigrationTarget(address newMigrationTarget) external virtual override {
12       _validateMigrationTarget(newMigrationTarget);
13   
14       address oldMigrationTarget = s_migrationTarget;
15       s_migrationTarget = newMigrationTarget;
16   
17       emit MigrationTargetSet(oldMigrationTarget, newMigrationTarget);
18:    }

```
*GitHub*: [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L11-L18)


### [D&#x2011;08] ~~The result of function calls should be cached rather than re-calling the function~~
The instances below point to the second+ call of the function within a single function

*There is one instance of this issue:*

```solidity
File: src/rewards/RewardVault.sol

/// @audit vestedRewardPerToken.toUint80() on line 1556
1558:         s_rewardBuckets.communityBase.vestedRewardPerToken += vestedRewardPerToken.toUint80();

```
*GitHub*: [1558](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1558)


### [D&#x2011;09] ~~`require()` or `revert()` statements that check input arguments should be at the top of the function~~
Checks that involve constants should come before checks that involve state variables, function calls, and calculations. By doing these checks first, the function is able to revert before wasting a Gcoldsload (**2100 gas***) in a function that may ultimately revert in the unhappy case.

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

/// @audit expensive op on line 357
358:      require(delay >= getMinDelay(calls), 'Timelock: insufficient delay');

```
*GitHub*: [358](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L358)


### [D&#x2011;10] ~~Avoid updating storage when the value hasn't changed~~
The general rule is valid, but the instances below are invalid

*There is one instance of this issue:*

```solidity
File: src/Migratable.sol

11     function setMigrationTarget(address newMigrationTarget) external virtual override {
12       _validateMigrationTarget(newMigrationTarget);
13   
14       address oldMigrationTarget = s_migrationTarget;
15       s_migrationTarget = newMigrationTarget;
16   
17       emit MigrationTargetSet(oldMigrationTarget, newMigrationTarget);
18:    }

```
*GitHub*: [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L11-L18)


### [D&#x2011;11] ~~Duplicated `require()`/`revert()` checks should be refactored to a modifier or function~~
This instance appears only once

*There are 6 instances of this issue:*

```solidity
File: src/timelock/Timelock.sol

357:      require(!isOperation(id), 'Timelock: operation already scheduled');

358:      require(delay >= getMinDelay(calls), 'Timelock: insufficient delay');

375:      require(isOperationPending(id), 'Timelock: operation cannot be cancelled');

424:      require(success, 'Timelock: underlying transaction reverted');

434       require(
435         predecessor == bytes32(0) || isOperationDone(predecessor), 'Timelock: missing dependency'
436:      );

486:      require(newDelay >= s_minDelay, 'Timelock: insufficient delay');

```
*GitHub*: [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L357), [358](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L358), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L375), [424](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L424), [434](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L434-L436), [486](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L486)


### [D&#x2011;12] ~~SPDX identifier should be the in the first line of a solidity file~~
It's already on the first line

*There are 10 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L1)

```solidity
File: src/MigrationProxy.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L1)

```solidity
File: src/PausableWithAccessControl.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L1)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L1)

```solidity
File: src/pools/CommunityStakingPool.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L1)

```solidity
File: src/pools/OperatorStakingPool.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L1)

```solidity
File: src/pools/StakingPoolBase.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L1)

```solidity
File: src/rewards/RewardVault.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1)

```solidity
File: src/timelock/StakingTimelock.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L1)

```solidity
File: src/timelock/Timelock.sol

1:    // SPDX-License-Identifier: MIT

```
*GitHub*: [1](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L1)

</details>

### [D&#x2011;13] ~~Prefer double quotes for string quoting~~
The examples below are not strings. Furthermore it's perfectly reasonable to use single quotes within text ([p. 16](https://www.ox.ac.uk/sites/files/oxford/media_wysiwyg/University%20of%20Oxford%20Style%20Guide.pdf)).

*There are 4 instances of this issue:*

```solidity
File: src/timelock/Timelock.sol

322      *
323:     * - the caller must have the 'proposer' or 'admin' role.

367      *
368:     * - the caller must have the 'canceller' or 'admin' role.

390      *
391:     * - the caller must have the 'executor' or 'admin' role.

454      *
455:     * - the caller must have the 'admin' role.

```
*GitHub*: [322](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L322-L323), [367](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L367-L368), [390](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L390-L391), [454](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L454-L455)


### [D&#x2011;14] ~~Public functions not used internally can be marked as external to save gas~~
After Solidity version 0.6.9 both `public` and `external` functions save the [same amount of gas](https://ethereum.stackexchange.com/a/107939), and since these files are >0.6.9, these findings are invalid

*There are 6 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

156:    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

```
*GitHub*: [156](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L156)

```solidity
File: src/pools/OperatorStakingPool.sol

204     function grantRole(
205       bytes32 role,
206:      address account

567:    function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

```
*GitHub*: [204](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L204-L206), [567](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L567)

```solidity
File: src/rewards/RewardVault.sol

552:    function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

```
*GitHub*: [552](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L552)

```solidity
File: src/timelock/Timelock.sol

332     function scheduleBatch(
333       Call[] calldata calls,
334       bytes32 predecessor,
335       bytes32 salt,
336       uint256 delay
337:    ) public virtual onlyRoleOrAdminRole(PROPOSER_ROLE) {

401     function executeBatch(
402       Call[] calldata calls,
403       bytes32 predecessor,
404       bytes32 salt
405:    ) public payable virtual onlyRoleOrAdminRole(EXECUTOR_ROLE) {

```
*GitHub*: [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L332-L337), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L401-L405)


### [D&#x2011;15] ~~Must approve or increase allowance first~~
The bot is just flagging `transferFrom()` calls without a prior approval. Many projects require you to approve their contract before using it, so this suggestion is not helpful, and certainly is not 'Low' severity, since that's the design and no funds are lost. There is no way for the project to address this issue other than by requiring that the caller send the tokens themselves, which has its own risks.

*There are 2 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

163:     i_LINK.transferFrom({from: msg.sender, to: address(this), value: amount});

```
*GitHub*: [163](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L163-L163)

```solidity
File: src/rewards/RewardVault.sol

370:     i_LINK.transferFrom({from: msg.sender, to: address(this), value: amount});

```
*GitHub*: [370](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L370-L370)


### [D&#x2011;16] ~~Array lengths not checked~~
These instances only have one array

*There are 17 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

288    function setFeedConfigs(SetFeedConfigParams[] calldata configs)
289      external
290      onlyRole(DEFAULT_ADMIN_ROLE)
291:   {

371    function setSlashableOperators(
372      address[] calldata operators,
373      address feed
374:   ) external onlyRole(DEFAULT_ADMIN_ROLE) {

436    function sendMigrationData(address[] calldata feeds)
437      external
438      onlyRole(DEFAULT_ADMIN_ROLE)
439      validateMigrationTargetSet
440:   {

472:   function _setFeedConfigs(SetFeedConfigParams[] memory configs) private {

554:   function _setSlashableOperators(address feed, address[] memory operators) private {

```
*GitHub*: [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L288-L291), [371](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L371-L374), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L436-L440), [472](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L472-L472), [554](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L554-L554)

```solidity
File: src/pools/CommunityStakingPool.sol

96     function hasAccess(
97       address staker,
98       bytes32[] calldata proof
99:    ) external view override returns (bool) {

109:   function _hasAccess(address staker, bytes32[] memory proof) private view returns (bool) {

```
*GitHub*: [96](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L96-L99), [109](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L109-L109)

```solidity
File: src/pools/OperatorStakingPool.sol

277    function slashAndReward(
278      address[] calldata stakers,
279      address alerter,
280      uint256 principalAmount,
281      uint256 alerterRewardAmount
282:   ) external override onlySlasher whenActive {

312    function _slashOperators(
313      address[] calldata operators,
314      uint256 principalAmount
315:   ) private returns (uint256) {

426    function addOperators(address[] calldata operators)
427      external
428      validateRewardVaultSet
429      validatePoolSpace(
430        s_pool.configs.maxPoolSize,
431        s_pool.configs.maxPrincipalPerStaker,
432        s_numOperators + operators.length
433      )
434      onlyRole(DEFAULT_ADMIN_ROLE)
435:   {

473    function removeOperators(address[] calldata operators)
474      external
475      onlyRole(DEFAULT_ADMIN_ROLE)
476      whenOpen
477:   {

```
*GitHub*: [277](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L277-L282), [312](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L312-L315), [426](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L426-L435), [473](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L473-L477)

```solidity
File: src/timelock/Timelock.sol

288:   function getMinDelay(Call[] calldata calls) public view returns (uint256) {

308    function hashOperationBatch(
309      Call[] calldata calls,
310      bytes32 predecessor,
311      bytes32 salt
312:   ) public pure virtual returns (bytes32) {

332    function scheduleBatch(
333      Call[] calldata calls,
334      bytes32 predecessor,
335      bytes32 salt,
336      uint256 delay
337:   ) public virtual onlyRoleOrAdminRole(PROPOSER_ROLE) {

356:   function _schedule(bytes32 id, uint256 delay, Call[] calldata calls) private {

401    function executeBatch(
402      Call[] calldata calls,
403      bytes32 predecessor,
404      bytes32 salt
405:   ) public payable virtual onlyRoleOrAdminRole(EXECUTOR_ROLE) {

469:   function updateDelay(UpdateDelayParams[] calldata params) external virtual onlyRole(ADMIN_ROLE) {

```
*GitHub*: [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L288-L288), [308](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L308-L312), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L332-L337), [356](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L356-L356), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L401-L405), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L469-L469)


### [D&#x2011;17] ~~Shorten the array rather than copying to a new one~~
None of these examples are of filtering out entries from an array.

*There are 2 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

243      SetFeedConfigParams[] memory setFeedConfigParams = new SetFeedConfigParams[](1);
244      for (uint256 i; i < params.feedConfigs.length; ++i) {
245        ConstructorFeedConfigParams memory config = params.feedConfigs[i];
246:       setFeedConfigParams[0] = SetFeedConfigParams({

360      address[] memory pools = new address[](2);
361      pools[0] = address(s_operatorStakingPool);
362      pools[1] = address(s_communityStakingPool);
363:     return pools;

```
*GitHub*: [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L243-L246), [360](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L360-L363)


### [D&#x2011;18] ~~Bad bot rules~~
The titles below correspond to issues submitted by various bots, where the submitting bot solely submitted invalid findings (i.e. the submitter didn't filter the results of the rule), so they should be given extra scrutiny:
- **Max allowance is not compatible with all tokens** - internal approval for the contract's own balance, so the rule is pointing to the support **for** max allowance
- **increase/decrease allowance should be used instead of approve** - this is an internal approval function
- **Must approve or increase allowance first** - the rule is flagging all transferFrom() calls, without approval logic
- **Contract existence is not checked before low level call** - reading calldata, not making an external call
- **Empty function blocks** - the bot's removed the extensive comment documentation in the 'code blocks' it shows for these virtual functions used to allow child contracts to implement functionality, or are constructors
- **Utility contracts can be made into libraries** - all provided examples are invalid
- **Address values should be used through variables rather than used as literals** - none of the examples are of addresses
- **Employ Explicit Casting to Bytes or Bytes32 for Enhanced Code Clarity and Meaning** - the large majority of the examples are of multiple arguments, not just one
- **Some if-statement can be converted to a ternary** - you can't use a ternary when only one of the branches is a `return`
- **Addresses shouldn't be hard-coded** - none of these are addresses
- **State variables used within a function more than once should be cached to save gas** - none of these are state variables
- **Use storage instead of memory for structs/arrays** - these all are array call arguments, not arrays copied from storage
- **Use bitmap to save gas** - none of these are examples where bitmaps can be used
- **Consider merging sequential for loops** - the examples cannot be merged
- **Emitting storage values instead of the memory one.** - this is a gas finding, not a Low one
- **`selfbalance()` is cheaper than `address(this).balance`** - some bots submit the issue twice (under the heading `Use assembly when getting a contractundefineds balance of ETH`)
- **Imports could be organized more systematically** - a lot of bots are blindly checking for interfaces not coming first. That is not the only way of organizing imports, and most projects are doing it in a systematic, valid, way
- **Unused * definition** - some bots are reporting false positives for these rules. Check that it isn't used, or that if it's used, that there are two definitions, with one being unused
- **`internal` functions not called by the contract should be removed** - some bots are reporting false positives when the function is called by a child contract, rather than the defining contract
- **Change `public` to `external` for functions that are not called internally** - some bots are reporting false positives when the function is called by a child contract, rather than the defining contract
- **Avoid contract existence checks by using low level calls** - at least one bot isn't checking that the version is prior to 0.8.10
- **For Operations that will not overflow, you could use unchecked** - at least one bot is flagging every single line, which has nothing to do with using `unchecked`

Some of these have been raised as invalid in multiple contests, and the bot owners have not fixed them. Without penalties, they're unlikely to make any changes

*There is one instance of this issue:*

```solidity
File: src/timelock/Timelock.sol

2:   pragma solidity 0.8.19;

```
*GitHub*: [2](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L2-L2)


### [D&#x2011;19] ~~The result of function calls should be cached rather than re-calling the function~~
These cannot be cached

*There are 2 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

453:       emit FeedConfigRemoved(feed);

```
*GitHub*: [453](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L453-L453)

```solidity
File: src/pools/StakingPoolBase.sol

636:       emit PoolSizeIncreased(maxPoolSize);

```
*GitHub*: [636](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L636-L636)


### [D&#x2011;20] ~~`require()` / `revert()` statements should have descriptive reason strings~~
These are not `revert()` calls, so these findings are invalid

*There are 112 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

27:        revert InvalidMigrationTarget();

39:        revert InvalidMigrationTarget();

```
*GitHub*: [27](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L27-L27), [39](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L39-L39)

```solidity
File: src/MigrationProxy.sol

66:      if (address(params.LINKAddress) == address(0)) revert InvalidZeroAddress();

68:        revert InvalidZeroAddress();

70:      if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();

71:      if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();

96:      if (source != i_v01StakingAddress) revert InvalidSourceAddress();

109:       revert InvalidAmounts(amountToStake, amountToWithdraw, amount);

171:     if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();

```
*GitHub*: [66](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L66-L66), [68](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L68-L68), [70](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L70-L70), [71](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L71-L71), [96](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L96-L96), [109](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L109-L109), [171](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L171-L171)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

234:       revert InvalidZeroAddress();

237:       revert InvalidZeroAddress();

265:     if (address(newCommunityStakingPool) == address(0)) revert InvalidZeroAddress();

278:     if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();

301:       revert FeedDoesNotExist();

332:     if (!returnValues.canAlert) revert AlertInvalid();

375:     if (feed == address(0)) revert InvalidZeroAddress();

378:     if (config.priorityPeriodThreshold == 0) revert FeedDoesNotExist();

427:       revert InvalidMigrationTarget();

445:         revert FeedDoesNotExist();

476:       if (configParams.feed == address(0)) revert InvalidZeroAddress();

478:         revert InvalidPriorityPeriodThreshold();

481:         revert InvalidRegularPeriodThreshold();

485:         revert InvalidSlashableAmount();

488:         revert InvalidAlerterRewardAmount();

559:         revert InvalidOperatorList();

561:       if (operator == address(0)) revert InvalidZeroAddress();

575:     if (!_hasSlasherRole()) revert DoesNotHaveSlasherRole();

```
*GitHub*: [234](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L234-L234), [237](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L237-L237), [265](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L265-L265), [278](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L278-L278), [301](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L301-L301), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L332-L332), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L375-L375), [378](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L378-L378), [427](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L427-L427), [445](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L445-L445), [476](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L476-L476), [478](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L478-L478), [481](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L481-L481), [485](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L485-L485), [488](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L488-L488), [559](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L559-L559), [561](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L561-L561), [575](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L575-L575)

```solidity
File: src/pools/CommunityStakingPool.sol

48:        revert InvalidZeroAddress();

75:        revert AccessForbidden();

80:        revert AccessForbidden();

87:        revert MerkleRootNotSet();

137:     if (address(newOperatorStakingPool) == address(0)) revert InvalidZeroAddress();

```
*GitHub*: [48](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L48-L48), [75](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L75-L75), [80](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L80-L80), [87](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L87-L87), [137](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L137-L137)

```solidity
File: src/pools/OperatorStakingPool.sol

159:     if (amount == 0) revert InvalidAlerterRewardFundAmount();

174:     if (s_isOpen) revert PoolNotClosed();

176:       revert InsufficientAlerterRewardFunds(amount, s_alerterRewardFunds);

208:     if (role == SLASHER_ROLE) revert InvalidRole();

233:       revert InvalidSlasher();

243:       revert ISlashable.InvalidSlasherConfig();

395:     if (!s_operators[staker].isOperator) revert StakerNotOperator();

416:       revert InadequateInitialOperatorCount(s_numOperators, i_minInitialOperatorCount);

440:         revert OperatorCannotBeCommunityStaker(operatorAddress);

444:         revert InvalidOperatorList();

448:         revert OperatorAlreadyExists(operatorAddress);

451:         revert OperatorHasBeenRemoved(operatorAddress);

484:         revert OperatorDoesNotExist(operatorAddress);

540:       revert StakerNotInClaimPeriod(msg.sender);

545:       revert UnstakeExceedsPrincipal();

574:       revert AccessForbidden();

592:       revert InsufficientPoolSpace(maxPoolSize, maxPrincipalPerStaker, numOperators);

```
*GitHub*: [159](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L159-L159), [174](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L174-L174), [176](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L176-L176), [208](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L208-L208), [233](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L233-L233), [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L243-L243), [395](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L395-L395), [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L416-L416), [440](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L440-L440), [444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L444-L444), [448](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L448-L448), [451](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L451-L451), [484](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L484-L484), [540](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L540-L540), [545](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L545-L545), [574](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L574-L574), [592](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L592-L592)

```solidity
File: src/pools/StakingPoolBase.sol

200:     if (address(params.LINKAddress) == address(0)) revert InvalidZeroAddress();

201:     if (params.minPrincipalPerStaker == 0) revert InvalidMinStakeAmount();

203:       revert InvalidMinStakeAmount();

206:       revert InvalidUnbondingPeriodRange(MIN_UNBONDING_PERIOD, params.maxUnbondingPeriod);

209:       revert InvalidClaimPeriodRange(params.minClaimPeriod, params.maxClaimPeriod);

243:     if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

269:       revert InvalidMigrationTarget();

281:     if (stakerPrincipal == 0) revert StakeNotFound(msg.sender);

284:       revert UnbondingPeriodActive(staker.unbondingPeriodEndsAt);

316:     if (address(newRewardVault) == address(0)) revert InvalidZeroAddress();

349:     if (staker == address(0)) revert InvalidZeroAddress();

437:     if (migrationProxy == address(0)) revert InvalidZeroAddress();

462:       revert StakerNotInClaimPeriod(msg.sender);

465:       revert CannotClaimRewardWhenPaused();

469:     if (amount == 0) revert UnstakeZeroAmount();

475:     if (amount > stakerPrincipal) revert UnstakeExceedsPrincipal();

480:       revert UnstakePrincipalBelowMinAmount();

626:       revert InvalidPoolSize(maxPoolSize);

632:     ) revert InvalidMaxStakeAmount(maxPrincipalPerStaker);

648:       revert InvalidUnbondingPeriod();

660:       revert InvalidClaimPeriod();

677:       revert InsufficientStakeAmount();

680:       revert ExceedsMaxStakeAmount();

684:       revert ExceedsMaxPoolSize();

704:     if (data.length == 0) revert InvalidData();

754:     if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();

760:     if (s_migrationProxy == address(0)) revert MigrationProxyNotSet();

766:     if (address(s_rewardVault) == address(0)) revert RewardVaultNotSet();

772:     if (s_isOpen) revert PoolHasBeenOpened();

773:     if (s_pool.state.closedAt != 0) revert PoolHasBeenClosed();

779:     if (s_pool.state.closedAt != 0) revert PoolHasBeenClosed();

785:     if (!s_isOpen) revert PoolNotOpen();

791:     if (!isActive()) revert PoolNotActive();

797:     if (s_pool.state.closedAt == 0) revert PoolNotClosed();

803:     if (!s_rewardVault.isOpen() || s_rewardVault.isPaused()) revert RewardVaultNotActive();

```
*GitHub*: [200](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L200-L200), [201](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L201-L201), [203](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L203-L203), [206](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L206-L206), [209](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L209-L209), [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L243-L243), [269](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L269-L269), [281](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L281-L281), [284](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L284-L284), [316](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L316-L316), [349](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L349-L349), [437](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L437-L437), [462](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L462-L462), [465](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L465-L465), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L469-L469), [475](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L475-L475), [480](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L480-L480), [626](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L626-L626), [632](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L632-L632), [648](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L648-L648), [660](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L660-L660), [677](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L677-L677), [680](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L680-L680), [684](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L684-L684), [704](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L704-L704), [754](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L754-L754), [760](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L760-L760), [766](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L766-L766), [772](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L772-L772), [773](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L773-L773), [779](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L779-L779), [785](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L785-L785), [791](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L791-L791), [797](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L797-L797), [803](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L803-L803)

```solidity
File: src/rewards/RewardVault.sol

312:     if (address(params.linkToken) == address(0)) revert InvalidZeroAddress();

313:     if (address(params.communityStakingPool) == address(0)) revert InvalidZeroAddress();

314:     if (address(params.operatorStakingPool) == address(0)) revert InvalidZeroAddress();

357:       revert InvalidPool();

390:       revert InvalidDelegationRateDenominator();

404:       revert InsufficentRewardsForDelegationRate();

469:       revert InvalidMigrationSource();

499:       revert InvalidMigrationTarget();

567:     if (msg.sender != address(i_LINK)) revert SenderNotLinkToken();

568:     if (sender != s_migrationSource) revert AccessForbidden();

589:     if (totalUnvestedRewards != amount) revert InvalidRewardAmount();

671:       revert NoRewardToClaim();

728:     if (paused() && shouldClaim) revert CannotClaimRewardWhenPaused();

833:     revert InvalidPool();

1161:    if (amount + remainingRewards < emissionRate) revert RewardDurationTooShort();

1288:      revert InvalidRewardAmount();

1314:      revert InvalidEmissionRate();

1329:      revert InvalidRewardAmount();

1333:      revert InvalidEmissionRate();

1686:      revert InvalidRewardAmount();

1693:      revert InvalidEmissionRate();

1715:      revert AccessForbidden();

1725:      revert AccessForbidden();

1732:    if (!s_vaultConfig.isOpen) revert VaultAlreadyClosed();

```
*GitHub*: [312](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L312-L312), [313](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L313-L313), [314](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L314-L314), [357](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L357-L357), [390](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L390-L390), [404](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L404-L404), [469](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L469-L469), [499](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L499-L499), [567](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L567-L567), [568](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L568-L568), [589](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L589-L589), [671](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L671-L671), [728](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L728-L728), [833](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L833-L833), [1161](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1161-L1161), [1288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1288-L1288), [1314](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1314-L1314), [1329](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1329-L1329), [1333](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1333-L1333), [1686](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1686-L1686), [1693](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1693-L1693), [1715](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1715-L1715), [1725](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1725-L1725), [1732](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1732-L1732)

```solidity
File: src/timelock/StakingTimelock.sol

55:      if (params.rewardVault == address(0)) revert InvalidZeroAddress();

56:      if (params.communityStakingPool == address(0)) revert InvalidZeroAddress();

57:      if (params.operatorStakingPool == address(0)) revert InvalidZeroAddress();

58:      if (params.alertsController == address(0)) revert InvalidZeroAddress();

```
*GitHub*: [55](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L55-L55), [56](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L56-L56), [57](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L57-L57), [58](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L58-L58)

</details>

### [D&#x2011;21] ~~Default `bool` values are manually reset~~
Using delete instead of assigning zero/false to state variables does not save any extra gas with the optimizer [on](https://gist.github.com/IllIllI000/ef8ec3a70aede7f12433fe63dc418515#with-the-optimizer-set-at-200-runs) (saves 5-8 gas with optimizer completely off), so this finding is invalid, especially since if they were interested in gas savings, they'd have the optimizer enabled. Some bots are also flagging `true` rather than just `false`

*There are 7 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

537:       returnValues.canAlert = true;

```
*GitHub*: [537](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L537-L537)

```solidity
File: src/pools/OperatorStakingPool.sol

453:       operator.isOperator = true;

500:       operator.isOperator = false;

501:       operator.isRemoved = true;

```
*GitHub*: [453](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L453-L453), [500](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L500-L500), [501](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L501-L501)

```solidity
File: src/pools/StakingPoolBase.sol

417:     s_isOpen = true;

426:     s_isOpen = false;

```
*GitHub*: [417](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L417-L417), [426](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L426-L426)

```solidity
File: src/rewards/RewardVault.sol

326:     s_vaultConfig.isOpen = true;

```
*GitHub*: [326](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L326-L326)


### [D&#x2011;22] ~~Use delete instead of setting mapping/state variable to zero, to save gas~~
Using delete instead of assigning zero to state variables does not save any extra gas with the optimizer [on](https://gist.github.com/IllIllI000/ef8ec3a70aede7f12433fe63dc418515#with-the-optimizer-set-at-200-runs) (saves 5-8 gas with optimizer completely off), so this finding is invalid, especially since if they were interested in gas savings, they'd have the optimizer enabled.

*There is one instance of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

547:     s_operators[msg.sender].removedPrincipal = 0;

```
*GitHub*: [547](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L547-L547)


### [D&#x2011;23] ~~Events that mark critical parameter changes should contain both the old and the new value~~
These are not critical parameter changes

*There are 40 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

344:     emit AlertRaised(msg.sender, returnValues.roundId, returnValues.feedConfig.alerterRewardAmount);

408:     emit AlertsControllerMigrated(s_migrationTarget);

453:       emit FeedConfigRemoved(feed);

460:     emit MigrationDataSent(s_migrationTarget, feeds, migrationData);

497        emit FeedConfigSet(
498          configParams.feed,
499          configParams.priorityPeriodThreshold,
500          configParams.regularPeriodThreshold,
501          configParams.slashableAmount,
502          configParams.alerterRewardAmount
503:       );

565:     emit SlashableOperatorsSet(feed, operators);

```
*GitHub*: [344](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L344-L344), [408](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L408-L408), [453](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L453-L453), [460](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L460-L460), [497](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L497-L503), [565](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L565-L565)

```solidity
File: src/pools/OperatorStakingPool.sol

164:     emit AlerterRewardDeposited(amount, s_alerterRewardFunds);

182:     emit AlerterRewardWithdrawn(amount, s_alerterRewardFunds);

253:     emit SlasherConfigSet(slasher, config.refillRate, config.slashCapacity);

338:       emit Slashed(operators[i], slashedAmount, updatedPrincipal);

364:     emit AlertingRewardPaid(alerter, alerterRewardActual, alerterRewardAmount);

552:     emit Unstaked(msg.sender, withdrawableAmount, 0);

```
*GitHub*: [164](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L164-L164), [182](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L182-L182), [253](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L253-L253), [338](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L338-L338), [364](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L364-L364), [552](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L552-L552)

```solidity
File: src/pools/StakingPoolBase.sol

252:     emit StakerMigrated(s_migrationTarget, stakerPrincipal, migrationData);

288:     emit UnbondingPeriodStarted(msg.sender);

362:       emit UnbondingPeriodReset(staker);

418:     emit PoolOpened();

428:     emit PoolClosed();

504:     emit Unstaked(msg.sender, amount, claimedReward);

636:       emit PoolSizeIncreased(maxPoolSize);

640:       emit MaxPrincipalAmountIncreased(maxPrincipalPerStaker);

653:     emit UnbondingPeriodSet(oldUnbondingPeriod, unbondingPeriod);

665:     emit ClaimPeriodSet(oldClaimPeriod, claimPeriod);

697:     emit Staked(sender, newPrincipal, newTotalPrincipal);

```
*GitHub*: [252](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L252-L252), [288](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L288-L288), [362](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L362-L362), [418](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L418-L418), [428](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L428-L428), [504](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L504-L504), [636](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L636-L636), [640](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L640-L640), [653](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L653-L653), [665](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L665-L665), [697](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L697-L697)

```solidity
File: src/rewards/RewardVault.sol

321:     emit DelegationRateDenominatorSet(0, params.delegationRateDenominator);

324:     emit MultiplierDurationSet(0, params.initialMultiplierDuration);

327:     emit VaultOpened();

539:     emit VaultMigrated(s_migrationTarget, totalUnvestedRewards, totalEmissionRate);

613:     emit VaultMigrationProcessed(sender, totalUnvestedRewards, totalEmissionRate);

648      emit StakerRewardUpdated(
649        msg.sender,
650        stakerReward.finalizedBaseReward,
651        stakerReward.finalizedDelegatedReward,
652        stakerReward.baseRewardPerToken,
653        stakerReward.operatorDelegatedRewardPerToken,
654        stakerReward.claimedBaseRewardsInPeriod
655:     );

680:     emit RewardClaimed(staker, claimableReward);

776:     emit RewardFinalized(staker, shouldForfeit);

777      emit StakerRewardUpdated(
778        staker,
779        stakerReward.finalizedBaseReward,
780        stakerReward.finalizedDelegatedReward,
781        stakerReward.baseRewardPerToken,
782        stakerReward.operatorDelegatedRewardPerToken,
783        stakerReward.claimedBaseRewardsInPeriod
784:     );

799:     emit VaultClosed(totalUnvestedRewards);

1354       emit PoolRewardUpdated(
1355         s_rewardBuckets.communityBase.vestedRewardPerToken,
1356         s_rewardBuckets.operatorBase.vestedRewardPerToken,
1357         s_rewardBuckets.operatorDelegated.vestedRewardPerToken
1358:      );

1562     emit ForfeitedRewardDistributed(
1563       vestedReward, vestedRewardPerToken, reclaimableReward, toOperatorPool
1564:    );

```
*GitHub*: [321](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L321-L321), [324](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L324-L324), [327](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L327-L327), [539](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L539-L539), [613](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L613-L613), [648](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L648-L655), [680](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L680-L680), [776](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L776-L776), [777](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L777-L784), [799](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L799-L799), [1354](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1354-L1358), [1562](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1562-L1564)

```solidity
File: src/timelock/Timelock.sol

198:     emit MinDelayChange(0, minDelay);

342        emit CallScheduled(
343          id, i, calls[i].target, calls[i].value, calls[i].data, predecessor, salt, delay
344:       );

378:     emit Cancelled(id);

412:       emit CallExecuted(id, i, calls[i].target, calls[i].value, calls[i].data);

489:     emit MinDelayChange(target, selector, oldDelay, newDelay);

```
*GitHub*: [198](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L198-L198), [342](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L342-L344), [378](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L378-L378), [412](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L412-L412), [489](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L489-L489)


### [D&#x2011;24] ~~Empty function body~~
These constructors have calls to base contracts, so the empty function body cannot be removed

*There is one instance of this issue:*

```solidity
File: src/PausableWithAccessControl.sol

16     constructor(
17       uint48 adminRoleTransferDelay,
18       address defaultAdmin
19:    ) AccessControlDefaultAdminRules(adminRoleTransferDelay, defaultAdmin) {}

```
*GitHub*: [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L16-L19)


### [D&#x2011;25] ~~`abi.encode()` is less efficient than `abi.encodepacked()`~~
`abi.encodePacked()` does not always save gas over `abi.encode()` and in fact often costs [more](https://gist.github.com/IllIllI000/2ee970e4f05af4d2a3d89a56b5cc93a5) gas. The [comparison](https://github.com/ConnorBlockchain/Solidity-Encode-Gas-Comparison) sometimes linked to itself even shows that when addresses are involved, the packed flavor costs more gas.

*There are 2 instances of this issue:*

```solidity
File: src/pools/CommunityStakingPool.sol

114:       leaf: keccak256(bytes.concat(keccak256(abi.encode(staker))))

```
*GitHub*: [114](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L114-L114)

```solidity
File: src/pools/StakingPoolBase.sol

245:     bytes memory migrationData = abi.encode(msg.sender, stakerStakedAtTime, data);

```
*GitHub*: [245](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L245-L245)


### [D&#x2011;26] ~~Event names should use CamelCase~~
The instances below are already CamelCase (events are supposed to use CamelCase, not lowerCamelCase)

*There are 40 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

65:    event AlertRaised(address indexed alerter, uint256 indexed roundId, uint96 rewardAmount);

74     event FeedConfigSet(
75       address indexed feed,
76       uint32 priorityPeriodThreshold,
77       uint32 regularPeriodThreshold,
78       uint96 slashableAmount,
79       uint96 alerterRewardAmount
80:    );

83:    event FeedConfigRemoved(address indexed feed);

88:    event SlashableOperatorsSet(address indexed feed, address[] operators);

93     event CommunityStakingPoolSet(
94       address indexed oldCommunityStakingPool, address indexed newCommunityStakingPool
95:    );

100    event OperatorStakingPoolSet(
101      address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
102:   );

108:   event MigrationDataSent(address indexed migrationTarget, address[] feeds, bytes migrationData);

112:   event AlertsControllerMigrated(address indexed migrationTarget);

```
*GitHub*: [65](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L65-L65), [74](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L74-L80), [83](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L83-L83), [88](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L88-L88), [93](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L93-L95), [100](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L100-L102), [108](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L108-L108), [112](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L112-L112)

```solidity
File: src/pools/CommunityStakingPool.sol

27     event OperatorStakingPoolChanged(
28       address indexed oldOperatorStakingPool, address indexed newOperatorStakingPool
29:    );

```
*GitHub*: [27](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L27-L29)

```solidity
File: src/pools/OperatorStakingPool.sol

69:    event OperatorRemoved(address indexed operator, uint256 principal);

72:    event OperatorAdded(address indexed operator);

76:    event AlerterRewardDeposited(uint256 amountFunded, uint256 totalBalance);

81:    event AlerterRewardWithdrawn(uint256 amountWithdrawn, uint256 remainingBalance);

90     event AlertingRewardPaid(
91       address indexed alerter, uint256 alerterRewardActual, uint256 alerterRewardExpected
92:    );

97:    event SlasherConfigSet(address indexed slasher, uint256 refillRate, uint256 slashCapacity);

103:   event Slashed(address indexed operator, uint256 slashedAmount, uint256 updatedStakerPrincipal);

```
*GitHub*: [69](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L69-L69), [72](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L72-L72), [76](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L76-L76), [81](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L81-L81), [90](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L90-L92), [97](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L97-L97), [103](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L103-L103)

```solidity
File: src/pools/StakingPoolBase.sol

83:    event UnbondingPeriodStarted(address indexed staker);

87:    event UnbondingPeriodReset(address indexed staker);

92:    event UnbondingPeriodSet(uint256 oldUnbondingPeriod, uint256 newUnbondingPeriod);

97:    event ClaimPeriodSet(uint256 oldClaimPeriod, uint256 newClaimPeriod);

102:   event RewardVaultSet(address indexed oldRewardVault, address indexed newRewardVault);

108:   event StakerMigrated(address indexed migrationTarget, uint256 amount, bytes migrationData);

```
*GitHub*: [83](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L83-L83), [87](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L87-L87), [92](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L92-L92), [97](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L97-L97), [102](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L102-L102), [108](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L108-L108)

```solidity
File: src/rewards/RewardVault.sol

103    event DelegationRateDenominatorSet(
104      uint256 oldDelegationRateDenominator, uint256 newDelegationRateDenominator
105:   );

111:   event RewardAdded(address indexed pool, uint256 amount, uint256 emissionRate);

114:   event VaultOpened();

119:   event VaultClosed(uint256 totalUnvestedRewards);

122:   event RewardClaimed(address indexed staker, uint256 claimedRewards);

127:   event MultiplierDurationSet(uint256 oldMultiplierDuration, uint256 newMultiplierDuration);

135    event ForfeitedRewardDistributed(
136      uint256 vestedReward,
137      uint256 vestedRewardPerToken,
138      uint256 reclaimedReward,
139      bool isOperatorReward
140:   );

149    event VaultMigrated(
150      address indexed migrationTarget, uint256 totalUnvestedRewards, uint256 totalEmissionRate
151:   );

159    event VaultMigrationProcessed(
160      address indexed migrationSource, uint256 totalUnvestedRewards, uint256 totalEmissionRate
161:   );

166:   event MigrationSourceSet(address indexed oldMigrationSource, address indexed newMigrationSource);

173    event PoolRewardUpdated(
174      uint256 communityBaseRewardPerToken,
175      uint256 operatorBaseRewardPerToken,
176      uint256 operatorDelegatedRewardPerToken
177:   );

186    event StakerRewardUpdated(
187      address indexed staker,
188      uint256 finalizedBaseReward,
189      uint256 finalizedDelegatedReward,
190      uint256 baseRewardPerToken,
191      uint256 operatorDelegatedRewardPerToken,
192      uint256 claimedBaseRewardsInPeriod
193:   );

198:   event RewardFinalized(address staker, bool shouldForfeit);

```
*GitHub*: [103](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L103-L105), [111](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L111-L111), [114](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L114-L114), [119](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L119-L119), [122](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L122-L122), [127](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L127-L127), [135](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L135-L140), [149](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L149-L151), [159](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L159-L161), [166](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L166-L166), [173](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L173-L177), [186](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L186-L193), [198](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L198-L198)

```solidity
File: src/timelock/Timelock.sol

56     event CallScheduled(
57       bytes32 indexed id,
58       uint256 indexed index,
59       address target,
60       uint256 value,
61       bytes data,
62       bytes32 predecessor,
63       bytes32 salt,
64       uint256 delay
65:    );

76     event CallExecuted(
77       bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data
78:    );

84:    event Cancelled(bytes32 indexed id);

91:    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

100    event MinDelayChange(
101      address indexed target, bytes4 selector, uint256 oldDuration, uint256 newDuration
102:   );

```
*GitHub*: [56](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L56-L65), [76](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L76-L78), [84](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L84-L84), [91](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L91-L91), [100](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L100-L102)


### [D&#x2011;27] ~~`internal` functions not called by the contract should be removed~~
These are required to exist, and are called by parent contracts

*There are 7 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

416    function _validateMigrationTarget(address newMigrationTarget)
417      internal
418      override(Migratable)
419      onlyRole(DEFAULT_ADMIN_ROLE)
420:   {

```
*GitHub*: [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L416-L420)

```solidity
File: src/pools/CommunityStakingPool.sol

59     function _validateOnTokenTransfer(
60       address sender,
61       address staker,
62       bytes calldata data
63:    ) internal view override {

85:    function _handleOpen() internal view override(StakingPoolBase) {

```
*GitHub*: [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L59-L63), [85](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L85-L85)

```solidity
File: src/pools/OperatorStakingPool.sol

393:   function _validateOnTokenTransfer(address, address staker, bytes calldata) internal view override {

414:   function _handleOpen() internal view override(StakingPoolBase) {

```
*GitHub*: [393](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L393-L393), [414](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L414-L414)

```solidity
File: src/pools/StakingPoolBase.sol

258    function _validateMigrationTarget(address newMigrationTarget)
259      internal
260      override(Migratable)
261      onlyRole(DEFAULT_ADMIN_ROLE)
262:   {

```
*GitHub*: [258](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L258-L262)

```solidity
File: src/rewards/RewardVault.sol

488    function _validateMigrationTarget(address newMigrationTarget)
489      internal
490      override(Migratable)
491      onlyRole(DEFAULT_ADMIN_ROLE)
492:   {

```
*GitHub*: [488](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L488-L492)


### [D&#x2011;28] ~~Change `public` to `external` for functions that are not called internally~~
These functions are referenced by modifiers

*There is one instance of this issue:*

```solidity
File: src/pools/StakingPoolBase.sol

571:   function isActive() public view override returns (bool) {

```
*GitHub*: [571](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L571-L571)


### [D&#x2011;29] ~~Function Names Not in mixedCase~~
According to the Solidity Style Guide, non-`external`/`public` function names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables), and all of these fall into that category

*There are 66 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

22:    function _validateMigrationTarget(address newMigrationTarget) internal virtual {

```
*GitHub*: [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L22-L22)

```solidity
File: src/MigrationProxy.sol

126:   function _migrateToPool(address staker, uint256 amount, bytes calldata data) internal {

```
*GitHub*: [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L126-L126)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

416    function _validateMigrationTarget(address newMigrationTarget)
417      internal
418      override(Migratable)
419      onlyRole(DEFAULT_ADMIN_ROLE)
420:   {

472:   function _setFeedConfigs(SetFeedConfigParams[] memory configs) private {

513    function _canAlert(
514      address alerter,
515      address feed
516:   ) private view returns (CanAlertReturnValues memory) {

547:   function _hasSlasherRole() private view returns (bool) {

554:   function _setSlashableOperators(address feed, address[] memory operators) private {

```
*GitHub*: [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L416-L420), [472](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L472-L472), [513](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L513-L516), [547](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L547-L547), [554](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L554-L554)

```solidity
File: src/pools/CommunityStakingPool.sol

59     function _validateOnTokenTransfer(
60       address sender,
61       address staker,
62       bytes calldata data
63:    ) internal view override {

85:    function _handleOpen() internal view override(StakingPoolBase) {

109:   function _hasAccess(address staker, bytes32[] memory proof) private view returns (bool) {

```
*GitHub*: [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L59-L63), [85](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L85-L85), [109](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L109-L109)

```solidity
File: src/pools/OperatorStakingPool.sol

241:   function _setSlasherConfig(address slasher, SlasherConfig calldata config) private {

312    function _slashOperators(
313      address[] calldata operators,
314      uint256 principalAmount
315:   ) private returns (uint256) {

350    function _payAlerter(
351      address alerter,
352      uint256 totalSlashedAmount,
353      uint256 alerterRewardAmount
354:   ) private {

375    function _getRemainingSlashCapacity(
376      SlasherConfig memory slasherConfig,
377      address slasher
378:   ) private view returns (uint256) {

393:   function _validateOnTokenTransfer(address, address staker, bytes calldata) internal view override {

414:   function _handleOpen() internal view override(StakingPoolBase) {

```
*GitHub*: [241](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L241-L241), [312](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L312-L315), [350](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L350-L354), [375](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L375-L378), [393](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L393-L393), [414](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L414-L414)

```solidity
File: src/pools/StakingPoolBase.sol

258    function _validateMigrationTarget(address newMigrationTarget)
259      internal
260      override(Migratable)
261      onlyRole(DEFAULT_ADMIN_ROLE)
262:   {

381    function _validateOnTokenTransfer(
382      address sender,
383      address staker,
384      bytes calldata data
385:   ) internal view virtual;

432:   function _handleOpen() internal view virtual;

622:   function _setPoolConfig(uint256 maxPoolSize, uint256 maxPrincipalPerStaker) internal {

646:   function _setUnbondingPeriod(uint256 unbondingPeriod) internal {

658:   function _setClaimPeriod(uint256 claimPeriod) private {

672:   function _increaseStake(address sender, uint256 newPrincipal, uint256 amount) internal {

703:   function _getStakerAddress(bytes calldata data) internal pure returns (address) {

717:   function _canUnstake(Staker storage staker) internal view returns (bool) {

725:   function _inClaimPeriod(Staker storage staker) private view returns (bool) {

737    function _updateStakerHistory(
738      Staker storage staker,
739      uint256 latestPrincipal,
740      uint256 latestStakedAtTime
741:   ) internal {

```
*GitHub*: [258](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L258-L262), [381](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L381-L385), [432](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L432-L432), [622](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L622-L622), [646](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L646-L646), [658](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L658-L658), [672](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L672-L672), [703](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L703-L703), [717](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L717-L717), [725](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L725-L725), [737](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L737-L741)

```solidity
File: src/rewards/RewardVault.sol

488    function _validateMigrationTarget(address newMigrationTarget)
489      internal
490      override(Migratable)
491      onlyRole(DEFAULT_ADMIN_ROLE)
492:   {

664    function _transferRewards(
665      address staker,
666      StakerReward memory stakerReward
667:   ) private returns (uint256) {

920    function _forfeitStakerBaseReward(
921      StakerReward memory stakerReward,
922      uint256 fullForfeitedRewardAmount,
923      uint256 unstakedAmount,
924      uint256 oldPrincipal,
925      bool isOperator
926:   ) private {

968    function _stopVestingRewardsToBuckets()
969      private
970      returns (uint256, uint256, uint256, uint256, uint256)
971:   {

999:   function _getTotalPrincipal(IStakingPool stakingPool) private view returns (uint256) {

1012   function _getStakerPrincipal(
1013     address staker,
1014     IStakingPool stakingPool
1015:  ) private view returns (uint256) {

1024:  function _getMultiplier(uint256 stakedAt) private view returns (uint256) {

1042   function _getStakerStakedAtTime(
1043     address staker,
1044     IStakingPool stakingPool
1045:  ) private view returns (uint256) {

1055:  function _getMigratedAtCheckpointId(IStakingPool stakingPool) private view returns (uint256) {

1066   function _getMigratedAtTotalPoolPrincipal(IStakingPool stakingPool)
1067     private
1068     view
1069     returns (uint256)
1070:  {

1079:  function _checkpointStakingPools() private {

1103:  function _stopVestingBucketRewards(RewardBucket storage bucket) private returns (uint256) {

1113:  function _updateRewardBuckets(address pool, uint256 amount, uint256 emissionRate) private {

1152   function _updateRewardBucket(
1153     RewardBucket storage bucket,
1154     uint256 amount,
1155     uint256 emissionRate
1156:  ) private {

1175   function _updateRewardDurationEndsAt(
1176     RewardBucket storage bucket,
1177     uint256 rewardAmount,
1178     uint256 emissionRate
1179:  ) private {

1193   function _getBucketRewardAndEmissionRateSplit(
1194     address pool,
1195     uint256 amount,
1196     uint256 emissionRate,
1197     bool isDelegated
1198:  ) private view returns (BucketRewardEmissionSplit memory) {

1269   function _checkForRoundingToZeroRewardAmountSplit(
1270     uint256 rewardAmount,
1271     uint256 communityPoolShare,
1272     uint256 operatorPoolShare,
1273     uint256 totalPoolShare
1274:  ) private pure {

1298   function _checkForRoundingToZeroEmissionRateSplit(
1299     uint256 emissionRate,
1300     uint256 communityPoolShare,
1301     uint256 operatorPoolShare,
1302     uint256 totalPoolShare
1303:  ) private pure {

1323   function _checkForRoundingToZeroDelegationSplit(
1324     uint256 communityReward,
1325     uint256 communityRate,
1326     uint256 delegationDenominator
1327:  ) private pure {

1338:  function _updateRewardPerToken() private {

1366:  function _calculatePoolsRewardPerToken() private view returns (uint256, uint256, uint256) {

1382   function _calculateVestedRewardPerToken(
1383     RewardBucket memory rewardBucket,
1384     uint256 totalPrincipal
1385:  ) private view returns (uint256) {

1404   function _calculateEarnedBaseReward(
1405     StakerReward memory stakerReward,
1406     uint256 stakerPrincipal,
1407     uint256 baseRewardPerToken
1408:  ) private pure returns (uint256) {

1423   function _calculateEarnedDelegatedReward(
1424     StakerReward memory stakerReward,
1425     uint256 stakerPrincipal,
1426     uint256 operatorDelegatedRewardPerToken
1427:  ) private pure returns (uint256) {

1444   function _applyMultiplier(
1445     StakerReward memory stakerReward,
1446     bool shouldForfeit,
1447     uint256 stakerStakedAtTime
1448:  ) private view returns (uint256) {

1484   function _calculateAccruedReward(
1485     uint256 principal,
1486     uint256 rewardPerToken,
1487     uint256 vestedRewardPerToken
1488:  ) private pure returns (uint256) {

1500   function _calculateStakerReward(
1501     address staker,
1502     bool isOperator,
1503     uint256 stakerPrincipal
1504:  ) private view returns (StakerReward memory) {

1546   function _distributeForfeitedReward(
1547     uint256 forfeitedReward,
1548     uint256 amountOfRecipientTokens,
1549     bool toOperatorPool
1550:  ) private returns (uint256, uint256) {

1579   function _calculateForfeitedRewardDistribution(
1580     uint256 forfeitedReward,
1581     uint256 amountOfRecipientTokens
1582:  ) private pure returns (uint256, uint256, uint256) {

1604   function _updateStakerRewardPerToken(
1605     StakerReward memory stakerReward,
1606     bool isOperator
1607:  ) private view {

1621:  function _getReward(address staker) private view returns (StakerReward memory, uint256) {

1672:  function _getUnvestedRewards(RewardBucket memory bucket) private view returns (uint256) {

1682:  function _validateAddedRewards(uint256 addedRewardAmount, uint256 totalEmissionRate) private view {

1701:  function _isOperator(address staker) private view returns (bool) {

```
*GitHub*: [488](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L488-L492), [664](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L664-L667), [920](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L920-L926), [968](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L968-L971), [999](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L999-L999), [1012](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1012-L1015), [1024](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1024-L1024), [1042](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1042-L1045), [1055](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1055-L1055), [1066](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1066-L1070), [1079](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1079-L1079), [1103](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1103-L1103), [1113](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1113-L1113), [1152](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1152-L1156), [1175](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1175-L1179), [1193](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1193-L1198), [1269](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1269-L1274), [1298](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1298-L1303), [1323](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1323-L1327), [1338](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1338-L1338), [1366](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1366-L1366), [1382](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1382-L1385), [1404](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1404-L1408), [1423](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1423-L1427), [1444](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1444-L1448), [1484](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1484-L1488), [1500](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1500-L1504), [1546](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1546-L1550), [1579](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1579-L1582), [1604](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1604-L1607), [1621](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1621-L1621), [1672](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1672-L1672), [1682](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1682-L1682), [1701](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1701-L1701)

```solidity
File: src/timelock/Timelock.sol

356:   function _schedule(bytes32 id, uint256 delay, Call[] calldata calls) private {

422:   function _execute(Call calldata call) internal virtual {

432:   function _beforeCall(bytes32 id, bytes32 predecessor) private view {

443:   function _afterCall(bytes32 id) private {

485:   function _setDelay(address target, bytes4 selector, uint256 newDelay) internal {

```
*GitHub*: [356](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L356-L356), [422](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L422-L422), [432](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L432-L432), [443](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L443-L443), [485](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L485-L485)

</details>

### [D&#x2011;30] ~~Use multiple `require()` and `if` statements instead of `&&`~~
The suggestion in this rule is not logically equivalent for `if`-statements unless they're nested, and cannot be done if there's an `else`-block without spending more gas. It doesn't seem more readable for `require()`s either

*There are 16 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

530      if (principalInOperatorPool == 0 && principalInCommunityStakingPool == 0) return returnValues;
531  
532:     // nobody can (feed is not stale)

558        if (i < operators.length - 1 && operator >= operators[i + 1]) {
559          revert InvalidOperatorList();
560:       }

```
*GitHub*: [530](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L530-L532), [558](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L558-L560)

```solidity
File: src/pools/CommunityStakingPool.sol

72         sender != address(s_migrationProxy) && s_merkleRoot != bytes32(0)
73           && !_hasAccess(staker, abi.decode(data, (bytes32[])))
74       ) {
75:        revert AccessForbidden();

```
*GitHub*: [72](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L72-L75)

```solidity
File: src/pools/OperatorStakingPool.sol

443        if (i < operators.length - 1 && operatorAddress >= operators[i + 1]) {
444          revert InvalidOperatorList();
445:       }

```
*GitHub*: [443](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L443-L445)

```solidity
File: src/pools/StakingPoolBase.sol

283      if (staker.unbondingPeriodEndsAt != 0 && block.timestamp <= staker.claimPeriodEndsAt) {
284        revert UnbondingPeriodActive(staker.unbondingPeriodEndsAt);
285:     }

464      if (paused() && shouldClaimReward) {
465        revert CannotClaimRewardWhenPaused();
466:     }

479      if (amount < stakerPrincipal && updatedPrincipal < i_minPrincipalPerStaker) {
480        revert UnstakePrincipalBelowMinAmount();
481:     }

```
*GitHub*: [283](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L283-L285), [464](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L464-L466), [479](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L479-L481)

```solidity
File: src/rewards/RewardVault.sol

354        pool != address(0) && pool != address(i_communityStakingPool)
355          && pool != address(i_operatorStakingPool)
356      ) {
357:       revert InvalidPool();

401        delegatedRate == 0 && newDelegationRateDenominator != 0 && communityRateWithoutDelegation != 0
402      ) {
403:       // delegated rate has rounded down to zero

728      if (paused() && shouldClaim) revert CannotClaimRewardWhenPaused();
729  
730:     _updateRewardPerToken();

1234     if (isDelegated && communityPoolShare != 0) {
1235       // prevent a possible rounding to zero error by validating inputs
1236:      _checkForRoundingToZeroDelegationSplit({

1276       rewardAmount != 0
1277         && (
1278           (
1279             operatorPoolShare != 0
1280               && rewardAmount.mulWadDown(operatorPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1281           )
1282             || (
1283               communityPoolShare != 0
1284                 && rewardAmount.mulWadDown(communityPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1285             )
1286         )
1287     ) {
1288:      revert InvalidRewardAmount();

1328     if (communityReward != 0 && communityReward < delegationDenominator) {
1329       revert InvalidRewardAmount();
1330:    }

1332     if (communityRate != 0 && communityRate < delegationDenominator) {
1333       revert InvalidEmissionRate();
1334:    }

1685     if (addedRewardAmount != 0 && addedRewardAmount < s_vaultConfig.delegationRateDenominator) {
1686       revert InvalidRewardAmount();
1687:    }

1723       msg.sender != address(i_operatorStakingPool) && msg.sender != address(i_communityStakingPool)
1724     ) {
1725:      revert AccessForbidden();

```
*GitHub*: [354](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L354-L357), [401](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L401-L403), [728](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L728-L730), [1234](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1234-L1236), [1276](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1276-L1288), [1328](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1328-L1330), [1332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1332-L1334), [1685](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1685-L1687), [1723](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1723-L1725)


### [D&#x2011;31] ~~Use `@inheritdoc` rather than using a non-standard annotation~~


*There are 4 instances of this issue:*

```solidity
File: src/MigrationProxy.sol

151    /// check if the contract deployed at this address is a valid
152    /// LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
153    /// if it implements the onTokenTransfer function.
154    /// @param interfaceId The ID of the interface to check against
155    /// @return bool True if the contract is a valid LINKTokenReceiver.
156:   function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

```
*GitHub*: [151](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L151-L156)

```solidity
File: src/pools/OperatorStakingPool.sol

562    /// check if the contract deployed at this address is a valid
563    /// LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
564    /// if it implements the onTokenTransfer function.
565    /// @param interfaceID The ID of the interface to check against
566    /// @return bool True if the contract is a valid LINKTokenReceiver.
567:   function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

```
*GitHub*: [562](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L562-L567)

```solidity
File: src/rewards/RewardVault.sol

547    /// check if the contract deployed at this address is a valid
548    /// LINKTokenReceiver.  A contract is a valid LINKTokenReceiver
549    /// if it implements the onTokenTransfer function.
550    /// @param interfaceID The ID of the interface to check against
551    /// @return bool True if the contract is a valid LINKTokenReceiver.
552:   function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

561    /// vault transfers LINK tokens to this contract.
562    /// @param sender The sender of the tokens
563    /// @param amount The amount of tokens transferred
564    /// @param data The data passed from the previous version reward vault
565    /// @dev precondition The migration source must be set.
566:   function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external override {

```
*GitHub*: [547](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L547-L552), [561](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L561-L566)


### [D&#x2011;32] ~~Using `storage` instead of `memory` for structs/arrays saves gas~~
There is no storage being read from

*There are 3 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

243:     SetFeedConfigParams[] memory setFeedConfigParams = new SetFeedConfigParams[](1);

360:     address[] memory pools = new address[](2);

441:     LastAlertedRoundId[] memory lastAlertedRoundIds = new LastAlertedRoundId[](feeds.length);

```
*GitHub*: [243](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L243-L243), [360](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L360-L360), [441](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L441-L441)


### [D&#x2011;33] ~~State variables not capped at reasonable values~~
These assignments already have the necessary checks

*There are 2 instances of this issue:*

```solidity
File: src/pools/OperatorStakingPool.sol

178:     s_alerterRewardFunds -= amount;

```
*GitHub*: [178](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L178-L178)

```solidity
File: src/pools/StakingPoolBase.sol

491:     s_pool.state.totalPrincipal -= amount;

```
*GitHub*: [491](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L491-L491)


### [D&#x2011;34] ~~Contracts are not using their OZ Upgradeable counterparts~~
The rule is true only when the contract being defined is upgradeable, which isn't the case for these invalid examples

*There are 18 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/MigrationProxy.sol

/// @audit MigrationProxy is a non-upgradeable contract
10:  import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

```
*GitHub*: [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L10-L10)

```solidity
File: src/PausableWithAccessControl.sol

/// @audit PausableWithAccessControl is a non-upgradeable contract
4    import {AccessControlDefaultAdminRules} from
5:     '@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol';

/// @audit PausableWithAccessControl is a non-upgradeable contract
6:   import {Pausable} from '@openzeppelin/contracts/security/Pausable.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L4-L5), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L6-L6)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

/// @audit PriceFeedAlertsController is a non-upgradeable contract
9:   import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

/// @audit PriceFeedAlertsController is a non-upgradeable contract
10:  import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

```
*GitHub*: [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L9-L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L10-L10)

```solidity
File: src/pools/CommunityStakingPool.sol

/// @audit CommunityStakingPool is a non-upgradeable contract
9:   import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

```
*GitHub*: [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L9-L9)

```solidity
File: src/pools/OperatorStakingPool.sol

/// @audit OperatorStakingPool is a non-upgradeable contract
7    import {AccessControlDefaultAdminRules} from
8:     '@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol';

/// @audit OperatorStakingPool is a non-upgradeable contract
9:   import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

/// @audit OperatorStakingPool is a non-upgradeable contract
10:  import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

```
*GitHub*: [7](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L7-L8), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L9-L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L10-L10)

```solidity
File: src/pools/StakingPoolBase.sol

/// @audit StakingPoolBase is a non-upgradeable contract
8:   import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

/// @audit StakingPoolBase is a non-upgradeable contract
9:   import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

/// @audit StakingPoolBase is a non-upgradeable contract
10:  import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

```
*GitHub*: [8](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L8-L8), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L9-L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L10-L10)

```solidity
File: src/rewards/RewardVault.sol

/// @audit RewardVault is a non-upgradeable contract
10:  import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

/// @audit RewardVault is a non-upgradeable contract
11:  import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

/// @audit RewardVault is a non-upgradeable contract
12:  import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

```
*GitHub*: [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L10-L10), [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L11-L11), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L12-L12)

```solidity
File: src/timelock/StakingTimelock.sol

/// @audit StakingTimelock is a non-upgradeable contract
4:   import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/StakingTimelock.sol#L4-L4)

```solidity
File: src/timelock/Timelock.sol

/// @audit Timelock is a non-upgradeable contract
4:   import {AccessControlEnumerable} from '@openzeppelin/contracts/access/AccessControlEnumerable.sol';

/// @audit Timelock is a non-upgradeable contract
5:   import {EnumerableSet} from '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L4-L4), [5](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L5-L5)

</details>

### [D&#x2011;35] ~~Unnecessary look up in if condition~~


*There are 27 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

24         newMigrationTarget == address(0) || newMigrationTarget == address(this)
25:          || newMigrationTarget == s_migrationTarget || newMigrationTarget.code.length == 0

24:        newMigrationTarget == address(0) || newMigrationTarget == address(this)

```
*GitHub*: [24](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L24-L25), [24](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L24-L25), [24](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L24-L24)

```solidity
File: src/MigrationProxy.sol

157:     return interfaceId == this.onTokenTransfer.selector || super.supportsInterface(interfaceId);

```
*GitHub*: [157](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L157-L157)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

483:       if (configParams.slashableAmount == 0 || configParams.slashableAmount > operatorMaxPrincipal)

523        !_hasSlasherRole() || feedConfig.priorityPeriodThreshold == 0
524:         || s_lastAlertedRoundIds[feed] >= roundId

523:       !_hasSlasherRole() || feedConfig.priorityPeriodThreshold == 0

```
*GitHub*: [483](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L483-L483), [523](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L523-L524), [523](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L523-L523)

```solidity
File: src/pools/CommunityStakingPool.sol

79:      if (s_operatorStakingPool.isOperator(staker) || s_operatorStakingPool.isRemoved(staker)) {

```
*GitHub*: [79](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L79-L79)

```solidity
File: src/pools/OperatorStakingPool.sol

242:     if (config.slashCapacity == 0 || config.refillRate == 0) {

568:     return interfaceID == this.onTokenTransfer.selector || super.supportsInterface(interfaceID);

```
*GitHub*: [242](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L242-L242), [568](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L568-L568)

```solidity
File: src/pools/StakingPoolBase.sol

208:     if (params.minClaimPeriod == 0 || params.minClaimPeriod >= params.maxClaimPeriod) {

625:     if (maxPoolSize == 0 || maxPoolSize < configs.maxPoolSize) {

630        maxPrincipalPerStaker == 0 || maxPrincipalPerStaker > maxPoolSize
631:         || configs.maxPrincipalPerStaker > maxPrincipalPerStaker

630:       maxPrincipalPerStaker == 0 || maxPrincipalPerStaker > maxPoolSize

647:     if (unbondingPeriod < MIN_UNBONDING_PERIOD || unbondingPeriod > i_maxUnbondingPeriod) {

659:     if (claimPeriod < i_minClaimPeriod || claimPeriod > i_maxClaimPeriod) {

718:     return s_pool.state.closedAt != 0 || _inClaimPeriod(staker) || paused();

726:     if (staker.unbondingPeriodEndsAt == 0 || block.timestamp < staker.unbondingPeriodEndsAt) {

803:     if (!s_rewardVault.isOpen() || s_rewardVault.isPaused()) revert RewardVaultNotActive();

```
*GitHub*: [208](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L208-L208), [625](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L625-L625), [630](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L630-L631), [630](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L630-L630), [647](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L647-L647), [659](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L659-L659), [718](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L718-L718), [718](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L718-L718), [726](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L726-L726), [803](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L803-L803)

```solidity
File: src/rewards/RewardVault.sol

468:     if (address(newMigrationSource) == address(0) || address(newMigrationSource) == address(this)) {

553:     return interfaceID == this.onTokenTransfer.selector || super.supportsInterface(interfaceID);

1278           (
1279             operatorPoolShare != 0
1280               && rewardAmount.mulWadDown(operatorPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1281           )
1282             || (
1283               communityPoolShare != 0
1284                 && rewardAmount.mulWadDown(communityPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1285:            )

1305       (
1306         operatorPoolShare != 0
1307           && emissionRate.mulWadDown(operatorPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1308       )
1309         || (
1310           communityPoolShare != 0
1311             && emissionRate.mulWadDown(communityPoolShare) * FixedPointMathLib.WAD < totalPoolShare
1312:        )

1692:    if (totalEmissionRate == 0 || totalEmissionRate < s_vaultConfig.delegationRateDenominator) {

1705:      : isCurrentOperator || i_operatorStakingPool.isRemoved(staker);

```
*GitHub*: [468](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L468-L468), [553](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L553-L553), [1278](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1278-L1285), [1305](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1305-L1312), [1692](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1692-L1692), [1705](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1705-L1705)

```solidity
File: src/timelock/Timelock.sol

435:       predecessor == bytes32(0) || isOperationDone(predecessor), 'Timelock: missing dependency'

```
*GitHub*: [435](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L435-L435)

</details>

### [D&#x2011;36] ~~It is standard for all external and public functions to be override from an interface~~
According to the Solidity [docs](https://docs.soliditylang.org/en/v0.8.20/contracts.html#function-overriding), "Starting from Solidity 0.8.8, the `override` keyword is not required when overriding an interface function, except for the case where the function is defined in multiple bases", so while it may have been a requirement in the past, they're trying to change that. Paired with the advice of making all `public` and `external` functions a part of an `interface`, this finding would end up having all sponsors mark all `public`/`external` functions with `override`, making the keyword meaningless. It's better to use `override` only when something is actually being overridden.

*There are 61 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

11:    function setMigrationTarget(address newMigrationTarget) external virtual override {

32:    function getMigrationTarget() external view virtual override returns (address) {

```
*GitHub*: [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L11-L11), [32](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L32-L32)

```solidity
File: src/MigrationProxy.sol

91     function onTokenTransfer(
92       address source,
93       uint256 amount,
94       bytes calldata data
95:    ) external override whenNotPaused validateFromLINK {

156:   function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

165:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [91](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L91-L95), [156](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L156-L156), [165](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L165-L165)

```solidity
File: src/PausableWithAccessControl.sol

22:    function emergencyPause() external override onlyRole(PAUSER_ROLE) {

27:    function emergencyUnpause() external override onlyRole(PAUSER_ROLE) {

```
*GitHub*: [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L22-L22), [27](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L27-L27)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

399    function migrate(bytes calldata)
400      external
401      override(IMigratable)
402      onlyRole(DEFAULT_ADMIN_ROLE)
403      withSlasherRole
404      validateMigrationTargetSet
405:   {

416    function _validateMigrationTarget(address newMigrationTarget)
417      internal
418      override(Migratable)
419      onlyRole(DEFAULT_ADMIN_ROLE)
420:   {

580:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [399](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L399-L405), [416](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L416-L420), [580](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L580-L580)

```solidity
File: src/pools/CommunityStakingPool.sol

59     function _validateOnTokenTransfer(
60       address sender,
61       address staker,
62       bytes calldata data
63:    ) internal view override {

85:    function _handleOpen() internal view override(StakingPoolBase) {

96     function hasAccess(
97       address staker,
98       bytes32[] calldata proof
99:    ) external view override returns (bool) {

120:   function setMerkleRoot(bytes32 newMerkleRoot) external override onlyRole(DEFAULT_ADMIN_ROLE) {

126:   function getMerkleRoot() external view override returns (bytes32) {

148:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [59](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L59-L63), [85](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L85-L85), [96](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L96-L99), [120](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L120-L120), [126](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L126-L126), [148](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L148-L148)

```solidity
File: src/pools/OperatorStakingPool.sol

204    function grantRole(
205      bytes32 role,
206      address account
207:   ) public virtual override(AccessControlDefaultAdminRules) {

218    function addSlasher(
219      address slasher,
220      SlasherConfig calldata config
221:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

228    function setSlasherConfig(
229      address slasher,
230      SlasherConfig calldata config
231:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

257:   function getSlasherConfig(address slasher) external view override returns (SlasherConfig memory) {

262:   function getSlashCapacity(address slasher) external view override returns (uint256) {

277    function slashAndReward(
278      address[] calldata stakers,
279      address alerter,
280      uint256 principalAmount,
281      uint256 alerterRewardAmount
282:   ) external override onlySlasher whenActive {

393:   function _validateOnTokenTransfer(address, address staker, bytes calldata) internal view override {

400    function setPoolConfig(
401      uint256 maxPoolSize,
402      uint256 maxPrincipalPerStaker
403    )
404      external
405      override
406      validatePoolSpace(maxPoolSize, maxPrincipalPerStaker, s_numOperators)
407      whenOpen
408      onlyRole(DEFAULT_ADMIN_ROLE)
409:   {

414:   function _handleOpen() internal view override(StakingPoolBase) {

567:   function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

602:   function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [204](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L204-L207), [218](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L218-L221), [228](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L228-L231), [257](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L257-L257), [262](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L262-L262), [277](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L277-L282), [393](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L393-L393), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L400-L409), [414](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L414-L414), [567](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L567-L567), [602](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L602-L602)

```solidity
File: src/pools/StakingPoolBase.sol

230    function migrate(bytes calldata data)
231      external
232      override(IMigratable)
233      whenClosed
234      validateMigrationTargetSet
235      validateRewardVaultSet
236:   {

258    function _validateMigrationTarget(address newMigrationTarget)
259      internal
260      override(Migratable)
261      onlyRole(DEFAULT_ADMIN_ROLE)
262:   {

332    function onTokenTransfer(
333      address sender,
334      uint256 amount,
335      bytes calldata data
336    )
337      external
338      override
339      validateFromLINK
340      validateMigrationProxySet
341      whenOpen
342      whenRewardVaultOpen
343      whenNotPaused
344:   {

400    function setPoolConfig(
401      uint256 maxPoolSize,
402      uint256 maxPrincipalPerStaker
403:   ) external virtual override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

409    function open()
410      external
411      override(IStakingOwner)
412      onlyRole(DEFAULT_ADMIN_ROLE)
413      whenBeforeOpening
414      validateRewardVaultSet
415      whenRewardVaultOpen
416:   {

425:   function close() external override(IStakingOwner) onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

436:   function setMigrationProxy(address migrationProxy) external override onlyRole(DEFAULT_ADMIN_ROLE) {

459:   function unstake(uint256 amount, bool shouldClaimReward) external override {

508:   function getTotalPrincipal() external view override returns (uint256) {

513:   function getStakerPrincipal(address staker) external view override returns (uint256) {

522    function getStakerPrincipalAt(
523      address staker,
524      uint256 checkpointId
525:   ) external view override returns (uint256) {

532:   function getStakerStakedAtTime(address staker) external view override returns (uint256) {

541    function getStakerStakedAtTimeAt(
542      address staker,
543      uint256 checkpointId
544:   ) external view override returns (uint256) {

551:   function getRewardVault() external view override returns (IRewardVault) {

556:   function getChainlinkToken() external view override returns (address) {

561:   function getMigrationProxy() external view override returns (address) {

566:   function isOpen() external view override returns (bool) {

571:   function isActive() public view override returns (bool) {

576:   function getStakerLimits() external view override returns (uint256, uint256) {

581:   function getMaxPoolSize() external view override returns (uint256) {

```
*GitHub*: [230](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L230-L236), [258](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L258-L262), [332](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L332-L344), [400](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L400-L403), [409](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L409-L416), [425](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L425-L425), [436](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L436-L436), [459](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L459-L459), [508](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L508-L508), [513](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L513-L513), [522](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L522-L525), [532](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L532-L532), [541](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L541-L544), [551](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L551-L551), [556](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L556-L556), [561](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L561-L561), [566](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L566-L566), [571](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L571-L571), [576](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L576-L576), [581](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L581-L581)

```solidity
File: src/rewards/RewardVault.sol

488    function _validateMigrationTarget(address newMigrationTarget)
489      internal
490      override(Migratable)
491      onlyRole(DEFAULT_ADMIN_ROLE)
492:   {

509    function migrate(bytes calldata data)
510      external
511      override(IMigratable)
512      onlyRole(DEFAULT_ADMIN_ROLE)
513      whenOpen
514      validateMigrationTargetSet
515:   {

552:   function supportsInterface(bytes4 interfaceID) public view override returns (bool) {

566:   function onTokenTransfer(address sender, uint256 amount, bytes calldata data) external override {

623:   function claimReward() external override whenNotPaused returns (uint256) {

687:   function updateReward(address staker, uint256 stakerPrincipal) external override onlyStakingPool {

721    function finalizeReward(
722      address staker,
723      uint256 oldPrincipal,
724      uint256 stakedAt,
725      uint256 unstakedAmount,
726      bool shouldClaim
727:   ) external override onlyStakingPool returns (uint256) {

793:   function close() external override onlyRole(DEFAULT_ADMIN_ROLE) whenOpen {

803:   function getReward(address staker) external view override returns (uint256) {

819:   function isOpen() external view override returns (bool) {

824:   function hasRewardDurationEnded(address stakingPool) external view override returns (bool) {

837:   function getStoredReward(address staker) external view override returns (StakerReward memory) {

904:   function isPaused() external view override(IRewardVault) returns (bool) {

1741:  function typeAndVersion() external pure virtual override returns (string memory) {

```
*GitHub*: [488](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L488-L492), [509](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L509-L515), [552](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L552-L552), [566](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L566-L566), [623](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L623-L623), [687](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L687-L687), [721](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L721-L727), [793](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L793-L793), [803](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L803-L803), [819](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L819-L819), [824](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L824-L824), [837](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L837-L837), [904](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L904-L904), [1741](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L1741-L1741)

</details>

### [D&#x2011;37] ~~Use replace and pop instead of the delete keyword to removing an item from an array~~
The examples below are mappings, not arrays

*There are 4 instances of this issue:*

```solidity
File: src/alerts/PriceFeedAlertsController.sol

304:     delete s_feedConfigs[feed];

305:     delete s_lastAlertedRoundIds[feed];

452:       delete s_feedConfigs[feed];

```
*GitHub*: [304](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L304-L304), [305](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L305-L305), [452](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L452-L452)

```solidity
File: src/timelock/Timelock.sol

376:     delete s_timestamps[id];

```
*GitHub*: [376](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/timelock/Timelock.sol#L376-L376)


### [D&#x2011;38] ~~It's not standard to end and begin a code object on the same line~~
These are perfectly standard

*There are 70 instances of this issue:*

<details>
<summary>see instances</summary>


```solidity
File: src/Migratable.sol

4:   import {IMigratable} from './interfaces/IMigratable.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/Migratable.sol#L4-L4)

```solidity
File: src/MigrationProxy.sol

4    import {ERC677ReceiverInterface} from
5:     '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';

6:   import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

7    import {TypeAndVersionInterface} from
8:     '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

10:  import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

12:  import {PausableWithAccessControl} from './PausableWithAccessControl.sol';

13:  import {CommunityStakingPool} from './pools/CommunityStakingPool.sol';

14:  import {OperatorStakingPool} from './pools/OperatorStakingPool.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L4-L5), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L6-L6), [7](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L7-L8), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L10-L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L12-L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L13-L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/MigrationProxy.sol#L14-L14)

```solidity
File: src/PausableWithAccessControl.sol

4    import {AccessControlDefaultAdminRules} from
5:     '@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol';

6:   import {Pausable} from '@openzeppelin/contracts/security/Pausable.sol';

8:   import {IPausable} from './interfaces/IPausable.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L4-L5), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L6-L6), [8](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/PausableWithAccessControl.sol#L8-L8)

```solidity
File: src/alerts/PriceFeedAlertsController.sol

4    import {AggregatorV3Interface} from
5:     '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

6    import {TypeAndVersionInterface} from
7:     '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

9:   import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

10:  import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

12:  import {IMigratable} from '../interfaces/IMigratable.sol';

13:  import {IMigrationDataReceiver} from '../interfaces/IMigrationDataReceiver.sol';

14:  import {Migratable} from '../Migratable.sol';

15:  import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';

16:  import {CommunityStakingPool} from '../pools/CommunityStakingPool.sol';

17:  import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L4-L5), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L6-L7), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L9-L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L10-L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L12-L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L13-L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L14-L14), [15](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L15-L15), [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L16-L16), [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/alerts/PriceFeedAlertsController.sol#L17-L17)

```solidity
File: src/pools/CommunityStakingPool.sol

4    import {ERC677ReceiverInterface} from
5:     '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';

6    import {TypeAndVersionInterface} from
7:     '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

9:   import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

11:  import {IMerkleAccessController} from '../interfaces/IMerkleAccessController.sol';

12:  import {OperatorStakingPool} from './OperatorStakingPool.sol';

13:  import {StakingPoolBase} from './StakingPoolBase.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L4-L5), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L6-L7), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L9-L9), [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L11-L11), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L12-L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/CommunityStakingPool.sol#L13-L13)

```solidity
File: src/pools/OperatorStakingPool.sol

4    import {TypeAndVersionInterface} from
5:     '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

7    import {AccessControlDefaultAdminRules} from
8:     '@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol';

9:   import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

10:  import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

12:  import {ISlashable} from '../interfaces/ISlashable.sol';

13:  import {IRewardVault} from '../interfaces/IRewardVault.sol';

14:  import {RewardVault} from '../rewards/RewardVault.sol';

15:  import {StakingPoolBase} from './StakingPoolBase.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L4-L5), [7](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L7-L8), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L9-L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L10-L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L12-L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L13-L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L14-L14), [15](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/OperatorStakingPool.sol#L15-L15)

```solidity
File: src/pools/StakingPoolBase.sol

4    import {ERC677ReceiverInterface} from
5:     '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';

6:   import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

8:   import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

9:   import {Checkpoints} from '@openzeppelin/contracts/utils/Checkpoints.sol';

10:  import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

12:  import {IMigratable} from '../interfaces/IMigratable.sol';

13:  import {IRewardVault} from '../interfaces/IRewardVault.sol';

14:  import {IStakingOwner} from '../interfaces/IStakingOwner.sol';

15:  import {IStakingPool} from '../interfaces/IStakingPool.sol';

16:  import {Migratable} from '../Migratable.sol';

17:  import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L4-L5), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L6-L6), [8](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L8-L8), [9](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L9-L9), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L10-L10), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L12-L12), [13](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L13-L13), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L14-L14), [15](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L15-L15), [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L16-L16), [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/pools/StakingPoolBase.sol#L17-L17)

```solidity
File: src/rewards/RewardVault.sol

4    import {ERC677ReceiverInterface} from
5:     '@chainlink/contracts/src/v0.8/interfaces/ERC677ReceiverInterface.sol';

6:   import {LinkTokenInterface} from '@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol';

7    import {TypeAndVersionInterface} from
8:     '@chainlink/contracts/src/v0.8/interfaces/TypeAndVersionInterface.sol';

10:  import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';

11:  import {Math} from '@openzeppelin/contracts/utils/math/Math.sol';

12:  import {SafeCast} from '@openzeppelin/contracts/utils/math/SafeCast.sol';

14:  import {FixedPointMathLib} from '@solmate/utils/FixedPointMathLib.sol';

16:  import {IMigratable} from '../interfaces/IMigratable.sol';

17:  import {IRewardVault} from '../interfaces/IRewardVault.sol';

18:  import {IStakingPool} from '../interfaces/IStakingPool.sol';

19:  import {Migratable} from '../Migratable.sol';

20:  import {PausableWithAccessControl} from '../PausableWithAccessControl.sol';

21:  import {CommunityStakingPool} from '../pools/CommunityStakingPool.sol';

22:  import {OperatorStakingPool} from '../pools/OperatorStakingPool.sol';

```
*GitHub*: [4](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L4-L5), [6](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L6-L6), [7](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L7-L8), [10](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L10-L10), [11](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L11-L11), [12](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L12-L12), [14](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L14-L14), [16](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L16-L16), [17](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L17-L17), [18](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L18-L18), [19](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L19-L19), [20](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L20-L20), [21](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L21-L21), [22](https://github.com/code-423n4/2023-08-chainlink/blob/040732951753e85a6a6668738eb211912ba491f8/src/rewards/RewardVault.sol#L22-L22)

