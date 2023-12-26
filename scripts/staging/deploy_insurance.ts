import hre from "hardhat"
import "dotenv/config"

async function main() {
    const UmbrellazProxy = await hre.ethers.getContractFactory("UmbrellazProxy")
    console.log("Deploying UmbrellazProxy ...")
    const umbrellazProxy = await hre.upgrades.deployProxy(
        UmbrellazProxy,
        [process.env.VICTIONUSDT, process.env.VICTIONVNST],
        { kind: "uups", txOverrides: { gasLimit: 0x1000000 } },
    )
    console.log("UmbrellazProxy deployed to:", umbrellazProxy.target)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
