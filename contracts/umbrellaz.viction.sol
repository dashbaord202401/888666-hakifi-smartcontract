// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract UmbrellazVIC {
    /**
     * USDT - 0
     * VNST - 1
     */
    enum TOKEN {
        USDT,
        VNST
    }

    /**
     * margin_pool - 0
     * claim_pool - 1
     * hakifi_fund - 2
     * third_party_fund - 3
     */
    enum VAULT {
        margin_pool,
        claim_pool,
        hakifi_fund,
        third_party_fund
    }

    enum TYPE {
        CREATE,
        UPDATE_AVAILABLE,
        UPDATE_INVALID,
        REFUND,
        CANCEL,
        CLAIM,
        EXPIRED,
        LIQUIDATED
    }

    /**
     * PENDING - 0
     * AVAILABLE - 1
     * CLAIMED - 2
     * REFUNDED - 3
     * LIQUIDATED - 4
     * EXPIRED - 5
     * CANCELED - 6
     * INVALID - 7
     */
    enum STATE {
        PENDING,
        AVAILABLE,
        CLAIMED,
        REFUNDED,
        LIQUIDATED,
        EXPIRED,
        CANCELED,
        INVALID
    }

    struct Insurance {
        address buyer;
        TOKEN unit;
        uint72 margin;
        uint72 claim_amount;
        uint48 expired_time;
        uint48 open_time;
        STATE state;
        bool valid;
    }

    mapping(VAULT => mapping(TOKEN => uint256)) private vaults;
    mapping(string => Insurance) private insurances;

    IERC20 usdt;
    IERC20 vnst;

    /*
     @event
    **/
    event EInsurance(
        string idInsurance,
        address buyer,
        TOKEN unit,
        uint72 margin,
        uint72 claim_amount,
        uint48 expired_time,
        uint48 open_time,
        STATE state,
        TYPE event_type
    );

    constructor() {
        usdt = IERC20(0x69d75da9e018f3E624c173358f47fffCdBaB5362);
        vnst = IERC20(0x3c34c84BD32AE728b0c871caF5fF389418cee22d);
    }

    function getVault(VAULT _vault, TOKEN _token) external view returns (uint256) {
        return vaults[_vault][_token];
    }

    function readInsurance(string memory _index) external view returns (Insurance memory) {
        return insurances[_index];
    }

    function createInsurance(string memory _idInsurance, TOKEN _unit, uint64 _margin) external {
        require(!insurances[_idInsurance].valid, "Id not unique");
        require(
            usdt.balanceOf(address(msg.sender)) >= _margin || vnst.balanceOf(address(msg.sender)) >= _margin,
            "TOKEN is not enough"
        );

        vaults[VAULT.margin_pool][_unit] += _margin;

        insurances[_idInsurance] = Insurance(
            msg.sender,
            _unit,
            _margin,
            0,
            0,
            uint48(block.timestamp),
            STATE.PENDING,
            true
        );

        if (_unit == TOKEN.USDT) {
            usdt.transferFrom(msg.sender, address(this), _margin);
        } else if (_unit == TOKEN.VNST) {
            vnst.transferFrom(msg.sender, address(this), _margin);
        }

        emit EInsurance(
            _idInsurance,
            msg.sender,
            _unit,
            _margin,
            0,
            0,
            uint48(block.timestamp),
            STATE.PENDING,
            TYPE.CREATE
        );
    }

    function updateAvailableInsurance(string memory _idInsurance, uint72 _claim_amount, uint48 _expired_time) external {
        require(insurances[_idInsurance].valid, "Id don't exists");
        require(
            usdt.balanceOf(address(msg.sender)) >= _claim_amount ||
                vnst.balanceOf(address(msg.sender)) >= _claim_amount,
            "TOKEN is not enough"
        );

        insurances[_idInsurance].state = STATE.AVAILABLE;
        insurances[_idInsurance].claim_amount = _claim_amount;
        insurances[_idInsurance].expired_time = _expired_time;
        vaults[VAULT.claim_pool][insurances[_idInsurance].unit] += _claim_amount;

        Insurance memory insurance = insurances[_idInsurance];

        emit EInsurance(
            _idInsurance,
            insurance.buyer,
            insurance.unit,
            insurance.margin,
            _claim_amount,
            _expired_time,
            insurance.open_time,
            STATE.AVAILABLE,
            TYPE.UPDATE_AVAILABLE
        );
    }

    function updateInvalidInsurance(string memory _idInsurance) external {
        require(insurances[_idInsurance].valid, "Id don't exists");

        Insurance memory insurance = insurances[_idInsurance];

        insurances[_idInsurance].state = STATE.INVALID;
        vaults[VAULT.margin_pool][insurance.unit] -= insurance.margin;

        insurances[_idInsurance].margin = 0;

        if (insurance.unit == TOKEN.USDT) {
            usdt.approve(address(this), insurance.margin);
            usdt.transferFrom(address(this), insurance.buyer, insurance.margin);
        } else if (insurance.unit == TOKEN.VNST) {
            vnst.approve(address(this), insurance.margin);
            vnst.transferFrom(address(this), insurance.buyer, insurance.margin);
        }

        emit EInsurance(
            _idInsurance,
            insurance.buyer,
            insurance.unit,
            0,
            insurance.claim_amount,
            insurance.expired_time,
            insurance.open_time,
            STATE.INVALID,
            TYPE.UPDATE_INVALID
        );
    }

    function refund(string memory _idInsurance) external {
        require(insurances[_idInsurance].valid, "Id don't exists");

        Insurance memory insurance = insurances[_idInsurance];

        insurances[_idInsurance].state = STATE.REFUNDED;
        vaults[VAULT.margin_pool][insurance.unit] -= insurance.margin;

        insurances[_idInsurance].margin = 0;

        if (insurance.unit == TOKEN.USDT) {
            usdt.approve(address(this), insurance.margin);
            usdt.transferFrom(address(this), insurance.buyer, insurance.margin);
        } else if (insurance.unit == TOKEN.VNST) {
            vnst.approve(address(this), insurance.margin);
            vnst.transferFrom(address(this), insurance.buyer, insurance.margin);
        }

        emit EInsurance(
            _idInsurance,
            insurance.buyer,
            insurance.unit,
            0,
            insurance.claim_amount,
            insurance.expired_time,
            insurance.open_time,
            STATE.REFUNDED,
            TYPE.REFUND
        );
    }

    function cancel(string memory _idInsurance) external {
        require(insurances[_idInsurance].valid, "Id don't exists");

        Insurance memory insurance = insurances[_idInsurance];

        insurances[_idInsurance].state = STATE.CANCELED;
        vaults[VAULT.margin_pool][insurance.unit] -= insurance.margin;

        insurances[_idInsurance].margin = 0;

        if (insurance.unit == TOKEN.USDT) {
            usdt.approve(address(this), insurance.margin);
            usdt.transferFrom(address(this), insurance.buyer, insurance.margin);
        } else if (insurance.unit == TOKEN.VNST) {
            vnst.approve(address(this), insurance.margin);
            vnst.transferFrom(address(this), insurance.buyer, insurance.margin);
        }

        emit EInsurance(
            _idInsurance,
            insurance.buyer,
            insurance.unit,
            0,
            insurance.claim_amount,
            insurance.expired_time,
            insurance.open_time,
            STATE.CANCELED,
            TYPE.CANCEL
        );
    }

    function claim(string memory _idInsurance) external {
        require(insurances[_idInsurance].valid, "Id don't exists");

        Insurance memory insurance = insurances[_idInsurance];

        insurances[_idInsurance].state = STATE.CLAIMED;
        vaults[VAULT.claim_pool][insurance.unit] -= insurance.claim_amount;

        insurances[_idInsurance].claim_amount = 0;

        if (insurance.unit == TOKEN.USDT) {
            usdt.approve(address(this), insurance.claim_amount);
            usdt.transferFrom(address(this), insurance.buyer, insurance.claim_amount);
        } else if (insurance.unit == TOKEN.VNST) {
            vnst.approve(address(this), insurance.claim_amount);
            vnst.transferFrom(address(this), insurance.buyer, insurance.claim_amount);
        }

        emit EInsurance(
            _idInsurance,
            insurance.buyer,
            insurance.unit,
            0,
            0,
            insurance.expired_time,
            insurance.open_time,
            STATE.CLAIMED,
            TYPE.CLAIM
        );
    }

    function expire(string memory _idInsurance) external {
        require(insurances[_idInsurance].valid, "Id don't exists");

        insurances[_idInsurance].state = STATE.EXPIRED;

        Insurance memory insurance = insurances[_idInsurance];

        emit EInsurance(
            _idInsurance,
            insurance.buyer,
            insurance.unit,
            insurance.margin,
            insurance.claim_amount,
            insurance.expired_time,
            insurance.open_time,
            STATE.EXPIRED,
            TYPE.EXPIRED
        );
    }

    function liquidate(string memory _idInsurance) external {
        require(insurances[_idInsurance].valid, "Id don't exists");

        insurances[_idInsurance].state = STATE.LIQUIDATED;

        Insurance memory insurance = insurances[_idInsurance];

        emit EInsurance(
            _idInsurance,
            insurance.buyer,
            insurance.unit,
            insurance.margin,
            insurance.claim_amount,
            insurance.expired_time,
            insurance.open_time,
            STATE.LIQUIDATED,
            TYPE.LIQUIDATED
        );
    }
}
