pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "initDebot.sol";

contract shopWalkingDebot is initDebot {

    uint32 m_taskId;

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping DeBot";
        version = "0.2.0";
        publisher = "TON Labs";
        key = "TODO list manager";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hello, I can help you make purchases.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID ];
    }

    function _menu() override public {
        string sep = '----------------------------------------';
        Menu.select(
            format(
               "You have {}/{}/{} (paid/unpaid/total) purchases",
                    m_stat.paidCount,
                    m_stat.unpaidCount,
                    m_stat.totalCount
            ),
            sep,
            [
                MenuItem("Show shopping list","",tvm.functionId(showPurchases)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase)),
                MenuItem("Make a purchase ","",tvm.functionId(buy))
            ]
        );
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function showPurchases(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShopingList(m_address).getPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
    }

    function showPurchases_( Purchase[] items ) public {
        uint32 i;
        if (items.length > 0 ) {
            Terminal.print(0, "Your shopping list:");
            for (i = 0; i < items.length; i++) {
                Purchase purchase = items[i];
                string completed;
                if (purchase.isPurchase) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" count: {}, price: {}", purchase.id, completed, purchase.name, purchase.count, purchase.price));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function deletePurchase(uint32 index) public {
        index = index;
        if (m_stat.totalCount > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, your shopping list is empty");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopingList(m_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }

    function buy(uint32 index) public {
        index = index;
        if (m_stat.totalCount > 0) {
            Terminal.input(tvm.functionId(buy_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, your shopping list is empty");
            _menu();
        }
    }

    function buy_(string value) public {
        (uint256 num,) = stoi(value);
        m_taskId = uint32(num);
        Terminal.input(tvm.functionId(buy__), "Enter purchase price:", false);
    }

    function buy__(string value) public view {
        optional(uint256) pubkey = 0;
        (uint256 num,) = stoi(value);
        uint32 buffPrice = uint32(num);
        IShopingList(m_address).buy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_taskId, buffPrice);
    }

    function setSummary(Summary thisSummary) public override {
        m_stat = thisSummary;
        _menu();
    }

    function getSummary(uint32 answerId) public override view {
        optional(uint256) none;
        IShopingList(m_address).getSummary{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }
}