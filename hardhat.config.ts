import "solidity-docgen"
import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "@openzeppelin/hardhat-upgrades"

import "dotenv/config"

const config: HardhatUserConfig = {
    networks: {
        bscTestnet: {
            url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
            accounts: [process.env.TESTNETKEY as string],
        },
        bscMainnet: {
            url: "https://bsc-dataseed.bnbchain.org/",
            accounts: [
                process.env.MAINNETKEY as string, // developer
            ],
        }, // for mainnet
        "tomo-mainnet": {
            url: "https://rpc.viction.xyz",
            accounts: [process.env.TESTNETKEY as string],
        },
        // for testnet
        "tomo-testnet": {
            url: "https://rpc-testnet.viction.xyz",
            accounts: [process.env.TESTNETKEY as string],
        },
        "viction-testnet": {
            url: "https://rpc-testnet.viction.xyz",
            accounts: [process.env.TESTNETKEY as string],
        },
    },
    etherscan: {
        apiKey: {
            bscTestnet: process.env.TESTNETAPI as string,
            bscMainnet: process.env.MAINNETAPI as string,
            Viction: "tomoscan2023",
        },
        customChains: [
            {
                network: "Viction",
                chainId: 88, // for mainnet
                urls: {
                    apiURL: "https://www.vicscan-testnet.xyz/api/contract/hardhat/verify", // for mainnet
                    browserURL: "https://testnet.tomoscan.io/", // for mainnet
                },
            },
        ],
    },

    solidity: {
        compilers: [
            {
                version: "0.8.19",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    mocha: {
        timeout: 40000,
    },
}

export default config
