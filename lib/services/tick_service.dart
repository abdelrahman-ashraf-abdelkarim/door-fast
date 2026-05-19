// [FIX-19] shared tick stream to replace individual timers
class TickService {
  static final Stream<int> tickStream = Stream.periodic(
    const Duration(seconds: 1),
    (tick) => tick,
  ).asBroadcastStream();
}
