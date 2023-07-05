import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'app.dart';

class AddProduct extends StatefulWidget {
  AddProduct({Key? key}) : super(key: key);
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

  PickedFile? _image;

  Future getImageFromGallery() async{
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(
            (){ _image = image;}
    );
  }

  Future<File> downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final fileName = url.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final _ProductnameController = TextEditingController();
    final _PriceController = TextEditingController();
    final _DescriptionController = TextEditingController();

    return MaterialApp(
      title: 'Flutter layout demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add'),
          leading: TextButton(onPressed: (){ Navigator.pushReplacementNamed(context, '/');}, child: const Text('Cancel',style: TextStyle(color: Colors.black, fontSize:10))),
          centerTitle: true,
          actions: <Widget>[
            TextButton(onPressed: ()
            async {
              int price = int.parse(_PriceController.text);
              if(_image != null)
                {
                  FirebaseFirestore.instance
                      .collection('PRODUCT')
                      .add(<String, dynamic>{
                    'name': _ProductnameController.text,
                    'price': _PriceController.text,
                    'description': _DescriptionController.text,
                    'user': FirebaseAuth.instance.currentUser!.displayName,
                    'update time': null,
                    'uid': FirebaseAuth.instance.currentUser!.uid,
                    'time':  FieldValue.serverTimestamp(),
                    'thumb': appState.favoriteCount

                  }).then((value) async {
                    final reference = FirebaseStorage.instance.ref().child('PRODUCT/${_ProductnameController.text}.png');
                    final task = reference.putFile(File(_image!.path));
                    await task.whenComplete(() => null);
                    print("data added and image uploaded");
                  }).catchError((error) => print("Failed to add user: $error"));
                }
              else if(_image == null)
                {
                  final file = await downloadImage('https://handong.edu/site/handong/res/img/logo.png');
                  if (file.existsSync()) {
                    final reference = FirebaseStorage.instance.ref().child('PRODUCT/${_ProductnameController.text}.png');
                    final task = reference.putFile(file);
                    await task.whenComplete(() => null);
                  } else {
                    print('File does not exist.');
                  }
                  FirebaseFirestore.instance.collection('PRODUCT').add(<String, dynamic>{
                    'name': _ProductnameController.text,
                    'price': _PriceController.text,
                    'description': _DescriptionController.text,
                    'user': FirebaseAuth.instance.currentUser!.displayName,
                    'uid': FirebaseAuth.instance.currentUser!.uid,
                    'update time': null,
                    'time':  FieldValue.serverTimestamp(),
                    'thumb': appState.favoriteCount
                  })
                      .then((value) => print("data added and image uploaded"))
                      .catchError((error) => print("Failed to add user: $error"));
                  }
              _DescriptionController.clear;
              _PriceController.clear;
              _ProductnameController.clear;
            },

                child: const Text('Save',style: TextStyle(color: Colors.black))),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
          children: [
            Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 10 / 7,
                        child: Hero(
                          tag: "hero",
                          child: Material(
                            color: Colors.transparent,
                            child: _image == null
                                ? Image.asset('assets/logo.png', fit: BoxFit.fill,)
                                : Image.file(File(_image!.path), fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                    ]
                )
            ),
            const SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                    onPressed: getImageFromGallery,
                    tooltip: 'Pick Image',
                    child: const Icon(Icons.camera_alt_outlined)
                )
              ],
            ),
            TextField(
              controller: _ProductnameController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Product Name',
              ),
            ),
            TextField(
              controller: _PriceController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Price',
              ),
            ),
            TextField(
              controller: _DescriptionController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Description',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
