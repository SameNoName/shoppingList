pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "res.sol";

contract shoppingList {
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 m_count;

    mapping(uint32 => Purchase) m_purchases;

    uint256 m_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function addPurchase(string name, uint32 count) public onlyOwner {
        tvm.accept();
        m_count++;
        m_purchases[m_count] = Purchase(m_count, name, count, now, false, 0);
    }

    function buy(uint32 id, uint32 price) public onlyOwner {
        optional(Purchase) items = m_purchases.fetch(id);
        require(items.hasValue(), 102);
        tvm.accept();
        Purchase thisItem = items.get();
        thisItem.isPurchase = true;
        thisItem.price = price;
        m_purchases[id] = thisItem;
    }

    function deletePurchase(uint32 id) public onlyOwner {
        require(m_purchases.exists(id), 102);
        tvm.accept();
        delete m_purchases[id];
    }

    function getPurchases() public view returns (Purchase[] purchases) {
        string name;
        uint32 count;
        uint32 timestamp;
        bool isPurchase;
        uint32 price;

        for((uint32 id, Purchase item) : m_purchases) {
            name = item.name;
            count = item.count;
            timestamp = item.timestamp;
            isPurchase = item.isPurchase;
            price = item.price;
            purchases.push(Purchase(id, name, count, timestamp, isPurchase, price));
       }
    }

    function getSummary() public view returns (Summary thisSummary) {
        uint32 paidCount;
        uint32 unpaidCount;

        for((, Purchase item) : m_purchases) {
            if  (item.isPurchase) {
                paidCount ++;
            } else {
                unpaidCount ++;
            }
        }
        thisSummary = Summary( paidCount, unpaidCount, paidCount + unpaidCount);
    }
}