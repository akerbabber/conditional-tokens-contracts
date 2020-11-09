pragma solidity ^0.5.0;

import "@chainlink/contracts/src/v0.5/ChainlinkClient.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./ConditionalTokens.sol";

contract GasOracle is ChainlinkClient, Ownable {
  
  uint256 constant PAYMENT = 1 * LINK;
  uint256 oraclePayment;
  int256 public gasPrice;
  address public oracle;
  
  constructor(address _oracle) public {
    setPublicChainlinkToken();
    oraclePayment = PAYMENT;
    oracle = _oracle;
  }
  // Additional functions here:

  function resolveMarket (address addr, bytes32 questionId) public onlyOwner {
    ConditionalTokens c = ConditionalTokens(addr);
    uint[] memory payouts;
    if (gasPrice>20) {
       payouts[0] = 1;
       payouts[1] = 0;
    }
    else {
      payouts[0] = 0;
      payouts[1] = 1;
    }
        return c.reportPayouts(questionId, payouts);
  }

  function requestGasPriceByDate(address _oracle, bytes32 _jobId, string memory _date)
  public
  onlyOwner
{
  Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfillGasPrice.selector);
  req.add("action", "date");
  req.add("date", _date);
  req.add("copyPath", "gasPrice");
  req.addInt("times", 1000);
  sendChainlinkRequestTo(_oracle, req, oraclePayment);
}





function fulfillGasPrice(bytes32 _requestId, int256 _gasPrice)
  public onlyOwner
  recordChainlinkFulfillment(_requestId)
{
  gasPrice = _gasPrice;
}

}