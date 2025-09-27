// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC3643} from "../ERC-3643/contracts/token/Token.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Minter is ERC3643 {
    mapping(address => address) public tokenToZToken; // USDC => zUSDC
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

      constructor(
        address _identityRegistry,
        address _compliance,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        // _onchainID can be zero address if not set, can be set later by owner
        address _onchainID
    ) {
        init(_identityRegistry,
         _compliance,
        _name,
        _symbol,
        _decimals,
        // _onchainID can be zero address if not set, can be set later by owner
        _onchainID
   );
        owner = msg.sender;
    }


    function addToken(address token, address zToken) external onlyOwner {
        tokenToZToken[token] = zToken;
    }

    function mintZToken(address sender , address token, uint256 amount) external {
           address zToken = tokenToZToken[token];
        require(zToken != address(0), "Unsupported token");

        // Transfer underlying from user
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Mint wrapped token to user
        mint(sender, amount);
    
         }
    
        function burnZToken(address receiver , address token, uint256 amount) external {
            address zToken = tokenToZToken[token];
        require(zToken != address(0), "Unsupported token");

        // Transfer underlying to user
        IERC20(token).transfer(receiver, amount);

        // Burn wrapped token from user
        burn(receiver, amount);
    
         }

}
