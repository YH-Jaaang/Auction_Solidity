
const Auction = artifacts.require('./Metaphors/Auction.sol')
const fs = require('fs')

module.exports = function (deployer) {
    deployer.deploy(Auction)
        .then((accounts) => {
            fs.writeFile(
                './truffle/address/Auction',
                Auction.address,
                (err) => {
                    if (err) throw err
                    console.log("파일에 주소 입력 성공");
                })
        })
}
