// SPDX-License-Identifier: MIT
pragma solidity ^0.5.1;

import "./AuctionInfo.sol";

contract Auction is AuctionInfo {

    constructor () public {
        auction_owner = msg.sender;
        auction_start = now;
        auction_end = auction_start + 5 * 1  minutes;
        STATE = auction_state.STARTED;
        AuctionList.Name = 'limited edition';
        AuctionList.Number = '1234';
    }

    // bid() 호가, 즉 참가자가 매수 신청액을 지정하는데 사용.
    //경매의 호가는 누적 방식, 즉 최고가를 부른 참가자를 이기려면
    //다음번 호가에서 절대금액이 아니라 추가분을 불러야함
    //payable 이지정자는 함수가 이더를 받을수 있음을 뜻함
    function bid() public payable an_ongoing_auction returns (bool){

        require(bids[msg.sender] + msg.value > highestBid, "You can't bid, Make a higher Bid");
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidders.push(msg.sender);
        bids[msg.sender] = bids[msg.sender] + msg.value;

        emit BidEvent(highestBidder, highestBid);

        return true;
    }
    // cancle 경매 소유자가 자신이 시작한 경매를 취소
    function cancel_auction() external only_owner an_ongoing_auction returns (bool){

        STATE = auction_state.CANCELLED;
        emit CanceledEvent("Auction Cancelled", now);
        return true;
    }
    // // 블록체인에서 경매계약을 제거
    // function destruct_auction() external only_owner returns (bool){

    //     require(now > auction_end,"You can't destruct the contract,The auction is still open");
    //     for(uint i=0;i<bidders.length;i++)
    //     {
    //         assert(bids[bidders[i]]==0);
    //     }

    //     //selfdestruct(auction_owner);
    //     return true;

    //}

    //withdraw() 경매가 끝났을때 참가자가 자신의 매수 신청액을 회수하는데 사용
    // function withdraw() public returns (bool){
    //     require(now > auction_end ,"You can't withdraw, the auction is still open");
    //     uint amount;

    //     amount=bids[msg.sender];
    //     bids[msg.sender]=0;
    //     msg.sender.transfer(amount);
    //     emit WithdrawalEvent(msg.sender, amount);
    //     return true;

    // }
    function withdraw() public returns (bool){
        require(auction_end < now);
        uint amount;
        if (msg.sender == highestBidder || STATE == auction_state.CANCELLED) {
            amount = bids[highestBidder];
            bids[highestBidder] = 0;
            auction_owner.transfer(amount);
            emit WithdrawalEvent(auction_owner, amount);
        }
        else {
            amount = bids[msg.sender];
            bids[msg.sender] = 0;
            msg.sender.transfer(amount);
            emit WithdrawalEvent(msg.sender, amount);
            return true;
        }

        return true;
    }

    // 경매소유자의 이더리움 주소, 경매가 끝난 후 경매금을 송금할 주소
    //view  이들은 함수가 계약상태를 변경하지 못함을 나타냄.
    // function get_owner() public view returns(address){
    //     return auction_owner;
    // }
}


