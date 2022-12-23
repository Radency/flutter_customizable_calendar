import 'package:flutter_customizable_calendar/src/domain/models/models.dart';

/// Function which builds an output [String] based on given [DateTime] value
typedef DateFormatter = String Function(DateTime);

/// Function which builds an output [String] based on given [DisplayedPeriod].
/// You should remember than the [DisplayedPeriod] end date can be omitted.
typedef PeriodFormatter = String Function(DisplayedPeriod);
