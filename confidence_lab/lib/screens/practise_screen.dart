import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/practice_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class PractiseScreen extends StatelessWidget {
  const PractiseScreen({super.key});

  void _open(BuildContext context, Scenario s) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeChatScreen(scenario: s)));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Practise', style: t.headlineSmall),
          const SizedBox(height: 8),
          const Text('Rehearse a conversation, then get feedback on your replies. Try it once with your '
              'usual habits and once without them, and notice the difference. Everything stays on your phone.'),
          const SizedBox(height: 20),
          for (final s in scenarios) ...[
            SectionCard(
              onTap: () => _open(context, s),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.title),
                subtitle: Text(s.setup),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          const SectionCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.mic_none),
              title: Text('Voice studio'),
              subtitle: Text('Coming in the next build: record, replay and compare your voice.'),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeChatScreen extends StatefulWidget {
  const PracticeChatScreen({super.key, required this.scenario});
  final Scenario scenario;

  @override
  State<PracticeChatScreen> createState() => _PracticeChatScreenState();
}

class _PracticeChatScreenState extends State<PracticeChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final List<PracticeMessage> _messages = [PracticeMessage('assistant', widget.scenario.opening)];
  String? _feedback;
  bool _busy = false;
  bool _crisis = false;
  bool _scriptEnded = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  int get _userTurns => _messages.where((m) => m.role == 'user').length;

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    _input.clear();
    setState(() {
      _messages.add(PracticeMessage('user', text));
      _busy = true;
    });
    await _call('reply');
  }

  Future<void> _call(String mode) async {
    final service = context.read<AppState>().practice;
    try {
      final reply = await service.send(widget.scenario.id, _messages, mode: mode);
      if (!mounted) return;
      setState(() {
        if (reply.crisis) {
          _crisis = true;
          _feedback = reply.text;
        } else if (mode == 'feedback') {
          _feedback = reply.text;
        } else {
          _messages.add(PracticeMessage('assistant', reply.text));
          _scriptEnded = reply.ended;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ended = _feedback != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenario.title),
        actions: [
          if (!ended && !_scriptEnded && _userTurns >= 2)
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      setState(() => _busy = true);
                      _call('feedback');
                    },
              child: const Text('End & get feedback'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.scenario.setup, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                for (final m in _messages) _Bubble(message: m),
                if (_busy) const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
                if (_feedback != null)
                  SectionCard(
                    color: _crisis ? scheme.errorContainer : scheme.tertiaryContainer,
                    child: Text(_feedback!),
                  ),
              ],
            ),
          ),
          if (!ended && _scriptEnded)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () {
                            setState(() => _busy = true);
                            _call('feedback');
                          },
                    child: const Text('Get feedback'),
                  ),
                ),
              ),
            ),
          if (!ended && !_scriptEnded)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(hintText: 'Your reply'),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(onPressed: _busy ? null : _send, icon: const Icon(Icons.send)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final PracticeMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = message.role == 'user';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: mine ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message.content, style: TextStyle(color: mine ? scheme.onPrimary : scheme.onSurface)),
      ),
    );
  }
}
