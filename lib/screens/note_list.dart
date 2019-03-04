import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/note.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:flutter_app/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';


class NoteList extends StatefulWidget {

	@override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}
// Hakee tietokannasta notet ja listaa ne.
class NoteListState extends State<NoteList> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Note> noteList;
	int count = 0;
//UI'näkymä
	@override
  Widget build(BuildContext context) {

		if (noteList == null) {
			noteList = List<Note>();
			updateListView();
		}

    return Scaffold(

	    appBar: AppBar(
		    title: Text('Notes'),
	    ),

	    body: getNoteListView(),

	    floatingActionButton: FloatingActionButton(
		    onPressed: () {
		      debugPrint('FAB clicked');
		      navigateToDetail(Note('', '', 2), 'Add Note');
		    },

		    tooltip: 'Add Note',

		    child: Icon(Icons.add),

	    ),
    );
  }

  ListView getNoteListView() {

		TextStyle titleStyle = Theme.of(context).textTheme.subhead;

		return ListView.builder(
			itemCount: count,
			itemBuilder: (BuildContext context, int position) {
				return Card(
					color: Colors.white30,
					elevation: 2.0,
					child: ListTile(

						leading: CircleAvatar(
							backgroundColor: getPriorityColor(this.noteList[position].priority),
							child: getPriorityIcon(this.noteList[position].priority),
						),

						title: Text(this.noteList[position].title, style: titleStyle,),

						subtitle: Text(this.noteList[position].date),

						trailing: GestureDetector(
							child: Icon(Icons.delete, color: Colors.black,),
							onTap: () {
								_delete(context, noteList[position]);
							},
						),


						onTap: () {
							debugPrint("ListTile Tapped");
							navigateToDetail(this.noteList[position],'Edit Note');
						},

					),
				);
			},
		);
  }

  // Prioriteettien väritys
	Color getPriorityColor(int priority) {
		switch (priority) {
			case 1:
				return Colors.purple;
				break;
			case 2:
				return Colors.deepPurpleAccent;
				break;

			default:
				return Colors.deepPurpleAccent;
		}
	}

	// Prioriteettien iconit
	Icon getPriorityIcon(int priority) {
		switch (priority) {
			case 1:
				return Icon(Icons.keyboard_arrow_right);
				break;
			case 2:
				return Icon(Icons.keyboard_arrow_right);
				break;

			default:
				return Icon(Icons.keyboard_arrow_right);
		}
	}
	//Tekstitiedoston poistaminen sekä ilmoitus
	void _delete(BuildContext context, Note note) async {

		int result = await databaseHelper.deleteNote(note.id);
		if (result != 0) {
			_showSnackBar(context, 'Note Deleted Successfully');
			updateListView();
		}
	}

	void _showSnackBar(BuildContext context, String message) {

		final snackBar = SnackBar(content: Text(message));
		Scaffold.of(context).showSnackBar(snackBar);
	}
// Navigoija ruutujen näkymiselle
  void navigateToDetail(Note note, String title) async {
	  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
		  return NoteDetail(note, title);
	  }));

	  if (result == true) {
	  	updateListView();
	  }
  }
// Päivittää listauksen tekstitiedosto listasta, joka näkyy kyseisellä screenillä
  void updateListView() {

		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {

			Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
			noteListFuture.then((noteList) {
				setState(() {
				  this.noteList = noteList;
				  this.count = noteList.length;
				});
			});
		});
  }
}







