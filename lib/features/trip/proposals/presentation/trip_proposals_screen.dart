import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import 'trip_proposals_provider.dart';

class TripProposalsScreen extends StatelessWidget {
  final int tripId;
  const TripProposalsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => TripProposalsProvider(c.read<ApiService>())..loadProposals(tripId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Propuestas')),
        body: Consumer<TripProposalsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                  child: Text(provider.error!,
                      style: const TextStyle(color: Colors.red)));
            }
            if (provider.proposals.isEmpty) {
              return const Center(
                  child: Text('Aún no hay propuestas para este viaje'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.proposals.length,
              itemBuilder: (context, i) => _ProposalCard(
                proposal: provider.proposals[i],
                onAccept: () =>
                    provider.acceptProposal(provider.proposals[i].id, tripId),
                isAccepting: provider.accepting,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback onAccept;
  final bool isAccepting;
  const _ProposalCard(
      {required this.proposal,
      required this.onAccept,
      required this.isAccepting});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${proposal.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                if (proposal.status == 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text('Aceptada',
                        style: TextStyle(color: Colors.green, fontSize: 12)),
                  ),
              ],
            ),
            if (proposal.car != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(proposal.car!.displayName,
                    style: const TextStyle(color: Colors.grey)),
              ]),
            ],
            if (proposal.driver != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${proposal.driver!.name} ${proposal.driver!.lastname}',
                    style: const TextStyle(color: Colors.grey)),
              ]),
            ],
            if (proposal.comment != null && proposal.comment!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.comment, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(proposal.comment!,
                        style: const TextStyle(color: Colors.grey))),
              ]),
            ],
            if (proposal.status != 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAccepting ? null : onAccept,
                  child: isAccepting
                      ? const CircularProgressIndicator()
                      : const Text('Aceptar propuesta'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
