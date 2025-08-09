module MyModule::VotingPower {
    use aptos_framework::signer;
    use std::vector;

    /// Struct representing a voter's profile with historical participation
    struct VoterProfile has store, key {
        total_votes_cast: u64,     // Total number of votes cast historically
        participation_score: u64,  // Calculated participation score
        last_vote_round: u64,      // Last voting round participated in
        voting_power: u64,         // Current voting power based on participation
    }

    /// Struct representing the voting system state
    struct VotingSystem has store, key {
        current_round: u64,        // Current voting round
        base_voting_power: u64,    // Base voting power for new voters
        participation_multiplier: u64, // Multiplier for calculating power
    }

    /// Error codes
    const E_VOTER_NOT_REGISTERED: u64 = 1;
    const E_VOTING_SYSTEM_NOT_INITIALIZED: u64 = 2;

    /// Function to initialize the voting system
    public entry fun initialize_voting_system(admin: &signer) {
        let voting_system = VotingSystem {
            current_round: 1,
            base_voting_power: 100,
            participation_multiplier: 10,
        };
        move_to(admin, voting_system);
    }

    /// Function to register a voter or cast a vote (updates participation)
    public entry fun cast_vote(voter: &signer, system_owner: address) acquires VoterProfile, VotingSystem {
        let voter_addr = signer::address_of(voter);
        let voting_system = borrow_global_mut<VotingSystem>(system_owner);
        let current_round = voting_system.current_round;
        let base_power = voting_system.base_voting_power;
        let multiplier = voting_system.participation_multiplier;
        
        if (!exists<VoterProfile>(voter_addr)) {
            // Register new voter
            let new_profile = VoterProfile {
                total_votes_cast: 1,
                participation_score: 1,
                last_vote_round: current_round,
                voting_power: base_power,
            };
            move_to(voter, new_profile);
        } else {
            // Update existing voter's participation
            let profile = borrow_global_mut<VoterProfile>(voter_addr);
            profile.total_votes_cast = profile.total_votes_cast + 1;
            profile.last_vote_round = current_round;
            profile.participation_score = profile.total_votes_cast;
            profile.voting_power = base_power + (profile.participation_score * multiplier);
        };
        
        // Advance to next round
        voting_system.current_round = current_round + 1;
    }
}