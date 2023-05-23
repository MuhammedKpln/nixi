import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:nextcloudnotes/core/controllers/queue.controller.dart';
import 'package:nextcloudnotes/main.dart';
import 'package:nextcloudnotes/models/note.model.dart';
import 'package:nextcloudnotes/repositories/notes.repositories.dart';

part 'note_view.controller.g.dart';

disposeNoteViewController(NoteViewController instance) {
  instance.dispose();
}

@LazySingleton(dispose: disposeNoteViewController)
class NoteViewController = _NoteViewControllerBase with _$NoteViewController;

abstract class _NoteViewControllerBase with Store {
  _NoteViewControllerBase(this._noteRepositories, this._queueController);
  final NoteRepositories _noteRepositories;
  final QueueController _queueController;

  final FocusNode focusNode = FocusNode();

  TextEditingController markdownController = TextEditingController();

  @observable
  bool isTextFieldFocused = false;

  @observable
  bool editMode = false;

  @computed
  String get prettyDate => DateFormat("yyyy-MM-dd HH:mm")
      .format(DateTime.utc(1970, 1, 1).add(Duration(seconds: note.modified)));

  late Note note;

  init(int noteId) {
    fetchNote(noteId);

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isTextFieldFocused = true;
      }
    });
  }

  dispose() {
    focusNode.dispose();
  }

  Future<Note> fetchNote(int noteId) async {
    note = await _noteRepositories.fetchNote(noteId);

    return note;
  }

  Future<bool> deleteNote(int noteId) async {
    final deleted = await _noteRepositories.deleteNote(noteId);

    if (deleted) {
      scaffolMessengerKey.currentState
          ?.showSnackBar(const SnackBar(content: Text("ok")));

      return true;
    }

    return false;
  }

  @action
  Future<void> updateNote(int noteId, Note note) async {
    final note0 = note.toJson();
    note0["content"] = markdownController.text;

    _queueController.queue.sink.add(
        QueueAction(type: QueueActionTypes.UPDATE, note: Note.fromJson(note0)));
  }

  onTapDone(int noteId, Note note) {
    focusNode.unfocus();
    toggleEditMode();
    isTextFieldFocused = false;
    updateNote(noteId, note).then((value) => fetchNote(noteId));
  }

  toggleEditMode() {
    editMode = !editMode;
  }
}
