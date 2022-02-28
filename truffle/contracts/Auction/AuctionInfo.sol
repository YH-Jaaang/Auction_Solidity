// SPDX-License-Identifier: MIT
pragma solidity ^0.5.1;

contract AuctionInfo {

  address payable internal auction_owner;     // 경매소유자의 이더리움 주소, 경매가 끝난 후 경매금을 송금할 주소
  uint256 public auction_start;               //경매 시작 시간
  uint256 public auction_end;                 //경매 종료 시간
  uint256 public highestBid;                  //현재 최대 매수 금액
  address public highestBidder;               //최대 매수 금액을 신청한 참가자의 이더리움 주소


  //경매 상태(진행중, 취소)나타냄
  enum auction_state{
    CANCELLED,STARTED
  }

  struct  AuctionInfo{
    string  Name;
    string  Number;
  }
  AuctionInfo public AuctionList;
  address[] bidders;      //모든 신청자의 주소 배열

  //각매수 신청자의 주소를 총 매수 신청액에 사상하는 매칭
  mapping(address => uint) public bids;

  auction_state public STATE;


  modifier an_ongoing_auction(){
    require(now <= auction_end);
    _;
  }

  modifier only_owner(){
    require(msg.sender==auction_owner);
    _;
  }

  function bid() public payable returns (bool){}
  function withdraw() public returns (bool){}
  function cancel_auction() external returns (bool){}

  event BidEvent(address indexed highestBidder, uint256 highestBid);
  event WithdrawalEvent(address withdrawer, uint256 amount);
  event CanceledEvent(string message, uint256 time);

}