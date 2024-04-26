import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/Screen/task_screen.dart';
import 'package:http/http.dart' as http;


class HomeScreenPage extends StatefulWidget{
const  HomeScreenPage({super.key});
@override
  State<HomeScreenPage>createState()=>_HomeScreenState();
}
class _HomeScreenState extends State<HomeScreenPage>{
  bool isLoading = true;
  List items = [];
  @override
  void initState(){
    super.initState();
    fetchTodos();
  }
  Widget build(BuildContext context){
    return  Scaffold(
      appBar: AppBar(
        title:const Text('Todo App',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
        ),
         backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
      ),
     
      // To add the list of items

      body: Visibility(
        visible: isLoading,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodos,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text('No items found',
              style: Theme.of(context).textTheme.headline3,
              
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index){
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(

                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        '${index + 1}'
                        ),
                        ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value){
                        if (value == 'edit'){
                              
                          //navigate to edit screen
                              
                          navigateToEditTaskScreen(item);
                        }
                        else if (value == 'delete'){
                          
                          //delete the item
                          
                          deleteById(id);
                              
                              
                        }
                      
                      },
                      itemBuilder: (context){
                        return [
                        const  PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                          ),
                          
                       const   PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                          ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddTaskScreen,
        label: const Text('Add Task'),
      ),
    );
  }

  // For Navigating the task to edit function

Future<void> navigateToEditTaskScreen(Map item)async{
    final route = MaterialPageRoute(
      builder:
     (context)=>TaskScreenPage(todo: item),
     );
     await Navigator.push(context, route);
      setState(() {
        isLoading = true;
      });
      fetchTodos();
  }

  //Navigate the page to Add task 

 Future <void> navigateToAddTaskScreen()async{
    final route = MaterialPageRoute(
      builder:
     (context)=>TaskScreenPage(),
     );
     await Navigator.push(context, route);
     setState(() {
       isLoading = true;
     });
     fetchTodos();
  }

  Future<void>deleteById(String id)async{

    //Delete the item from the server

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200){

      // Remove the item from the list

      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });

    }
    else{
      showErrorMessage('Failed to delete the item');
    }
    }

  //get all the data from the server
  Future<void> fetchTodos()async{
    final url ='https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (
      response.statusCode == 200){
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
      
      
    }
    else{
      
    }
    setState(() {
      isLoading = false;
    });
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