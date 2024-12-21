// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HobbyLearningNetworks {

    struct User {
        string username;
        string[] hobbies;
        bool registered;
    }

    struct Hobby {
        string name;
        address[] members;
        uint256 totalContributions;
    }

    mapping(address => User) public users;
    mapping(string => Hobby) public hobbies;
    
    event UserRegistered(address userAddress, string username);
    event HobbyJoined(address userAddress, string hobby);
    event ContributionMade(address userAddress, string hobby, uint256 amount);

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    // Register a new user
    function registerUser(string memory _username, string[] memory _hobbies) public {
        require(!users[msg.sender].registered, "User already registered");

        users[msg.sender] = User({
            username: _username,
            hobbies: _hobbies,
            registered: true
        });

        for (uint256 i = 0; i < _hobbies.length; i++) {
            string memory hobby = _hobbies[i];
            hobbies[hobby].name = hobby;
            hobbies[hobby].members.push(msg.sender);
        }

        emit UserRegistered(msg.sender, _username);
    }

    // Join a specific hobby
    function joinHobby(string memory _hobby) public onlyRegistered {
        Hobby storage hobby = hobbies[_hobby];
        
        for (uint256 i = 0; i < hobby.members.length; i++) {
            if (hobby.members[i] == msg.sender) {
                revert("User already joined this hobby");
            }
        } 

        hobby.members.push(msg.sender);
        users[msg.sender].hobbies.push(_hobby);
        emit HobbyJoined(msg.sender, _hobby);
    }

    // Contribute to a hobby network
    function contributeToHobby(string memory _hobby) public payable onlyRegistered {
        require(msg.value > 0, "Contribution must be greater than 0");

        hobbies[_hobby].totalContributions += msg.value;
        emit ContributionMade(msg.sender, _hobby, msg.value);
    }

    // Get total contributions of a hobby
    function getHobbyTotalContributions(string memory _hobby) public view returns (uint256) {
        return hobbies[_hobby].totalContributions;
    }

    // Get members of a hobby
    function getHobbyMembers(string memory _hobby) public view returns (address[] memory) {
        return hobbies[_hobby].members;
    }
}
