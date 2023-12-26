import hre from "hardhat"

async function main() {
    // console.log("Deploying USDT ...")
    // const usdt = await hre.ethers.deployContract("USDT", { gasLimit: "0x1000000" })
    // await usdt.waitForDeployment()
    // console.log("USDT Deployed at " + usdt.target)
    console.log("Deploying VNST ...")
    const vnst = await hre.ethers.deployContract("VNST", { gasLimit: "0x1000000" })
    await vnst.waitForDeployment()
    console.log("Token Contract Deployed at " + vnst.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
