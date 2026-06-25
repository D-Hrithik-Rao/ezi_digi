import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Event {
  String title;
  DateTime startDate;
  DateTime endDate;

  Event({
    required this.title,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        title: json['title'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
      );
}

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  // Local storage array
  List<Event> events = [];
  bool _isLoading = true;

  // ── colours (matching app palette) ──────────────────────────────────────
  static const Color _primary = Color(0xFF0D47A1);
  static const Color _bg = Color(0xFFEFF3FF);
  static const Color _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(eventsJson);
        setState(() {
          events = decoded.map((e) => Event.fromJson(e)).toList();
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          events = [];
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await prefs.setString('events', encoded);
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);
  String _formatTime(DateTime dt) => DateFormat('hh:mm a').format(dt);
  String _formatFull(DateTime dt) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(dt);

  Color _statusColor(Event e) {
    final now = DateTime.now();
    if (e.endDate.isBefore(now)) return Colors.red.shade400;
    if (e.startDate.isBefore(now)) return Colors.green.shade500;
    return _primary;
  }

  String _statusLabel(Event e) {
    final now = DateTime.now();
    if (e.endDate.isBefore(now)) return 'Ended';
    if (e.startDate.isBefore(now)) return 'Ongoing';
    return 'Upcoming';
  }

  // ── dialog ───────────────────────────────────────────────────────────────

  void _openEventDialog({Event? event, int? index}) {
    final titleCtrl = TextEditingController(text: event?.title ?? '');
    DateTime? startDate = event?.startDate;
    DateTime? endDate = event?.endDate;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) {
          Future<void> pickStartDateTime() async {
            final date = await showDatePicker(
              context: ctx,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDate: startDate ?? DateTime.now(),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: const ColorScheme.light(primary: _primary),
                ),
                child: child!,
              ),
            );
            if (date == null || !ctx.mounted) return;
            final time = await showTimePicker(
              context: ctx,
              initialTime: startDate != null
                  ? TimeOfDay.fromDateTime(startDate!)
                  : TimeOfDay.now(),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: const ColorScheme.light(primary: _primary),
                ),
                child: child!,
              ),
            );
            if (time == null) return;
            setDlg(() {
              startDate = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
            });
          }

          Future<void> pickEndDateTime() async {
            final date = await showDatePicker(
              context: ctx,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDate: endDate ?? startDate ?? DateTime.now(),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: const ColorScheme.light(primary: _primary),
                ),
                child: child!,
              ),
            );
            if (date == null || !ctx.mounted) return;
            final time = await showTimePicker(
              context: ctx,
              initialTime: endDate != null
                  ? TimeOfDay.fromDateTime(endDate!)
                  : TimeOfDay.now(),
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: const ColorScheme.light(primary: _primary),
                ),
                child: child!,
              ),
            );
            if (time == null) return;
            setDlg(() {
              endDate = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
            });
          }

          void onSave() {
            if (titleCtrl.text.trim().isEmpty ||
                startDate == null ||
                endDate == null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            if (endDate!.isBefore(startDate!)) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('End date/time must be after start'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            setState(() {
              if (event == null) {
                events.add(Event(
                  title: titleCtrl.text.trim(),
                  startDate: startDate!,
                  endDate: endDate!,
                ));
              } else {
                events[index!] = Event(
                  title: titleCtrl.text.trim(),
                  startDate: startDate!,
                  endDate: endDate!,
                );
              }
            });
            _saveEvents();

            if (ctx.mounted) Navigator.pop(ctx);
          }

          // ─────────── the dialog itself ───────────────────────────────────
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: _cardBg,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_rounded,
                            color: _primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        event == null ? 'New Event' : 'Edit Event',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1B1F3B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // title field
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Event Title',
                      prefixIcon:
                          const Icon(Icons.title_rounded, color: _primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFCBD5F5), width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: _primary, width: 1.5),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // start date/time
                  _DateTimeTile(
                    label: 'Start Date & Time',
                    icon: Icons.play_circle_outline_rounded,
                    value: startDate != null ? _formatFull(startDate!) : null,
                    iconColor: Colors.green.shade600,
                    onTap: pickStartDateTime,
                  ),
                  const SizedBox(height: 12),

                  // end date/time
                  _DateTimeTile(
                    label: 'End Date & Time',
                    icon: Icons.stop_circle_outlined,
                    value: endDate != null ? _formatFull(endDate!) : null,
                    iconColor: Colors.red.shade400,
                    onTap: pickEndDateTime,
                  ),
                  const SizedBox(height: 20),

                  // actions
                  Row(
                    children: [
                      if (event != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18),
                            label: const Text('Delete'),
                            onPressed: () {
                              setState(() => events.removeAt(index!));
                              _saveEvents();
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                          ),
                        ),
                      if (event != null) const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          icon: Icon(
                            event == null
                                ? Icons.add_rounded
                                : Icons.save_rounded,
                            size: 18,
                          ),
                          label: Text(event == null ? 'Create Event' : 'Save'),
                          onPressed: onSave,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Event Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          if (events.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _openEventDialog(),
              tooltip: 'Add Event',
            ),
        ],
      ),

      // ── body ─────────────────────────────────────────────────────────────
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : events.isEmpty
          ? _EmptyState(onAdd: () => _openEventDialog())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _StatsHeader(events: events),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final e = events[i];
                        return _EventCard(
                          event: e,
                          statusColor: _statusColor(e),
                          statusLabel: _statusLabel(e),
                          formatDate: _formatDate,
                          formatTime: _formatTime,
                          onTap: () => _openEventDialog(event: e, index: i),
                        );
                      },
                      childCount: events.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Reusable date/time tile ──────────────────────────────────────────────────

class _DateTimeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final Color iconColor;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCBD5F5), width: 1.2),
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFFF8F9FF),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    value ?? 'Tap to select',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value != null
                          ? const Color(0xFF1B1F3B)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF9E9E9E), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Stats header ─────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  final List<Event> events;
  const _StatsHeader({required this.events});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = events.where((e) => e.startDate.isAfter(now)).length;
    final ongoing = events
        .where((e) => e.startDate.isBefore(now) && e.endDate.isAfter(now))
        .length;
    final ended = events.where((e) => e.endDate.isBefore(now)).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
              label: 'Upcoming',
              value: upcoming,
              color: Colors.lightBlue.shade200),
          _vDivider(),
          _StatChip(
              label: 'Ongoing',
              value: ongoing,
              color: Colors.green.shade300),
          _vDivider(),
          _StatChip(label: 'Ended', value: ended, color: Colors.red.shade300),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2));
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.w700, color: color),
        ),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Event card ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final Event event;
  final Color statusColor;
  final String statusLabel;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.statusColor,
    required this.statusLabel,
    required this.formatDate,
    required this.formatTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // left colour bar + date
                Column(
                  children: [
                    Container(
                      width: 48,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            formatDate(event.startDate).split(' ')[0],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            formatDate(event.startDate).split(' ')[1],
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: statusColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B1F3B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                          icon: Icons.play_arrow_rounded,
                          label: 'Start',
                          value:
                              '${formatDate(event.startDate)}, ${formatTime(event.startDate)}',
                          color: Colors.green.shade600),
                      const SizedBox(height: 4),
                      _InfoRow(
                          icon: Icons.stop_rounded,
                          label: 'End',
                          value:
                              '${formatDate(event.endDate)}, ${formatTime(event.endDate)}',
                          color: Colors.red.shade400),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFFBDBDBD), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text('$label: ',
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF1B1F3B),
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_available_rounded,
                  size: 52, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 20),
            Text(
              'No Events Yet',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1B1F3B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first event \nand keep track of your schedule.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF6B7280), height: 1.6),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text('Create Event',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}