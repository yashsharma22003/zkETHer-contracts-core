// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./zPool.sol";
import {Minter} from "./Minter.sol";

/**
 * @title ZFactory
 * @notice Deploys ZToken and ZPool contracts and keeps registry of created instances.
 * @dev This factory assumes the ZToken and ZPool contracts match the interfaces used here.
 */
contract ZFactory {
    // Records
    address[] public deployedZTokens;
    address[] public deployedZPools;
    address public owner;
    
    // mapping underlying token => zToken (last created)
    mapping(address => address) public lastZTokenFor;
    // mapping pool address => exists
    mapping(address => bool) public isPool;
    // mapping zToken address => exists
    mapping(address => bool) public isZToken;

    event ZTokenCreated(address indexed zToken, address indexed createdBy);
    event ZPoolCreated(address indexed zPool, address indexed createdBy);

     modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }


      constructor(){
        owner = msg.sender;
      }

    function createZPool(
        IVerifier _verifier,
        Poseidon2 _hasher,
        uint32 _merkleTreeDepth,
        ICompliance _compliance,
        uint256 _denomination,
         IERC20  _poolToken,
        IERC20 _minterToken
    ) external onlyOwner returns (address) {
        zPool pool = new zPool(
            _verifier,
            _hasher,
            _merkleTreeDepth,
            _compliance,
            _denomination,
            _poolToken,
            _minterToken
        );
        address poolAddr = address(pool);
        deployedZPools.push(poolAddr);
        isPool[poolAddr] = true;

        emit ZPoolCreated(poolAddr, msg.sender);
        return poolAddr;
    }

    /* ========== READ HELPERS ========== */

    function zTokenCount() external view returns (uint256) {
        return deployedZTokens.length;
        }

    function zPoolCount() external view returns (uint256) {
        return deployedZPools.length;
    }

    function createMinterTokenAndRegister(address underlying, address wrapToken) external onlyOwner returns (address) {
        Minter ztoken = new Minter(); 

        address ztokenAddr = address(ztoken);

        // register mapping in ztoken manager contract
        // NOTE: ZToken.addzToken is onlyOwner; the factory is the owner because it deployed ZToken
        ztoken.addToken(underlying, wrapToken);
        deployedZTokens.push(ztokenAddr);
        isZToken[ztokenAddr] = true;
        lastZTokenFor[underlying] = ztokenAddr;

        emit ZTokenCreated(ztokenAddr, msg.sender);
        return ztokenAddr;
    }

    function createMinterToken() external onlyOwner returns (address) {
        Minter ztoken = new Minter();
        
        address ztokenAddr = address(ztoken);
        deployedZTokens.push(ztokenAddr);
        isZToken[ztokenAddr] = true;

        emit ZTokenCreated(ztokenAddr, msg.sender);
        return ztokenAddr;
    }
}
