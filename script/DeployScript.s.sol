// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {Minter} from "../src/Minter.sol";
import {MockDAI} from "../src/MockDAI.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
import {ZFactory} from "../src/ZFactory.sol";
import {HonkVerifier} from "../src/Verifier.sol";
import {zPool, IVerifier, Poseidon2} from "../src/zPool.sol";
import {IncrementalMerkleTree} from "../src/IncrementalMerkleTree.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployScript is Script{

    IVerifier public verifier;
    zPool public _zPool;
    Poseidon2 public poseidon;
    address public recipient = makeAddr("recipient");
    IERC20 public parentToken;
    IERC20 public zToken;

    function run() external {
        // Load private key from .env or config
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();
      
        // Deploy Poseiden hasher contract
        poseidon = new Poseidon2();

        // Deploy Groth16 verifier contract.
        verifier = new HonkVerifier();

        // Deploy MockDAI
        MockDAI mockDai = new MockDAI();
        console.log("MockDAI deployed at:", address(mockDai));

        // Deploy zMockDAI (you need another instance since zToken has mint/burn)
        MockDAI zMockDai = new MockDAI();
        console.log("zMockDAI deployed at:", address(zMockDai));
  
        // Deploy MockUSDC
        MockUSDC mockUsdc = new MockUSDC();
        console.log("MockUSDC deployed at:", address(mockDai));

       // Deploy MockDAI
        MockUSDC zMockUsdc = new MockUSDC();
        console.log("MockUSDC deployed at:", address(mockDai));

        MockUSDT mockUsdt = new MockUSDT();
        console.log("MockDAI deployed at:", address(mockDai));
     
        MockUSDT zMockUsdt = new MockUSDT();
        console.log("MockDAI deployed at:", address(mockDai));

        // Deploy Minter
        Minter minter = new Minter();
        console.log("Minter deployed at:", address(minter));

        // Register mapping (DAI -> zDAI)
        minter.addToken(address(mockDai), address(zMockDai));
        console.log("Token mapping added: DAI => zDAI");
        ZFactory zFactory = new ZFactory(poseidon, verifier,  20, 1 ether, IERC20(address(mockDai)), IERC20(address(zMockDai)));
        console.log("ZFactory deployed at:", address(zFactory));
        vm.stopBroadcast();
    }
}
