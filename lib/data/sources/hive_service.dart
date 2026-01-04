import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';
import '../models/product_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
    await Hive.openBox<ProductModel>(AppConstants.cartBox);
    await Hive.openBox<int>(AppConstants.cartQuantitiesBox);
  }
}