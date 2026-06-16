import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/download_helper.dart';
import '../../providers/message_provider.dart';
import '../../data/models/message_model.dart';

class MessagesScreen extends StatefulWidget {
  final VoidCallback? onGoHome;
  const MessagesScreen({super.key, this.onGoHome});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<MessageProvider>();
      p.loadInbox();
      p.loadSent();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<MessageProvider>();
    final w      = MediaQuery.of(context).size.width;
    final isWide = w > 900;
    final hPad   = isWide ? ((w - 1100) / 2).clamp(24.0, double.infinity) : 24.0;
    final pad    = EdgeInsets.symmetric(horizontal: hPad);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true, floating: false,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 64,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
              padding: pad,
              child: Row(children: [
                if (widget.onGoHome != null) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'Back to Home',
                    onPressed: widget.onGoHome,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.forum_rounded,
                      color: Colors.white, size: 17),
                ),
                const SizedBox(width: 10),
                Text('Messages',
                  style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
                const Spacer(),
                if (prov.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${prov.unreadCount} unread',
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.white)),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () { prov.loadInbox(); prov.loadSent(); },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.refresh_rounded,
                        size: 20, color: AppColors.textSecondary),
                  ),
                ),
              ]),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(49),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(height: 1, color: AppColors.divider),
                TabBar(
                  controller: _tab,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.inbox_rounded, size: 16),
                        const SizedBox(width: 6),
                        const Text('Inbox'),
                        if (prov.unreadCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 18, height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${prov.unreadCount}',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ]),
                    ),
                    const Tab(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.send_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Sent'),
                      ]),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _MessageList(
              messages:    prov.inbox,
              loading:     prov.loading,
              error:       prov.error,
              emptyTitle:  'No messages yet',
              emptyBody:   'When recruiters reply or you receive messages, they\'ll appear here.',
              isInbox:     true,
              onRefresh:   prov.loadInbox,
              onMarkRead:  (id) => prov.markAsRead(id),
              hPad:        hPad,
            ),
            _MessageList(
              messages:    prov.sent,
              loading:     prov.loading,
              error:       prov.error,
              emptyTitle:  'No sent messages',
              emptyBody:   'Cold emails you send to recruiters will appear here.',
              isInbox:     false,
              onRefresh:   prov.loadSent,
              onMarkRead:  null,
              hPad:        hPad,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable list for inbox / sent ────────────────────────────────────────────
class _MessageList extends StatelessWidget {
  final List<MessageModel>      messages;
  final bool                    loading;
  final String?                 error;
  final String                  emptyTitle;
  final String                  emptyBody;
  final bool                    isInbox;
  final VoidCallback            onRefresh;
  final void Function(int id)?  onMarkRead;
  final double                  hPad;

  const _MessageList({
    required this.messages,
    required this.loading,
    required this.error,
    required this.emptyTitle,
    required this.emptyBody,
    required this.isInbox,
    required this.onRefresh,
    required this.onMarkRead,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.symmetric(horizontal: hPad);

    if (loading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator(
          strokeWidth: 2, color: AppColors.primary));
    }
    if (error != null && messages.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded,
            size: 36, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(error!,
          style: GoogleFonts.inter(
            fontSize: 13, color: AppColors.textSecondary),
          textAlign: TextAlign.center),
        const SizedBox(height: 14),
        ElevatedButton(onPressed: onRefresh, child: const Text('Retry')),
      ]));
    }
    if (messages.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface, shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(
              isInbox ? Icons.inbox_outlined : Icons.send_outlined,
              size: 28, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Text(emptyTitle,
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(emptyBody,
            style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center),
        ]),
      ));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: pad.add(const EdgeInsets.symmetric(vertical: 16)),
        itemCount: messages.length,
        itemBuilder: (_, i) => _MessageCard(
          message:    messages[i],
          isInbox:    isInbox,
          onMarkRead: onMarkRead,
        ),
      ),
    );
  }
}

// ── Single message card ───────────────────────────────────────────────────────
class _MessageCard extends StatefulWidget {
  final MessageModel           message;
  final bool                   isInbox;
  final void Function(int id)? onMarkRead;
  const _MessageCard({
    required this.message,
    required this.isInbox,
    this.onMarkRead,
  });
  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  bool _expanded       = false;
  bool _downloading    = false;

  Future<void> _downloadResume(BuildContext context, int messageId) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider  = context.read<MessageProvider>();
    setState(() => _downloading = true);
    try {
      final bytes = await provider.downloadResume(messageId);
      if (kIsWeb) {
        triggerBrowserDownload(Uint8List.fromList(bytes), 'resume.pdf');
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Resume downloaded'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to download resume: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m        = widget.message;
    final isUnread = widget.isInbox && !m.read;
    final other    = widget.isInbox ? m.senderName   : m.recipientName;
    final otherEmail = widget.isInbox ? m.senderEmail : m.recipientEmail;

    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
        if (widget.isInbox && !m.read && widget.onMarkRead != null) {
          widget.onMarkRead!(m.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider,
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // Avatar
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      other.isNotEmpty ? other[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(other,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isUnread
                                ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      ),
                      if (isUnread)
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle),
                        ),
                    ]),
                    const SizedBox(height: 2),
                    Text(otherEmail,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textMuted)),
                  ],
                )),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_formatDate(m.sentAt),
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    if (m.resumeAttached)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Tooltip(
                          message: 'Resume attached',
                          child: Icon(Icons.attach_file_rounded,
                              size: 13, color: AppColors.success),
                        ),
                      ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18, color: AppColors.textMuted),
                  ]),
                ]),
              ]),
            ),

            // Subject line (always visible)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(m.subject,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textSecondary),
                maxLines: _expanded ? null : 1,
                overflow: _expanded ? null : TextOverflow.ellipsis),
            ),

            // Expanded body
            if (_expanded) ...[
              Divider(height: 1, color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.content,
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textPrimary,
                        height: 1.7)),
                    if (m.resumeAttached) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _downloading ? null : () => _downloadResume(context, m.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.25)),
                          ),
                          child: Row(children: [
                            _downloading
                                ? const SizedBox(
                                    width: 15, height: 15,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.success))
                                : const Icon(Icons.download_rounded,
                                    size: 15, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(
                              _downloading
                                  ? 'Downloading resume…'
                                  : 'Download Applicant Resume',
                              style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.success,
                                fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
      if (diff.inHours   < 24)  return '${diff.inHours}h ago';
      if (diff.inDays    < 7)   return '${diff.inDays}d ago';
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[dt.month - 1]} ${dt.day}';
    } catch (_) { return raw; }
  }
}
