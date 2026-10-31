import 'package:flutter/material.dart';

import '../services/household_service.dart';

class HouseholdMembersPage extends StatefulWidget {
  final String householdId;

  const HouseholdMembersPage({super.key, required this.householdId});

  @override
  State<HouseholdMembersPage> createState() => _HouseholdMembersPageState();
}

class _HouseholdMembersPageState extends State<HouseholdMembersPage> {
  List<dynamic> members = [];

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    final result = await HouseholdService.getMembers(widget.householdId);

    if (!mounted) {
      return;
    }

    setState(() {
      members = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メンバー一覧')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];

          final profile = member['profiles'];

          return ListTile(
            leading: Icon(
              member['role'] == 'ADMIN'
                  ? Icons.admin_panel_settings
                  : Icons.person,
            ),
            title: Text(member['user_id'].toString().substring(0, 8)),
            subtitle: Text(member['role']),
          );
        },
      ),
    );
  }
}
