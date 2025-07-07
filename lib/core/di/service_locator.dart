import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../entities/batch_entity.dart';
import '../entities/addition_entity.dart';
import '../entities/death_entity.dart';
import '../entities/sale_entity.dart';
import '../repositories/batch_repository.dart';
import '../repositories/addition_repository.dart';
import '../repositories/death_repository.dart';
import '../repositories/sale_repository.dart';
import '../usecases/batch_usecases.dart';
import '../usecases/addition_usecases.dart';
import '../usecases/death_usecases.dart';
import '../usecases/sale_usecases.dart';
import '../../features/batches/cubit/batches_cubit.dart';
import '../../features/additions/cubit/additions_cubit.dart';
import '../../features/deaths/cubit/deaths_cubit.dart';
import '../../features/sales/cubit/sales_cubit.dart';
import '../services/sync_queue.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(BatchEntityAdapter());
  Hive.registerAdapter(AdditionEntityAdapter());
  Hive.registerAdapter(DeathEntityAdapter());
  Hive.registerAdapter(SaleEntityAdapter());
  Hive.registerAdapter(SyncQueueItemAdapter());

  // Repositories
  sl.registerLazySingleton<IBatchRepository>(() => BatchRepository());
  sl.registerLazySingleton<IAdditionRepository>(() => AdditionRepository());
  sl.registerLazySingleton<IDeathRepository>(() => DeathRepository());
  sl.registerLazySingleton<ISaleRepository>(() => SaleRepository());

  // Batch Use Cases
  sl.registerLazySingleton(() => GetBatchesUseCase(sl()));
  sl.registerLazySingleton(() => AddBatchUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBatchUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBatchUseCase(sl()));
  sl.registerLazySingleton(
    () => GetBatchStatisticsUseCase(
      batchRepository: sl(),
      additionRepository: sl(),
      deathRepository: sl(),
      saleRepository: sl(),
    ),
  );

  // Addition Use Cases
  sl.registerLazySingleton(() => GetAdditionsUseCase(sl()));
  sl.registerLazySingleton(() => AddAdditionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAdditionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAdditionUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalAdditionsCostUseCase(sl()));

  // Death Use Cases
  sl.registerLazySingleton(() => GetDeathsUseCase(sl()));
  sl.registerLazySingleton(() => AddDeathUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeathUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDeathUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalDeathsCountUseCase(sl()));

  // Sale Use Cases
  sl.registerLazySingleton(() => GetSalesUseCase(sl()));
  sl.registerLazySingleton(() => AddSaleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSaleUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSaleUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalSoldCountUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalSalesAmountUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => BatchesCubit(
      getBatchesUseCase: sl(),
      addBatchUseCase: sl(),
      updateBatchUseCase: sl(),
      deleteBatchUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AdditionsCubit(
      getAdditionsUseCase: sl(),
      addAdditionUseCase: sl(),
      updateAdditionUseCase: sl(),
      deleteAdditionUseCase: sl(),
      getTotalAdditionsCostUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => DeathsCubit(
      getDeathsUseCase: sl(),
      addDeathUseCase: sl(),
      updateDeathUseCase: sl(),
      deleteDeathUseCase: sl(),
      getTotalDeathsCountUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SalesCubit(
      getSalesUseCase: sl(),
      addSaleUseCase: sl(),
      updateSaleUseCase: sl(),
      deleteSaleUseCase: sl(),
      getTotalSoldCountUseCase: sl(),
      getTotalSalesAmountUseCase: sl(),
    ),
  );
}
