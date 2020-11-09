pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./ATestnetConsumer.sol";
import "./ConditionalTokens.sol";

contract ElectionsOracle is Ownable {
    struct Winner {
      string winner;
      uint256 resultNow;
      uint256 resultBlock;
    }
    
    ATestnetConsumer internal winners;
    
    constructor() public {
        winners = ATestnetConsumer(0x12B7B8Dea45AF31b6303E00C735332A8b6752856);
    }
    
    function resolveMarket (address addr, bytes32 questionId) public onlyOwner {
    ConditionalTokens c = ConditionalTokens(addr);
    uint[] memory payouts;
    (string memory winner, uint256 resultNow, uint256 resultBlock) = selectWinner("US");
    if (keccak256("Trump")==keccak256(bytes(winner))) {
       payouts[0] = 1;
       payouts[1] = 0;
    }
    else {
      payouts[0] = 0;
      payouts[1] = 1;
    }
        return c.reportPayouts(questionId, payouts);
  }

   function selectWinner(string memory _state) public view returns (string memory winner, uint256 resultNow, uint256 resultBlock)
  {
    (string memory winner, uint256 resultNow, uint256 resultBlock) = winners.presidentialWinners(_state);
    return (winner, resultNow, resultBlock);
  }
}