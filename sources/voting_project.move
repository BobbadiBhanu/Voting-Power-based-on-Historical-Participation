module MyModule::VotingPower {
    use aptos_framework::signer;
    use std::vector;

   
    struct VoterProfile has store, key {
        total_votes_cast: u64,     
        participation_score: u64,  
        last_vote_round: u64,      
        voting_power: u64,         
    }

    
    struct VotingSystem has store, key {
        current_round: u64,        
        base_voting_power: u64,    
        participation_multiplier: u64, 
    }

   
    const E_VOTER_NOT_REGISTERED: u64 = 1;
    const E_VOTING_SYSTEM_NOT_INITIALIZED: u64 = 2;

    
    public entry fun initialize_voting_system(admin: &signer) {
        let voting_system = VotingSystem {
            current_round: 1,
            base_voting_power: 100,
            participation_multiplier: 10,
        };
        move_to(admin, voting_system);
    }

    
    public entry fun cast_vote(voter: &signer, system_owner: address) acquires VoterProfile, VotingSystem {
        let voter_addr = signer::address_of(voter);
        let voting_system = borrow_global_mut<VotingSystem>(system_owner);
        let current_round = voting_system.current_round;
        let base_power = voting_system.base_voting_power;
        let multiplier = voting_system.participation_multiplier;
        
        if (!exists<VoterProfile>(voter_addr)) {
           
            let new_profile = VoterProfile {
                total_votes_cast: 1,
                participation_score: 1,
                last_vote_round: current_round,
                voting_power: base_power,
            };
            move_to(voter, new_profile);
        } else {
           
            let profile = borrow_global_mut<VoterProfile>(voter_addr);
            profile.total_votes_cast = profile.total_votes_cast + 1;
            profile.last_vote_round = current_round;
            profile.participation_score = profile.total_votes_cast;
            profile.voting_power = base_power + (profile.participation_score * multiplier);
        };
        
       
        voting_system.current_round = current_round + 1;
    }

}
