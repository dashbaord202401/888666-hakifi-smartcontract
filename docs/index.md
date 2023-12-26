# Solidity API

## Insurance

### totalInsurance

```solidity
uint256 totalInsurance
```

### quantity_nain_eligible_for_incentives

```solidity
uint256 quantity_nain_eligible_for_incentives
```

### address_nain

```solidity
address address_nain
```

### enable_user_nain

```solidity
bool enable_user_nain
```

### enable_buy_insurance

```solidity
bool enable_buy_insurance
```

### token_nain

```solidity
contract IERC20 token_nain
```

### usdt

```solidity
contract IERC20 usdt
```

### constructor

```solidity
constructor(address _addressUSDT) public
```

### EBuyInsurance

```solidity
event EBuyInsurance(uint256 idInsurance, address buyer, string asset, uint256 margin, uint256 q_covered, uint256 p_market, uint256 p_claim, string state, uint256 period, uint256 recognition_date, bool isUseNain)
```

### EUpdateStateInsurance

```solidity
event EUpdateStateInsurance(uint256 idInsurance)
```

### EUpdateQuantityNainEligibleForIncentives

```solidity
event EUpdateQuantityNainEligibleForIncentives(uint256 quantity_nain_eligible_for_incentives)
```

### ECancelStateInsurance

```solidity
event ECancelStateInsurance(uint256 idInsurnace)
```

### EValidInsurance

```solidity
event EValidInsurance(uint256 idInsurnace)
```

### onlyContractCaller

```solidity
modifier onlyContractCaller(address _caller)
```

### checkAllowance

```solidity
modifier checkAllowance(uint256 amount)
```

### configAddressNain

```solidity
function configAddressNain(address _address_nain) external
```

### renounceNain

```solidity
function renounceNain() external
```

### enableNain

```solidity
function enableNain() external
```

### updateQuantityNainEligibleForIncentives

```solidity
function updateQuantityNainEligibleForIncentives(uint256 _quantity) external
```

### insuranceState

```solidity
function insuranceState(uint256 _insuranceId) external view returns (struct IInsurance.InsuranceStruct)
```

### createInsurance

```solidity
function createInsurance(address _buyer, string _asset, uint256 _margin, uint256 _q_covered, uint256 _p_market, uint256 _p_claim, uint256 _period, bool useNain) external payable returns (struct IInsurance.InsuranceStruct)
```

### cancelInsurance

```solidity
function cancelInsurance(uint256 _idInsurance) external returns (string)
```

### invalidInsurance

```solidity
function invalidInsurance(uint256 _idInsurance) external returns (string)
```

### updateStateInsurance

```solidity
function updateStateInsurance(uint256 _idInsurance, string _state) external returns (string)
```

### configInsurance

```solidity
function configInsurance(bool _mode) external
```

## IInsurance

### InsuranceStruct

```solidity
struct InsuranceStruct {
  uint256 idInsurance;
  address buyer;
  string asset;
  uint256 margin;
  uint256 q_covered;
  uint256 p_market;
  uint256 p_claim;
  string state;
  uint256 period;
  uint256 recognition_date;
  uint256 expired;
  bool isUseNain;
}
```

### configAddressNain

```solidity
function configAddressNain(address _address_nain) external
```

### renounceNain

```solidity
function renounceNain() external
```

### insuranceState

```solidity
function insuranceState(uint256 _insuranceId) external view returns (struct IInsurance.InsuranceStruct)
```

### createInsurance

```solidity
function createInsurance(address _buyer, string _asset, uint256 _margin, uint256 _q_covered, uint256 _p_market, uint256 _p_claim, uint256 _period, bool _isUseNain) external payable returns (struct IInsurance.InsuranceStruct)
```

### cancelInsurance

```solidity
function cancelInsurance(uint256 _idInsurance) external returns (string)
```

### invalidInsurance

```solidity
function invalidInsurance(uint256 _idInsurance) external returns (string)
```

### updateStateInsurance

```solidity
function updateStateInsurance(uint256 _idInsurance, string _state) external returns (string)
```

### configInsurance

```solidity
function configInsurance(bool _mode) external
```

## USDT

### constructor

```solidity
constructor() public
```

