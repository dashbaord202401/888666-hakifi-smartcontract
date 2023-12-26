import hre from "hardhat"

async function main() {
    console.log("Deploying Umbrellaz ...")
    const umbrellaz = await hre.ethers.deployContract("UmbrellazVIC", { gasLimit: 0x1000000 })

    await umbrellaz.waitForDeployment()

    console.log("Umbrellaz Deployed at:", umbrellaz.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
