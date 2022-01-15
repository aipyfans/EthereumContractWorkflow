const fs = require('fs-extra');
const path = require('path');
const Web3 = require('web3');
const HDWalletProvider = require('truffle-hdwallet-provider');

// 1. 拿到 bytecode
// const contractPath = path.resolve(__dirname, '../compiled/Car.json');
const contractPath = path.resolve(__dirname, '../compiled/ProjectList.json');
const { interface, bytecode } = require(contractPath);

// 2. 配置 provider
const provider = new HDWalletProvider(
    'spell salon wolf rural recipe junior baby chase drink club muscle smooth',
    'https://ropsten.infura.io/v3/9b5ee59307d44af6b7636dcc002d9026'
);

// 3. 初始化 web3 实例
const web3 = new Web3(provider);

(async () => {
    // 4. 获取钱包里面的账户
    const accounts = await web3.eth.getAccounts();
    console.log('合约的账户：', accounts[0]);

    // 5. 创建合约实例并且部署
    console.time('合约部署耗时');
    const result = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({ data: bytecode})
        .send({ from: accounts[0], gas: '1000000' });
    
    console.time('合约部署耗时');

    const contractAddress = result.options.address;
    
    console.log('合约部署成功:', contractAddress);
    console.log('合约查看地址:', `https://ropsten.etherscan.io/address/${contractAddress}`);
    
    // 6. 合约地址写入文件系统
    const addressFile = path.resolve(__dirname, '../address.json');
    fs.writeFileSync(addressFile, JSON.stringify(contractAddress));
    console.log('地址写入成功:', addressFile);
    
    process.exit();

})();