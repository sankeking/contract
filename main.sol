pragma solidity >=0.4.22 <0.6.0;
contract ordersc{
    address public Lessor;
    address public Hotelier;
    address public Customer;
    string public vehicle_lessor;
    string public vehicle_name;
    uint public rent_price;
    string public hotel_name;
    string public room_name;
    uint public hotel_price;
    uint public total_price;
    uint public star;
    uint public publish_time;
    string public start_time;
    string public end_time;
    bool public close = false;
    bool public lessorPay = false;
    bool public hotelierPay = false;
    bool public rateEnd = false;
    
    //透過mapping方式記錄客戶方Address及下單時間
    mapping(address => customers) public CustomerData;
    struct customers{
        address customer_address;
        uint buy_time;
    }
    modifier priceEqual{        //訂單總價是否等於所付finney(1 ether = 1000 finney)
        require(msg.value == total_price * 1.5 finney);
        _;
    }
    modifier onlyLessor {       //是否為出租方
        require (msg.sender == Lessor);
        _;  
    }
    modifier onlyHotelier {      //是否為飯店方
        require (msg.sender == Hotelier);
        _;
    }
    modifier onlyCustomer {     //是否為客戶方
        require (msg.sender == Customer);
        _;
    }
    modifier notEnd{        //訂單是否還尚未結束
        require(close == false);
        _;
    }
    modifier End{       //訂單是否已結束
        require(close == true);
        _;
    }
    modifier LessorPayEnd{      //出租方是否已繳還押金
        require(lessorPay == true);
        _;
    }
    modifier HotelierPayEnd{        //飯店方是否已繳還押金
        require(hotelierPay == true);
        _;
    }
    modifier notRate{       //客戶是否已完成投票
        require(rateEnd == false);
        _;
    }
    //初始化    
    constructor(address _Lessor, string memory _vehicle_lessor, string memory _vehicle_name, uint _rent_price, address _Hotelier,string memory _hotel_name,
                string memory _room_name, uint _hotel_price, string memory _start_time, string memory _end_time) public {
        publish_time = now;
        Lessor = _Lessor;
        vehicle_lessor = _vehicle_lessor;
        vehicle_name = _vehicle_name;
        rent_price = _rent_price;
        Hotelier = _Hotelier;
        hotel_name = _hotel_name;
        room_name = _room_name;
        hotel_price = _hotel_price;
        total_price = _rent_price + _hotel_price;
        start_time = _start_time;
        end_time = _end_time;
    }
    //送出訂單
    function SendOrder(address _Customer) priceEqual notEnd public payable{
        CustomerData[_Customer] = customers({
            customer_address : _Customer,
            buy_time : now
        });
        Customer = _Customer;
    }
    //結束訂單
    function end() HotelierPayEnd LessorPayEnd public{
        close = true;
    }
    //評分
    function rate(uint _star) onlyCustomer End notRate public{
        if(0 < _star && _star <= 5){
            star = _star;
            rateEnd = true;
        }
        else{
            star = 0;
        }
    }
    //將address設為payable
    function make_payable(address x) internal pure returns(address payable){
    return address(uint160(x));
    }
    //出租方繳還押金    
    function LessorDepositRefund() onlyLessor notEnd public{
        make_payable(Customer).transfer(rent_price  * 0.5 finney);
        lessorPay = true;
    }   
    //出租方收款  
    function LessorGetEther() onlyLessor End public{
        make_payable(Lessor).transfer(rent_price  * 1 finney);
    }
    //飯店方繳還押金  
    function HotelDepositRefund() onlyHotelier notEnd public{
        make_payable(Customer).transfer(hotel_price  * 0.5 finney);
        hotelierPay = true;
    }   
    //飯店方收款  
    function HotelGetEther() onlyHotelier End public{
        make_payable(Hotelier).transfer(hotel_price  * 1 finney);
    }
}
    