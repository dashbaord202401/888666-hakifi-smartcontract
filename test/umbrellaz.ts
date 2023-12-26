import { expect } from "chai"
import hre from "hardhat"

let umbrellaz: any
let umbrellazProxy: any
let vnst: any
let usdt: any

describe("Umbrellaz", function () {
    this.beforeAll(async function () {
        // Deploy Token
        const USDT = await hre.ethers.getContractFactory("USDT")
        console.log("Deploying USDT ...")
        usdt = await USDT.deploy()
        console.log("USDT deployed to:", usdt.target)

        const VNST = await hre.ethers.getContractFactory("VNST")
        console.log("Deploying VNST ...")
        vnst = await VNST.deploy()
        console.log("VNST deployed to:", vnst.target)

        // Deploy hakifi contract
        const UmbrellazProxy = await hre.ethers.getContractFactory("UmbrellazProxy")
        console.log("Deploying UmbrellazProxy ...")
        umbrellazProxy = await hre.upgrades.deployProxy(UmbrellazProxy, [usdt.target, vnst.target], { kind: "uups" })
        console.log("UmbrellazProxy deployed to:", umbrellazProxy.target)

        const Umbrellaz = await hre.ethers.getContractFactory("Umbrellaz")
        console.log("Upgrading Umbrellaz ...")
        umbrellaz = await hre.upgrades.upgradeProxy(umbrellazProxy, Umbrellaz)
        console.log("Umbrellaz upgraded to:", umbrellaz.target)

        // Approve
        usdt.approve(umbrellaz.target, hre.ethers.parseEther("10000000"))
        vnst.approve(umbrellaz.target, hre.ethers.parseEther("10000000"))
    })

    describe("Test Proxy Umbrellaz", () => {
        it("Proxy work correctly", async () => {
            expect(umbrellaz.target).to.equal(umbrellazProxy.target)
            expect(await umbrellaz.version()).to.equal("v1!")
        })

        it("Create Insurance work correctly", async () => {
            await umbrellaz.createInsurance("some", 0, 5)

            await umbrellaz.createInsurance("thing", 1, 5)

            await expect(umbrellaz.createInsurance("some", 0, 5)).to.be.revertedWith("Id not unique")

            expect(await umbrellaz.getVault(0, 1)).to.equal(5n)
            expect(await usdt.balanceOf(umbrellaz.target)).to.equal(5n)
            expect(await vnst.balanceOf(umbrellaz.target)).to.equal(5n)
        })

        it("Read Insurance work correctly", async () => {
            // console.log(await umbrellaz.readInsurance("thing"))
        })

        it("Update Available Insurance work correctly", async () => {
            // await umbrellaz.updateAvailableInsurance()
        })

        it("Update Invalid Insurance work correctly", async () => {
            await umbrellaz.updateInvalidInsurance("some")
            console.log(await umbrellaz.readInsurance("some"))
            console.log(await usdt.balanceOf(umbrellaz.target))
        })

        it("Delete Insurance work correctly", async () => {})
    })
})
