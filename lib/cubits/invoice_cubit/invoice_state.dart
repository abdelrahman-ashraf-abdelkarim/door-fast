
abstract class InvoiceState {}

class InvoiceInitial extends InvoiceState {}
class InvoiceLoading extends InvoiceState {}
class InvoiceSuccess extends InvoiceState {}
class InvoiceError extends InvoiceState {
  final String message;
  InvoiceError(this.message);
}