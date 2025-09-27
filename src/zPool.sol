// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Minter} from "./Minter.sol";
import {IncrementalMerkleTree, Poseidon2} from "./IncrementalMerkleTree.sol";
import {IVerifier} from "./Verifier.sol";


contract zPool is IncrementalMerkleTree, ReentrancyGuard {
    IVerifier public  verifier;
    IERC20 public minterToken;
    Minter public minter;
    uint256 public DENOMINATION;
    IERC20 public ptoken;
    address public owner;
    uint256 constant depositFee = 0.001 ether; // Example fee, adjust as needed
    mapping(bytes32 => bool) public s_nullifierHashes;
    mapping(bytes32 => bool) public s_commitments;

    event Deposit(bytes32 indexed commitment, uint32 leafIndex, uint256 timestamp);
    event Withdrawal(address to, bytes32 nullifierHash);


    constructor(
        IVerifier _verifier,
        Poseidon2 _hasher,
        uint32 _merkleTreeDepth,
        uint256 _denomination,
        IERC20 _ptoken,
        IERC20 _minterToken
    ) IncrementalMerkleTree(_merkleTreeDepth, _hasher) {
        verifier = _verifier;
        DENOMINATION = _denomination;
        ptoken = _ptoken;
        minterToken  = _minterToken;    
        minter = new Minter();
        owner = msg.sender;
    }


     modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }


    function updateVerifier(IVerifier _newVerifier) external onlyOwner {
        // Add access control as needed
        verifier = _newVerifier;
    }

    function deposit(bytes32 _commitment, uint256 _amount, address _token) external payable nonReentrant {
        require(msg.value == depositFee, "Incorrect deposit fee");
        require(!s_commitments[_commitment], "Commitment exists");
        require(_amount == DENOMINATION, "Deposit mismatch");

      
       IERC20(_token).transferFrom(msg.sender, address(this), _amount);
       IERC20(_token).approve(address(minterToken), _amount);
    
        minter.mintZToken(msg.sender, _token, _amount);

        uint32 insertedIndex = _insert(_commitment);
        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }

    function withdraw(
        bytes calldata _proof,
        bytes32 _root,
        bytes32 _nullifierHash,
        address payable _recipient,
        address _token
    ) external nonReentrant {
        require(!s_nullifierHashes[_nullifierHash], "Note spent");
        require(isKnownRoot(_root), "Unknown root");

        bytes32[] memory publicInputs = new bytes32[](3);
        publicInputs[0] = _root;
        publicInputs[1] = _nullifierHash;
        publicInputs[2] = bytes32(uint256(uint160(address(_recipient))));

        require(verifier.verify(_proof, publicInputs), "Invalid proof");

        s_nullifierHashes[_nullifierHash] = true;

        // Burn wrapped token via MintProxy
        address zTokenAddr = minter.tokenToZToken(_token);
        require(zTokenAddr != address(0), "Unsupported token");

        minter.burnZToken(msg.sender, _token, DENOMINATION);

        // Transfer underlying token to recipient
        // IERC20(_token).transfer(_recipient, DENOMINATION);

        emit Withdrawal(_recipient, _nullifierHash);
    }
}
