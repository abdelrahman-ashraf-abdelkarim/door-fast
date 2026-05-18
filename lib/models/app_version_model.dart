int compareVersions(String v1, String v2) {
  List<int> parseVersion(String version) {
    final cleanVersion = version.split('+').first;
    final parts = cleanVersion.split('.');

    return List<int>.generate(3, (index) {
      if (index >= parts.length) return 0;
      return int.tryParse(parts[index]) ?? 0;
    });
  }

  final first = parseVersion(v1);
  final second = parseVersion(v2);

  for (var i = 0; i < 3; i++) {
    if (first[i] < second[i]) return -1;
    if (first[i] > second[i]) return 1;
  }

  return 0;
}

class AppVersionModel {
  final String minimumVersion;
  final String latestVersion;
  final String updateUrl;

  const AppVersionModel({
    required this.minimumVersion,
    required this.latestVersion,
    required this.updateUrl,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      minimumVersion: json['minimum_version']?.toString() ?? '0.0.0',
      latestVersion: json['latest_version']?.toString() ?? '0.0.0',
      updateUrl: json['update_url']?.toString() ?? '',
    );
  }

  bool isForceUpdate(String currentVersion) {
    return compareVersions(currentVersion, minimumVersion) < 0;
  }

  bool isOptionalUpdate(String currentVersion) {
    return compareVersions(currentVersion, minimumVersion) >= 0 &&
        compareVersions(currentVersion, latestVersion) < 0;
  }
}
