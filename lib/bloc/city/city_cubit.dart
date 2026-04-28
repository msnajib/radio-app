import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/hive_datasource.dart';

class CityCubit extends Cubit<String?> {
  final HiveDatasource _datasource;

  CityCubit({required HiveDatasource datasource})
      : _datasource = datasource,
        super(datasource.getSelectedCity());

  void selectCity(String? city) {
    if (state == city) return;
    emit(city);
    _datasource.saveSelectedCity(city);
  }
}
