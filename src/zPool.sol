// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// pragma solidity ^0.8.17;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Minter} from "./Minter.sol";
import {IncrementalMerkleTree, Poseidon2} from "./IncrementalMerkleTree.sol";

interface ICompliance {
    function isCompliant(address user) external view returns (bool);
}

contract zPool is IncrementalMerkleTree, ReentrancyGuard {
    Minter public minterToken;
    ICompliance public compliance;
    address public depositFee;
    uint256 public DENOMINATION;
    address public minterToken;        
    IERC20 public ptoken;
    mapping(bytes32 => bool) public s_nullifierHashes;
    mapping(bytes32 => bool) public s_commitments;

    event Deposit(bytes32 indexed commitment, uint32 leafIndex, uint256 timestamp);
    event Withdrawal(address to, bytes32 nullifierHash);

    constructor(
        Poseidon2 _hasher,
        uint32 _merkleTreeDepth,
        ICompliance _compliance,
        uint256 _denomination,
        IERC20 _ptoken,
        address _minterToken
    ) IncrementalMerkleTree(_merkleTreeDepth, _hasher) {
        compliance = _compliance;
        DENOMINATION = _denomination;
        ptoken = _ptoken;
        minterToken  = _minterToken;    
    }

    function deposit(bytes32 _commitment, uint256 _amount, address _token) external nonReentrant {
    }

    function withdraw(
        bytes calldata _proof,
        bytes32 _root,
        bytes32 _nullifierHash,
        address payable _recipient,
        address _token
    ) external nonReentrant {
    }
}
