pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

 struct Purchase {
        //- идентификатор/номер
        uint32 id;
        //- название
        string name;
        //- количество (сколько надо купить)
        uint32 quantity;
        // когда заведена
        uint32 timestamp;
        //- флаг, что куплена
        bool isDone;
        //- цена, за которую купили [за все единиицы сразу] (при заведении в список всегда 0 
        uint32 price;
    }
    
    //Структура "Саммари покупок"
    struct SumPurchase {
        //- сколько предметов в списке "оплачено"
        uint32 paidFor;
        //- сколько предметов в списке "не оплачено"
        uint32 unpaidt;
       // - на какую сумму всего было оплачено
        uint32 sumpricepaid;
    }

    //"Transactable"- sendTransaction
    interface Transactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
    }


    abstract contract HasConstructorWithPubKey {
        constructor(uint256 pubkey) public {}
    }
    //Интерфейсы: "Список покупок"
    interface IShopList {
      function addPurchase(string nameP, uint32 quantityP) external;
      function updatePurchase(uint32 id, uint32 price) external;
      function deletePurchase(uint32 id) external;
      function getPurchases() external returns (Purchase[] purchasess);
      function getSumPurchase() external returns (SumPurchase );
}