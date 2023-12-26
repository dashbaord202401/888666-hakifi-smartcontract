import hre from "hardhat"
import "dotenv/config"

async function main() {
    const Umbrellaz = await hre.ethers.getContractFactory("Umbrellaz")
    console.log("Upgrading Umbrellaz ...")
    const umbrellaz = await hre.upgrades.upgradeProxy(process.env.PROXYTESTNETADDRESS as string, Umbrellaz, {
        txOverrides: { gasLimit: "0x1000000" },
    })
    console.log("Umbrellaz upgraded to:", umbrellaz.target)

    // Add mod
    // await umbrellaz.addMod("0x5cEaD3BAbEb5163c3C253289358f379eC0c8b4c1")
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
