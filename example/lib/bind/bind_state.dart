// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class BindState extends Equatable {
  final String name;
  final String address;
  final double age;

  const BindState({
    this.name = "",
    this.address = "",
    this.age = 0.0,
  });

  bool get isComplete => name.isNotEmpty && address.isNotEmpty && age >= 18;

  @override
  List<Object?> get props => [name, address, age];

  BindState copyWith({
    String? name,
    String? address,
    double? age,
  }) {
    return BindState(
      name: name ?? this.name,
      address: address ?? this.address,
      age: age ?? this.age,
    );
  }
}
