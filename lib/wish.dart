import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';

class WishPage extends StatefulWidget {
  const WishPage({Key? key}) : super(key: key);

  @override
  State<WishPage> createState() => _WishPageState();
}

class _WishPageState extends State<WishPage> {


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pushReplacementNamed(context, '/');
        }, icon: const Icon(Icons.arrow_back),),
        title: const Text('Wish List'),
          centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: appState.wishs.length,
        itemBuilder: (context, index) {
          final item = appState.wishs[index];
          final url = appState.imageURLs[index];
          return Container(
            child: Row(
              children: [
                SizedBox(
                  height: 10,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: Image.network(
                      '$url',
                      width: 100,
                      height: 50,
                      fit:BoxFit.fill
                  ),
                ),
                const SizedBox(
                  width: 50,
                ),
                Text(
                    item,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                ),
                IconButton(onPressed: (){
                  FirebaseFirestore.instance.collection('WiSH').doc(item).delete();
                  appState.wishs.removeAt(index);
                  appState.imageURLs.removeAt(index);
                  appState.prices.removeAt(index);
                  appState.descriptions.removeAt(index);
                }, icon: Icon(Icons.delete)),
                const Divider(
                  thickness: 1,
                )
              ],
            )
          );
        },
      )
    );
  }
}
