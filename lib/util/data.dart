import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nyxx/nyxx.dart';
import 'package:path/path.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_discord_bot/handlers/music_handler.dart';
import 'package:rpmtw_discord_bot/model/covid19_info.dart';
import 'package:rpmtw_discord_bot/util/log.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';

final Snowflake rpmtwDiscordServerID = 815819580840607807.toSnowflake();
final Snowflake logChannelID = 934595900528025640.toSnowflake();
final Snowflake chatChannelID = 815819581440262146.toSnowflake();
final Snowflake siongsngUserID = 645588343228334080.toSnowflake();
final Snowflake voiceChannelID = 832895058281758740.toSnowflake();

late final INyxxWebsocket _client;
INyxxWebsocket get dcClient => _client;

late final BotLogger _logger;
BotLogger get logger => _logger;
late bool kDebugMode;

class Data {
  static late final Box _chefBox;
  static late final Box _covid19Box;
  static late final DotEnv _dotEnv;

  static Box get chefBox => _chefBox;
  static Box get covid19Box => _covid19Box;
  static DotEnv get dotEnv => _dotEnv;

  static Future<void> init() async {
    _dotEnv = DotEnv(includePlatformEnvironment: true)..load();
    RPMTWApiClient.init();
    String path = absolute(Directory.current.path, 'data');
    Hive.init(path);
    Hive.registerAdapter(Covid19InfoAdapter());
    _chefBox = await Hive.openBox('chefBox');
    _covid19Box = await Hive.openBox('covid19Box');
    await initializeDateFormatting('zh-TW');

    kDebugMode = dotEnv['DEBUG_MODE']?.toBool() ?? false;
  }

  static Future<void> initOnReady(INyxxWebsocket client) async {
    _client = client;

    ITextChannel channel =
        await dcClient.fetchChannel<ITextChannel>(logChannelID);
    _logger = BotLogger(channel);
    await MusicHandler.init();
  }
}
