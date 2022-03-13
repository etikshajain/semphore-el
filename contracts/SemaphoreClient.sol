//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Semaphore } from './Semaphore.sol';

contract SemaphoreClient {
    // A mapping of all signals broadcasted
    mapping (uint256 => bytes) public signalIndexToSignal;

    // A mapping between signal indices to external nullifiers
    mapping (uint256 => uint256) public signalIndexToExternalNullifier;

    mapping(uint256 => uint256) public nullifierSecretMap;

    // The next index of the `signalIndexToSignal` mapping
    uint256 public nextSignalIndex = 0;

    Semaphore public semaphore;
    
    // added new
    uint256[] public identityCommitments;

    event SignalBroadcastByClient(uint256 indexed signalIndex);

    constructor(Semaphore _semaphore) {
        semaphore = _semaphore;
    }

   function insertIdentityAsClient(uint256 _leaf) public {
        semaphore.insertIdentity(_leaf);
        identityCommitments.push(_leaf);
    }

    function insertIdentityPasswordAsClient(uint256 _leaf,uint256 _nullfierHash,uint256 _secret) public {
        nullifierSecretMap[_nullfierHash]=_secret;
        semaphore.insertIdentityWSecret(_leaf,_nullfierHash,_secret);
        identityCommitments.push(_leaf);
    }

    function broadcastSignal(
        bytes memory _signal,
        uint256 _root,
        uint256 _nullifiersHash,
        uint232 _externalNullifier,
          uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[4] memory input
    ) public {
        uint256 signalIndex = nextSignalIndex;

        // store the signal
        signalIndexToSignal[nextSignalIndex] = _signal;

        // map the the signal index to the given external nullifier
        signalIndexToExternalNullifier[nextSignalIndex] = _externalNullifier;

        // increment the signal index
        nextSignalIndex ++;

        // broadcast the signal
        semaphore.broadcastSignal(_signal,_root,_nullifiersHash,_externalNullifier,a,b,c,input);

        emit SignalBroadcastByClient(signalIndex);
    }

    /*
     * Returns the external nullifier which a signal at _index broadcasted to
     * @param _index The index to use to look up the signalIndexToExternalNullifier mapping
     */
    function getExternalNullifierBySignalIndex(uint256 _index) public view returns (uint256) {
        return signalIndexToExternalNullifier[_index];
    }

    function getSignalBySignalIndex(uint256 _index) public view returns (bytes memory) {
        return signalIndexToSignal[_index];
    }


     function getNextSignalIndex() public view returns (uint256) {
        return nextSignalIndex;
    }

    function getIdentityCommitments() public view returns (uint256 [] memory) {
        return identityCommitments;
    }

    function getIdentityCommitment(uint256 _index) public view returns (uint256) {
        return identityCommitments[_index];
    }

    function getSignalByIndex(uint256 _index) public view returns (bytes memory) {
        return signalIndexToSignal[_index];
    }


}
