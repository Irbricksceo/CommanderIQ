import 'package:flutter/material.dart';

void main() => runApp(const CommanderIqApp());

const ink = Color(0xFF172923);
const forest = Color(0xFF245C45);
const mint = Color(0xFFE6F1E9);
const paper = Color(0xFFF7F8F4);

class CommanderIqApp extends StatefulWidget {
  const CommanderIqApp({super.key});

  @override
  State<CommanderIqApp> createState() => _CommanderIqAppState();
}

class _CommanderIqAppState extends State<CommanderIqApp> {
  int _selected = 0;
  final List<Deck> _decks = [];
  final List<GameRecord> _games = [];
  bool _hadFunEnabled = true;
  bool _venueEnabled = true;
  bool _seatEnabled = true;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomePage(
        deckCount: _decks.length,
        gameCount: _games.length,
        onNavigate: (index) => setState(() => _selected = index),
        onQuickLog: _quickLog,
      ),
      _DecksPage(decks: _decks, onAdd: _addDeck),
      _RecordsPage(games: _games),
      _InsightsPage(games: _games),
      _StatsPage(
        hadFunEnabled: _hadFunEnabled,
        venueEnabled: _venueEnabled,
        seatEnabled: _seatEnabled,
        onChanged: (metric, value) => setState(() {
          switch (metric) {
            case 'fun':
              _hadFunEnabled = value;
            case 'venue':
              _venueEnabled = value;
            case 'seat':
              _seatEnabled = value;
          }
        }),
      ),
    ];
    const titles = ['Home', 'Decks', 'Game Records', 'Insights', 'Stats'];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CommanderIQ',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forest,
          primary: forest,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: paper,
          foregroundColor: ink,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE8ECE6)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAF7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE3E8E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE3E8E1)),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titles[_selected], style: const TextStyle(fontWeight: FontWeight.w800)),
              if (_selected == 0)
                const Text('Your Commander companion',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: _settings,
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(child: IndexedStack(index: _selected, children: pages)),
        floatingActionButton: _selected == 0 || _selected == 2
            ? FloatingActionButton.extended(
                onPressed: _quickLog,
                backgroundColor: forest,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Quick log'),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selected,
          onDestinationSelected: (value) => setState(() => _selected = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: 'Decks'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Game Records'),
            NavigationDestination(icon: Icon(Icons.lightbulb_outline), selectedIcon: Icon(Icons.lightbulb), label: 'Insights'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          ],
        ),
      ),
    );
  }

  Future<void> _addDeck() async {
    final deck = await showDialog<Deck>(
      context: context,
      builder: (context) => const _AddDeckDialog(),
    );
    if (deck != null) setState(() => _decks.add(deck));
  }

  Future<void> _quickLog() async {
    if (_decks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a deck first, then you can log a game.')),
      );
      setState(() => _selected = 1);
      return;
    }
    final usedVenues = _games
        .map((game) => game.venue)
        .whereType<String>()
        .toSet()
        .toList();
    final game = await showModalBottomSheet<GameRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _LogGameSheet(
        decks: [..._decks]..sort((a, b) => _lastPlayed(b).compareTo(_lastPlayed(a))),
        venues: usedVenues,
        hadFunEnabled: _hadFunEnabled,
        venueEnabled: _venueEnabled,
        seatEnabled: _seatEnabled,
      ),
    );
    if (game != null) {
      setState(() {
        _games.insert(0, game);
        final deckIndex = _decks.indexWhere((deck) => deck.name == game.deckName);
        if (deckIndex >= 0) _decks[deckIndex] = _decks[deckIndex].copyWith(lastPlayed: game.date);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game saved for this session.')));
      }
    }
  }

  DateTime _lastPlayed(Deck deck) => deck.lastPlayed ?? DateTime(1900);

  void _settings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Settings and local data controls will be added as the app takes shape.'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class Deck {
  const Deck({required this.name, required this.commander, required this.bracket, this.lastPlayed});
  final String name;
  final String commander;
  final String bracket;
  final DateTime? lastPlayed;

  Deck copyWith({DateTime? lastPlayed}) => Deck(
        name: name,
        commander: commander,
        bracket: bracket,
        lastPlayed: lastPlayed ?? this.lastPlayed,
      );
}

class GameRecord {
  const GameRecord({
    required this.deckName,
    required this.won,
    required this.date,
    required this.bracket,
    required this.turns,
    this.hadFun,
    this.venue,
    this.seat,
  });
  final String deckName;
  final bool won;
  final DateTime date;
  final String bracket;
  final int turns;
  final bool? hadFun;
  final String? venue;
  final String? seat;
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.deckCount, required this.gameCount, required this.onNavigate, required this.onQuickLog});
  final int deckCount;
  final int gameCount;
  final ValueChanged<int> onNavigate;
  final VoidCallback onQuickLog;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [Color(0xFF1F503D), Color(0xFF34765A)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Every game tells a story.', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Track your table time and find the patterns that matter to you.', style: TextStyle(color: Colors.white.withValues(alpha: .82), height: 1.4)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onQuickLog,
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: forest),
                icon: const Icon(Icons.add),
                label: const Text('Quick log a game'),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _SummaryCard(label: 'Decks', value: '$deckCount', icon: Icons.style_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _SummaryCard(label: 'Games logged', value: '$gameCount', icon: Icons.casino_outlined)),
          ]),
          const SizedBox(height: 26),
          const _SectionHeading(title: 'Your space', subtitle: 'Pick up where you left off'),
          const SizedBox(height: 12),
          _NavigationTile(icon: Icons.style_outlined, title: 'Decks', subtitle: 'Manage your collection', onTap: () => onNavigate(1)),
          _NavigationTile(icon: Icons.receipt_long_outlined, title: 'Game Records', subtitle: 'Review your past games', onTap: () => onNavigate(2)),
          _NavigationTile(icon: Icons.lightbulb_outline, title: 'Insights', subtitle: 'Explore patterns over time', onTap: () => onNavigate(3)),
          _NavigationTile(icon: Icons.bar_chart_outlined, title: 'Stats', subtitle: 'Choose the metrics you track', onTap: () => onNavigate(4)),
        ],
      );
}

class _DecksPage extends StatelessWidget {
  const _DecksPage({required this.decks, required this.onAdd});
  final List<Deck> decks;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _PageIntro(title: 'Your decks', subtitle: 'Keep your commanders and builds in one place.'),
          const SizedBox(height: 18),
          if (decks.isEmpty)
            const _EmptyCard(icon: Icons.style_outlined, title: 'No decks yet', message: 'Add a deck to get started. You’ll choose from your decks when logging a game.'),
          ...decks.map((deck) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  leading: const CircleAvatar(backgroundColor: mint, foregroundColor: forest, child: Icon(Icons.auto_awesome)),
                  title: Text(deck.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${deck.commander}\nBracket ${deck.bracket}', style: const TextStyle(height: 1.5)),
                  isThreeLine: true,
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add a deck')),
        ],
      );
}

class _RecordsPage extends StatelessWidget {
  const _RecordsPage({required this.games});
  final List<GameRecord> games;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _PageIntro(title: 'Game records', subtitle: 'A clear history of the games you’ve played.'),
          const SizedBox(height: 18),
          if (games.isEmpty)
            const _EmptyCard(icon: Icons.receipt_long_outlined, title: 'No games recorded', message: 'Your game history will appear here after your first log.'),
          ...games.map((game) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: game.won ? mint : const Color(0xFFF1EAE4),
                    child: Icon(game.won ? Icons.emoji_events_outlined : Icons.sports_martial_arts_outlined, color: game.won ? forest : Colors.brown),
                  ),
                  title: Text(game.deckName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${_dateLabel(game.date)} · Bracket ${game.bracket} · ${game.turns} turns${game.venue == null ? '' : ' · ${game.venue}'}'),
                  trailing: Text(game.won ? 'WIN' : 'LOSS', style: TextStyle(color: game.won ? forest : Colors.brown, fontWeight: FontWeight.bold)),
                ),
              )),
        ],
      );
}

class _InsightsPage extends StatelessWidget {
  const _InsightsPage({required this.games});
  final List<GameRecord> games;

  @override
  Widget build(BuildContext context) {
    final wins = games.where((game) => game.won).length;
    final rate = games.isEmpty ? 0 : (wins / games.length * 100).round();
    final averageTurns = games.isEmpty ? 0 : games.fold<int>(0, (sum, game) => sum + game.turns) / games.length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const _PageIntro(title: 'Insights', subtitle: 'Useful context from your own play history.'),
      const SizedBox(height: 18),
      if (games.length < 3)
        const _EmptyCard(icon: Icons.lightbulb_outline, title: 'Insights grow with your history', message: 'Log a few more games to start seeing meaningful patterns. We’ll avoid drawing conclusions from too little data.'),
      if (games.isNotEmpty) ...[
        _MetricCard(label: 'Win rate', value: '$rate%', helper: '$wins wins from ${games.length} logged ${games.length == 1 ? 'game' : 'games'}', icon: Icons.trending_up),
        const SizedBox(height: 12),
        _MetricCard(label: 'Average game length', value: '${averageTurns.toStringAsFixed(1)} turns', helper: 'Based on your logged games', icon: Icons.hourglass_bottom),
      ],
    ]);
  }
}

class _StatsPage extends StatelessWidget {
  const _StatsPage({required this.hadFunEnabled, required this.venueEnabled, required this.seatEnabled, required this.onChanged});
  final bool hadFunEnabled;
  final bool venueEnabled;
  final bool seatEnabled;
  final void Function(String metric, bool value) onChanged;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const _PageIntro(title: 'Stats & metrics', subtitle: 'Choose which optional details to capture in each game.'),
        const SizedBox(height: 18),
        const Text('OPTIONAL FIELDS', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 8),
        Card(child: Column(children: [
          SwitchListTile(secondary: const Icon(Icons.mood_outlined), title: const Text('Had Fun'), value: hadFunEnabled, onChanged: (value) => onChanged('fun', value)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(secondary: const Icon(Icons.place_outlined), title: const Text('Venue'), value: venueEnabled, onChanged: (value) => onChanged('venue', value)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SwitchListTile(secondary: const Icon(Icons.event_seat_outlined), title: const Text('Seat Position'), value: seatEnabled, onChanged: (value) => onChanged('seat', value)),
        ])),
        const SizedBox(height: 22),
        const Text('CORE GAME FIELDS', style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 10),
        const Wrap(spacing: 8, runSpacing: 8, children: [
          _FieldChip(label: 'Win / Loss'), _FieldChip(label: 'Date'), _FieldChip(label: 'Game Bracket'), _FieldChip(label: 'Turns'),
        ]),
        const SizedBox(height: 22),
        const Card(child: ListTile(
          leading: Icon(Icons.add_chart, color: forest),
          title: Text('Custom metrics', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Create your own fields in a future iteration.'),
          trailing: Icon(Icons.lock_outline, size: 18),
        )),
        const SizedBox(height: 8),
        const Text('Metric settings are currently held in memory and reset when the app closes.', style: TextStyle(color: Colors.black54, fontSize: 12)),
      ]);
}

class _AddDeckDialog extends StatefulWidget {
  const _AddDeckDialog();
  @override
  State<_AddDeckDialog> createState() => _AddDeckDialogState();
}

class _AddDeckDialogState extends State<_AddDeckDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _commander = TextEditingController();
  String _bracket = '3';

  @override
  void dispose() {
    _name.dispose();
    _commander.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add a deck'),
        content: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Deck name'), validator: _required),
          const SizedBox(height: 12),
          TextFormField(controller: _commander, decoration: const InputDecoration(labelText: 'Commander'), validator: _required),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _bracket,
            decoration: const InputDecoration(labelText: 'Bracket'),
            items: List.generate(5, (index) => '${index + 1}').map((value) => DropdownMenuItem(value: value, child: Text('Bracket $value'))).toList(),
            onChanged: (value) => setState(() => _bracket = value ?? '3'),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, Deck(name: _name.text.trim(), commander: _commander.text.trim(), bracket: _bracket));
            }
          }, child: const Text('Save deck')),
        ],
      );
}

class _LogGameSheet extends StatefulWidget {
  const _LogGameSheet({required this.decks, required this.venues, required this.hadFunEnabled, required this.venueEnabled, required this.seatEnabled});
  final List<Deck> decks;
  final List<String> venues;
  final bool hadFunEnabled;
  final bool venueEnabled;
  final bool seatEnabled;

  @override
  State<_LogGameSheet> createState() => _LogGameSheetState();
}

class _LogGameSheetState extends State<_LogGameSheet> {
  final _formKey = GlobalKey<FormState>();
  late final List<String> _venues = [...widget.venues];
  late String _deckName = widget.decks.first.name;
  String _bracket = '3';
  String? _venue;
  String? _seat;
  DateTime _date = DateTime.now();
  final _turns = TextEditingController();
  bool _won = false;
  bool? _hadFun;

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(key: _formKey, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 18),
          const Text('Log a game', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _deckName,
            decoration: const InputDecoration(labelText: 'Deck played'),
            items: widget.decks.map((deck) => DropdownMenuItem(value: deck.name, child: Text('${deck.name} · ${deck.commander}'))).toList(),
            onChanged: (value) => setState(() => _deckName = value ?? _deckName),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: false, label: Text('Loss'), icon: Icon(Icons.close)), ButtonSegment(value: true, label: Text('Win'), icon: Icon(Icons.check))],
            selected: {_won},
            onSelectionChanged: (value) => setState(() => _won = value.first),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              initialValue: _bracket,
              decoration: const InputDecoration(labelText: 'Game bracket'),
              items: List.generate(5, (index) => '${index + 1}').map((value) => DropdownMenuItem(value: value, child: Text('Bracket $value'))).toList(),
              onChanged: (value) => setState(() => _bracket = value ?? '3'),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _turns, decoration: const InputDecoration(labelText: 'Turns'), keyboardType: TextInputType.number, validator: (value) {
              final turns = int.tryParse(value ?? '');
              return turns == null || turns < 1 ? 'Enter turns' : null;
            })),
          ]),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final selected = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime.now());
              if (selected != null) setState(() => _date = selected);
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text('Date · ${_dateLabel(_date)}'),
          ),
          if (widget.hadFunEnabled) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<bool?>(
              initialValue: _hadFun,
              decoration: const InputDecoration(labelText: 'Did you have fun?'),
              items: const [DropdownMenuItem(value: true, child: Text('Yes')), DropdownMenuItem(value: false, child: Text('Not really'))],
              onChanged: (value) => setState(() => _hadFun = value),
            ),
          ],
          if (widget.venueEnabled) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _venue,
              decoration: const InputDecoration(labelText: 'Venue (optional)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('No venue')),
                ..._venues.map((venue) => DropdownMenuItem<String?>(value: venue, child: Text(venue))),
                const DropdownMenuItem<String?>(value: '__add__', child: Text('+ Add a venue')),
              ],
              onChanged: (value) async {
                if (value == '__add__') {
                  final controller = TextEditingController();
                  final venue = await showDialog<String>(context: context, builder: (context) => AlertDialog(
                    title: const Text('Add venue'),
                    content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Venue name')),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Add'))],
                  ));
                  controller.dispose();
                  if (venue != null && venue.isNotEmpty) {
                    setState(() {
                      if (!_venues.contains(venue)) _venues.add(venue);
                      _venue = venue;
                    });
                  }
                } else {
                  setState(() => _venue = value);
                }
              },
            ),
          ],
          if (widget.seatEnabled) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _seat,
              decoration: const InputDecoration(labelText: 'Seat position (optional)'),
              items: const [DropdownMenuItem(value: null, child: Text('Not recorded')), DropdownMenuItem(value: '1st', child: Text('1st')), DropdownMenuItem(value: '2nd', child: Text('2nd')), DropdownMenuItem(value: '3rd', child: Text('3rd')), DropdownMenuItem(value: '4th', child: Text('4th'))],
              onChanged: (value) => setState(() => _seat = value),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, GameRecord(deckName: _deckName, won: _won, date: _date, bracket: _bracket, turns: int.parse(_turns.text), hadFun: _hadFun, venue: _venue, seat: _seat));
            }
          }, child: const Padding(padding: EdgeInsets.all(12), child: Text('Save game'))),
        ]))),
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: forest),
        const SizedBox(height: 14),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ])));
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: mint, foregroundColor: forest, child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ));
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.black54, height: 1.4)),
      ]);
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        CircleAvatar(radius: 28, backgroundColor: mint, foregroundColor: forest, child: Icon(icon, size: 28)),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, height: 1.45)),
      ])));
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.helper, required this.icon});
  final String label;
  final String value;
  final String helper;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: mint, foregroundColor: forest, child: Icon(icon)),
        title: Text(label),
        subtitle: Text(helper),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: forest)),
      ));
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Chip(label: Text(label), backgroundColor: mint, side: BorderSide.none);
}

String? _required(String? value) => value == null || value.trim().isEmpty ? 'This field is required' : null;

String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
