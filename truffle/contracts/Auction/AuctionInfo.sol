// SPDX-License-Identifier: MIT
pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;

contract AuctionInfos {

    //경매 정보
    struct AuctionInfo {
        address auctionOwner;          // 경매소유자의 이더리움 주소, 경매가 끝난 후 경매금을 송금할 주소
        uint256 auctionStart;          //경매 시작 시간
        uint256 auctionEnd;            //경매 종료 시간
        uint256 highestBid;            //현재 최대 매수 금액
        address highestBidder;         //최대 매수 금액을 신청한 참가자의 이더리움 주소
        auctionState state;
        string name;
        string number;
    }

    //경매 상태(진행중, 취소)나타냄
    enum auctionState{
        CANCELLED, STARTED
    }

    struct Auctioning {
        uint256 auctionEnd;
        uint256 highestBid;
        auctionState state;
        string name;
    }

    mapping(string => AuctionInfo)  AuctionList;

    //모든 신청자의 주소 배열
    mapping(string => address) bidders;

    //각매수 신청자의 주소를 총 매수 신청액에 사상하는 매칭
    mapping(string => mapping(address => uint))  bids;

    //현재 경매중인 물품 목록
    string[] auctionNames;

    auctionState public STATE;

    //모든 경매중인 목록 검색
    //        function getAllAuctioning() public view returns (
    //            allAuctioning memory
    //        ) {
    //            allAuctioning memory result;
    //
    //            result. =;
    //            result. =;
    //            result. =;
    //            return result;
    //        }

    //해당 경매중인 물품 상세 검색
    function getNumberOfAuctioning(string memory _number) public view returns (
        Auctioning memory
    ) {
        Auctioning memory result;
        result.auctionEnd = AuctionList[_number].auctionEnd;
        result.highestBid = AuctionList[_number].highestBid;
        result.state = AuctionList[_number].state;
        result.name = AuctionList[_number].name;
        return result;
    }

    function bid() public payable returns (bool){}

    function withdraw() public returns (bool){}

    function cancelAuction() external returns (bool){}

    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event WithdrawalEvent(address withdrawer, uint256 amount);
    event CanceledEvent(string message, uint256 time);

}