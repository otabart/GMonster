// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

// import { console2 } from "forge-std/console2.sol";

struct TokenURIParams {
    string name;
    string description;
    string image;
}

abstract contract GMonsterNFT is ERC721 {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/
    string constant NAME = "GMonsterNFT";
    string constant DESCRIPTION = "This NFT is minted for GMonster.";
    uint8 constant KIND_COUNT = 21;
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    uint public currentTokenId;
    uint public seasonStartTimestamp;
    //Token ID => kind
    mapping(uint => uint8) public nftKinds;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(uint _seasonStartTimestamp) ERC721(NAME, NAME) {
        seasonStartTimestamp = _seasonStartTimestamp;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL UPDATE
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                             EXTERNAL VIEW
    //////////////////////////////////////////////////////////////*/

    // prettier-ignore
    function generateImage(string memory _message, string[3] memory _colors)
    public
    pure
    returns (string memory)
{
    return
        Base64.encode(bytes(
            string(
                abi.encodePacked(
'<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 320 320" style="background-color:white"><defs><style type="text/css">@import url("https://fonts.googleapis.com/css2?family=Roboto:wght@400;700");', _generateFill(_colors) ,'</style><linearGradient id="grad1" x1="0%" y1="20%" x2="0%" y2="100%"><stop offset="0%" style="stop-color:#6AE;stop-opacity:1" /><stop offset="100%" style="stop-color:#F2A43E;stop-opacity:1" /></linearGradient></defs><rect x="0" y="0" width="100%" height="100%" fill="url(#grad1)" /><rect x="20" y="32" width="280" height="40" rx="8" ry="8" fill="#222"/>',
'<text x="160" y="59" font-size="18" fill="#fff" text-anchor="middle" style="font-family: \'Roboto\';font-weight: 700;">', _message,'</text>',
'<rect x="110" y="100" width="10" height="10" fill="#000"/><rect x="120" y="100" width="10" height="10" fill="#000"/><rect x="220" y="100" width="10" height="10" fill="#000"/><rect x="100" y="110" width="10" height="10" fill="#000"/><rect x="120" y="110" width="10" height="10" fill="#000"/><rect x="200" y="110" width="20" height="10" fill="#000"/><rect x="230" y="110" width="10" height="10" fill="#000"/><rect x="100" y="120" width="10" height="10" fill="#000"/><rect x="120" y="120" width="10" height="10" fill="#000"/><rect x="190" y="120" width="20" height="10" fill="#000"/><rect x="240" y="120" width="10" height="10" fill="#000"/>',
'<rect x="90" y="130" width="10" height="10" fill="#000"/><rect x="120" y="130" width="10" height="10" fill="#000"/><rect x="170" y="130" width="30" height="10" fill="#000"/><rect x="240" y="130" width="10" height="10" fill="#000"/><rect x="80" y="140" width="10" height="10" fill="#000"/><rect x="90" y="140" width="10" height="10" fill="#000"/><rect x="120" y="140" width="10" height="10" fill="#000"/><rect x="150" y="140" width="20" height="10" fill="#000"/><rect x="230" y="140" width="10" height="10" fill="#000"/><rect x="190" y="140" width="10" height="10" fill="#000"/><rect x="70" y="150" width="10" height="10" fill="#000"/><rect x="80" y="150" width="10" height="10" fill="#000"/><rect x="130" y="150" width="20" height="10" fill="#000"/><rect x="220" y="150" width="10" height="10" fill="#000"/><rect x="180" y="150" width="10" height="10" fill="#000"/><rect x="70" y="160" width="10" height="10" fill="#000"/><rect x="210" y="160" width="10" height="10" fill="#000"/><rect x="170" y="160" width="20" height="10" fill="#000"/><rect x="60" y="170" width="10" height="10" fill="#000"/><rect x="70" y="170" width="10" height="10" fill="#fff"/><rect x="220" y="170" width="10" height="10" fill="#000"/><rect x="190" y="170" width="10" height="10" fill="#000"/><rect x="170" y="170" width="10" height="10" fill="#000"/>',
'<rect x="60" y="180" width="10" height="10" fill="#000"/><rect x="70" y="180" width="10" height="10" fill="#000"/><rect x="220" y="180" width="10" height="10" fill="#000"/><rect x="190" y="180" width="20" height="10" fill="#000"/><rect x="170" y="180" width="10" height="10" fill="#000"/><rect x="60" y="190" width="10" height="10" fill="#000"/><rect x="110" y="190" width="10" height="10" fill="#fff"/><rect x="120" y="190" width="10" height="10" fill="#000"/><rect x="210" y="190" width="10" height="10" fill="#000"/><rect x="180" y="190" width="20" height="10" fill="#000"/><rect x="70" y="200" width="10" height="10" fill="#000"/><rect x="110" y="200" width="20" height="10" fill="#000"/><rect x="180" y="200" width="30" height="10" fill="#000"/><rect x="80" y="210" width="10" height="10" fill="#000"/><rect x="190" y="210" width="10" height="10" fill="#000"/><rect x="70" y="220" width="10" height="10" fill="#000"/><rect x="190" y="220" width="10" height="10" fill="#000"/><rect x="80" y="230" width="10" height="10" fill="#000"/><rect x="90" y="230" width="10" height="10" fill="#000"/><rect x="190" y="230" width="10" height="10" fill="#000"/><rect x="150" y="230" width="10" height="10" fill="#000"/><rect x="90" y="240" width="10" height="10" fill="#000"/><rect x="190" y="240" width="10" height="10" fill="#000"/><rect x="140" y="240" width="10" height="10" fill="#000"/>',
'<rect x="80" y="250" width="10" height="10" fill="#000"/><rect x="100" y="250" width="10" height="10" fill="#000"/><rect x="190" y="250" width="10" height="10" fill="#000"/><rect x="150" y="250" width="10" height="10" fill="#000"/><rect x="80" y="260" width="50" height="10" fill="#000"/><rect x="180" y="260" width="10" height="10" fill="#000"/><rect x="130" y="270" width="30" height="10" fill="#000"/><rect x="170" y="270" width="20" height="10" fill="#000"/><rect x="140" y="280" width="10" height="10" fill="#000"/><rect x="180" y="280" width="10" height="10" fill="#000"/><rect x="150" y="290" width="30" height="10" fill="#000"/><rect x="110" y="110" width="10" height="10" class="ear-fill" /><rect x="170" y="140" width="20" height="10" class="ear-fill" /><rect x="170" y="150" width="10" height="10" class="ear-fill" /><rect x="210" y="170" width="10" height="10" class="ear-fill" /><rect x="210" y="180" width="10" height="10" class="ear-fill" /><rect x="200" y="190" width="10" height="10" class="ear-fill" /><rect x="170" y="210" width="20" height="10" class="ear-fill" /><rect x="180" y="230" width="10" height="10" class="ear-fill" />',
'<rect x="130" y="200" width="20" height="10" class="beard-fill" /><rect x="130" y="210" width="10" height="10" class="beard-fill" /><rect x="220" y="110" width="10" height="10" class="body-fill" /><rect x="110" y="120" width="10" height="10" class="body-fill" /><rect x="210" y="120" width="30" height="10" class="body-fill" /><rect x="100" y="130" width="20" height="10" class="body-fill" /><rect x="200" y="130" width="40" height="10" class="body-fill" /><rect x="100" y="140" width="20" height="10" class="body-fill" /><rect x="200" y="140" width="30" height="10" class="body-fill" /><rect x="90" y="150" width="40" height="10" class="body-fill" /><rect x="150" y="150" width="20" height="10" class="body-fill" /><rect x="190" y="150" width="30" height="10" class="body-fill" /><rect x="80" y="160" width="90" height="10" class="body-fill" /><rect x="190" y="160" width="20" height="10" class="body-fill" />',
'<rect x="80" y="170" width="90" height="10" class="body-fill" /><rect x="180" y="170" width="10" height="10" class="body-fill" /><rect x="200" y="170" width="10" height="10" class="body-fill" /><rect x="80" y="180" width="90" height="10" class="body-fill" /><rect x="180" y="180" width="10" height="10" class="body-fill" /><rect x="70" y="190" width="40" height="10" class="body-fill" /><rect x="130" y="190" width="50" height="10" class="body-fill" /><rect x="80" y="200" width="30" height="10" class="body-fill" /><rect x="150" y="200" width="30" height="10" class="body-fill" /><rect x="90" y="210" width="40" height="10" class="body-fill" /><rect x="140" y="210" width="30" height="10" class="body-fill" /><rect x="80" y="220" width="110" height="10" class="body-fill" /><rect x="100" y="230" width="50" height="10" class="body-fill" /><rect x="160" y="230" width="20" height="10" class="body-fill" /><rect x="100" y="240" width="40" height="10" class="body-fill" /><rect x="150" y="240" width="40" height="10" class="body-fill" /><rect x="90" y="250" width="10" height="10" class="body-fill" /><rect x="110" y="250" width="40" height="10" class="body-fill" /><rect x="160" y="250" width="30" height="10" class="body-fill" /><rect x="130" y="260" width="50" height="10" class="body-fill" /><rect x="160" y="270" width="10" height="10" class="body-fill" /><rect x="150" y="280" width="30" height="10" class="body-fill" /></svg>'
                )
            )
        ));
    }

    function _generateFill(
        string[3] memory _colors
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ".body-fill {fill: #",
                    _colors[0],
                    ";}.ear-fill {fill: #",
                    _colors[1],
                    ";}.beard-fill {fill: #",
                    _colors[2],
                    ";}"
                )
            );
    }

    function _getMessageAndColors(
        uint8 kind
    ) internal pure returns (string memory, string[3] memory) {
        if (kind == 0) {
            return ("HOGE", ["FAFAFA", "A736FF", "DCDCDC"]);
        } else if (kind == 1) {
            return ("FUGA", ["00AEEF", "FFD700", "FF0000"]);
        } else if (kind == 2) {
            return ("PIYO", ["FFD1A4", "A736FF", "DCDCDC"]);
        } else if (kind == 3) {
            return ("Message3", ["A9A9A9", "2E8B57", "8B4513"]);
        } else if (kind == 4) {
            return ("Message4", ["FF0000", "0000FF", "DCDCDC"]);
        } else if (kind == 5) {
            return ("Message5", ["0000FF", "FFFF00", "DCDCDC"]);
        } else if (kind == 6) {
            return ("Message6", ["FFA500", "010101", "FFA500"]);
        } else if (kind == 7) {
            return ("Message7", ["0A5C62", "FF0000", "DCDCDC"]);
        } else if (kind == 8) {
            return ("Message8", ["8B4513", "FFFFFF", "FFC0CB"]);
        } else if (kind == 9) {
            return ("Message9", ["20DA1D", "D1FF1B", "DCDCDC"]);
        } else if (kind == 10) {
            return ("Message10", ["FFA6A6", "8F00FF", "DCDCDC"]);
        } else if (kind == 11) {
            return ("Message11", ["625FFF", "A736FF", "DCDCDC"]);
        } else if (kind == 12) {
            return ("Message12", ["A5A5A5", "A736FF", "DCDCDC"]);
        } else if (kind == 13) {
            return ("Message13", ["FFC940", "ECD4FF", "DCDCDC"]);
        } else if (kind == 14) {
            return ("Message14", ["EF0DE6", "52FF36", "DCDCDC"]);
        } else if (kind == 15) {
            return ("Message15", ["BDFF00", "A736FF", "DCDCDC"]);
        } else if (kind == 16) {
            return ("Message16", ["008124", "8F00FF", "DCDCDC"]);
        } else if (kind == 17) {
            return ("Message17", ["000000", "52FF36", "DCDCDC"]);
        } else if (kind == 18) {
            return ("Message18", ["747474", "FF3636", "DCDCDC"]);
        } else if (kind == 19) {
            return ("Message19", ["FF2674", "FDC3BF", "DCDCDC"]);
        } else if (kind == 20) {
            return ("Message20", ["E5E540", "434343", "B8280B"]);
        }
        return ("", ["", "", ""]);
    }

    function tokenURI(
        uint256 _id
    ) public view override returns (string memory) {
        (
            string memory _message,
            string[3] memory _colors
        ) = _getMessageAndColors(nftKinds[_id]);
        TokenURIParams memory params = TokenURIParams({
            name: string(abi.encodePacked(NAME, " #", Strings.toString(_id))),
            description: DESCRIPTION,
            image: generateImage(_message, _colors)
        });
        return constructTokenURI(params);
    }

    /*//////////////////////////////////////////////////////////////
                             INTERNAL VIEW
    //////////////////////////////////////////////////////////////*/
    function constructTokenURI(
        TokenURIParams memory params
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                params.name,
                                '", "description":"',
                                params.description,
                                '", "image": "data:image/svg+xml;base64,',
                                params.image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL UPDATE
    //////////////////////////////////////////////////////////////*/
    function _mint(address _to) internal virtual {
        currentTokenId++;
        uint8 _kind;
        for (uint8 i = 0; i < KIND_COUNT; i++) {
            if (block.timestamp < seasonStartTimestamp + ((i + 1) * 1 days)) {
                _kind = i;
                break;
            }
        }
        nftKinds[currentTokenId] = _kind;
        _mint(_to, currentTokenId);
    }
}
