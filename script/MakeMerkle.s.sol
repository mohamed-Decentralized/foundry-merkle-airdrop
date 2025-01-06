// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string;

    Merkle private m = new Merkle(); 

    string private inputPath = "/script/target/input.json";
    string private outputPath = "/script/target/output.json";

    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath)); 
    string[] private types = elements.readStringArray(".types"); 
    uint256 private count = elements.readUint(".count"); 

    bytes32[] private leafs = new bytes32[](count);  

    string[] private inputs = new string[](count);
    string[] private outputs = new string[](count);

    string private output;

    /// @dev returns the JSON path of the input file
    function getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    } 

    /// @dev generate the JSON entries for the output file
    function generateJsonEntries(string memory _inputs, string memory _proof, string memory _root, string memory _leaf)
        internal
        pure
        returns (string memory)
    {
        string memory result = string.concat(
            "{",
            "\"inputs\":",
            _inputs,
            ",",
            "\"proof\":",
            _proof,
            ",",
            "\"root\":\"",
            _root,
            "\",",
            "\"leaf\":\"",
            _leaf,
            "\"",
            "}"
        );

        return result;
    }

    /// @dev read the input file and generate the Merkle proof, then write the output file
    function run() public {
        console.log("generating merkle proof ", inputPath);

        for (uint256 i = 0; i < count; ++i) {
            string[] memory input = new string[](types.length); 
            bytes32[] memory data = new bytes32[](types.length);

            for (uint256 j = 0; j < types.length; ++j) {
                if (compareStrings(types[j], "address")) {
                    address value = elements.readAddress(getValuesByIndex(i, j));
                    data[j] = bytes32(uint256(uint160(value))); 
                    input[j] = vm.toString(value);
                } else if (compareStrings(types[j], "uint")) {
                    uint256 value = vm.parseUint(elements.readString(getValuesByIndex(i, j)));
                    data[j] = bytes32(value);
                    input[j] = vm.toString(value);
                }
            }

            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));

            inputs[i] = stringArrayToString(input);
        }

        for (uint256 i = 0; i < count; ++i) {
            
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            
            string memory root = vm.toString(m.getRoot(leafs));
            
            string memory leaf = vm.toString(leafs[i]);
            
            string memory input = inputs[i];

            outputs[i] = generateJsonEntries(input, proof, root, leaf);
        }

        output = stringArrayToArrayString(outputs);
         
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console.log("OUTPUT_PATH:", outputPath);
    }
}
