# 🚀 Blockchain-based Rapid Fundraising Platform

Welcome to a decentralized platform for rapid fundraising and automated fund distribution! This project addresses real-world issues in traditional crowdfunding, such as lack of transparency, centralized control over funds, and inefficient decision-making on how to allocate raised money. By leveraging the Stacks blockchain and Clarity smart contracts, it enables communities, charities, or projects to raise funds quickly and distribute them based on crowd-voted priorities. This ensures democratic governance, reduces fraud, and automates payouts to verified recipients—perfect for disaster relief, open-source development, or community initiatives where speed and fairness matter.

## ✨ Features

💰 Create and manage fundraising campaigns with customizable goals and deadlines  
🤝 Allow secure donations in STX or SIP-10 tokens  
🗳️ Propose fund allocation priorities (e.g., "allocate 40% to marketing")  
📊 Crowd-voting on proposals using governance tokens  
🔄 Automatic fund distribution to approved recipients based on vote outcomes  
🔒 Escrow mechanism to hold funds until votes are finalized  
📈 Real-time tracking of campaign progress and voting results  
🚫 Dispute resolution for invalid proposals or votes  
✅ Token-based governance to prevent sybil attacks  
🛡️ Immutable audit trail for all transactions and decisions

## 🛠 How It Works

**For Campaign Creators**  
- Deploy a new campaign by calling the campaign-factory contract to create a dedicated campaign instance.  
- Set parameters like funding goal, deadline, and initial governance token distribution.  
- Promote your campaign off-chain to attract donors.  

Once funds are raised:  
- Use the proposal contract to submit fund usage ideas.  
- Community votes via the voting contract.  
- Funds auto-distribute through the distribution contract after voting closes.  

**For Donors**  
- Contribute to a campaign using the donation contract—funds go into escrow.  
- Receive governance tokens proportional to your donation for voting rights.  
- Track your contributions and vote on proposals.  

**For Voters and Verifiers**  
- Stake governance tokens to participate in votes.  
- Use the query contract to view campaign details, proposals, and results.  
- If a dispute arises, invoke the governance contract for resolution.  

That's it! Funds are raised rapidly, decisions are made democratically, and distributions happen automatically on-chain, ensuring trust and efficiency.

## 📚 Smart Contracts Overview

This platform is built with 8 modular Clarity smart contracts for scalability and security. Each handles a specific aspect to keep the system composable and auditable:

1. **Campaign Factory Contract**: Creates new fundraising campaigns as child contracts, managing templates and initialization.  
2. **Campaign Instance Contract**: Core per-campaign logic for setting goals, tracking progress, and handling basic state (e.g., active/closed status).  
3. **Donation Contract**: Processes incoming donations, issues receipts, and mints governance tokens to donors.  
4. **Governance Token Contract**: Implements a SIP-10 compatible token for voting rights, including minting, burning, and transfer logic.  
5. **Proposal Contract**: Allows users to submit and manage proposals for fund allocation, with validation for duplicates or invalid formats.  
6. **Voting Contract**: Handles vote casting, tallying, and quorum checks using staked governance tokens.  
7. **Distribution Contract**: Executes automated payouts to recipients based on winning proposals, integrating with escrow for fund release.  
8. **Escrow Contract**: Securely holds raised funds in a multi-sig-like structure until voting finalizes, preventing premature withdrawals.  

These contracts interact via public functions and traits for loose coupling. For example, the Voting Contract calls the Proposal Contract to fetch active proposals and updates the Distribution Contract with results.

## 🏗️ Getting Started

1. Install the Clarinet SDK for Stacks development.  
2. Clone this repo and navigate to the contracts directory.  
3. Deploy contracts to a Stacks testnet using `clarinet deploy`.  
4. Interact via the Clarity console or integrate with a frontend dApp.  
