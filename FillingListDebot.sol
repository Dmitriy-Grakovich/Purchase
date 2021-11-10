pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import 'ShopListDebot.sol';

contract FillingListDebot is ShopListDebot {
    
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
              
                MenuItem("Show purchase list","",tvm.functionId(showPurchases)),
                MenuItem("Update purchase status","",tvm.functionId(updatePurchase)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase))
            ]
        );
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

     function updatePurchase(uint32 index) public {
        index = index;
        if (m_sumPurchase.paidFor + m_sumPurchase.unpaidt > 0) {
            Terminal.input(tvm.functionId(updatePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchases to update");
            _menu();
        }
    }

    function updatePurchase_(string value) public {
        (uint256 num,) = stoi(value);
        m_purchaseId = uint32(num);
        ConfirmInput.get(tvm.functionId(updatePurchase__),"Is this purchase completed?");
    }

    function updatePurchase__(uint32 value) public {
        optional(uint256) pubkey = 0;
        IShopList(m_address).updatePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_purchaseId, value);
    }
    

   

}