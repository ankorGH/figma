pragma solidity ^0.4.24;

contract VirtualConference {
    
    struct Conference {
        uint conferenceId;
        address organizer;
        string  name;
        uint cost;
        string description;
        string date;
        uint sellingtickets;
        uint initialTickets;
    }
    
    struct Guest {
        uint conferenceId;
        address guest;
        bool satisfaction;
        uint ticketsBought;
    }
    
    event LogRegisterConference(string conferenceName);
    event LogAttendConference(string conferenceName,address user);
    
    uint ConferenceCount = 0;
    uint GuestCount = 0;
    
    mapping(uint => Conference) public conferences;
    mapping(uint => Guest) public guests;
    
    function registerConference(string _name,uint _price,string _description,string _date,uint _tickets) public {
        require(_tickets != 0);
        
        ConferenceCount += 1;
        conferences[ConferenceCount] = Conference(ConferenceCount,msg.sender,_name,_price,_description,_date,_tickets,_tickets);
        emit LogRegisterConference(_name);
    }
    
    function attendConference(uint _conferenceId,uint _ticketsBuying) payable public {
        require(msg.sender != 0x0);
        require(conferences[_conferenceId].sellingtickets >= _ticketsBuying);
        require(msg.value >= (_ticketsBuying * conferences[_conferenceId].sellingtickets));
        require(conferences[_conferenceId].sellingtickets != 0);
        
        conferences[_conferenceId].sellingtickets -= _ticketsBuying;
        guests[_conferenceId] =  Guest(_conferenceId,msg.sender,true,_ticketsBuying);
        emit LogAttendConference(conferences[_conferenceId].name,msg.sender);
    }
    
    function conferenceVote(uint _conferenceId,bool _satisfaction) public {
        require(_conferenceId <= ConferenceCount);
        require(guests[_conferenceId].guest == msg.sender);
        
        guests[_conferenceId].satisfaction = _satisfaction;
        
    }
    
    function releasefunds(uint _conferenceId) payable public {
        uint unsatisfied = 0;
        uint satisfied = 0;
        
        for(uint i = 1;i <= GuestCount;i++){
            if(guests[i].conferenceId == _conferenceId){
                if(guests[i].satisfaction){
                    satisfied += 1;    
                }else {
                    unsatisfied += 1;
                }
            }  
        }
        
        if(satisfied >= unsatisfied){
            conferences[_conferenceId].organizer.transfer(conferences[_conferenceId].cost * (conferences[_conferenceId].initialTickets - conferences[_conferenceId].sellingtickets));
        }
    }
}