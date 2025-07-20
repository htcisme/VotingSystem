const { ethers } = require("hardhat");

async function main() {
  // Lấy danh sách signer
  const [owner, voter1, voter2, voter3] = await ethers.getSigners();
  console.log("Owner:", await owner.getAddress());
  console.log("Voter1:", await voter1.getAddress());
  console.log("Voter2:", await voter2.getAddress());
  console.log("Voter3:", await voter3.getAddress());

  // Deploy contract
  const Voting = await ethers.getContractFactory("Voting");
  const voting = await Voting.deploy();
  await voting.waitForDeployment();
  console.log("Voting deployed to:", voting.target);

  // Owner đăng ký candidate
  await (await voting.connect(owner).registerCandidate("Alice")).wait();
  await (await voting.connect(owner).registerCandidate("Bob")).wait();
  await (await voting.connect(owner).registerCandidate("Trung")).wait();
  console.log("Registered candidates: Alice & Bob");

  // voter1 và voter2 đăng ký voter
  await (await voting.connect(voter1).registerVoter()).wait();
  await (await voting.connect(voter2).registerVoter()).wait();
  await (await voting.connect(voter3).registerVoter()).wait();
  console.log("Voter1 and Voter2 registered");

  // voter1 vote cho Alice
  await (await voting.connect(voter1).vote("Alice")).wait();

  console.log("Voter1 voted for Alice");

  // voter2 vote cho Bob
  await (await voting.connect(voter2).vote("Bob")).wait();
  console.log("Voter2 voted for Bob");

  // voter3 vote cho Trung
  await (await voting.connect(voter3).vote("Alice")).wait();
  console.log("Voter3 voted for Trung");

  // Xem số phiếu
  const aliceVotes = await voting.getVotes("Alice");
  const bobVotes = await voting.getVotes("Bob");
  const trungVotes = await voting.getVotes("Trung");
  console.log(`Alice votes: ${aliceVotes}`);
  console.log(`Bob votes: ${bobVotes}`);
  console.log(`Trung votes: ${trungVotes}`);

  // Xem winner
  const winner = await voting.getWinner();
  console.log(`Winner is: ${winner}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
