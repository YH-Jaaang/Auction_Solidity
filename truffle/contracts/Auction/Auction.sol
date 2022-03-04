// SPDX-License-Identifier: MIT
pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2;

import "./AuctionInfo.sol";
//import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract Auction is AuctionInfos {

    //    constructor() ERC721Full("AuctionToken", "ACT") public {
    //    }

    //경매 등록
    function setAuction(uint256 _minuteSet, string memory _name, string memory _number) public returns (bool){
        require(_minuteSet > 0, "Please set the auction time.");
        require(bytes(_name).length != 0, "Please enter the auction name.");
        require(bytes(_number).length != 0, "Please enter the auction number.");
        require(keccak256(bytes(AuctionList[_number].number)) != keccak256(bytes(_number)), "The same number already exists.");

        uint256 unixTime = now;

        AuctionInfo memory auctionInfo = AuctionInfo(
            msg.sender,
            unixTime,
            unixTime + (_minuteSet * 60),
            0,
            address(0),
            auctionState.STARTED,
            _name,
            _number
        );
        AuctionList[_number] = auctionInfo;

        //현재 경매 중인 물품 번호
        itemUnderAuction.push(_number);
        itemUnderAuctionIndex[_number] = itemUnderAuction.length;

        //현재 경매 중인 자신의 물품 번호
        itemUnderAuctionOfOwn[msg.sender].push(_number);
        itemUnderAuctionOfOwnIndex[msg.sender][_number] = itemUnderAuctionOfOwn[msg.sender].length;

        emit SetAuctionEvent(auctionInfo);
        return true;
    }
    // bid() 호가, 즉 참가자가 매수 신청액을 지정하는데 사용.
    //경매의 호가는 누적 방식, 즉 최고가를 부른 참가자를 이기려면
    //다음번 호가에서 절대금액이 아니라 추가분을 불러야함
    //payable 이지정자는 함수가 이더를 받을수 있음을 뜻함
    function bid(string memory _number) public payable {
        require(now <= AuctionList[_number].auctionEnd, "The auction is already over.");
        require(bids[_number][msg.sender] + msg.value > AuctionList[_number].highestBid, "You can't bid, Make a higher Bid");
        require(AuctionList[_number].state != auctionState.CANCELLED, "This auction has already been canceled.");
        require(bytes(_number).length != 0, "Please enter the auction number.");

        AuctionList[_number].highestBidder = msg.sender;
        AuctionList[_number].highestBid = msg.value;
        bidders[_number] = msg.sender;
        bids[_number][msg.sender] = bids[_number][msg.sender] + msg.value;

        //현재 자신이 참여중인 경매
//        if (keccak256(bytes(participatingAuction[msg.sender][participatingAuctionIndex[msg.sender][_number]])) != keccak256(bytes(_number))) {
//            participatingAuction[msg.sender].push(_number);
//            participatingAuctionIndex[msg.sender][_number] = participatingAuction[msg.sender].length;
//        }

        emit BidEvent(AuctionList[_number].highestBidder, AuctionList[_number].highestBid);

    }
    // cancle 경매 소유자가 자신이 시작한 경매를 취소
    // 취소했을 경우, 그 이전 비드 상황 어떻게 고려(2번 채택)
    // 1.값이 존재하고 취소했을 경우, 경매 처리 2. 다시 되돌려준다
    function cancelAuction(string calldata _number) external returns (bool){
        require(now <= AuctionList[_number].auctionEnd, "The auction is already over.");
        require(msg.sender == AuctionList[_number].auctionOwner, "msg.sender and auction owner are different.");
        require(bytes(_number).length != 0, "Please enter the auction number.");

        AuctionList[_number].state = auctionState.CANCELLED;

        initAuction(_number);
        initAuctionOfOwn(msg.sender, _number);

        emit CanceledEvent("Auction Cancelled", now);

        return true;
    }

    //withdraw() 경매가 끝났을때 참가자가 자신의 매수 신청액을 회수하는데 사용
    function withdraw(string memory _number) public {
        require(bytes(_number).length != 0, "Please enter the auction number.");

        uint256 amount;
        if (msg.sender == AuctionList[_number].highestBidder && AuctionList[_number].state != auctionState.CANCELLED) {
            require(AuctionList[_number].auctionEnd <= now, "The auction is still underway.");

            amount = bids[_number][msg.sender];
            bids[_number][msg.sender] = 0;

            address payable payableOwner = address(uint160(AuctionList[_number].auctionOwner));
            payableOwner.transfer(amount);

            initAuction(_number);
            initAuctionOfOwn(AuctionList[_number].auctionOwner, _number);
            //_mint(msg.sender, _number);
            //현재 자신이 참여중인 경매 제거
            emit WithdrawalEvent(payableOwner, amount);
        }
        else {
            if (AuctionList[_number].state != auctionState.CANCELLED) {
                require(AuctionList[_number].auctionEnd <= now, "The auction is still underway.");
            }
            amount = bids[_number][msg.sender];
            bids[_number][msg.sender] = 0;
            msg.sender.transfer(amount);
            //현재 자신이 참여중인 경매 제거
            emit WithdrawalEvent(msg.sender, amount);
        }

    }

    function initAuction(string memory _number) private returns (bool){

        uint256 lastIndex = itemUnderAuction.length - 1;

        if (itemUnderAuction.length != itemUnderAuctionIndex[_number]) {
            uint256 index = itemUnderAuctionIndex[_number] - 1;

            itemUnderAuction[index] = itemUnderAuction[lastIndex];

            string memory element = itemUnderAuction[index];
            itemUnderAuctionIndex[element] = itemUnderAuctionIndex[_number];
        }

        delete itemUnderAuction[lastIndex];
        itemUnderAuction.length--;
        itemUnderAuctionIndex[_number] = 0;

        return true;
    }

    function initAuctionOfOwn(address _address, string memory _number) private returns (bool){

        uint256 lastIndex = itemUnderAuctionOfOwn[_address].length - 1;

        if (itemUnderAuctionOfOwn[_address].length != itemUnderAuctionOfOwnIndex[_address][_number]) {
            uint256 index = itemUnderAuctionOfOwnIndex[_address][_number] - 1;

            itemUnderAuctionOfOwn[_address][index] = itemUnderAuctionOfOwn[_address][lastIndex];

            string memory element = itemUnderAuctionOfOwn[_address][index];
            itemUnderAuctionOfOwnIndex[_address][element] = itemUnderAuctionOfOwnIndex[_address][_number];
        }

        delete itemUnderAuctionOfOwn[_address][lastIndex];
        itemUnderAuctionOfOwn[_address].length--;
        itemUnderAuctionOfOwnIndex[_address][_number] = 0;

        return true;
    }
    //모든 경매중인 목록 검색
    function getAllAuctioning() public view returns (
        string[] memory
    ) {
        return itemUnderAuction;
    }

    //해당 경매중인 물품 상세 검색
    function getNumberOfAuctioning(string memory _number) public view returns (
        Auctioning memory
    ) {
        Auctioning memory result;
        result.auctionStart = AuctionList[_number].auctionStart;
        result.auctionEnd = AuctionList[_number].auctionEnd;
        result.highestBid = AuctionList[_number].highestBid;
        result.state = AuctionList[_number].state;
        result.name = AuctionList[_number].name;
        return result;
    }
    //자신이 경매중인 목록 검색
    function getAllAuctioningOfOwn(address _address) public view returns (
        string[] memory
    ) {
        return itemUnderAuctionOfOwn[_address];
    }

    //현재 자신이 참여중인 경매
    function getAllParticipatingAuction(address _address) public view returns (
        string[] memory
    ) {
        return participatingAuction[_address];
    }
}
