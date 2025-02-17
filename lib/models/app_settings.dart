import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@Collection()
class AppSettings {
  Id id = Isar.autoIncrement;

  bool isFirstLaunch = true;
  String selectedLanguage = 'en';

  AppSettings({
    this.isFirstLaunch = true,
    this.selectedLanguage = 'en',
  });
}
