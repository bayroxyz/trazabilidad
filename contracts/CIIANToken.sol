//************************************************* */
// Autor Alan Enrique Escudero Caporal
// Fecha 19/Febrero/2020
// Version: 1.1.0
//************************************************* */
pragma solidity ^0.5.0;

import '@openzeppelin/contracts/token/ERC721/ERC721Full.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/drafts/Counters.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721Full.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/IERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/drafts/Counters.sol";

contract CIIANToken is ERC721Full {
    //State Variables
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    IERC20 private _token;
    mapping (uint256 => Producto) TokenList;

    //Structs used
    struct Producto {
        uint64 creacionHora;
        uint8 PLUCode;
        uint16 numAcciones;
        address creacionAddress;
        mapping (uint16 => Accion) Historia; // Y si mejor usamos un aproach similar al del DNA en los Gatos o Zombies?
    }
    
    //Esto deberia estar publico?
    struct Accion {
        uint32 idAccion;
        uint64 horaAccion;
        string ubicacionAccion;
        address usuarioAccion;
    }

    //Events
    event VerduraCreada(uint64 _creacionHora, uint8 _tipoProducto);
    event AccionTaken(uint8 _tipoProducto, uint32 _idAccion, uint64 _horaAccion, address _usuarioAccion);

    constructor() ERC721Full("CIIAN Token", "CIIANT") public {
    }
//Quien crea el token sera el mismo que lo posea?
    function createProduct(address _user, uint8 _tipoProducto, string memory _ubicacionAccion, 
    string memory _tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        //
        TokenList[newItemId].creacionHora = uint64(now);
        TokenList[newItemId].tipoProducto = _tipoProducto;
        TokenList[newItemId].numAcciones = 1;
        TokenList[newItemId].creacionAddress = msg.sender;
        TokenList[newItemId].Historia[1].idAccion = "Creacion Del Token";
        TokenList[newItemId].Historia[1].horaAccion = uint64(now);
        TokenList[newItemId].Historia[1].ubicacionAccion = _ubicacionAccion;
        TokenList[newItemId].Historia[1].usuarioAccion = msg.sender;
        //
        _mint(_user, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        //emit VerduraCreada(uint64(now), _tipoProducto); //Que cosas deberian ir en el emit
        return newItemId;
    }

    function getNumeroAcciones(uint256 _itemID) public view returns (uint16) {
        return (TokenList[_itemID].numAcciones);
    }
    
    function comprarToken(uint8 _tipoProducto, string calldata _ubicacionAccion, string calldata _tokenURI) external{
        address from = msg.sender;
        _token.transferFrom(from, address(this), 1000);
        createProduct(msg.sender, _tipoProducto, _ubicacionAccion, _tokenURI);
    }
    
    function getEstatusProducto(uint256 _itemID) public view returns (uint32 _idAccion, uint64 _horaAccion, 
    string memory _ubicacionAccion, address _usuarioAccion) {
        uint16 accionActual = TokenList[_itemID].numAcciones;
        return (TokenList[_itemID].Historia[accionActual].idAccion, TokenList[_itemID].Historia[accionActual].horaAccion, 
        TokenList[_itemID].Historia[accionActual].ubicacionAccion, TokenList[_itemID].Historia[accionActual].usuarioAccion);
    }

}