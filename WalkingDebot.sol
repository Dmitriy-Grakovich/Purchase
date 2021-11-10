pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import 'ShopListDebot.sol';

contract WalkingDebot is ShopListDebot {
    
    string purchaseName;

    function _menu() public override{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (shoplist/done/total) purchases",
                    m_sumPurchase.unpaidt,
                    m_sumPurchase.paidFor,
                    m_sumPurchase.paidFor + m_sumPurchase.unpaidt
            ),
            sep,
            [
                MenuItem("Create new purchase","",tvm.functionId(createPurchase)),

                MenuItem("Show purchase list","",tvm.functionId(showPurchases)),
             
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase))
            ]
        );
    }
     function createPurchase(uint32 index)  public{  index = index;
       
        Terminal.input(tvm.functionId(createPurchase_), "One line please:", false);
        }
    
    function createPurchase_(string value)  public {
        purchaseName = value;
        Terminal.input(tvm.functionId(createPurchase__), "quantity please", false);
    }

    function createPurchase__(string value) public {
        (uint quantity, bool status) = stoi(value);
        if(status){
            IShopList(m_address).createPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: 0,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(purchaseName, uint32(quantity));
        }
    }

    
    function showPurchases_( Purchase[] purchases ) public override {
        uint32 i;
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your purchases list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isDone) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\"  at {}", purchase.id, completed, purchase.name, purchase.quantity));
            }
        } else {
            Terminal.print(0, "Your purchases list is empty");
        }
        _menu();
    }

    function deletePurchase_(string value) public view override{
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopList(m_address).deletePurchase{
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

}