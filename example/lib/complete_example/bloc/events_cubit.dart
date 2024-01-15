import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:example/complete_example/custom_events/delivery_event.dart';
import 'package:example/complete_example/custom_events/event_attachment.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:meta/meta.dart';

part 'events_state.dart';

class Shop {
  final String name;
  final String assetIcon;

  const Shop({
    required this.name,
    required this.assetIcon,
  });
}

class EventsCubit extends Cubit<EventsState> {
  EventsCubit() : super(EventsInitial());

  static List<EventAttachment> attachments = [
    EventAttachment(title: 'Airpods', iconAsset: 'assets/images/airpods.jpg'),
    EventAttachment(title: 'Book', iconAsset: 'assets/images/book.jpg'),
    EventAttachment(title: 'Yellow Duck', iconAsset: 'assets/images/duck.webp'),
    EventAttachment(title: 'T-Shirt', iconAsset: 'assets/images/tshirt.jpg'),
    EventAttachment(
        title: 'Sneakers', iconAsset: 'assets/images/sneakers.webp'),
  ];

  static List<Shop> stores = [
    Shop(name: "Amazon", assetIcon: "assets/images/amazon.png"),
    Shop(name: "ASOS", assetIcon: "assets/images/asos.png"),
    Shop(name: "eBay", assetIcon: "assets/images/ebay.png"),
    Shop(name: "Adidas", assetIcon: "assets/images/adidas.webp"),
  ];

  static const List<String> locations = ["🏠 Home", "💼 Work"];

  void init() {
    final List<DeliveryEvent<EventAttachment>> events = [];
    final random = Random.secure();
    //   generate current month events

    final start = DateTime.now().subtract(const Duration(days: 30));
    final end = DateTime.now().add(const Duration(days: 30));
    var current = start;
    while (current.isBefore(end)) {
      final addEvents = random.nextBool() || current.day == DateTime.now().day;
      if (!addEvents) {
        current = current.add(const Duration(days: 1));
        continue;
      }

      final number = random.nextInt(6);

      events.addAll(
        List.generate(
          number,
          (index) {
            final shop = stores[random.nextInt(stores.length)];
            final List<EventAttachment> attachments = [];
            final attachmentNumber = max(1, random.nextInt(5));

            for (var i = 0; i < attachmentNumber; i++) {
              attachments.add(
                EventsCubit.attachments[
                    random.nextInt(EventsCubit.attachments.length)],
              );
            }

            return DeliveryEvent<EventAttachment>(
              attachments: attachments,
              id: "${current.millisecondsSinceEpoch}_$index",
              start: current,
              duration: const Duration(hours: 4),
              location: locations[random.nextInt(locations.length)],
              title: shop.name,
              iconAsset: shop.assetIcon,
              completed: current.isBefore(DateTime.now()),
            );
          },
        ),
      );
      current = current.add(const Duration(days: 1));
    }

    emit(EventsInitialized(events: events));
  }

  void addEvent(DeliveryEvent<EventAttachment> value) {
    final state = this.state;
    if (state is EventsInitialized) {
      final events = state.events;
      events.add(value);
      emit(EventsInitialized(events: events));
    }
  }
}
