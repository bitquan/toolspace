import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'color_utils.dart';

/// Result of k-means clustering with dominant colors and their frequencies
class PaletteResult {
  final List<Color> colors;
  final List<int> frequencies;

  PaletteResult(this.colors, this.frequencies);

  /// Get color at index with its frequency
  ColorFrequency getColorFrequency(int index) {
    return ColorFrequency(colors[index], frequencies[index]);
  }

  /// Total number of pixels
  int get totalPixels => frequencies.fold(0, (sum, freq) => sum + freq);

  /// Get percentage for a color at index
  double getPercentage(int index) {
    return (frequencies[index] / totalPixels) * 100;
  }
}

/// A color with its frequency in the image
class ColorFrequency {
  final Color color;
  final int frequency;

  ColorFrequency(this.color, this.frequency);
}

/// K-means clustering implementation for color quantization
class KMeansClustering {
  static const int maxIterations = 50;
  static const double convergenceThreshold = 0.01;

  /// Extract dominant colors from image pixels using k-means clustering
  /// 
  /// [pixels] - List of colors from the image
  /// [k] - Number of colors to extract (default: 10)
  /// [sampleSize] - Maximum number of pixels to use for clustering (for performance)
  /// 
  /// Returns a [PaletteResult] with the dominant colors and their frequencies
  static Future<PaletteResult> extractPalette(
    List<Color> pixels, {
    int k = 10,
    int? sampleSize,
  }) async {
    return compute(_extractPaletteIsolate, _ExtractParams(pixels, k, sampleSize));
  }

  /// Run k-means clustering in an isolate for better performance
  static PaletteResult _extractPaletteIsolate(_ExtractParams params) {
    final pixels = params.pixels;
    final k = params.k;
    final sampleSize = params.sampleSize;

    if (pixels.isEmpty) {
      return PaletteResult([], []);
    }

    // Sample pixels if necessary for performance
    final sampledPixels = _samplePixels(pixels, sampleSize);

    // Initialize centroids using k-means++ algorithm
    List<_ColorVector> centroids = _initializeCentroids(sampledPixels, k);

    // Run k-means iterations
    List<int> assignments = List.filled(sampledPixels.length, 0);
    int iteration = 0;
    bool converged = false;

    while (iteration < maxIterations && !converged) {
      // Assign each pixel to nearest centroid
      final newAssignments = _assignToClusters(sampledPixels, centroids);

      // Check for convergence
      converged = _hasConverged(assignments, newAssignments);
      assignments = newAssignments;

      // Update centroids
      centroids = _updateCentroids(sampledPixels, assignments, k);

      iteration++;
    }

    // Count frequencies for each cluster
    final frequencies = List.filled(k, 0);
    for (var assignment in assignments) {
      frequencies[assignment]++;
    }

    // Convert centroids to Colors and sort by frequency
    final results = List.generate(
      k,
      (i) => ColorFrequency(centroids[i].toColor(), frequencies[i]),
    );

    // Sort by frequency (most common first)
    results.sort((a, b) => b.frequency.compareTo(a.frequency));

    // Filter out clusters with no pixels
    final filteredResults = results.where((cf) => cf.frequency > 0).toList();

    return PaletteResult(
      filteredResults.map((cf) => cf.color).toList(),
      filteredResults.map((cf) => cf.frequency).toList(),
    );
  }

  /// Sample pixels randomly if there are too many
  static List<Color> _samplePixels(List<Color> pixels, int? maxSamples) {
    if (maxSamples == null || pixels.length <= maxSamples) {
      return pixels;
    }

    final random = Random(42); // Use fixed seed for reproducibility
    final sampled = <Color>[];
    final step = pixels.length / maxSamples;

    for (var i = 0; i < maxSamples; i++) {
      final index = (i * step).floor();
      sampled.add(pixels[index]);
    }

    return sampled;
  }

  /// Initialize centroids using k-means++ algorithm for better initial placement
  static List<_ColorVector> _initializeCentroids(List<Color> pixels, int k) {
    final random = Random(42);
    final centroids = <_ColorVector>[];

    // Choose first centroid randomly
    centroids.add(_ColorVector.fromColor(pixels[random.nextInt(pixels.length)]));

    // Choose remaining centroids with probability proportional to distance squared
    while (centroids.length < k) {
      final distances = pixels.map((pixel) {
        final p = _ColorVector.fromColor(pixel);
        return centroids
            .map((c) => c.distanceSquared(p))
            .reduce((a, b) => a < b ? a : b);
      }).toList();

      final totalDistance = distances.fold(0.0, (sum, d) => sum + d);
      if (totalDistance == 0) break;

      var threshold = random.nextDouble() * totalDistance;
      for (var i = 0; i < pixels.length; i++) {
        threshold -= distances[i];
        if (threshold <= 0) {
          centroids.add(_ColorVector.fromColor(pixels[i]));
          break;
        }
      }
    }

    return centroids;
  }

  /// Assign each pixel to the nearest centroid
  static List<int> _assignToClusters(
    List<Color> pixels,
    List<_ColorVector> centroids,
  ) {
    return pixels.map((pixel) {
      final p = _ColorVector.fromColor(pixel);
      var minDist = double.infinity;
      var nearestCluster = 0;

      for (var i = 0; i < centroids.length; i++) {
        final dist = p.distanceSquared(centroids[i]);
        if (dist < minDist) {
          minDist = dist;
          nearestCluster = i;
        }
      }

      return nearestCluster;
    }).toList();
  }

  /// Check if assignments have converged
  static bool _hasConverged(List<int> oldAssignments, List<int> newAssignments) {
    var changes = 0;
    for (var i = 0; i < oldAssignments.length; i++) {
      if (oldAssignments[i] != newAssignments[i]) {
        changes++;
      }
    }
    return changes < (oldAssignments.length * convergenceThreshold);
  }

  /// Update centroids based on current cluster assignments
  static List<_ColorVector> _updateCentroids(
    List<Color> pixels,
    List<int> assignments,
    int k,
  ) {
    final sums = List.generate(k, (_) => _ColorVector(0, 0, 0));
    final counts = List.filled(k, 0);

    for (var i = 0; i < pixels.length; i++) {
      final cluster = assignments[i];
      final p = _ColorVector.fromColor(pixels[i]);
      sums[cluster] = sums[cluster].add(p);
      counts[cluster]++;
    }

    return List.generate(k, (i) {
      if (counts[i] == 0) {
        // Keep old centroid if no pixels assigned
        return _ColorVector(0, 0, 0);
      }
      return sums[i].divide(counts[i].toDouble());
    });
  }
}

/// Parameters for isolate computation
class _ExtractParams {
  final List<Color> pixels;
  final int k;
  final int? sampleSize;

  _ExtractParams(this.pixels, this.k, this.sampleSize);
}

/// Vector representation of a color in RGB space
class _ColorVector {
  final double r;
  final double g;
  final double b;

  _ColorVector(this.r, this.g, this.b);

  factory _ColorVector.fromColor(Color color) {
    return _ColorVector(
      color.red.toDouble(),
      color.green.toDouble(),
      color.blue.toDouble(),
    );
  }

  Color toColor() {
    return Color.fromARGB(
      255,
      r.round().clamp(0, 255),
      g.round().clamp(0, 255),
      b.round().clamp(0, 255),
    );
  }

  double distanceSquared(_ColorVector other) {
    final dr = r - other.r;
    final dg = g - other.g;
    final db = b - other.b;
    return dr * dr + dg * dg + db * db;
  }

  _ColorVector add(_ColorVector other) {
    return _ColorVector(r + other.r, g + other.g, b + other.b);
  }

  _ColorVector divide(double divisor) {
    return _ColorVector(r / divisor, g / divisor, b / divisor);
  }
}
