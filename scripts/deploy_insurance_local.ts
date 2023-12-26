import hre from "hardhat"

async function main() {
    const USDT = await hre.ethers.getContractFactory("USDT")
    console.log("Deploying USDT ...")
    const usdt = await USDT.deploy()
    console.log("USDT deployed to:", usdt.target)

    const INSURANCE = await hre.ethers.getContractFactory("Insurance")
    console.log("Deploying Insurance ...")
    const insurance = await INSURANCE.deploy(usdt.target)

    console.log("Insurance deployed to:", insurance.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
