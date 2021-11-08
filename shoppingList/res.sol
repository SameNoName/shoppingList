pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase
{
    uint32 id;
    string name;
    uint32 count;
    uint32 timestamp;
    bool isPurchase;
    uint32 price;
}

struct Summary
{
    uint32 paidCount;
    uint32 unpaidCount;
    uint32 totalCount;
}

interface IShopingList {
   function addPurchase(string name, uint32 count) external;
   function buy(uint32 id, uint32 price) external;
   function deletePurchase(uint32 id) external;
   function getPurchases() external returns (Purchase[] items);
   function getSummary() external returns (Summary);
}

interface ITransactable {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}

abstract contract HasConstructorWithPubKey {
   constructor(uint256 pubkey) public {}
}