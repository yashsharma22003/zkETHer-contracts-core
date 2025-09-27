// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IMinterToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

contract Minter {
    mapping(address => address) public tokenToZToken; // USDC => zUSDC
    address public owner;
    event ZTokenMinted(address indexed sender, uint256 amount );
    event ZTokenBurned(address indexed receiver, uint256 amount);


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

      constructor(){
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
        IMinterToken(zToken).mint(sender, amount);
        emit ZTokenMinted(sender, amount );
    
    }
    
    // @audit-dev : Burn functionality
        function burnZToken(address receiver , address token, uint256 amount) external {
        address zToken = tokenToZToken[token];
        require(zToken != address(0), "Unsupported token");

        // Transfer underlying to user
        IERC20(token).transfer(receiver, amount);

        // Burn wrapped token from user
        IMinterToken(zToken).burn(receiver, amount);
        emit ZTokenBurned(receiver, amount);
    }

}
