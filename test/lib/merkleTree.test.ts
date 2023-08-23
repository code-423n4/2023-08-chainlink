import { expect } from 'chai';
import { bytesToHex } from 'ethereum-cryptography/utils';
import { generateMerkleTree, verifyMerkleProof } from '../../lib/merkleTree';
import {
  TEST_SNAPSHOT,
  TEST_MERKLE_ROOT,
  STAKER_1_MERKLE_PROOF,
  STAKER_1_ADDRESS,
} from '../utils/mockdata';

type Bytes = Uint8Array;

function hex(b: Bytes): string {
  return '0x' + bytesToHex(b);
}
describe('generator', function () {
  describe('generateMerkleTree', function () {
    it('returns a merkle tree', async function () {
      const allowlist = Object.keys(TEST_SNAPSHOT);
      const tree = generateMerkleTree(allowlist);

      expect(tree.root).to.equal(TEST_MERKLE_ROOT);
      expect(tree.tree.map(hex)).to.eql([
        "0x1f0a6d9541b5c209a5317601c99b293af2c60b0356c15ef11882901fee884e51",
        "0x48abad7255a7e6c6cf4802687a2e6a934877ff458cb754e0e3719f230df2fe5f",
        "0x73331ae2661435152eaef0a752ebf6d3411ad5b0bed808474c7bca3f733c57c3",
        "0x6cdc18f84e98082d923464d1dd675b61e35d5114b91d52e487ad0c9928f933e2",
        "0xc38d88f82cc919c1cea67f2aa5ca78ddfff0c766ca1484c033cb53176245d10d",
        "0xbe6662d0d151ce751ee3bf5865f948ab70d538b2367ad5852db2c6a0ed788cea",
        "0x7d72777873f95721dfddd795e9dd04c53bad039a6fc118ffacbdc8149d4e5c0a",
        "0x6b53f83e55e3a865463ea3d6c9d56b7b8b5108972cd7ad8aa7ea27349414bcd9",
        "0x4037c6f743ab4de78e149bfd4c409b29b1da1d34ecbfa5ff222fe73f77f7dec3",
      ]);
      expect(allowlist.map((v: string) => tree.getProof([v]))).to.eql([
        STAKER_1_MERKLE_PROOF,
        [
          "0x7d72777873f95721dfddd795e9dd04c53bad039a6fc118ffacbdc8149d4e5c0a",
          "0x48abad7255a7e6c6cf4802687a2e6a934877ff458cb754e0e3719f230df2fe5f",
        ],
        [
          "0x6b53f83e55e3a865463ea3d6c9d56b7b8b5108972cd7ad8aa7ea27349414bcd9",
          "0xc38d88f82cc919c1cea67f2aa5ca78ddfff0c766ca1484c033cb53176245d10d",
          "0x73331ae2661435152eaef0a752ebf6d3411ad5b0bed808474c7bca3f733c57c3",
        ],
        [
          "0x6cdc18f84e98082d923464d1dd675b61e35d5114b91d52e487ad0c9928f933e2",
          "0x73331ae2661435152eaef0a752ebf6d3411ad5b0bed808474c7bca3f733c57c3",
        ],
        [
          "0xbe6662d0d151ce751ee3bf5865f948ab70d538b2367ad5852db2c6a0ed788cea",
          "0x48abad7255a7e6c6cf4802687a2e6a934877ff458cb754e0e3719f230df2fe5f",
        ],
      ]);
    });
  });

  describe('verifyProof', function () {
    it('verifies a valid merkle proof', async function () {
      expect(
        verifyMerkleProof({
          merkleRoot: TEST_MERKLE_ROOT,
          merkleProof: STAKER_1_MERKLE_PROOF,
          address: STAKER_1_ADDRESS,
        }),
      ).to.equal(true);
    });
  });
});
