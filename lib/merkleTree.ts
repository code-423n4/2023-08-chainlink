import { StandardMerkleTree } from "@openzeppelin/merkle-tree";

export function generateMerkleTree(allowlist: string[]): any {
  return StandardMerkleTree.of(allowlist.map(a => [a]), ['address']);
}

export function getProofs(allowlist: string[], tree: Record<string, any>) {
  return allowlist.map((v: any) => tree.getProof([v]));
}

export function verifyMerkleProof({
  address,
  merkleProof,
  merkleRoot,
}: {
  address: string;
  merkleProof: any;
  merkleRoot: string;
}): boolean {
  return StandardMerkleTree.verify(merkleRoot, ['address'], [address], merkleProof);
}

export default generateMerkleTree;