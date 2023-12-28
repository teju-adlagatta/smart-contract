// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CompanyFunds is ERC20 {
    
    struct Department {
        address[] admins;
        mapping(address => bool) isAdmin;
        uint256 balance;
        mapping(uint256 => bool) requests;
    }

    address public companyAccount; 
    mapping(address => bool) public companyAdmins;
    mapping(address => Department) public departments;

    ERC20 public tokenContract;

    modifier onlyCompanyAdmin() {
        require(companyAdmins[msg.sender], "Only company admin is allowed");
        _;
    }

    modifier onlyDepartmentAdmin(address department) {
        require(departments[department].isAdmin[msg.sender], "Only department admin is allowed");
        _;
    }

    constructor(address _tokenContract) ERC20("Inventory", "INV") {
        companyAccount = msg.sender;
        companyAdmins[msg.sender] = true;
        tokenContract = ERC20(_tokenContract);
    }

    function setCompanyAdmin(address _admin) external {
        require(msg.sender == companyAccount, "Only company account can set admins");
        companyAdmins[_admin] = true;
    }

    function setDepartmentAdmin(address _department, address _admin) external onlyCompanyAdmin {
        departments[_department].isAdmin[_admin] = true;
        departments[_department].admins.push(_admin);
    }

      
    

    function convertEthToTokens() public payable onlyCompanyAdmin {
    uint256 ethAmount = msg.value; // Amount sent in the transaction
    require(ethAmount > 0, "No Ether sent");

    // Determine the conversion rate (for example, 1 ETH = 10000 tokens)
    uint256 tokens = ethAmount * 10000; // Change this based on our conversion rate

    // Transfer ERC20 tokens to the contract
    // tokenContract.transferFrom(companyAccount, address(this), tokens);
     _mint(msg.sender , tokens );

    // Update company balance
    //departments[companyAccount].balance += tokens;
    }
    



     function transferToDepartment(address _department, uint256 _amount) external onlyCompanyAdmin {
        require(departments[companyAccount].balance >= _amount, "Insufficient balance");
       transfer( _department,  _amount);
       
    }

    function transfer(address from, address to,uint256 value) external {
        _transfer(from, to, value);
    }

    

    function requestFunds( uint256 _amount) external {
        require(departments[msg.sender].balance >= _amount, "Insufficient balance");
        departments[msg.sender].requests[_amount] = true;
    }

    function approveRequest(address _department, uint256 _amount ) external onlyDepartmentAdmin(_department) {
        require(departments[_department].requests[_amount], "No such request");
        _approve(msg.sender, _department, _amount);
    }

    // View functions to check balances

    function getCompanyBalance() external view returns (uint256) {
        return departments[companyAccount].balance;
    }

    function getDepartmentBalance(address _department) external view returns (uint256) {
        return departments[_department].balance;
    }

   
}

   
   
  
