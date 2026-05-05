import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/cargo_repository.dart';

abstract class CargoEvent extends Equatable {
  const CargoEvent();
  @override List<Object?> get props => [];
}
class CargoLoadMine extends CargoEvent { const CargoLoadMine(); }

abstract class CargoState extends Equatable {
  const CargoState();
  @override List<Object?> get props => [];
}
class CargoInitial extends CargoState { const CargoInitial(); }
class CargoLoading extends CargoState { const CargoLoading(); }
class CargoLoaded extends CargoState {
  const CargoLoaded(this.items);
  final List<CargoRequestItem> items;
  @override List<Object?> get props => [items];
}
class CargoFailure extends CargoState {
  const CargoFailure(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

class CargoBloc extends Bloc<CargoEvent, CargoState> {
  CargoBloc(this._repo) : super(const CargoInitial()) {
    on<CargoLoadMine>((e, emit) async {
      emit(const CargoLoading());
      try {
        emit(CargoLoaded(await _repo.myRequests()));
      } catch (err) {
        emit(CargoFailure(err.toString()));
      }
    });
  }
  final CargoRepository _repo;
}
