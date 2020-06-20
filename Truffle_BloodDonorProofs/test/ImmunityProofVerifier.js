contract("verifier", accounts => {
  it("should display 5", async () => {
    const verifier = await verifier.deployed();
    await verifier.add(3, 2, { from: accounts[0] });
    const storedVerify = await verifier.verify.call();
  assert.equal(storedVerify, 5);
  });
});
