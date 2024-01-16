import 'package:example/complete_example/bloc/events_cubit.dart';
import 'package:example/complete_example/colors.dart';
import 'package:flutter/material.dart';

class AttachmentsListPage extends StatelessWidget {
  const AttachmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExampleColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              for (final attachment in EventsCubit.attachments)
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(attachment);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          attachment.iconAsset,
                          width: 48,
                          height: 48,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          attachment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
