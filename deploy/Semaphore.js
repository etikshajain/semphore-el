const { genExternalNullifier } = require("../utils");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const depth = 20;

  const poseidonT3 = await deployments.get("PoseidonT3");
  const poseidonT6 = await deployments.get("PoseidonT6");
  const verifier = await deploy("Verifier", {
    from: deployer,
    log: true,
    args: [],
    libraries: {},
  });

  //const verifier = await deployments.get("Verifier");
  const externalNullifier = genExternalNullifier("test-voting");
  const semaphore = await deploy("Semaphore", {
    from: deployer,
    log: true,
    args: [depth, externalNullifier, verifier.address],
    libraries: {
      PoseidonT3: poseidonT3.address,
      PoseidonT6: poseidonT6.address,
    },
  });

  await deploy("SemaphoreClient", {
    from: deployer,
    log: true,
    args: [semaphore.address],
  });
};
module.exports.tags = ["complete"];
module.exports.dependencies = ["PoseidonT3", "PoseidonT6"];
