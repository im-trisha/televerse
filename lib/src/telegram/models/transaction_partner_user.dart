part of 'models.dart';

/// Describes a transaction with a user.
class TransactionPartnerUser extends TransactionPartner {
  @override
  TransactionPartnerType get type => TransactionPartnerType.user;

  /// Information about the user.
  final User user;

  /// Bot-specified invoice payload.
  final String? invoicePayload;

  /// Optional. Information about the paid media bought by the user
  final List<PaidMedia>? paidMedia;

  /// Optional. Bot-specified paid media payload
  final String? paidMediaPayload;

  /// Optional. The duration of the paid subscription.
  final int? subscriptionPeriod;

  /// Optional. The gift sent to the user by the bot.
  final Gift? gift;

  /// Optional. Information about the affiliate that received a commission via this transaction
  final AffiliateInfo? affiliate;

  /// Constructs a [TransactionPartnerUser] object.
  const TransactionPartnerUser({
    required this.user,
    this.invoicePayload,
    this.paidMedia,
    this.paidMediaPayload,
    this.subscriptionPeriod,
    this.gift,
    this.affiliate,
  });

  /// Creates a [TransactionPartnerUser] object from JSON.
  factory TransactionPartnerUser.fromJson(Map<String, dynamic> json) {
    return TransactionPartnerUser(
      user: User.fromJson(json['user']),
      invoicePayload: json['invoice_payload'],
      paidMedia: json['paid_media'] != null
          ? List<PaidMedia>.from(
              (json['paid_media'] as List).map(
                (e) => PaidMedia.fromJson(e),
              ),
            )
          : null,
      paidMediaPayload: json['paid_media_payload'],
      subscriptionPeriod: json['subscription_period'],
      gift: json['gift'] != null ? Gift.fromJson(json['gift']) : null,
      affiliate: json['affiliate'] != null
          ? AffiliateInfo.fromJson(json['affiliate'])
          : null,
    );
  }

  /// Converts a [TransactionPartnerUser] object to JSON.
  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'user': user.toJson(),
      'invoice_payload': invoicePayload,
      'paid_media': paidMedia?.map((e) => e.toJson()).toList(),
      'paid_media_payload': paidMediaPayload,
      'subscription_period': subscriptionPeriod,
      'gift': gift?.toJson(),
      'affiliate': affiliate?.toJson(),
    }..removeWhere(_nullFilter);
  }
}
