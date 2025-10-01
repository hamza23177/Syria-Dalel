abstract class ServiceEvent {}

class LoadServiceDetails extends ServiceEvent {
  final int id;
  LoadServiceDetails(this.id);
}
