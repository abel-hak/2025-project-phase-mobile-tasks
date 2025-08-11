import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message_model.dart';

/// Abstract class defining the contract for chat socket operations
abstract class ChatSocketDataSource {
  /// Connects to the socket server with the given authentication token
  void connect(String token);

  /// Disconnects from the socket server
  void disconnect();

  /// Sends a message through the socket connection
  void sendMessage(MessageModel message);

  /// Stream of received messages
  Stream<MessageModel> onMessageReceived();

  /// Stream of message delivery confirmations
  Stream<MessageModel> onMessageDelivered();

  /// Stream of socket connection state changes
  Stream<bool> onConnectionStateChanged();

  /// Current connection state
  bool get isConnected;
}

/// Implementation of [ChatSocketDataSource] using Socket.IO client
class ChatSocketDataSourceImpl implements ChatSocketDataSource {
  final String baseSocketUrl;
  final String socketNamespace;

  bool _isConnected = false;
  bool _namespaceJoined = false;
  IO.Socket? _socket;
  static const int maxReconnectAttempts = 5;

  // Message controllers
  final _messageReceivedController = StreamController<MessageModel>.broadcast();
  final _messageDeliveredController = StreamController<MessageModel>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _pendingMessages = <MessageModel>[];

  ChatSocketDataSourceImpl(this.baseSocketUrl, {required this.socketNamespace});

  @override
  bool get isConnected => _isConnected;

  @override
  void connect(String token) {
    try {
      // If already connected, don't reconnect
      if (_isConnected && _socket != null) {
        print('🔌 Socket already connected');
        return;
      }

      // Cleanup existing socket if any
      if (_socket != null) {
        print('🔌 Socket exists, cleaning up first...');
        disconnect();
      }

      print('🔌 Connecting socket with token: $token');

      // Create socket instance
      _socket = IO.io(
        baseSocketUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            .setPath('/socket.io')
            .setAuth({'token': token})
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            })
            .enableForceNew()
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(maxReconnectAttempts)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(20000)
            .build(),
      );

      // Setup listeners before connecting
      _setupSocketListeners();

      // Connect after setup
      _socket?.connect();

      print('🔌 Socket initialized, waiting for connection...');
    } catch (e, stackTrace) {
      print('❌ Error initializing socket: $e');
      print('❌ Stack trace: $stackTrace');
      _handleConnectionError('Failed to initialize socket: $e');
    }
  }

  Map<String, dynamic> _createSocketOptions(String token) {
    return {
      'transports': ['websocket'],
      'path': '/socket.io',
      'auth': {'token': token},
      'extraHeaders': {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      'forceNew': true,
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': maxReconnectAttempts,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'timeout': 20000,
      'nsp': '/api/v3',
    };
  }

  void _setupSocketListeners() {
    print('🔌 Socket initialized, setting up listeners...');

    // Debug handlers for all events
    _socket?.onAny((event, data) {
      print('💬 Socket.IO event: $event, data: $data');
    });

    // Connection state change handlers
    _socket?.onConnect((_) {
      print('🔌 Socket connected, joining namespace...');
      _socket?.emit('join', {'namespace': socketNamespace});
      _handleConnect();
    });

    _socket?.onDisconnect((_) => _handleDisconnect('Socket disconnected'));
    _socket?.onConnectError((err) => _handleError(err));
    _socket?.onError((err) => _handleError(err));

    // Namespace join handlers
    _socket?.on('join_success', (_) {
      print('🔌 Successfully joined namespace: $socketNamespace');
      _namespaceJoined = true;
      _isConnected = true;
      // Send any pending messages
      _sendPendingMessages();
    });

    _socket?.on('join_error', (error) {
      print('❌ Error joining namespace: $error');
      _namespaceJoined = false;
      _handleError('Failed to join namespace: $error');
    });

    // Message handlers
    _socket?.on('message:delivered', (data) {
      print('🔉 Message delivered: $data');
      try {
        if (data is Map<String, dynamic>) {
          final message = MessageModel.fromJson(data);
          _messageDeliveredController.add(message);
        }
      } catch (e) {
        print('❌ Error parsing delivered message: $e');
      }
    });

    _socket?.on('message:received', (data) {
      print('🔈 Message received: $data');
      try {
        if (data is Map<String, dynamic>) {
          final message = MessageModel.fromJson(data);
          _messageReceivedController.add(message);
        }
      } catch (e) {
        print('❌ Error parsing received message: $e');
      }
    });

    // Room join handlers
    _socket?.on('room:joined', (data) {
      print('🔌 Joined chat room: $data');
    });

    _socket?.on('room:error', (error) {
      print('❌ Error joining chat room: $error');
      _handleError('Failed to join chat room: $error');
    });
  }

  void _handleConnect() {
    print('🔌 Socket Connected');
    _isConnected = true;
    _connectionController.add(true);
  }

  void _handleDisconnect(String reason) {
    print('🔌 Socket Disconnected: $reason');
    _isConnected = false;
    _connectionController.add(false);
  }

  void _handleConnectionError(String error) {
    print('❌ $error');
    _isConnected = false;
    _connectionController.add(false);
  }

  void _handleError(dynamic error) {
    print('❌ Socket.IO Error: $error');
    _isConnected = false;
    _connectionController.add(false);

    // Try to reconnect if not connected
    if (!_isConnected) {
      print('🔌 Attempting to reconnect...');
      _socket?.connect();
    }
  }

  void _sendPendingMessages() {
    if (_pendingMessages.isEmpty) return;
    print('💬 Sending ${_pendingMessages.length} pending messages...');
    for (final message in _pendingMessages) {
      _sendMessageNow(message);
    }
    _pendingMessages.clear();
  }

  void _sendMessageNow(MessageModel message) {
    final payload = jsonEncode(message.toJson());
    print('💬 Sending message: $payload');
    _socket?.emit('message:send', message.toJson());
  }

  @override
  void sendMessage(MessageModel message) {
    if (!_isConnected || _socket == null) {
      throw Exception('Socket not connected');
    }

    if (!_namespaceJoined) {
      print('💬 Queuing message until namespace join is confirmed...');
      _pendingMessages.add(message);
      return;
    }

    _sendMessageNow(message);
  }

  @override
  Stream<MessageModel> onMessageReceived() => _messageReceivedController.stream;

  @override
  Stream<MessageModel> onMessageDelivered() =>
      _messageDeliveredController.stream;

  @override
  Stream<bool> onConnectionStateChanged() => _connectionController.stream;

  @override
  void disconnect() {
    print('🔌 Disconnecting socket...');
    try {
      _socket?.clearListeners();
      _socket?.dispose();
      _socket = null;
      _isConnected = false;
      _connectionController.add(false);
      print('🔌 Socket disconnected successfully');
    } catch (e, stackTrace) {
      print('❌ Error during socket cleanup: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }
}
