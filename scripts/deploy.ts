import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config();

const FUNDING_AMOUNT = ethers.parseEther("0.02");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying MyPaymaster with account:", deployer.address);
  console.log("Account balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");

  const MyPaymaster = await ethers.getContractFactory("MyPaymaster");
  const paymaster = await MyPaymaster.deploy();
  await paymaster.waitForDeployment();
  const paymasterAddress = await paymaster.getAddress();
  console.log("MyPaymaster deployed to:", paymasterAddress);

  console.log("Funding paymaster with", ethers.formatEther(FUNDING_AMOUNT), "ETH...");
  const tx = await deployer.sendTransaction({
    to: paymasterAddress,
    value: FUNDING_AMOUNT,
  });
  await tx.wait();
  console.log("Paymaster funded. Tx hash:", tx.hash);
  console.log("Paymaster balance:", ethers.formatEther(await ethers.provider.getBalance(paymasterAddress)), "ETH");
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
