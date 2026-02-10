/// 协议解析器
///
/// 解析 OpenClaw Gateway 的消息协议
library;

import '../models/message.dart';
import '../utils/constants.dart';

/// 协议解析结果
class ParsedMessage {
  final String type;
  final String? content;
  final String? messageId;
  final String? sessionId;
  final bool isComplete;
  final Map<String, dynamic> raw;

  const ParsedMessage({
    required this.type,
    this.content,
    this.messageId,
    this.sessionId,
    this.isComplete = false,
    required this.raw,
  });

  /// 是否为流式消息块
  bool get isStreamChunk => type == ProtocolConstants.typeResponseChunk;
}

/// 协议解析器
class ProtocolParser {
  ProtocolParser._();

  /// 解析接收到的消息
  static ParsedMessage parse(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final event = data['event'] as String?;

    // 处理 OpenClaw Gateway 的 chat 事件
    if (type == 'event' && event == 'chat') {
      return _parseChatEvent(data);
    }

    // 处理 OpenClaw Gateway 的 agent 事件
    if (type == 'event' && event == 'agent') {
      return _parseAgentEvent(data);
    }

    switch (type) {
      case ProtocolConstants.typeResponseChunk:
        return _parseResponseChunk(data);

      case ProtocolConstants.typeResponseComplete:
        return _parseResponseComplete(data);

      case ProtocolConstants.typeToolCall:
        return _parseToolCall(data);

      case ProtocolConstants.typeSessionUpdate:
        return _parseSessionUpdate(data);

      case ProtocolConstants.typeTyping:
        return _parseTyping(data);

      case ProtocolConstants.typeError:
        return _parseError(data);

      default:
        return ParsedMessage(type: type, raw: data);
    }
  }

  /// 解析接收到的消息（别名，用于兼容）
  static ParsedMessage parseMessage(Map<String, dynamic> data) {
    return parse(data);
  }

  /// 解析响应块（流式响应）
  static ParsedMessage _parseResponseChunk(Map<String, dynamic> data) {
    return ParsedMessage(
      type: ProtocolConstants.typeResponseChunk,
      content: data['chunk'] as String? ?? data['content'] as String?,
      messageId: data['messageId'] as String?,
      sessionId: data['sessionId'] as String?,
      isComplete: false,
      raw: data,
    );
  }

  /// 解析响应完成
  static ParsedMessage _parseResponseComplete(Map<String, dynamic> data) {
    return ParsedMessage(
      type: ProtocolConstants.typeResponseComplete,
      content: data['content'] as String?,
      messageId: data['messageId'] as String?,
      sessionId: data['sessionId'] as String?,
      isComplete: true,
      raw: data,
    );
  }

  /// 解析工具调用
  static ParsedMessage _parseToolCall(Map<String, dynamic> data) {
    final toolName = data['tool'] as String? ?? 'unknown';
    final toolArgs = data['args'] as Map<String, dynamic>?;

    return ParsedMessage(
      type: ProtocolConstants.typeToolCall,
      content: '🔧 调用工具: $toolName',
      messageId: data['messageId'] as String?,
      sessionId: data['sessionId'] as String?,
      raw: data,
    );
  }

  /// 解析会话更新
  static ParsedMessage _parseSessionUpdate(Map<String, dynamic> data) {
    return ParsedMessage(
      type: ProtocolConstants.typeSessionUpdate,
      sessionId: data['sessionId'] as String?,
      raw: data,
    );
  }

  /// 解析正在输入
  static ParsedMessage _parseTyping(Map<String, dynamic> data) {
    return ParsedMessage(
      type: ProtocolConstants.typeTyping,
      raw: data,
    );
  }

  /// 解析错误
  static ParsedMessage _parseError(Map<String, dynamic> data) {
    return ParsedMessage(
      type: ProtocolConstants.typeError,
      content: data['error'] as String? ?? data['message'] as String?,
      raw: data,
    );
  }

  /// 解析 OpenClaw Gateway 的 chat 事件
  static ParsedMessage _parseChatEvent(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>?;
    if (payload == null) {
      return ParsedMessage(type: 'chat', raw: data);
    }

    final state = payload['state'] as String?;
    final message = payload['message'] as Map<String, dynamic>?;
    final runId = payload['runId'] as String?;
    final sessionKey = payload['sessionKey'] as String?;

    // 判断是否为完整消息
    final isComplete = state == 'final';

    // 只有在 final 状态时才提取完整内容
    String? content;
    if (isComplete && message != null) {
      final contentList = message['content'] as List?;
      if (contentList != null && contentList.isNotEmpty) {
        final firstContent = contentList[0] as Map<String, dynamic>?;
        if (firstContent != null && firstContent['type'] == 'text') {
          content = firstContent['text'] as String?;
        }
      }
    }

    return ParsedMessage(
      type: isComplete
          ? ProtocolConstants.typeResponseComplete
          : ProtocolConstants.typeResponseChunk,
      content: content,
      messageId: runId,
      sessionId: sessionKey,
      isComplete: isComplete,
      raw: data,
    );
  }

  /// 解析 OpenClaw Gateway 的 agent 事件
  static ParsedMessage _parseAgentEvent(Map<String, dynamic> data) {
    final payload = data['payload'] as Map<String, dynamic>?;
    if (payload == null) {
      return ParsedMessage(type: 'agent', raw: data);
    }

    final stream = payload['stream'] as String?;
    final eventData = payload['data'] as Map<String, dynamic>?;
    final runId = payload['runId'] as String?;
    final sessionKey = payload['sessionKey'] as String?;

    // agent 事件包含 delta（增量内容）
    String? content;
    if (eventData != null && stream == 'assistant') {
      // 提取 delta 字段（增量内容）
      content = eventData['delta'] as String?;
    }

    // agent 事件都是流式消息块（增量更新）
    return ParsedMessage(
      type: ProtocolConstants.typeResponseChunk,
      content: content,
      messageId: runId,
      sessionId: sessionKey,
      isComplete: false,
      raw: data,
    );
  }

  /// 构建发送消息的 JSON
  static Map<String, dynamic> buildUserMessage({
    required String content,
    String? agentId,
    String thinking = ProtocolConstants.thinkingHigh,
  }) {
    return {
      'type': ProtocolConstants.typeAgentProcess,
      'message': content,
      'thinking': thinking,
      if (agentId != null) 'agentId': agentId,
    };
  }

  /// 创建消息负载（别名，用于兼容）
  static Map<String, dynamic> createMessagePayload({
    required String content,
    String? agentId,
    String thinking = ProtocolConstants.thinkingHigh,
  }) {
    return buildUserMessage(
      content: content,
      agentId: agentId,
      thinking: thinking,
    );
  }

  /// 构建认证消息
  static Map<String, dynamic> buildAuthMessage(String password) {
    return {
      'type': ProtocolConstants.typeAuth,
      'mode': ProtocolConstants.authModePassword,
      'password': password,
    };
  }

  /// 构建 connect 请求（符合 OpenClaw Gateway 规范）
  static Map<String, dynamic> buildConnectRequest({
    required String token,
    required String role,
    required List<String> scopes,
    int minProtocol = 3,
    int maxProtocol = 3,
    String clientId = 'flutter-app',
    String clientVersion = '1.0.0',
    String clientPlatform = 'flutter',
  }) {
    return {
      'type': ProtocolConstants.typeRequest,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'method': ProtocolConstants.methodConnect,
      'params': {
        'minProtocol': minProtocol,
        'maxProtocol': maxProtocol,
        'client': {
          'id': clientId,
          'version': clientVersion,
          'platform': clientPlatform,
        },
        'role': role,
        'scopes': scopes,
        'auth': {
          'token': token,
        },
      },
    };
  }

  /// 将 ParsedMessage 转换为 Message 模型
  static Message? toMessage(ParsedMessage parsed) {
    if (parsed.content == null) return null;

    return Message.ai(
      id: parsed.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: parsed.content!,
      sessionId: parsed.sessionId,
    );
  }

  /// 检查消息是否为流式响应的一部分
  static bool isStreamingChunk(String type) {
    return type == ProtocolConstants.typeResponseChunk;
  }

  /// 检查消息是否为完整响应
  static bool isCompleteResponse(String type) {
    return type == ProtocolConstants.typeResponseComplete;
  }

  /// 检查消息是否为错误
  static bool isError(String type) {
    return type == ProtocolConstants.typeError;
  }

  /// 检查消息是否为工具调用
  static bool isToolCall(String type) {
    return type == ProtocolConstants.typeToolCall;
  }
}

/// 流式消息累加器
///
/// 用于累积流式响应的多个块
class StreamingAccumulator {
  final String messageId;
  final StringBuffer _buffer = StringBuffer();
  DateTime lastUpdate = DateTime.now();

  StreamingAccumulator(this.messageId);

  /// 添加内容块
  void addChunk(String chunk) {
    _buffer.write(chunk);
    lastUpdate = DateTime.now();
  }

  /// 获取当前累积的内容
  String get content => _buffer.toString();

  /// 获取完整内容（别名，用于兼容）
  String get fullContent => content;

  /// 获取内容长度
  int get length => _buffer.length;

  /// 清空内容
  void clear() {
    _buffer.clear();
  }

  /// 是否为空
  bool get isEmpty => _buffer.isEmpty;

  /// 转换为 Message
  Message toMessage({String? sessionId}) {
    return Message.ai(
      id: messageId,
      content: content,
      sessionId: sessionId,
    );
  }
}
