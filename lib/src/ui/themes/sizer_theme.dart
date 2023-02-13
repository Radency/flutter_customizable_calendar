part of 'timeline_theme.dart';

/// Wrapper for the sizer view customization parameters
class SizerTheme extends Equatable {
  /// Customize the sizer view with the parameters
  const SizerTheme({
    this.size = const Size.square(8),
    this.decoration = const BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
    ),
    this.extraSpace = 4,
  });

  /// Size of the view
  final Size size;

  /// Decoration parameters of the view
  final BoxDecoration decoration;

  /// Needs to increase the tappable area
  final double extraSpace;

  @override
  List<Object?> get props => [
        size,
        decoration,
        extraSpace,
      ];

  /// Creates a copy of this theme but with the given fields replaced with
  /// the new values
  SizerTheme copyWith({
    Size? size,
    BoxDecoration? decoration,
    double? extraSpace,
  }) {
    return SizerTheme(
      size: size ?? this.size,
      decoration: decoration ?? this.decoration,
      extraSpace: extraSpace ?? this.extraSpace,
    );
  }
}
