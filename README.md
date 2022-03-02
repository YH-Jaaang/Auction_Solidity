#Auction

# 개요
본 프로젝트는 이더리움 기반 경매 시스템 입니다.

## 프로젝트 구조
```bash
- Auction_Solidity
    +- truffle 
      +- abi          ==> 스마트 컨트랙트의 abi 파일들
      +- contracts    ==> Solidity 소스 파일들
      +- migrations   ==> Migrate를 위한 자바스크립트 소스 파일들

```

# 빌드
## 시스템 필요사항
* node 12.22.9
* truffle 5.1.23
* solc 0.5.1

## 시스템 실행 방법
### Ganache Network
```bash
  $ truffle migrate --network ganache
```

