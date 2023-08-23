const fsExtra = require('fs-extra');

// The environment variables are loaded in hardhat.config.ts
const mnemonic = process.env.MNEMONIC;
if (!mnemonic) {
  throw new Error('Please set your MNEMONIC in a .env file');
}

module.exports = {
  istanbulReporter: ['html', 'lcov', 'text', 'json-summary'],
  onCompileComplete: async function (_config) {
    await run('typechain');
  },
  onIstanbulComplete: async function (_config) {
    // We need to do this because solcover generates bespoke artifacts.
    await fsExtra.remove('../artifacts');
  },
  providerOptions: {
    mnemonic,
  },
  skipFiles: ['mocks', 'test', 'fuzzing'],
  configureYulOptimizer: true,
  solcOptimizerDetails: {
    peephole: false,
    inliner: false,
    jumpdestRemover: false,
    orderLiterals: true, // <-- TRUE! Stack too deep when false
    deduplicate: false,
    cse: false,
    constantOptimizer: false,
    yul: true,
  },
};
