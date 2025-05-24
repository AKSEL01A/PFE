import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HistoryController extends GetxController {
  final box = GetStorage();
  var history = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

void loadHistory() {
  final userId = box.read('userId');
  if (userId == null) return;

  try {
    final List<dynamic>? stored = box.read('user_history_$userId');
    if (stored != null) {
history.value = stored
    .map<Map<String, String>>((e) => Map<String, String>.from(e.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        )))
    .toList();

    }
  } catch (e) {
    print("Erreur de chargement de l'historique: $e");
  }
}



  void addAction(String type, String description) {
    final userId = box.read('userId');
    if (userId == null) return;

    final newAction = {
      "type": type,
      "description": description,
      "date": DateTime.now().toString().split('.').first,
    };

    history.insert(0, newAction);
    box.write('user_history_$userId', history);
  }

  void clearHistory() {
    final userId = box.read('userId');
    if (userId == null) return;

    history.clear();
    box.remove('user_history_$userId');
  }
}
