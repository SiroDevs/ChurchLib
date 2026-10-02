import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/sources/local/app_database.dart';
import '../../data/sources/remote/bible/bible_api_service.dart';
import '../../data/repositories/bible/bible_annotation_repository.dart';
import '../../data/repositories/bible/bible_repository.dart';
import '../../data/repositories/bible/bible_repository_impl.dart';
import '../../data/repositories/bible/bible_tracking_repository.dart';
import '../../data/repositories/database_repository_impl.dart';
import '../../data/repositories/database_repository.dart';
import '../../data/repositories/bible/scripture_repository.dart';
import '../../presentation/blocs/scripture/scripture_queue_cubit.dart';
import '../utils/app_util.dart';
import '../utils/constants/app_constants.dart';
import 'injectable.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'initGetIt',
  generateForDir: ['lib'],
)
Future<void> configureDependencies(String environment) async {
  logger('Using environment: $environment');
  await getIt.initGetIt(environment: environment);
  await getIt.allReady();
}

@module
abstract class RegisterModule {
  @singleton
  @preResolve
  Future<SharedPreferences> prefRepo() => SharedPreferences.getInstance();

  @singleton
  @preResolve
  Future<AppDatabase> provideAppDatabase() async => await $FroomAppDatabase
      .databaseBuilder(await AppConstants.databaseFile)
      .build();

  @lazySingleton
  DatabaseRepository provideDatabaseRepository(AppDatabase appDatabase) =>
      DatabaseRepositoryImpl(appDatabase);

  @lazySingleton
  BibleApiService provideBibleApiService() => BibleApiService();

  @lazySingleton
  BibleRepository provideBibleRepository(
    AppDatabase appDatabase,
    BibleApiService bibleApiService,
  ) =>
      BibleRepositoryImpl(appDatabase, bibleApiService);

  @lazySingleton
  BibleTrackingRepository provideBibleTrackingRepository(
    AppDatabase appDatabase,
  ) =>
      BibleTrackingRepository(appDatabase);

  @lazySingleton
  BibleAnnotationRepository provideBibleAnnotationRepository(
    AppDatabase appDatabase,
  ) =>
      BibleAnnotationRepository(appDatabase);

  @lazySingleton
  ScriptureRepository provideScriptureRepository(AppDatabase appDatabase) =>
      ScriptureRepository(appDatabase);

  /// Session-scoped: one shared instance for the Scripture Opener,
  /// Scripture Lists screens and the reader's floating queue widget.
  @lazySingleton
  ScriptureQueueCubit provideScriptureQueueCubit() => ScriptureQueueCubit();
}

dynamic _parseAndDecode(String response) => jsonDecode(response);

dynamic parseJson(String text) =>
    compute<String, dynamic>(_parseAndDecode, text);
