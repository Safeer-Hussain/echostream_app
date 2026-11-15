import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/live_room.dart';
import '../../../domain/repositories/live_room_repository.dart';

// Events
abstract class LiveRoomEvent extends Equatable {
  const LiveRoomEvent();
  @override
  List<Object?> get props => [];
}

class LoadLiveRoomsEvent extends LiveRoomEvent {}

class SelectLiveRoomEvent extends LiveRoomEvent {
  final String roomId;
  const SelectLiveRoomEvent(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class HostLiveRoomEvent extends LiveRoomEvent {
  final String title;
  final String topicTag;
  final String hostName;
  const HostLiveRoomEvent({
    required this.title,
    required this.topicTag,
    required this.hostName,
  });
  @override
  List<Object?> get props => [title, topicTag, hostName];
}

class ToggleRaiseHandEvent extends LiveRoomEvent {
  final String roomId;
  const ToggleRaiseHandEvent(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class SendReactionEvent extends LiveRoomEvent {
  final String roomId;
  final String reactionType; // applaud, insightful, question
  const SendReactionEvent(this.roomId, this.reactionType);
  @override
  List<Object?> get props => [roomId, reactionType];
}

class SendChatMessageEvent extends LiveRoomEvent {
  final String roomId;
  final String message;
  final String senderName;
  const SendChatMessageEvent({
    required this.roomId,
    required this.message,
    required this.senderName,
  });
  @override
  List<Object?> get props => [roomId, message, senderName];
}

class PromoteParticipantEvent extends LiveRoomEvent {
  final String roomId;
  final String participantName;
  const PromoteParticipantEvent(this.roomId, this.participantName);
  @override
  List<Object?> get props => [roomId, participantName];
}

// State
class LiveRoomState extends Equatable {
  final List<LiveRoom> rooms;
  final LiveRoom? activeRoom;
  final bool isLoading;
  final String? errorMessage;

  const LiveRoomState({
    this.rooms = const [],
    this.activeRoom,
    this.isLoading = false,
    this.errorMessage,
  });

  LiveRoomState copyWith({
    List<LiveRoom>? rooms,
    LiveRoom? activeRoom,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LiveRoomState(
      rooms: rooms ?? this.rooms,
      activeRoom: activeRoom ?? this.activeRoom,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [rooms, activeRoom, isLoading, errorMessage];
}

// BLoC
class LiveRoomBloc extends Bloc<LiveRoomEvent, LiveRoomState> {
  final LiveRoomRepository _liveRoomRepository;

  LiveRoomBloc({required LiveRoomRepository liveRoomRepository})
    : _liveRoomRepository = liveRoomRepository,
      super(const LiveRoomState()) {
    on<LoadLiveRoomsEvent>(_onLoadLiveRooms);
    on<SelectLiveRoomEvent>(_onSelectLiveRoom);
    on<HostLiveRoomEvent>(_onHostLiveRoom);
    on<ToggleRaiseHandEvent>(_onToggleRaiseHand);
    on<SendReactionEvent>(_onSendReaction);
    on<SendChatMessageEvent>(_onSendChatMessage);
    on<PromoteParticipantEvent>(_onPromoteParticipant);
  }

  Future<void> _onLoadLiveRooms(
    LoadLiveRoomsEvent event,
    Emitter<LiveRoomState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final rooms = await _liveRoomRepository.getLiveRooms();
      LiveRoom? currentActive = state.activeRoom;
      if (currentActive != null) {
        try {
          currentActive = rooms.firstWhere((r) => r.id == currentActive!.id);
        } catch (_) {}
      }
      emit(
        state.copyWith(
          rooms: rooms,
          activeRoom: currentActive,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSelectLiveRoom(
    SelectLiveRoomEvent event,
    Emitter<LiveRoomState> emit,
  ) async {
    try {
      final room = await _liveRoomRepository.getRoomById(event.roomId);
      emit(state.copyWith(activeRoom: room));
    } catch (_) {}
  }

  Future<void> _onHostLiveRoom(
    HostLiveRoomEvent event,
    Emitter<LiveRoomState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _liveRoomRepository.hostRoom(
      title: event.title,
      topicTag: event.topicTag,
      hostName: event.hostName,
    );
    final rooms = await _liveRoomRepository.getLiveRooms();
    emit(
      state.copyWith(
        rooms: rooms,
        activeRoom: rooms.isNotEmpty ? rooms.last : null,
        isLoading: false,
      ),
    );
  }

  Future<void> _onToggleRaiseHand(
    ToggleRaiseHandEvent event,
    Emitter<LiveRoomState> emit,
  ) async {
    if (state.activeRoom == null) return;
    final room = state.activeRoom!;
    final nextRaised = !room.isUserHandRaised;

    // Immediately toggle hand raise and promote user if raised
    if (nextRaised) {
      await _liveRoomRepository.promoteToSpeaker(
        event.roomId,
        'Safeer Hussain (You)',
      );
    } else {
      await _liveRoomRepository.toggleRaiseHand(event.roomId, false);
    }

    final updatedRoom = await _liveRoomRepository.getRoomById(event.roomId);
    final rooms = await _liveRoomRepository.getLiveRooms();
    emit(state.copyWith(rooms: rooms, activeRoom: updatedRoom));
  }

  Future<void> _onSendReaction(
    SendReactionEvent event,
    Emitter<LiveRoomState> emit,
  ) async {
    await _liveRoomRepository.incrementReaction(
      event.roomId,
      event.reactionType,
    );
    final updatedRoom = await _liveRoomRepository.getRoomById(event.roomId);
    if (updatedRoom != null) {
      final updatedList = state.rooms
          .map((r) => r.id == updatedRoom.id ? updatedRoom : r)
          .toList();
      emit(state.copyWith(rooms: updatedList, activeRoom: updatedRoom));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessageEvent event,
    Emitter<LiveRoomState> emit,
  ) async {
    final msg = LiveChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderName: event.senderName,
      message: event.message,
      timestamp: DateTime.now().toIso8601String().substring(11, 16),
    );
    await _liveRoomRepository.sendChatMessage(event.roomId, msg);
    final updatedRoom = await _liveRoomRepository.getRoomById(event.roomId);
    if (updatedRoom != null) {
      emit(state.copyWith(activeRoom: updatedRoom));
    }
  }

  Future<void> _onPromoteParticipant(
    PromoteParticipantEvent event,
    Emitter<LiveRoomState> emit,
  ) async {
    await _liveRoomRepository.promoteToSpeaker(
      event.roomId,
      event.participantName,
    );
    final updatedRoom = await _liveRoomRepository.getRoomById(event.roomId);
    final rooms = await _liveRoomRepository.getLiveRooms();
    emit(state.copyWith(rooms: rooms, activeRoom: updatedRoom));
  }
}
