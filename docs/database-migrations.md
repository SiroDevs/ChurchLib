# Local database migrations

The local schema version is declared on `AppDatabase` in
`lib/data/sources/local/app_database.dart`. Froom runs migrations registered in
`lib/data/sources/local/migrations/database_migrations.dart` when the database
opens.

For every schema change, increase the database version and add a migration for
each supported old version to the new version. Keep migrations ordered and
preserve existing user data where possible. Froom aborts an upgrade when no
registered migration reaches the current schema version.

Regenerate the ignored database and dependency injection files after changing
the database definition or registrations:

```sh
dart run build_runner build --delete-conflicting-outputs
```
