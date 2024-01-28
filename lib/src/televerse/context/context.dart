part of '../../../televerse.dart';

/// This class is used to represent the context of an update. It contains the update and the [RawAPI] instance.
///
/// Whenever an update is received, a context is created and passed to the handler.
/// Currently Televerse support the following types of contexts:
class Context<TeleverseSession extends Session> {
  /// The RawAPI getter.
  RawAPI get api => _bot.api;

  /// The bot that received the update's informations.
  User get me => _bot.me;

  /// The RawAPI instance.
  final Bot<TeleverseSession> _bot;

  /// The [Update] instance.
  ///
  /// This represents the update for which the context is created.
  final Update update;

  /// The Session
  late TeleverseSession _session;

  /// The Session getter.
  TeleverseSession get session {
    try {
      return _session;
    } catch (e) {
      throw TeleverseException.sessionsNotEnabled;
    }
  }

  /// The Session setter.
  set session(TeleverseSession session) {
    _bot.sessions.addSession(id.id, _session);
  }

  /// The [ChatID] instance.
  ///
  /// This represents the ID of the chat from which the update was sent.
  ///
  /// Note: On `poll`, and `unknown` updates, this will throw a [TeleverseException].
  /// This is because these updates do not have a chat.
  ID get id {
    if (chat == null) {
      throw TeleverseException(
        "The update type is ${update.type}, which does not have a chat.",
      );
    }
    return ChatID(chat!.id);
  }

  /// Creates a new context.
  Context(
    this._bot, {
    required this.update,
  }) {
    if (_bot.sessionsEnabled) {
      _session = _bot.sessions.getSession(id.id);
    }
  }

  /// Contains the matches of the regular expression. (Internal)
  List<RegExpMatch>? _matches;

  /// **Regular expression matches**
  ///
  /// Contains the matches of the regular expression.
  ///
  /// This will be automatically set when you use the [Bot.hears] method.
  List<RegExpMatch>? get matches => _matches;

  /// If the message is a command, the list will be filled with the command arguments.
  /// e.g. /hello @mom @dad will have a ctx.args like this: ['@mom', '@dad'].
  /// This will be empty if the message is not a command or if the message doesn't contain text
  /// NOTE: This is obviously also used for the deeplink start parameters.
  List<String>? get args {
    if (!(msg?.text?.startsWith('/') ?? false)) return [];

    return msg?.text?.clean.split(' ').sublist(1);
  }

  /// This is a shorthand getter for the [Message] recieved in the current context
  ///
  /// This can either be `Message` or `Channel Post` or `Edited Message` or `Edited Channel Post`. (Internal)
  Message? get _msg {
    Message? m = update.message ??
        update.editedMessage ??
        update.channelPost ??
        update.editedChannelPost;
    return m;
  }

  /// This is a shorthand getter for the [Message] recieved in the current context
  ///
  /// This can either be `Message` or `Channel Post` or `Edited Message` or `Edited Channel Post`.
  Message? get msg => _msg;

  /// The incoming message.
  Message? get message => update.message;

  /// The edited message.
  Message? get editedMessage => update.editedMessage;

  /// The channel post.
  Message? get channelPost => update.channelPost;

  /// The edited channel post.
  Message? get editedChannelPost => update.editedChannelPost;

  /// The callback query of the update.
  CallbackQuery? get callbackQuery => update.callbackQuery;

  /// The incoming inline query.
  InlineQuery? get inlineQuery => update.inlineQuery;

  /// The [ChosenInlineResult] instance.
  ChosenInlineResult? get chosenInlineResult => update.chosenInlineResult;

  /// The chat boost that was removed.
  ChatBoostRemoved? get chatBoostRemoved => update.removedChatBoost;

  /// The chat boost that was updated.
  ChatBoostUpdated? get chatBoost => update.chatBoost;

  /// The [ChatJoinRequest] instance.
  ChatJoinRequest? get chatJoinRequest => update.chatJoinRequest;

  /// Shorthand getter for the [ChatMemberUpdated] instance.
  ///
  /// This can either be `chatMemberUpdated` or `myChatMemberUpdated`.
  ChatMemberUpdated? get chatMemberUpdated =>
      update.chatMember ?? update.myChatMember;

  /// The Chat Member Updated instance of ChatMember
  ChatMemberUpdated? get chatMember => update.chatMember;

  /// The Chat Member Updated instance of MyChatMember
  ChatMemberUpdated? get myChatMember => update.myChatMember;

  /// The [MessageReactionCountUpdated] object.
  MessageReactionCountUpdated? get messageReactionCount =>
      update.messageReactionCount;

  /// The [MessageReactionUpdated] object.
  MessageReactionUpdated? get messageReaction => update.messageReaction;

  /// The [PollAnswer] instance.
  PollAnswer? get pollAnswer => update.pollAnswer;

  /// Removed chat boost instance
  ChatBoostRemoved? get removedChatBoost => update.removedChatBoost;

  /// The [Poll] instance.
  Poll? get poll => update.poll;

  /// The [PreCheckoutQuery] instance.
  ///
  /// This represents the pre-checkout query for which the context is created.
  PreCheckoutQuery? get preCheckoutQuery => update.preCheckoutQuery;

  /// The [ShippingQuery] instance.
  ///
  /// This represents the shipping query for which the context is created.
  ShippingQuery? get shippingQuery => update.shippingQuery;

  /// The thread id
  int? _threadId([int? id]) {
    bool isInTopic = _msg?.isTopicMessage ?? false;
    return id ?? (isInTopic ? _msg?.messageThreadId : null);
  }

  /// A shorthand getter for the [Chat] instance from the update.
  ///
  /// This can be any of `msg.chat` or `myChatMember.chat` or `chatMember.chat` or `chatJoinRequest.chat` or `messageReaction.chat` or `messageReactionCount.chat` or `chatBoost.chat` or `removedChatBoost.chat`.
  Chat? get chat {
    return (chatJoinRequest ??
            removedChatBoost ??
            chatBoost ??
            chatMember ??
            myChatMember ??
            messageReaction ??
            messageReactionCount ??
            msg)
        ?.chat;
  }

  /// A shorthand getter for the [User] instance from the update.
  User? get from {
    return (callbackQuery ??
            inlineQuery ??
            shippingQuery ??
            preCheckoutQuery ??
            chosenInlineResult ??
            msg ??
            myChatMember ??
            chatMember ??
            chatJoinRequest)
        ?.from;
  }

  /// The Chat ID for internal use
  int? get _chatId {
    return chat?.id;
  }

  /// The message id for internal use
  int? get _msgId {
    return _msg?.messageId ??
        messageReaction?.messageId ??
        messageReactionCount?.messageId;
  }

  /// Internal method to check if the context contains necessary information
  /// to call the context aware methods.
  void _verifyInfo(List<dynamic> info, APIMethod method) {
    if (info.contains(null)) {
      throw TeleverseException(
        "The context does not contain necessary information to call the method `$method`.",
      );
    }
  }

  /// Reply a Text Message to the user.
  Future<Message> reply(
    String text, {
    int? messageThreadId,
    ParseMode? parseMode,
    List<MessageEntity>? entities,
    LinkPreviewOptions? linkPreviewOptions,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendMessage);
    return await api.sendMessage(
      id,
      text,
      messageThreadId: _threadId(messageThreadId),
      parseMode: parseMode,
      entities: entities,
      linkPreviewOptions: linkPreviewOptions,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply a Photo to the user.
  /// Reply with a Photo to the user.
  ///
  /// Provide an [InputFile] as [photo]. Use the [InputFile.fromFile] or [InputFile.fromUrl] or [InputFile.fromFileId]
  /// constructors to create an [InputFile] from a file or a URL or a file ID.
  ///
  /// Example:
  /// ```dart
  /// ctx.replyPhoto(InputFile.fromFile(File("photo.jpg")));
  /// ```
  Future<Message> replyWithPhoto(
    InputFile photo, {
    int? messageThreadId,
    String? caption,
    ParseMode? parseMode,
    List<MessageEntity>? captionEntities,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendPhoto);
    return await api.sendPhoto(
      id,
      photo,
      messageThreadId: _threadId(messageThreadId),
      caption: caption,
      parseMode: parseMode,
      captionEntities: captionEntities,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with an Audio to the user.
  ///
  /// Provide an [InputFile] as [audio]. Use the [InputFile.fromFile] or [InputFile.fromUrl] or [InputFile.fromFileId]
  /// constructors to create an [InputFile] from a file or a URL or a file ID.
  Future<Message> replyWithAudio(
    InputFile audio, {
    int? messageThreadId,
    String? caption,
    ParseMode? parseMode,
    List<MessageEntity>? captionEntities,
    int? duration,
    String? performer,
    String? title,
    InputFile? thumbnail,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendAudio);
    return await api.sendAudio(
      id,
      audio,
      messageThreadId: _threadId(messageThreadId),
      caption: caption,
      parseMode: parseMode,
      captionEntities: captionEntities,
      duration: duration,
      performer: performer,
      title: title,
      thumbnail: thumbnail,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Document to the user.
  ///
  /// Provide an [InputFile] as [document]. Use the [InputFile.fromFile] or [InputFile.fromUrl] or [InputFile.fromFileId]
  /// constructors to create an [InputFile] from a file or a URL or a file ID.
  Future<Message> replyWithDocument(
    InputFile document, {
    int? messageThreadId,
    InputFile? thumbnail,
    String? caption,
    ParseMode? parseMode,
    List<MessageEntity>? captionEntities,
    bool? disableContentTypeDetection,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendDocument);
    return await api.sendDocument(
      id,
      document,
      messageThreadId: _threadId(messageThreadId),
      thumbnail: thumbnail,
      caption: caption,
      parseMode: parseMode,
      captionEntities: captionEntities,
      disableContentTypeDetection: disableContentTypeDetection,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Video to the user.
  ///
  /// Provide an [InputFile] as [video]. Use the [InputFile.fromFile] or [InputFile.fromUrl] or [InputFile.fromFileId]
  /// constructors to create an [InputFile] from a file or a URL or a file ID.
  Future<Message> replyWithVideo(
    InputFile video, {
    int? messageThreadId,
    int? duration,
    int? width,
    int? height,
    InputFile? thumbnail,
    String? caption,
    ParseMode? parseMode,
    List<MessageEntity>? captionEntities,
    bool? hasSpoiler,
    bool? supportsStreaming,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendVideo);
    return await api.sendVideo(
      id,
      video,
      messageThreadId: _threadId(messageThreadId),
      duration: duration,
      width: width,
      height: height,
      thumbnail: thumbnail,
      caption: caption,
      parseMode: parseMode,
      captionEntities: captionEntities,
      hasSpoiler: hasSpoiler,
      supportsStreaming: supportsStreaming,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Video Note to the user.
  ///
  /// Provide an [InputFile] as [videoNote]. Use the [InputFile.fromFile] or [InputFile.fromUrl] or [InputFile.fromFileId]
  /// constructors to create an [InputFile] from a file or a URL or a file ID.
  Future<Message> replyWithVideoNote(
    InputFile videoNote, {
    int? messageThreadId,
    int? duration,
    int? length,
    InputFile? thumbnail,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendVideoNote);
    return await api.sendVideoNote(
      id,
      videoNote,
      messageThreadId: _threadId(messageThreadId),
      duration: duration,
      length: length,
      thumbnail: thumbnail,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Voice to the user.
  ///
  /// Provide an [InputFile] as [voice]. Use the [InputFile.fromFile] or [InputFile.fromUrl] or [InputFile.fromFileId]
  /// constructors to create an [InputFile] from a file or a URL or a file ID.
  Future<Message> replyWithVoice(
    InputFile voice, {
    int? messageThreadId,
    String? caption,
    ParseMode? parseMode,
    List<MessageEntity>? captionEntities,
    int? duration,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendVoice);
    return await api.sendVoice(
      id,
      voice,
      messageThreadId: _threadId(messageThreadId),
      caption: caption,
      parseMode: parseMode,
      captionEntities: captionEntities,
      duration: duration,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Media Group to the user.
  ///
  /// Provide a list of [InputMedia] as [media].
  /// constructors to create an [InputMedia] from a file or a URL or a file ID.
  Future<List<Message>> replyWithMediaGroup(
    List<InputMedia> media, {
    int? messageThreadId,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendMediaGroup);
    return await api.sendMediaGroup(
      id,
      media,
      messageThreadId: _threadId(messageThreadId),
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
    );
  }

  /// Reply with a Location to the user.
  ///
  /// Provide a [latitude] and a [longitude] to send a location.
  Future<Message> replyWithLocation(
    double latitude,
    double longitude, {
    int? messageThreadId,
    double? horizontalAccuracy,
    int? livePeriod,
    int? heading,
    int? proximityAlertRadius,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendLocation);
    return await api.sendLocation(
      id,
      latitude,
      longitude,
      messageThreadId: _threadId(messageThreadId),
      horizontalAccuracy: horizontalAccuracy,
      livePeriod: livePeriod,
      heading: heading,
      proximityAlertRadius: proximityAlertRadius,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Venue to the user.
  ///
  /// Provide a [latitude], a [longitude], a [title] and an [address] to send a venue.
  Future<Message> replyWithVenue(
    double latitude,
    double longitude,
    String title,
    String address, {
    int? messageThreadId,
    String? foursquareId,
    String? foursquareType,
    String? googlePlaceId,
    String? googlePlaceType,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendVenue);
    return await api.sendVenue(
      id,
      latitude,
      longitude,
      title,
      address,
      messageThreadId: _threadId(messageThreadId),
      foursquareId: foursquareId,
      foursquareType: foursquareType,
      googlePlaceId: googlePlaceId,
      googlePlaceType: googlePlaceType,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Contact to the user.
  ///
  /// Provide a [phoneNumber], a [firstName] and an [lastName] to send a contact.
  Future<Message> replyWithContact(
    String phoneNumber,
    String firstName, {
    int? messageThreadId,
    String? lastName,
    String? vcard,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendContact);
    return await api.sendContact(
      id,
      phoneNumber,
      firstName,
      lastName: lastName,
      messageThreadId: _threadId(messageThreadId),
      vcard: vcard,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Poll to the user.
  ///
  /// Provide a [question], a list of [options] and a [type] to send a poll.
  Future<Message> replyWithPoll(
    String question,
    List<String> options, {
    int? messageThreadId,
    bool? isAnonymous,
    PollType type = PollType.regular,
    bool? allowsMultipleAnswers,
    int? correctOptionId,
    String? explanation,
    ParseMode? explanationParseMode,
    List<MessageEntity>? explanationEntities,
    int? openPeriod,
    DateTime? closeDate,
    bool? isClosed,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    return await api.sendPoll(
      id,
      question,
      options,
      messageThreadId: _threadId(messageThreadId),
      isAnonymous: isAnonymous,
      type: type,
      allowsMultipleAnswers: allowsMultipleAnswers,
      correctOptionId: correctOptionId,
      explanation: explanation,
      explanationParseMode: explanationParseMode,
      explanationEntities: explanationEntities,
      openPeriod: openPeriod,
      closeDate: closeDate,
      isClosed: isClosed,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Dice to the user.
  ///
  /// Provide a [emoji] to send a dice.
  Future<Message> replyWithDice({
    DiceEmoji emoji = DiceEmoji.dice,
    int? messageThreadId,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendDice);
    return await api.sendDice(
      id,
      emoji: emoji,
      messageThreadId: _threadId(messageThreadId),
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Chat Action to the user.
  ///
  /// Provide a [action] to send a chat action.
  Future<bool> replyWithChatAction(
    ChatAction action, {
    int? messageThreadId,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendChatAction);
    return await api.sendChatAction(
      id,
      action,
      messageThreadId: _threadId(messageThreadId),
    );
  }

  /// Reply with a Game to the user.
  ///
  /// Provide a [shortName] to send a game.
  Future<Message> replyWithGame(
    String shortName, {
    int? messageThreadId,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendGame);
    return await api.sendGame(
      id,
      shortName,
      messageThreadId: _threadId(messageThreadId),
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with an Animation to the user.
  ///
  /// Provide an [animation] to send an animation.
  Future<Message> replyWithAnimation(
    InputFile animation, {
    int? messageThreadId,
    int? duration,
    int? width,
    int? height,
    InputFile? thumbnail,
    String? caption,
    ParseMode? parseMode,
    List<MessageEntity>? captionEntities,
    bool? hasSpoiler,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    ReplyMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendAnimation);
    return await api.sendAnimation(
      id,
      animation,
      messageThreadId: _threadId(messageThreadId),
      duration: duration,
      width: width,
      height: height,
      thumbnail: thumbnail,
      caption: caption,
      parseMode: parseMode,
      captionEntities: captionEntities,
      hasSpoiler: hasSpoiler,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Reply with a Sticker to the user.
  ///
  /// Provide a [sticker] to send a sticker.
  Future<Message> replyWithSticker(
    InputFile sticker, {
    int? messageThreadId,
    bool? disableNotification,
    bool? protectContent,
    ReplyParameters? replyParameters,
    InlineKeyboardMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId], APIMethod.sendSticker);
    return await api.sendSticker(
      id,
      sticker,
      messageThreadId: _threadId(messageThreadId),
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyParameters: replyParameters,
      replyMarkup: replyMarkup,
    );
  }

  /// Edit the text of a message.
  ///
  /// This method can be used to edit text of messages sent by the bot.
  Future<Message> editMessageText(
    String text, {
    ParseMode? parseMode,
    List<MessageEntity>? entities,
    LinkPreviewOptions? linkPreviewOptions,
    InlineKeyboardMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId, _msgId], APIMethod.editMessageText);
    return await api.editMessageText(
      id,
      _msgId!,
      text,
      parseMode: parseMode,
      entities: entities,
      linkPreviewOptions: linkPreviewOptions,
      replyMarkup: replyMarkup,
    );
  }

  /// Delete the message.
  ///
  /// Use this method to delete the message received by the bot.
  Future<bool> deleteMessage() async {
    _verifyInfo([_chatId, _msgId], APIMethod.deleteMessage);
    return await api.deleteMessage(
      id,
      _msgId!,
    );
  }

  /// Edit the caption of a message.
  ///
  /// This method can be used to edit captions of the message in the current context.
  Future<Message> editMessageCaption(
    String caption, {
    ParseMode? parseMode,
    List<MessageEntity>? captionEntities,
    InlineKeyboardMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId, _msgId], APIMethod.editMessageCaption);
    return await api.editMessageCaption(
      id,
      _msgId!,
      caption: caption,
      parseMode: parseMode,
      captionEntities: captionEntities,
      replyMarkup: replyMarkup,
    );
  }

  /// Edit message live location
  ///
  /// This method will edit the message live location in the current context.
  Future<Message> editMessageLiveLocation({
    String? inlineMessageId,
    double? latitude,
    double? longitude,
    double? horizontalAccuracy,
    int? heading,
    int? proximityAlertRadius,
    InlineKeyboardMarkup? replyMarkup,
  }) async {
    _verifyInfo([_chatId, _msgId], APIMethod.editMessageLiveLocation);
    return await api.editMessageLiveLocation(
      id,
      _msgId!,
      latitude: latitude,
      longitude: longitude,
      horizontalAccuracy: horizontalAccuracy,
      heading: heading,
      proximityAlertRadius: proximityAlertRadius,
      replyMarkup: replyMarkup,
    );
  }

  /// Forward the message.
  ///
  /// This method will forward the message in the current context.
  Future<Message> forwardMessage(
    ID chatId, {
    bool? disableNotification,
    int? messageThreadId,
    bool? protectContent,
  }) async {
    _verifyInfo([_chatId, _msgId], APIMethod.forwardMessage);
    return await api.forwardMessage(
      chatId,
      id,
      _msgId!,
      messageThreadId: _threadId(messageThreadId),
      disableNotification: disableNotification,
      protectContent: protectContent,
    );
  }

  /// Get Author
  ///
  /// This method will get the chat member in the current context.
  Future<ChatMember> getAuthor() async {
    _verifyInfo([_chatId, from?.id], APIMethod.getChatMember);
    return await api.getChatMember(id, from!.id);
  }

  /// hasText checks if the message has the given text.
  ///
  /// **Parameters:**
  /// - [text] - The text to check for, you can either pass a [String] or a [RegExp].
  ///
  /// Pass this if you want exact match for the text.
  ///
  /// - [texts] - List of [Pattern] to check for. If any of the strings match, it will return true.
  ///
  /// Returns true if the message text matches any of the patterns.
  bool hasText({Pattern? text, List<Pattern>? texts}) {
    // Ensure message text is available for comparison
    final messageText = _msg?.text;
    if (messageText == null) return false;

    // Check for exact match with `text`
    if (text != null && text.allMatches(messageText).isNotEmpty) {
      return true;
    }

    // Check for matches with any text in `texts`
    if (texts != null &&
        texts.any((pattern) => pattern.allMatches(messageText).isNotEmpty)) {
      return true;
    }

    // No matches found
    return false;
  }

  /// React to the message with a reaction.
  Future<bool> react(
    String emoji, {
    bool? isBig,
  }) async {
    _verifyInfo([_chatId, _msgId], APIMethod.setMessageReaction);
    return await api.setMessageReaction(
      id,
      _msgId!,
      reaction: [
        ReactionTypeEmoji(emoji: emoji),
      ],
      isBig: isBig,
    );
  }

  /// React to the message with multiple reactions.
  Future<bool> reactMultiple(
    List<String> emojis, {
    bool? isBig,
  }) async {
    _verifyInfo([_chatId, _msgId], APIMethod.setMessageReaction);
    return await api.setMessageReaction(
      id,
      _msgId!,
      reaction: emojis
          .map(
            (e) => ReactionTypeEmoji(emoji: e),
          )
          .toList(),
      isBig: isBig,
    );
  }

  /// Context aware method to get chat member [APIMethod.getChatMember].
  Future<ChatMember> getChatMember(int userId) async {
    _verifyInfo([_chatId], APIMethod.getChatMember);
    return await api.getChatMember(id, userId);
  }

  /// Context aware method for set chat sticker set [APIMethod.setChatStickerSet].
  Future<bool> setChatStickerSet(String stickerSetName) async {
    _verifyInfo([_chatId], APIMethod.setChatStickerSet);
    return await api.setChatStickerSet(id, stickerSetName);
  }

  /// Context aware method for delete chat sticker set [APIMethod.deleteChatStickerSet].
  Future<bool> deleteChatStickerSet() async {
    _verifyInfo([_chatId], APIMethod.deleteChatStickerSet);
    return await api.deleteChatStickerSet(id);
  }

  /// Context aware method for set chat title [APIMethod.setChatTitle].
  Future<bool> setChatTitle(String title) async {
    _verifyInfo([_chatId], APIMethod.setChatTitle);
    return await api.setChatTitle(id, title);
  }

  /// Context aware method for set chat description [APIMethod.setChatDescription].
  Future<bool> setChatDescription(String description) async {
    _verifyInfo([_chatId], APIMethod.setChatDescription);
    return await api.setChatDescription(id, description);
  }

  /// Context aware method for pin chat message [APIMethod.pinChatMessage].
  Future<bool> pinChatMessage(
    int messageId, {
    bool? disableNotification,
  }) async {
    _verifyInfo([_chatId], APIMethod.pinChatMessage);
    return await api.pinChatMessage(
      id,
      messageId,
      disableNotification: disableNotification,
    );
  }

  /// Context aware method for pin the current message [APIMethod.pinChatMessage].
  Future<bool> pinThisMessage({
    bool? disableNotification,
  }) async {
    _verifyInfo([_chatId, _msgId], APIMethod.pinChatMessage);
    return await api.pinChatMessage(
      id,
      _msgId!,
      disableNotification: disableNotification,
    );
  }

  /// Context aware method for unpin chat message [APIMethod.unpinChatMessage].
  Future<bool> unpinChatMessage(int messageId) async {
    _verifyInfo([_chatId], APIMethod.unpinChatMessage);
    return await api.unpinChatMessage(id, messageId);
  }

  /// Context aware method for unpin the current message [APIMethod.unpinChatMessage].
  /// This will unpin the message in the current context.
  Future<bool> unpinThisMessage() async {
    _verifyInfo([_chatId, _msgId], APIMethod.unpinChatMessage);
    return await api.unpinChatMessage(id, _msgId!);
  }

  /// Context aware method for creating a new forum topic [APIMethod.createForumTopic].
  Future<ForumTopic> createForumTopic(
    String name, {
    int? iconColor,
    String? iconCustomEmojiId,
  }) async {
    _verifyInfo([_chatId], APIMethod.createForumTopic);
    return await api.createForumTopic(
      id,
      name,
      iconColor: iconColor,
      iconCustomEmojiId: iconCustomEmojiId,
    );
  }

  /// Context aware method for editing a forum topic [APIMethod.editForumTopic].
  ///
  /// If you want to edit a different forum topic, you can pass the [messageThreadId] parameter. Otherwise, the bot will edit the current forum topic.
  Future<bool> editForumTopic({
    int? messageThreadId,
    String? name,
    String? iconCustomEmojiId,
  }) async {
    _verifyInfo(
      [_chatId, _threadId(messageThreadId)],
      APIMethod.editForumTopic,
    );
    return await api.editForumTopic(
      id,
      _threadId(messageThreadId)!,
      name: name,
      iconCustomEmojiId: iconCustomEmojiId,
    );
  }

  /// Context aware method for closing a forum topic [APIMethod.closeForumTopic].
  ///
  /// If you want to close a different forum topic, you can pass the [messageThreadId] parameter. Otherwise, the bot will close the current forum topic.
  Future<bool> closeForumTopic({
    int? messageThreadId,
  }) async {
    _verifyInfo(
      [_chatId, _threadId(messageThreadId)],
      APIMethod.closeForumTopic,
    );
    return await api.closeForumTopic(
      id,
      _threadId(messageThreadId)!,
    );
  }

  /// Context aware method for reopening a forum topic [APIMethod.reopenForumTopic].
  ///
  /// If you want to reopen a different forum topic, you can pass the [messageThreadId] parameter. Otherwise, the bot will reopen the current forum topic.
  Future<bool> reopenForumTopic({
    int? messageThreadId,
  }) async {
    _verifyInfo(
      [_chatId, _threadId(messageThreadId)],
      APIMethod.reopenForumTopic,
    );
    return await api.reopenForumTopic(
      id,
      _threadId(messageThreadId)!,
    );
  }

  /// Context aware method for deleting a forum topic [APIMethod.deleteForumTopic].
  ///
  /// If you want to delete a different forum topic, you can pass the [messageThreadId] parameter. Otherwise, the bot will delete the current forum topic.
  Future<bool> deleteForumTopic({
    int? messageThreadId,
  }) async {
    _verifyInfo(
      [_chatId, _threadId(messageThreadId)],
      APIMethod.deleteForumTopic,
    );
    return await api.deleteForumTopic(
      id,
      _threadId(messageThreadId)!,
    );
  }

  /// Context aware method for unpinning all forum topic messages [APIMethod.unpinAllForumTopicMessages].
  ///
  /// If you want to unpin all forum topic messages of a different forum topic, you can pass the [messageThreadId] parameter. Otherwise, the bot will unpin all forum topic messages of the current forum topic.
  Future<bool> unpinAllForumTopicMessages({
    int? messageThreadId,
  }) async {
    _verifyInfo(
      [_chatId, _threadId(messageThreadId)],
      APIMethod.unpinAllForumTopicMessages,
    );
    return await api.unpinAllForumTopicMessages(
      id,
      _threadId(messageThreadId)!,
    );
  }

  /// Context aware method for editing the general forum topic [APIMethod.editGeneralForumTopic].
  Future<bool> editGeneralForumTopic(
    String name,
  ) async {
    _verifyInfo([_chatId], APIMethod.editGeneralForumTopic);
    return await api.editGeneralForumTopic(
      id,
      name,
    );
  }

  /// Context aware method for closing the general forum topic [APIMethod.closeGeneralForumTopic].
  Future<bool> closeGeneralForumTopic() async {
    _verifyInfo([_chatId], APIMethod.closeGeneralForumTopic);
    return await api.closeGeneralForumTopic(id);
  }

  /// Context aware method for reopening the general forum topic [APIMethod.reopenGeneralForumTopic].
  Future<bool> reopenGeneralForumTopic() async {
    _verifyInfo([_chatId], APIMethod.reopenGeneralForumTopic);
    return await api.reopenGeneralForumTopic(id);
  }

  /// Context aware method for hiding the general forum topic [APIMethod.hideGeneralForumTopic].
  Future<bool> hideGeneralForumTopic() async {
    _verifyInfo([_chatId], APIMethod.hideGeneralForumTopic);
    return await api.hideGeneralForumTopic(id);
  }

  /// Context aware method for unhiding the general forum topic [APIMethod.unhideGeneralForumTopic].
  Future<bool> unhideGeneralForumTopic() async {
    _verifyInfo([_chatId], APIMethod.unhideGeneralForumTopic);
    return await api.unhideGeneralForumTopic(id);
  }

  /// Context aware method for unpinning all general forum topic messages [APIMethod.unpinAllGeneralForumTopicMessages].
  Future<bool> unpinAllGeneralForumTopicMessages() async {
    _verifyInfo([_chatId], APIMethod.unpinAllGeneralForumTopicMessages);
    return await api.unpinAllGeneralForumTopicMessages(id);
  }
}

/// Base handler
typedef Handler<TeleverseSession extends Session> = FutureOr<void> Function(
  Context<TeleverseSession> ctx,
);
