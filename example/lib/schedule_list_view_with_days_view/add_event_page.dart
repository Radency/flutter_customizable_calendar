import 'package:example/colors.dart';
import 'package:example/common/event_with_label/event_label.dart';
import 'package:example/common/event_with_label/event_with_label.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({
    super.key,
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController =
      TextEditingController(text: "New Event");
  EventLabel _label = EventLabel.values.first;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    _startDate = widget.initialDate;
    _endDate = _startDate.add(
      Duration(
        hours: 2,
      ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: ExampleColors.swatch24().withOpacity(0.5),
        foregroundColor: ExampleColors.white,
        onPressed: () {
          final event = EventWithLabel(
            id: UniqueKey(),
            duration: _endDate.difference(_startDate),
            start: _startDate,
            title: _titleController.text,
            label: _label,
          );
          Navigator.of(context).pop(event);
        },
        child: Icon(Icons.check),
      ),
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
                    DateFormat.MMMM().format(_startDate),
                    style: TextStyle(
                      color: ExampleColors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    DateFormat.y().format(_startDate),
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
                          ]),
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
                              height: 32,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Label:",
                                    style: TextStyle(
                                      color: ExampleColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  DropdownButton<EventLabel>(
                                    items: EventLabel.values
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: e.color,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 16,
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
                                      _label = value!;
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    value: _label,
                                    style: TextStyle(
                                      color: ExampleColors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    underline: Container(
                                      height: 0,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: ExampleColors.black,
                                      size: 24,
                                    ),
                                    iconSize: 4,
                                    elevation: 4,
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              visualDensity: VisualDensity.compact,
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
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              visualDensity: VisualDensity.compact,
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
