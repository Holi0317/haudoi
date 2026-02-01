import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/link.dart';
import '../extensions.dart';
import 'api.dart';

part 'item.g.dart';

@riverpod
Future<Link> linkItem(Ref ref, int id) async {
  // TODO: Apply pending edits from EditQueue
  final client = await ref.watch(apiRepositoryProvider.future);
  return await client.getItem(id, abortTrigger: ref.abortTrigger());
}
