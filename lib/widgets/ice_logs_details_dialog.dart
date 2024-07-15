import 'package:flutter/material.dart';
import 'package:icedetector/themes/colors.dart';

class IceLogsDetailsDialog extends StatelessWidget {
  const IceLogsDetailsDialog({
    super.key, required this.logDate, required this.url
  });

  final String logDate;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
          color: bgColor,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 30
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ice Logs',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close_rounded))
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      height: 200.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return const Center(
                              child: Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text('Timestamp: $logDate',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                )
            ),
          )
      ),
    );
  }
}
