import 'dart:developer';
import 'dart:io';
import 'dart:convert';

final libDir = Directory('lib');
final testDir = Directory('test');
final bool deleteUnused = true; // <-- Turn auto delete ON/OFF

class ClassInfo {
  final String name;
  final String type; // class, abstract, enum, mixin, typedef
  final String filePath;
  final int lineNumber;

  ClassInfo(this.name, this.type, this.filePath, this.lineNumber);

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'file': filePath,
    'line': lineNumber,
  };
}

Future<void> main() async {
  log('🔍 Scanning for unused classes...\n');

  final stopwatch = Stopwatch()..start();

  final libFiles = await _getDartFiles(libDir);
  final testFiles = await _getDartFiles(testDir);
  final allFiles = [...libFiles, ...testFiles];

  log(
    '📁 Found ${libFiles.length} files in lib and ${testFiles.length} files in test',
  );

  final Map<String, ClassInfo> allClasses = {};
  final Map<String, String> fileContents = {};

  for (var file in allFiles) {
    fileContents[file.path] = await file.readAsString();
  }

  for (var file in libFiles) {
    final content = fileContents[file.path]!;
    final extractedClasses = _extractClasses(content, file.path);
    for (var classInfo in extractedClasses) {
      allClasses[classInfo.name] = classInfo;
    }
  }

  log('🏗️  Found ${allClasses.length} classes to check...');

  final Set<String> usedClasses = {};
  for (var entry in fileContents.entries) {
    final filePath = entry.key;
    final content = entry.value;

    for (var className in allClasses.keys) {
      if (_isClassUsed(
        content,
        className,
        filePath,
        allClasses[className]!.filePath,
      )) {
        usedClasses.add(className);
      }
    }
  }

  final unusedClasses =
      allClasses.values
          .where((classInfo) => !usedClasses.contains(classInfo.name))
          .toList();

  final Map<String, List<ClassInfo>> unusedByType = {};
  for (var classInfo in unusedClasses) {
    unusedByType.putIfAbsent(classInfo.type, () => []).add(classInfo);
  }

  stopwatch.stop();

  _printResults(unusedByType, allClasses.length, stopwatch.elapsedMilliseconds);
  await _saveReport(unusedClasses);

  if (deleteUnused) {
    log('🧨 Starting auto-delete of unused classes...');
    await _deleteUnusedClasses(unusedClasses);
  }
}

Future<List<File>> _getDartFiles(Directory dir) async {
  if (!dir.existsSync()) return [];
  return dir
      .list(recursive: true)
      .where((f) => f is File && f.path.endsWith('.dart'))
      .cast<File>()
      .toList();
}

List<ClassInfo> _extractClasses(String content, String filePath) {
  final List<ClassInfo> classes = [];
  final lines = content.split('\n');

  final patterns = [
    RegExp(
      r'^(?:export\s+)?(?:abstract\s+)?class\s+(\w+)(?:\s+extends|\s+with|\s+implements|\s*\{)',
    ),
    RegExp(
      r'^(?:export\s+)?abstract\s+class\s+(\w+)(?:\s+extends|\s+with|\s+implements|\s*\{)',
    ),
    RegExp(r'^(?:export\s+)?enum\s+(\w+)\s*\{'),
    RegExp(r'^(?:export\s+)?mixin\s+(\w+)(?:\s+on|\s*\{)'),
    RegExp(r'^(?:export\s+)?typedef\s+(\w+)\s*='),
  ];

  final types = ['class', 'abstract', 'enum', 'mixin', 'typedef'];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*'))
      continue;

    for (int patternIndex = 0; patternIndex < patterns.length; patternIndex++) {
      final match = patterns[patternIndex].firstMatch(line);
      if (match != null) {
        final className = match.group(1)!;
        if (!className.startsWith('_') && !className.startsWith('\$')) {
          classes.add(
            ClassInfo(className, types[patternIndex], filePath, i + 1),
          );
        }
        break;
      }
    }
  }

  return classes;
}

bool _isClassUsed(
  String content,
  String className,
  String currentFile,
  String classDefinitionFile,
) {
  if (currentFile == classDefinitionFile) return false;

  final usagePatterns = [
    RegExp(r'\b' + className + r'\s+\w+'),
    RegExp(r'<[^>]*\b' + className + r'\b[^>]*>'),
    RegExp(r'\(\s*[^)]*\b' + className + r'\b[^)]*\)'),
    RegExp(r'\b' + className + r'\s+\w+\s*\('),
    RegExp(r'(?:extends|implements|with)\s+[^{]*\b' + className + r'\b'),
    RegExp(r'\b' + className + r'\s*\('),
    RegExp(r'\b' + className + r'\.'),
    RegExp(r'@\s*' + className),
    RegExp(r'as\s+' + className + r'\b'),
    RegExp(r'is\s+' + className + r'\b'),
  ];

  return usagePatterns.any((pattern) => pattern.hasMatch(content));
}

void _printResults(
  Map<String, List<ClassInfo>> unusedByType,
  int totalClasses,
  int timeMs,
) {
  final totalUnused = unusedByType.values.expand((list) => list).length;

  if (totalUnused == 0) {
    log('🎉 All classes are used. Great job!');
    log('✅ Scanned $totalClasses classes in ${timeMs}ms');
    return;
  }

  log('🧹 Found $totalUnused unused classes out of $totalClasses:\n');

  final sortedTypes = unusedByType.keys.toList()..sort();
  for (var type in sortedTypes) {
    final classes = unusedByType[type]!;
    log('📦 ${_getTypeEmoji(type)} $type (${classes.length}):');
    classes.sort((a, b) => a.filePath.compareTo(b.filePath));
    String? currentFile;
    for (var classInfo in classes) {
      final shortPath = classInfo.filePath.replaceFirst(libDir.path, 'lib');
      if (currentFile != shortPath) {
        currentFile = shortPath;
        log('   📁 $shortPath');
      }
      log('      ❌ ${classInfo.name} (line ${classInfo.lineNumber})');
    }
    log('');
  }

  log('⏱️ Done in ${timeMs}ms');
}

String _getTypeEmoji(String type) {
  switch (type) {
    case 'class':
      return '🏗️';
    case 'abstract':
      return '🔮';
    case 'enum':
      return '📋';
    case 'mixin':
      return '🧩';
    case 'typedef':
      return '🏷️';
    default:
      return '📦';
  }
}

Future<void> _saveReport(List<ClassInfo> unusedClasses) async {
  if (unusedClasses.isEmpty) return;

  final report = {
    'timestamp': DateTime.now().toIso8601String(),
    'summary': {
      'total_unused': unusedClasses.length,
      'by_type': <String, int>{},
    },
    'unused_classes': unusedClasses.map((c) => c.toJson()).toList(),
  };

  final summary = report['summary'] as Map<String, dynamic>;
  final byType = summary['by_type'] as Map<String, int>;
  for (var classInfo in unusedClasses) {
    final type = classInfo.type;
    byType[type] = (byType[type] ?? 0) + 1;
  }

  final jsonReport = JsonEncoder.withIndent('  ').convert(report);
  final file = File('unused_classes_report.json');
  await file.writeAsString(jsonReport);
  log('📄 Saved detailed report to unused_classes_report.json');
}

Future<void> _deleteUnusedClasses(List<ClassInfo> unusedClasses) async {
  final Map<String, List<ClassInfo>> classesByFile = {};
  for (var classInfo in unusedClasses) {
    classesByFile.putIfAbsent(classInfo.filePath, () => []).add(classInfo);
  }

  for (var entry in classesByFile.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) continue;

    final lines = await file.readAsLines();
    final List<bool> toDelete = List.filled(lines.length, false);

    for (var classInfo in entry.value) {
      int start = classInfo.lineNumber - 1;
      int end = start;

      int openBraces = 0;
      bool started = false;

      for (int i = start; i < lines.length; i++) {
        final line = lines[i];
        final open = RegExp(r'\{').allMatches(line).length;
        final close = RegExp(r'\}').allMatches(line).length;

        if (!started && open > 0) started = true;
        if (started) openBraces += open - close;

        toDelete[i] = true;
        if (started && openBraces <= 0) {
          end = i;
          break;
        }
      }
    }

    final newLines = [
      for (int i = 0; i < lines.length; i++)
        if (!toDelete[i]) lines[i],
    ];

    await file.writeAsString(newLines.join('\n'));
    log('🧽 Cleaned: ${entry.key}');
  }
}
