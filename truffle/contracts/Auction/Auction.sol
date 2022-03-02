// SPDX-License-Identifier: MIT
pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;
import "./AuctionInfo.sol";

contract Auction is AuctionInfos {

    constructor () public {
    }

    //bid배열
    //

    //경매 등록
    function setAuction(uint8 _minuteSet, string memory _name, string memory _number) public returns(bool){
        require(_minuteSet > 0, "");
        require(bytes(_name).length != 0, "");
        require(bytes(_number).length != 0, "");

        AuctionList[_number].auctionOwner = msg.sender;
        AuctionList[_number].auctionStart = now;
        AuctionList[_number].auctionEnd = AuctionList[_number].auctionStart + (_minuteSet * 1 minutes);
        AuctionList[_number].state = auctionState.STARTED;
        AuctionList[_number].name = _name;
        //나중에 입력 X, 바로 사용할 수 있게끔.
        AuctionList[_number].number = _number;

        auctionNames.push(_name);
        return true;
    }
    // bid() 호가, 즉 참가자가 매수 신청액을 지정하는데 사용.
    //경매의 호가는 누적 방식, 즉 최고가를 부른 참가자를 이기려면
    //다음번 호가에서 절대금액이 아니라 추가분을 불러야함
    //payable 이지정자는 함수가 이더를 받을수 있음을 뜻함
    function bid(string memory _number) public payable{
        require(now <= AuctionList[_number].auctionEnd, "The auction is already over.");
        require(bids[_number][msg.sender] + msg.value > AuctionList[_number].highestBid, "You can't bid, Make a higher Bid");

        AuctionList[_number].highestBidder = msg.sender;
        AuctionList[_number].highestBid = msg.value;
        bidders[_number] = msg.sender;
        bids[_number][msg.sender] = bids[_number][msg.sender] + msg.value;

        emit BidEvent(AuctionList[_number].highestBidder,AuctionList[_number].highestBid);

    }
    // cancle 경매 소유자가 자신이 시작한 경매를 취소
    function cancelAuction(string calldata _number) external returns (bool){
        require(now <= AuctionList[_number].auctionEnd, "The auction is already over.");
        require(msg.sender == AuctionList[_number].auctionOwner);
        AuctionList[_number].state = auctionState.CANCELLED;
        emit CanceledEvent("Auction Cancelled", now);
        return true;
    }

    //withdraw() 경매가 끝났을때 참가자가 자신의 매수 신청액을 회수하는데 사용
    function withdraw(string memory _number) public returns (bool){
        require(AuctionList[_number].auctionEnd < now);
        uint amount;
        if (msg.sender == AuctionList[_number].highestBidder && AuctionList[_number].state == auctionState.CANCELLED) {
            amount = bids[_number][AuctionList[_number].highestBidder];
            bids[_number][AuctionList[_number].highestBidder] = 0;

            address payable payableOwner = address(uint160(AuctionList[_number].auctionOwner));
            payableOwner.transfer(amount);

            emit WithdrawalEvent(payableOwner, amount);
        }
        else {
            amount = bids[_number][msg.sender];
            bids[_number][msg.sender] = 0;
            msg.sender.transfer(amount);
            emit WithdrawalEvent(msg.sender, amount);
            return true;
        }

        return true;
    }

}

// // 블록체인에서 경매계약을 제거
/*
    function destruct_auction() external only_owner returns (bool){

       require(now > auction_end,"You can't destruct the contract,The auction is still open");
       for(uint i=0;i<bidders.length;i++)
       {
           assert(bids[bidders[i]]==0);
       }

       //selfdestruct(auction_owner);
       return true;
    }
*/

// 경매소유자의 이더리움 주소, 경매가 끝난 후 경매금을 송금할 주소
// view  이들은 함수가 계약상태를 변경하지 못함을 나타냄.
/*
    function get_owner() public view returns(address){
        return auction_owner;
    }
*/