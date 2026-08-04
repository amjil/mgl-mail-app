class MailMessageDto {
  const MailMessageDto({
    required this.id,
    required this.accountId,
    required this.subject,
    required this.from,
    required this.fromName,
    required this.to,
    required this.date,
    required this.isRead,
    required this.isStarred,
    required this.hasAttachment,
    required this.hasBody,
    required this.state,
    this.folderRole,
  });

  final int id;
  final String accountId;
  final String subject;
  final String from;
  final String fromName;
  final String to;
  final DateTime date;
  final bool isRead;
  final bool isStarred;
  final bool hasAttachment;
  final bool hasBody;
  final String state;
  final String? folderRole;
}

class MailBodyDto {
  const MailBodyDto({this.plainText, this.html});

  final String? plainText;
  final String? html;
}

class MailFolderDto {
  const MailFolderDto({
    required this.id,
    required this.accountId,
    required this.name,
    required this.path,
    required this.role,
    this.selectable = true,
    this.unreadCount = 0,
  });

  final int id;
  final String accountId;
  final String name;
  final String path;

  /// inbox / sent / trash / draft / custom
  final String role;
  final bool selectable;
  final int unreadCount;
}

class MailAttachmentDto {
  const MailAttachmentDto({
    required this.id,
    required this.messageId,
    required this.filename,
    this.mimeType,
    this.size,
    this.localPath,
    required this.isDownloaded,
  });

  final int id;
  final int messageId;
  final String filename;
  final String? mimeType;
  final int? size;
  final String? localPath;
  final bool isDownloaded;
}

class MailSearchResultDto {
  const MailSearchResultDto({
    required this.messageId,
    required this.accountId,
    required this.subject,
    required this.snippet,
  });

  final int messageId;
  final String accountId;
  final String subject;
  final String snippet;
}

class MailOutboxDto {
  const MailOutboxDto({
    required this.id,
    required this.accountId,
    required this.messageId,
    required this.clientMessageId,
    required this.status,
    required this.retryCount,
    this.nextRetryAt,
    this.lastError,
    required this.createdAt,
    this.subject,
  });

  final int id;
  final String accountId;
  final int messageId;
  final String clientMessageId;
  final String status;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastError;
  final DateTime createdAt;
  final String? subject;
}

class MailAccountDto {
  const MailAccountDto({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
}

class MailMessageWithBody {
  const MailMessageWithBody({
    required this.message,
    this.body,
    this.attachments = const [],
  });

  final MailMessageDto message;
  final MailBodyDto? body;
  final List<MailAttachmentDto> attachments;
}
