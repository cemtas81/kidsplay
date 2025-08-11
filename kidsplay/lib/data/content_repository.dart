import 'dart:async';
import 'package:flutter/services.dart' show rootBundle, AssetBundle, FlutterError;

import '../models/hobby.dart';
import '../models/skill.dart';
import '../models/tool.dart';
import '../models/activity.dart';

/// Loads content from assets/data/*.json
class ContentRepository {
  static final ContentRepository instance = ContentRepository._();

  ContentRepository._({
    AssetBundle? bundle,
    String? hobbiesPath,
    String? skillsPath,
    String? toolsPath,
    String? activitiesPath,
    String? activityFallbackPath,
  })  : _bundle = bundle ?? rootBundle,
        _hobbiesPath = hobbiesPath ?? 'assets/data/hobbies.json',
        _skillsPath = skillsPath ?? 'assets/data/skills.json',
        _toolsPath = toolsPath ?? 'assets/data/tools.json',
        _activitiesPath = activitiesPath ?? 'assets/data/activities.json',
        _activityFallbackPath = activityFallbackPath ?? 'assets/data/activity.json';

  final AssetBundle _bundle;
  final String _hobbiesPath;
  final String _skillsPath;
  final String _toolsPath;
  final String _activitiesPath;
  final String _activityFallbackPath;

  List<Hobby>? _hobbies;
  List<Skill>? _skills;
  List<Tool>? _tools;
  List<Activity>? _activities;

  bool get isLoaded =>
      _hobbies != null && _skills != null && _tools != null && _activities != null;

  List<Hobby> get hobbies => _hobbies ?? const [];
  List<Skill> get skills => _skills ?? const [];
  List<Tool> get tools => _tools ?? const [];
  List<Activity> get activities => _activities ?? const [];

  Future<void> init({bool force = false}) async {
    if (isLoaded && !force) return;
    _hobbies = await _loadHobbies();
    _skills = await _loadSkills();
    _tools = await _loadTools();
    _activities = await _loadActivitiesWithFallback();
  }

  Future<List<Hobby>> _loadHobbies() async {
    final str = await _safeLoadString(_hobbiesPath);
    if (str == null) return [];
    return Hobby.listFromJsonString(str);
  }

  Future<List<Skill>> _loadSkills() async {
    final str = await _safeLoadString(_skillsPath);
    if (str == null) return [];
    return Skill.listFromJsonString(str);
  }

  Future<List<Tool>> _loadTools() async {
    final str = await _safeLoadString(_toolsPath);
    if (str == null) return [];
    return Tool.listFromJsonString(str);
  }

  Future<List<Activity>> _loadActivitiesWithFallback() async {
    final primary = await _safeLoadString(_activitiesPath);
    if (primary != null) return Activity.listFromJsonString(primary);

    final fallback = await _safeLoadString(_activityFallbackPath);
    if (fallback != null) return Activity.listFromJsonString(fallback);

    return [];
  }

  Future<String?> _safeLoadString(String path) async {
    try {
      return await _bundle.loadString(path);
    } on FlutterError {
      return null;
    }
  }
}