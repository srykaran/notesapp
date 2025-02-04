import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudtutorial/services/firestore.dart';
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textController = TextEditingController();
  //open a box to add note
  void openNoteBox({String? docID}){

    showDialog(context: context,
        builder: (context)=>AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            //button to save
            ElevatedButton(onPressed: (){
              if(docID == null) {
                firestoreService.addNote(textController.text);
              }
              else{
                firestoreService.updateNote(docID,textController.text);
              }
              //claer the text controller
              textController.clear();
              //clear the box
              Navigator.pop(context);
            },
                child: Text('Add'),
            )
          ],
        ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('Notes'),),
      floatingActionButton: FloatingActionButton(
          onPressed: openNoteBox,
              child:const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot){
          //if we have data get all the docs
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty){
            List notesList = snapshot.data!.docs;

            //display as a list
            return ListView.builder(
                itemCount: notesList.length,
                itemBuilder:
            (context ,  index){
              //get individual document
              DocumentSnapshot document = notesList[index];
              String docID = document.id;
              //get note from each document
              Map<String, dynamic> data = document.data() as Map<String,dynamic>;
              String noteText = data ['note'];
              //display a list tile
              return ListTile(
                title: Text(noteText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: ()=>openNoteBox(docID: docID), icon: Icon(Icons.edit)),
                    IconButton(onPressed: ()=> firestoreService.deleteNote(docID), icon: Icon(Icons.delete)),
                  ],
                ),
              );
            }
            );
          }
          else{
            return const Center(child: Text('No Data Available at the moment'),);
          }
        },
      ),
    );
  }
}
