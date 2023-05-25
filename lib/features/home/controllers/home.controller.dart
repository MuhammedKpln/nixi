import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';
import 'package:nextcloudnotes/core/services/offline.service.dart';
import 'package:nextcloudnotes/core/services/toast.service.dart';
import 'package:nextcloudnotes/core/storage/note.storage.dart';
import 'package:nextcloudnotes/models/note.model.dart';
import 'package:nextcloudnotes/repositories/notes.repositories.dart';

part 'home.controller.g.dart';

disposeHomeController(HomeViewController instance) {
  instance.dispose();
}

@LazySingleton(dispose: disposeHomeController)
class HomeViewController = _HomeViewControllerBase with _$HomeViewController;

abstract class _HomeViewControllerBase with Store {
  _HomeViewControllerBase(this._noteRepositories, this._toastService,
      this._noteStorage, this._offlineService);
  final NoteRepositories _noteRepositories;
  final ToastService _toastService;
  final NoteStorage _noteStorage;
  final OfflineService _offlineService;

  @observable
  ObservableList<Note> notes = ObservableList();

  @observable
  bool syncing = false;

  @observable
  ObservableList<Note> selectedNotes = ObservableList();

  late ReactionDisposer sortAutomaticallyDisposer;

  void init() async {
    sortAutomaticallyDisposer = autorun((_) {
      notes.sort((a, b) => b.favorite ? 1 : 0);
    });

    syncing = true;
    await _offlineService.runQueue();
    await fetchNotes();
    syncing = false;
  }

  @action
  fetchNotes() async {
    final data = await _offlineService.fetch<List<Note>>(
        _noteStorage.getAllNotes, _noteRepositories.fetchNotes);
    notes = ObservableList.of(data.localData);

    if (data.shouldMerge != null && data.shouldMerge!) {
      if (data.remoteData != null) {
        _noteStorage.deleteAll();
        _noteStorage.saveAllNotes(data.remoteData!);

        notes = ObservableList.of(data.remoteData!);
      }
    }
  }

  Future<void> toggleFavorite(Note note) async {
    final model = Note(
        id: note.id,
        etag: note.etag,
        readonly: note.readonly,
        modified: DateTime.now().millisecondsSinceEpoch,
        title: note.title,
        category: note.category,
        content: note.content,
        favorite: !note.favorite);

    await _noteRepositories.updateNote(note.id, model);

    final updatedList = notes
        .map((element) => element.id == note.id ? model : element)
        .toList();

    notes = ObservableList.of(updatedList);
  }

  @action
  deleteNote(Note note) async {
    await _noteRepositories.deleteNote(note.id);

    notes.removeWhere((element) => element.id == note.id);

    _toastService.showTextToast("Deleted ${note.title}",
        type: ToastType.success);
  }

  @action
  bunchDeleteNotes() async {
    final List<Future<bool>> futures = [];
    for (var note in selectedNotes) {
      final future = _noteRepositories.deleteNote(note.id);
      futures.add(future);
    }

    Future.wait<bool>(futures).then((value) {
      for (var note in selectedNotes) {
        notes.removeWhere((element) => element.id == note.id);
      }

      _toastService.showTextToast("Deleted (${selectedNotes.length}) notes.",
          type: ToastType.success);
      selectedNotes.clear();
    });
  }

  @action
  addToSelectedNote(Note note) async {
    if (selectedNotes.where((element) => element.id == note.id).isNotEmpty) {
      selectedNotes.removeWhere((element) => element.id == note.id);
      return;
    }

    selectedNotes.add(note);
  }

  dispose() {
    sortAutomaticallyDisposer();
  }
}
