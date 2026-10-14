import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';
import 'check_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editGoal(BuildContext context) async {
    final state = context.read<AppState>();
    final controller = TextEditingController(text: state.profile?.goal ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your goal'),
        content: TextField(controller: controller, maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    final p = state.profile;
    if (result != null && p != null) await state.updateProfile(p.copyWith(goal: result));
  }

  Future<void> _export(BuildContext context) async {
    final json = context.read<AppState>().exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All your data was copied to the clipboard as JSON.')),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
            'This permanently deletes your profile, thought journal, challenges and check-ins. It cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) await context.read<AppState>().deleteAllData();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Profile', style: t.headlineSmall),
          const SizedBox(height: 16),
          SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Goal'),
                  subtitle: Text((state.profile?.goal.isEmpty ?? true) ? 'Not set' : state.profile!.goal),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editGoal(context),
                ),
                ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title: const Text('Weekly check-in'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Support', style: t.titleMedium),
          const SizedBox(height: 12),
          const SectionCard(
            child: Text(
              'Confidence Lab is a training tool, not a medical or therapy service.\n\n'
              'If fear of judgment is seriously affecting your work, studies or relationships, '
              'consider speaking to a psychologist, counsellor or your doctor. CBT for social anxiety '
              'is a well-supported treatment.\n\n'
              'If you are in crisis or thinking about harming yourself, contact your local emergency '
              'number or a crisis line right away.',
            ),
          ),
          const SizedBox(height: 24),
          Text('Privacy', style: t.titleMedium),
          const SizedBox(height: 12),
          SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Stored only on this phone'),
                  subtitle: Text('No account, no servers. Uninstalling the app deletes your data, so export a copy if you want to keep it.'),
                ),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Export my data'),
                  onTap: () => _export(context),
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  title: const Text('Delete all my data'),
                  onTap: () => _delete(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('How this works', style: t.titleMedium),
          const SizedBox(height: 12),
          const SectionCard(
            child: Text(
              'Confidence Lab draws on cognitive behavioural therapy for social anxiety (Clark & Wells), '
              'the inhibitory learning approach to exposure (Craske et al.), and self-compassion research '
              '(Neff). Challenges are behavioural experiments: you write what your fear predicts, try it, '
              'and compare. It does not diagnose anything or promise results in 30 days.',
            ),
          ),
        ],
      ),
    );
  }
}
