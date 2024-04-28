import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static const String socketUrl = 'http://192.168.1.15:5000';
  IO.Socket? socket;

  void initSocket() {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
  }

  void closeSocket() {
    if (socket != null) {
      socket!.disconnect();
    }
  }
}
class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  IO.Socket? _socket;

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  void initialize() {
    _socket = IO.io('https://your-backend-url'); // Replace with your Socket.IO server URL
    _socket!.onConnect((_) {
      print('Connected to Socket.IO server');
    });
    _socket!.on('reservation_success', (data) {
      // Handle reservation success event
      print('New reservation: $data');
    });
    _socket!.on('reservation_error', (data) {
      // Handle reservation error event
      print('Reservation error: $data');
    });
  }

  void emitReservation(dynamic data) {
    _socket!.emit('reservation', data);
  }

  void dispose() {
    _socket?.dispose();
  }
}