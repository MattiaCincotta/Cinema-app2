class ParserUtils {
  static List<int>? tryGetListInt(dynamic obj, String field) {
    try {
      if (obj != null && (obj as dynamic).toJson != null) {
        final map = (obj as dynamic).toJson();
        final val = map[field];
        if (val is List) {
          return val.map((e) => int.tryParse(e.toString()) ?? 0).toList();
        }
      }
    } catch (_) {
      try {
        if (obj is Map) {
          final val = obj[field];
          if (val is List<int>) return val;
          if (val is List) {
            return val.map((e) => int.tryParse(e.toString()) ?? 0).toList();
          }
        } else if (obj != null && (obj as dynamic).genreIds != null) {
          final val = (obj as dynamic).genreIds;
          if (val is List<int>) return val;
          if (val is List) {
            return val.map((e) => int.tryParse(e.toString()) ?? 0).toList();
          }
        }
      } catch (_) {}
    }
    try {
      if (obj != null && (obj as dynamic).genreIds != null) {
        final val = (obj as dynamic).genreIds;
        if (val is List<int>) return val;
        if (val is List) {
          return val.map((e) => int.tryParse(e.toString()) ?? 0).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  static String? tryGetString(dynamic obj, String field) {
    try {
      if (obj != null && (obj as dynamic).toJson != null) {
        final map = (obj as dynamic).toJson();
        final val = map[field];
        if (val is String) return val;
      }
    } catch (_) {
      try {
        if (obj is Map) {
          final val = obj[field];
          if (val is String) return val;
        } else if (obj != null && (obj as dynamic).releaseDate != null) {
          final val = (obj as dynamic).releaseDate;
          if (val is String) return val;
        }
      } catch (_) {}
    }
    try {
      if (obj != null && (obj as dynamic).releaseDate != null) {
        final val = (obj as dynamic).releaseDate;
        if (val is String) return val;
      }
    } catch (_) {}
    return null;
  }

  static double? tryGetDouble(dynamic obj, String field) {
    try {
      if (obj != null && (obj as dynamic).toJson != null) {
        final map = (obj as dynamic).toJson();
        final val = map[field];
        if (val is double) return val;
        if (val is String) return double.tryParse(val);
        if (val is int) return val.toDouble();
      }
    } catch (_) {
      try {
        if (obj is Map) {
          final val = obj[field];
          if (val is double) return val;
          if (val is String) return double.tryParse(val);
          if (val is int) return val.toDouble();
        } else if (obj != null && (obj as dynamic).voteAverage != null) {
          final val = (obj as dynamic).voteAverage;
          if (val is double) return val;
          if (val is String) return double.tryParse(val);
          if (val is int) return val.toDouble();
        }
      } catch (_) {}
    }
    try {
      if (obj != null && (obj as dynamic).voteAverage != null) {
        final val = (obj as dynamic).voteAverage;
        if (val is double) return val;
        if (val is String) return double.tryParse(val);
        if (val is int) return val.toDouble();
      }
    } catch (_) {}
    return null;
  }
}