

pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract ShopList {
   //- контроль за правами доступа (onlyOwner)
   modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }
    uint32 m_count;
    //Структура:"Покупка"
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

    //- список покупок-статистика о покупках
    mapping(uint32 => Purchase) m_purchase;

    uint256 m_ownerPubkey;

  //- конструктор
    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }
    //- добавление покупки в список (параметры: название продукта, количество)
    function createPurchase(string nameP, uint32 quantityP) public onlyOwner{
         tvm.accept();
         m_count++;
         m_purchase[m_count] = Purchase(m_count, nameP, quantityP, now, false, 0);
    }

    //- удаление покупки из списка
    function deletePurchase(uint32 id) public onlyOwner {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        delete m_purchase[id];
    }

    //- купить [помечает, чты вы купили; купить обратно, то есть сбросить флаг покупки  не надо делать].
    // параметры: (ID, цена)
    function updatePurchase(uint32 id, uint32 price) public onlyOwner {
        optional(Purchase ) purchase  = m_purchase .fetch(id);
        require(purchase .hasValue(), 102);
        tvm.accept();
        Purchase  thisPurchase  = purchase.get();
        thisPurchase.isDone = true;
        thisPurchase.price = price;
        m_purchase [id] = thisPurchase;
    }
     //
    // Get methods
    //

    function getPurchases() public view returns (Purchase[] purchases) {
        string name;
        uint32 quantity;
        uint32 timestamp;
        bool isDone; 
        uint32 price;

        for((uint32 id, Purchase purchase) : m_purchase) {
            name = purchase.name;
            isDone = purchase.isDone;
            quantity = purchase.quantity;
            timestamp = purchase.timestamp;
            price = purchase.price;
            purchases.push(Purchase(id, name, quantity,timestamp, isDone,price));
       }
    }

    function getSumPurchase() public view returns (SumPurchase sumPurchase) {
        uint32 paidFor;
        uint32 unpaidt;
        uint32 sumpricepaid;

        for((, Purchase purchase) : m_purchase) {
            if  (purchase.isDone) {
                paidFor += purchase.quantity;
                sumpricepaid += purchase.price;
            } else {
                unpaidt ++;
            }
        }
        sumPurchase = SumPurchase( paidFor, unpaidt, sumpricepaid);
    }

  
}
