// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../common/utils/app_util.dart';
import '../../common/utils/constants/app_constants.dart';
import '../../data/sources/local/app_database.dart';
import '../../data/sources/remote/bible/bible_api_service.dart';
import '../../domain/repos/bible/bible_annotation_repo.dart';
import '../../domain/repos/bible/bible_repo.dart';
import '../../domain/repos/bible/bible_repo_impl.dart';
import '../../domain/repos/bible/bible_tracking_repo.dart';
import '../../domain/repos/bible/scripture_repo.dart';
import '../../domain/repos/database_repo.dart';
import '../../domain/repos/database_repo_impl.dart';
import '../../features/bible/scripture_queue/cubit/scripture_queue_cubit.dart';
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
  DatabaseRepo provideDatabaseRepo(AppDatabase appDatabase) =>
      DatabaseRepoImpl(appDatabase);

  @lazySingleton
  BibleApiService provideBibleApiService() => BibleApiService();

  @lazySingleton
  BibleRepo provideBibleRepo(
    AppDatabase appDatabase,
    BibleApiService bibleApiService,
  ) =>
      BibleRepoImpl(appDatabase, bibleApiService);

  @lazySingleton
  BibleTrackingRepo provideBibleTrackingRepo(
    AppDatabase appDatabase,
  ) =>
      BibleTrackingRepo(appDatabase);

  @lazySingleton
  BibleAnnotationRepo provideBibleAnnotationRepo(
    AppDatabase appDatabase,
  ) =>
      BibleAnnotationRepo(appDatabase);

  @lazySingleton
  ScriptureRepo provideScriptureRepo(AppDatabase appDatabase) =>
      ScriptureRepo(appDatabase);

  /// Session-scoped: one shared instance for the Scripture Opener,
  /// Scripture Lists screens and the reader's floating queue widget.
  @lazySingleton
  ScriptureQueueCubit provideScriptureQueueCubit() => ScriptureQueueCubit();
}

dynamic _parseAndDecode(String response) => jsonDecode(response);

dynamic parseJson(String text) =>
    compute<String, dynamic>(_parseAndDecode, text);
