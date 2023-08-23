import { bytesToHex } from 'ethereum-cryptography/utils';
import { generateMerkleTree, getProofs } from '../lib/merkleTree';
import fs from 'fs';

type Bytes = Uint8Array;

function hex(b: Bytes): string {
    return '0x' + bytesToHex(b);
}

// No need to sanitize, display help etc.
// main.then() style script with async function main() doesn't play well with fs.readFile
const filename = process.argv[2];
fs.readFile(filename, "utf-8", (err, data) => {
    if (err) {
        console.log('err', err);
        return;
    }
    // add quotes around each entry and square brackets at beginning & end.
    let jsonData = "[" + data.replace(/0x/g, "\"0x").replace(/,/g, "\",").replace(/\n/g, "") + "\"]";
    const allowlist = JSON.parse(jsonData);
    console.log('allowlist', allowlist);

    const tree = generateMerkleTree(allowlist);
    console.log('merkle tree hex', tree.tree.map(hex));
    console.log('merkle tree', JSON.stringify(tree.tree));
    console.log('merkle root', tree.root);
    console.log('proofs', getProofs(allowlist, tree));
});
