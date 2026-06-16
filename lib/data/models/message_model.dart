class MessageModel {
  final int    id;
  final String senderEmail;
  final String senderName;
  final String recipientEmail;
  final String recipientName;
  final String subject;
  final String content;
  final int?   jobId;
  final String sentAt;
  final bool   read;
  final bool   resumeAttached;

  const MessageModel({
    required this.id,
    required this.senderEmail,
    required this.senderName,
    required this.recipientEmail,
    required this.recipientName,
    required this.subject,
    required this.content,
    this.jobId,
    required this.sentAt,
    required this.read,
    required this.resumeAttached,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id:             json['id']             as int,
    senderEmail:    json['senderEmail']    as String? ?? '',
    senderName:     json['senderName']     as String? ?? '',
    recipientEmail: json['recipientEmail'] as String? ?? '',
    recipientName:  json['recipientName']  as String? ?? '',
    subject:        json['subject']        as String? ?? '',
    content:        json['content']        as String? ?? '',
    jobId:          json['jobId']          as int?,
    sentAt:         json['sentAt']         as String? ?? '',
    read:           json['read']           as bool?   ?? false,
    resumeAttached: json['resumeAttached'] as bool?   ?? false,
  );
}
