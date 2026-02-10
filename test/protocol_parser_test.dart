/// 协议解析器测试
///
/// 测试修复后的消息解析逻辑
library;

import 'package:test/test.dart';
import 'package:clawchat/services/protocol_parser.dart';

void main() {
  group('ProtocolParser - Agent Event', () {
    test('应该正确提取 agent 事件中的 delta 增量内容', () {
      final agentEvent = {
        'type': 'event',
        'event': 'agent',
        'payload': {
          'runId': 'msg-123',
          'stream': 'assistant',
          'data': {
            'text': '可以。虽然没有专门的旅行规划技能',
            'delta': '可以',
          },
          'sessionKey': 'agent:main:main',
          'seq': 1,
        },
      };

      final parsed = ProtocolParser.parseMessage(agentEvent);

      expect(parsed.type, equals('response.chunk'));
      expect(parsed.content, equals('可以')); // 应该是 delta，不是 text
      expect(parsed.messageId, equals('msg-123'));
      expect(parsed.isComplete, isFalse);
    });

    test('应该处理空 delta 的 agent 事件', () {
      final agentEvent = {
        'type': 'event',
        'event': 'agent',
        'payload': {
          'runId': 'msg-123',
          'stream': 'assistant',
          'data': {
            'text': '完整内容',
            'delta': '',
          },
          'sessionKey': 'agent:main:main',
        },
      };

      final parsed = ProtocolParser.parseMessage(agentEvent);

      expect(parsed.type, equals('response.chunk'));
      expect(parsed.content, equals(''));
      expect(parsed.isComplete, isFalse);
    });

    test('应该处理没有 data 的 agent 事件', () {
      final agentEvent = {
        'type': 'event',
        'event': 'agent',
        'payload': {
          'runId': 'msg-123',
          'stream': 'assistant',
          'sessionKey': 'agent:main:main',
        },
      };

      final parsed = ProtocolParser.parseMessage(agentEvent);

      expect(parsed.type, equals('response.chunk'));
      expect(parsed.content, isNull);
      expect(parsed.isComplete, isFalse);
    });
  });

  group('ProtocolParser - Chat Event', () {
    test('应该正确解析 chat delta 事件（不提取内容）', () {
      final chatDeltaEvent = {
        'type': 'event',
        'event': 'chat',
        'payload': {
          'runId': 'msg-123',
          'sessionKey': 'agent:main:main',
          'state': 'delta',
          'message': {
            'role': 'assistant',
            'content': [
              {'type': 'text', 'text': '可以。虽然没有专门的旅行规划技能'}
            ],
          },
        },
      };

      final parsed = ProtocolParser.parseMessage(chatDeltaEvent);

      expect(parsed.type, equals('response.chunk'));
      expect(parsed.content, isNull); // delta 状态不应该提取内容
      expect(parsed.messageId, equals('msg-123'));
      expect(parsed.isComplete, isFalse);
    });

    test('应该正确解析 chat final 事件（提取完整内容）', () {
      final chatFinalEvent = {
        'type': 'event',
        'event': 'chat',
        'payload': {
          'runId': 'msg-123',
          'sessionKey': 'agent:main:main',
          'state': 'final',
          'message': {
            'role': 'assistant',
            'content': [
              {
                'type': 'text',
                'text': '可以。虽然没有专门的旅行规划技能，但可以帮你做：\n\n1. **搜索信息**'
              }
            ],
          },
        },
      };

      final parsed = ProtocolParser.parseMessage(chatFinalEvent);

      expect(parsed.type, equals('response.complete'));
      expect(parsed.content, isNotNull);
      expect(parsed.content, contains('可以。虽然没有专门的旅行规划技能'));
      expect(parsed.messageId, equals('msg-123'));
      expect(parsed.isComplete, isTrue);
    });
  });

  group('StreamingAccumulator', () {
    test('应该正确累积多个消息块', () {
      final accumulator = StreamingAccumulator('msg-123');

      accumulator.addChunk('可以');
      expect(accumulator.fullContent, equals('可以'));

      accumulator.addChunk('。');
      expect(accumulator.fullContent, equals('可以。'));

      accumulator.addChunk('虽然');
      expect(accumulator.fullContent, equals('可以。虽然'));

      expect(accumulator.length, equals(5)); // 5个字符：可以。虽然
    });

    test('应该处理空字符串块', () {
      final accumulator = StreamingAccumulator('msg-123');

      accumulator.addChunk('Hello');
      accumulator.addChunk('');
      accumulator.addChunk('World');

      expect(accumulator.fullContent, equals('HelloWorld'));
    });

    test('应该正确清空内容', () {
      final accumulator = StreamingAccumulator('msg-123');

      accumulator.addChunk('Some content');
      expect(accumulator.isEmpty, isFalse);

      accumulator.clear();
      expect(accumulator.isEmpty, isTrue);
      expect(accumulator.fullContent, equals(''));
    });
  });

  group('消息流程模拟', () {
    test('应该模拟完整的流式消息接收流程', () {
      final accumulator = StreamingAccumulator('msg-123');

      // 模拟接收多个 agent delta 事件
      final deltas = ['可以', '。', '虽然', '没有', '专门的', '旅行', '规划', '技能'];

      for (final delta in deltas) {
        final agentEvent = {
          'type': 'event',
          'event': 'agent',
          'payload': {
            'runId': 'msg-123',
            'stream': 'assistant',
            'data': {'delta': delta},
            'sessionKey': 'agent:main:main',
          },
        };

        final parsed = ProtocolParser.parseMessage(agentEvent);
        expect(parsed.content, equals(delta));
        accumulator.addChunk(parsed.content!);
      }

      // 验证累积结果
      expect(accumulator.fullContent, equals('可以。虽然没有专门的旅行规划技能'));

      // 模拟接收 chat final 事件
      final chatFinalEvent = {
        'type': 'event',
        'event': 'chat',
        'payload': {
          'runId': 'msg-123',
          'sessionKey': 'agent:main:main',
          'state': 'final',
          'message': {
            'role': 'assistant',
            'content': [
              {'type': 'text', 'text': '可以。虽然没有专门的旅行规划技能'}
            ],
          },
        },
      };

      final finalParsed = ProtocolParser.parseMessage(chatFinalEvent);
      expect(finalParsed.isComplete, isTrue);
      expect(finalParsed.content, equals(accumulator.fullContent));
    });
  });
}
