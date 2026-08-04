import '../../db/app_database.dart';
import '../dto/mail_dtos.dart';

class MailMapper {
  static MailMessageDto toMessageDto(
    Message m, {
    bool hasBody = false,
    String? folderRole,
  }) {
    return MailMessageDto(
      id: m.id,
      accountId: m.accountId,
      subject: m.subject ?? '',
      from: m.fromAddr,
      fromName: m.fromName ?? '',
      to: m.toAddr,
      date: m.date,
      isRead: m.isRead,
      isStarred: m.isStarred,
      hasAttachment: m.hasAttachment,
      hasBody: hasBody,
      state: m.state,
      folderRole: folderRole,
    );
  }

  static MailBodyDto? toBodyDto(MessageBody? body) {
    if (body == null) return null;
    return MailBodyDto(plainText: body.plainText, html: body.htmlText);
  }

  static MailFolderDto toFolderDto(Folder f) {
    return MailFolderDto(
      id: f.id,
      accountId: f.accountId,
      name: f.name,
      path: f.path,
      role: f.role,
    );
  }

  static MailAttachmentDto toAttachmentDto(Attachment a) {
    return MailAttachmentDto(
      id: a.id,
      messageId: a.messageId,
      filename: a.filename,
      mimeType: a.mimeType,
      size: a.size,
      localPath: a.localPath,
      isDownloaded: a.isDownloaded,
    );
  }

  static MailAccountDto toAccountDto(Account a) {
    return MailAccountDto(
      id: a.id,
      email: a.email,
      displayName: a.displayName,
    );
  }

  static MailOutboxDto toOutboxDto(OutboxData o, {String? subject}) {
    return MailOutboxDto(
      id: o.id,
      accountId: o.accountId,
      messageId: o.messageId,
      clientMessageId: o.clientMessageId,
      status: o.status,
      retryCount: o.retryCount,
      nextRetryAt: o.nextRetryAt,
      lastError: o.lastError,
      createdAt: o.createdAt,
      subject: subject,
    );
  }
}
