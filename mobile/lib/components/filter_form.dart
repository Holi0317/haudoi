import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/strings.g.dart';
import '../models/search_query.dart';
import 'common_query_chip.dart';

class FilterForm extends StatelessWidget {
  const FilterForm({
    super.key,
    required this.query,
    required this.order,
    required this.onQueryChanged,
    required this.onOrderChanged,
  });

  final String? query;
  final SearchOrder order;
  final ValueChanged<String?> onQueryChanged;
  final ValueChanged<SearchOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16.0,
        children: [
          // Query input field with documentation link
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                launchUrl(
                  Uri.parse(
                    'https://github.com/Holi0317/haudoi?tab=readme-ov-file#query-dsl',
                  ),
                  mode: LaunchMode.inAppBrowserView,
                );
              },
              icon: const Icon(Icons.description_outlined),
              label: const Text('Search Query (DSL) documentation'),
            ),
          ),

          // Common queries
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Text(
                'Common Queries',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  CommonQueryChip(
                    label: 'All links',
                    query: '',
                    onQueryChanged: onQueryChanged,
                  ),
                  CommonQueryChip(
                    label: 'Archived',
                    query: 'archive:true',
                    onQueryChanged: onQueryChanged,
                  ),
                  CommonQueryChip(
                    label: 'Not Archived',
                    query: 'archive:false',
                    onQueryChanged: onQueryChanged,
                  ),
                  CommonQueryChip(
                    label: 'Favorited',
                    query: 'favorite:true',
                    onQueryChanged: onQueryChanged,
                  ),
                  CommonQueryChip(
                    label: 'Not Favorited',
                    query: 'favorite:false',
                    onQueryChanged: onQueryChanged,
                  ),
                ],
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Text(
                t.filter.order.title,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<SearchOrder>(
                  segments: [
                    ButtonSegment<SearchOrder>(
                      value: SearchOrder.createdAtDesc,
                      label: Text(t.filter.order.newestFirst),
                    ),
                    ButtonSegment<SearchOrder>(
                      value: SearchOrder.createdAtAsc,
                      label: Text(t.filter.order.oldestFirst),
                    ),
                  ],
                  selected: {order},
                  onSelectionChanged: _handleSelection(onOrderChanged),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ValueChanged<Set<T>> _handleSelection<T>(ValueChanged<T> onChanged) {
    return (Set<T> selection) {
      assert(
        selection.length == 1,
        "SegmentedButton should only allow single selection. Is the SegmentedButton misconfigured?",
      );
      onChanged(selection.first);
    };
  }
}
