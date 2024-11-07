import 'package:example/month_view_with_schedule_list_view/attachments_list_page.dart';
import 'package:example/month_view_with_schedule_list_view/cubit/events_cubit.dart';
import 'package:example/colors.dart';
import 'package:example/month_view_with_schedule_list_view/custom_events/delivery_event.dart';
import 'package:example/month_view_with_schedule_list_view/custom_events/event_attachment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController =
      TextEditingController(text: "New Event");
  String _location = EventsCubit.locations.first;
  Shop _store = EventsCubit.stores.first;
  late DateTime _startDate;
  late DateTime _endDate;
  final List<EventAttachment> _attachments = [];

  @override
  void initState() {
    _startDate = DateTime.now();
    _endDate = _startDate.add(
      Duration(days: 1),
    );

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExampleColors.white,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    DateFormat.yMMMEd().format(_startDate),
                    style: TextStyle(
                      color: ExampleColors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: ExampleColors.swatch24().withAlpha(110),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ExampleColors.black.withOpacity(0.25),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.close,
                          color: ExampleColors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
                height: 32,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ExampleColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: ExampleColors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox()),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    80,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ExampleColors.swatch24().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 32,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: "Title",
                                  labelStyle: TextStyle(
                                    color: ExampleColors.black,
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ExampleColors.swatch24(),
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ExampleColors.swatch24(),
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ExampleColors.swatch24(),
                                    ),
                                  ),
                                ),
                                cursorColor: ExampleColors.swatch24(),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Location:",
                                    style: TextStyle(
                                      color: ExampleColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      items: EventsCubit.locations
                                          .map(
                                            (e) => DropdownMenuItem(
                                              child: Text(e),
                                              value: e,
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        _location = value!;
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                      value: _location,
                                      style: TextStyle(
                                        color: ExampleColors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      underline: Container(
                                        height: 1,
                                        color: ExampleColors.swatch24(),
                                      ),
                                      iconSize: 0,
                                      elevation: 4,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Store:",
                                    style: TextStyle(
                                      color: ExampleColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: DropdownButton<Shop>(
                                      items: EventsCubit.stores
                                          .map(
                                            (e) => DropdownMenuItem(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.asset(
                                                        e.assetIcon,
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 12,
                                                    ),
                                                    Text(e.name),
                                                  ],
                                                ),
                                              ),
                                              value: e,
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        _store = value!;
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                      value: _store,
                                      style: TextStyle(
                                        color: ExampleColors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      underline: Container(
                                        height: 1,
                                        color: ExampleColors.swatch24(),
                                      ),
                                      iconSize: 0,
                                      elevation: 4,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                ).then((value) {
                                  if (value != null) {
                                    _startDate = value;
                                    if (_endDate.isBefore(_startDate)) {
                                      _endDate = _startDate.add(
                                        Duration(days: 1),
                                      );
                                    }
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                });
                              },
                              title: Row(
                                children: [
                                  Text(
                                    "Starts",
                                    style: TextStyle(
                                      color: ExampleColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(DateFormat.yMMMEd().format(_startDate)),
                                ],
                              ),
                            ),
                            ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                ).then((value) {
                                  if (value != null) {
                                    _endDate = value;
                                    if (_endDate.isBefore(_startDate)) {
                                      _startDate = _endDate.subtract(
                                        Duration(days: 1),
                                      );
                                    }
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                });
                              },
                              title: Row(
                                children: [
                                  Text(
                                    "Ends",
                                    style: TextStyle(
                                      color: ExampleColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(DateFormat.yMMMEd().format(_endDate)),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Attachments:",
                                    style: TextStyle(
                                      color: ExampleColors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  if (_attachments.isEmpty)
                                    Text(
                                      "No attachments added",
                                      style: TextStyle(
                                        color: ExampleColors.black
                                            .withOpacity(0.5),
                                        fontSize: 16,
                                      ),
                                    ),
                                  for (int i = 0; i < _attachments.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            _attachments[i].iconAsset,
                                            width: 48,
                                            height: 48,
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            _attachments[i].title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          InkWell(
                                            onTap: () {
                                              _attachments.removeAt(i);
                                              if (mounted) {
                                                setState(() {});
                                              }
                                            },
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AttachmentsListPage(),
                                            ),
                                          )
                                              .then((value) {
                                            if (value is EventAttachment) {
                                              _attachments.add(value);
                                              if (mounted) {
                                                setState(() {});
                                              }
                                            }
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                            ExampleColors.swatch24()
                                                .withOpacity(0.1),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        child: Text("Add"),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                            DeliveryEvent<EventAttachment>(
                                              attachments: _attachments,
                                              id: "${DateTime.now().millisecondsSinceEpoch}",
                                              start: _startDate,
                                              duration: _endDate
                                                  .difference(_startDate),
                                              location: _location,
                                              title: _titleController.text,
                                              iconAsset: _store.assetIcon,
                                              completed: false,
                                            ),
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                            ExampleColors.swatch24()
                                                .withOpacity(0.1),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        child: Text("done"),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 72,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
