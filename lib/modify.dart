import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'app.dart';

class ModifyPage extends StatefulWidget {
  var name;
  var price;
  var description;
  var user;
  var url;
  var id;  //doc id
  var uid;

  ModifyPage(this.name, this.price,this.description ,this.user, this.url,this.id,this.uid,{Key? key}) : super(key: key);

  @override
  _ModifyPage createState() => _ModifyPage();
}

class _ModifyPage extends State<ModifyPage> {

  PickedFile? _image;

  Future getImageFromGallery() async{
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState(
            (){ _image = image;}
    );
  }

  final _ProductnameController = TextEditingController();
  final _PriceController = TextEditingController();
  final _DescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(onPressed: (){
              Navigator.of(context).popUntil((route) => route.isFirst);
//              Navigator.pushReplacementNamed(context, '/');
            }, icon: const Icon(Icons.arrow_back),),
            title: const Text('Edit'),
            centerTitle: true,
            actions: [
              TextButton(onPressed: ()
              async {
                FirebaseFirestore.instance.collection('PRODUCT').doc('${widget.id}').update({'name': _ProductnameController.text});
                FirebaseFirestore.instance.collection('PRODUCT').doc('${widget.id}').update({'price': _PriceController.text});
                FirebaseFirestore.instance.collection('PRODUCT').doc('${widget.id}').update({'description': _DescriptionController.text});
                FirebaseFirestore.instance.collection('PRODUCT').doc('${widget.id}').update({'thumb': appState.favoriteCount});
                FirebaseFirestore.instance.collection('PRODUCT').doc('${widget.id}').update({'update time': FieldValue.serverTimestamp()});
                final reference = FirebaseStorage.instance.ref().child('PRODUCT/${_ProductnameController.text}.png');
                final task = reference.putFile(File(_image!.path));
                await task.whenComplete(() => null);
              },
                  child: const Text('Save'))
            ]),
        body: ListView(
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
                                  ? Image.network('${widget.url}',fit: BoxFit.fitWidth,)
                                  : Image.file(File(_image!.path), fit: BoxFit.fitWidth,)
                          ),
                        ),
                      ),
                    ]
                )
            ),
            const SizedBox(
              height: 60,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                    labelText: 'Product',
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
                //Text(widget.time, style: const TextStyle(fontSize: 15,)),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
