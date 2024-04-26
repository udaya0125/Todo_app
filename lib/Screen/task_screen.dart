import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskScreenPage extends StatefulWidget{
  final Map? todo;
  TaskScreenPage({super.key,
  this.todo,
  });
  @override
  State<TaskScreenPage> createState()=> _TaskScreenState();

}

class _TaskScreenState extends State <TaskScreenPage>{
 TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit =false;
  @override
  void initState(){
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title =todo['title'];
      final desctiption = todo['description'];
      titleController.text =title;
      descriptionController.text = desctiption;
    }
  }
  Widget build (BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit ':'Add Task',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(.0),
        children: [
         TextField(
          controller:titleController,
              
            decoration:const InputDecoration(hintText: 'Title'
          ),
          ),
         TextField(
          controller:descriptionController,
            decoration:const InputDecoration(hintText: 'Description'
          ),
          keyboardType: TextInputType.multiline,
          minLines: 5,
          maxLines: 8,
          ),
        const  SizedBox(height: 30),
          ElevatedButton(  
            onPressed:isEdit ? UpdateData : SubmitData,
          child: Text(
            isEdit ? 'update':'Submit',
          style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          ),
        ],
      ),
    );
  }
  Future<void> UpdateData() async{
     //get the data from the textfield

     final todo = widget.todo;
     if(todo == null){
      print('You can not call updated without todo data');
      return;
     }
     final id = todo['_id'];
    //  final isCompleted = todo['is_completed'];
    
    final title =  titleController.text;
    final description = descriptionController.text;
    final body={
      'title':title,
      'description':description,
      "_iscompleted":false,
      

      
    };
    //send updated data to the server 
    final url ='https://api.nstack.in/v1/todos/$id';
    final uri =Uri.parse(url);
    final response = await http.put(
      uri,
    body:jsonEncode(body),
    headers: 
    {'Content-Type':'application/json'}
    );

    //check the response

    if( response.statusCode == 200){
 // print('Data posted successfully');
  showSucessMessage('Data updated successfully');
}
else 
{
  // print('Failed to post data');
  showErrorMessage('Failed to updated data');
}   
  }

  Future<void> SubmitData() async {

    //get the data from the textfield
    
    final title =  titleController.text;
    final description = descriptionController.text;
    final body={
      'title':title,
      'description':description,
      "_iscompleted":false,
    };

    //send the data to the server
   
   const url ='https://api.nstack.in/v1/todos';
    final uri =Uri.parse(url);
    final response = await http.post(uri,
    body:jsonEncode(body),
    headers: 
    {'Content-Type':'application/json'}
    );


    //check the response

if(response.statusCode==201){
  titleController.text='';
  descriptionController.text='';
 // print('Data posted successfully');
  showSucessMessage('Data posted successfully');
}
else 
{
  // print('Failed to post data');
  showErrorMessage('Failed to post data');


}
  }


  void showSucessMessage(String message){
    final snackBar = SnackBar(
      content: Text(message,
      style: const TextStyle(color: Colors.white),
      
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


   void showErrorMessage(String message){
    final snackBar = SnackBar(
      content: Text(message,
      style: const TextStyle(color: Colors.white),
      
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  
}