import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'modify.dart';

class DetailPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey <ScaffoldState>();

  var name;
  var price;
  var description;
  var user;
  var url;
  var id;  //doc id
  var uid;
  var time;
  var uptime;
  int thumb;

  DetailPage(this.name, this.price,this.description ,this.user, this.url,this.id,
      this.uid, this.uptime,this.time,this.thumb,{Key? key}) : super(key: key);

  @override
  _DetailPage createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();



    IconData icon;
    if (appState.wishs.contains(widget.name)) {
      icon = Icons.check;
    } else {
      icon = Icons.shopping_cart;
    }
    return MaterialApp(
      home: Scaffold(
        key: widget.scaffoldKey,
        appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: const Icon(Icons.arrow_back),),
            title: const Text('Detail'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.create),
                onPressed: () {
                  if(FirebaseAuth.instance.currentUser!.uid == widget.uid)
                    {
                      Navigator.push(context,MaterialPageRoute(
                          builder: (context) => ModifyPage(widget.name,
                              widget.price, widget.description,
                              widget.user,widget.url, widget.id,
                              widget.uid)));
                    }
                  else{
                    print('No access');
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  if(FirebaseAuth.instance.currentUser!.uid == widget.uid)
                    {
                      FirebaseFirestore.instance.collection('PRODUCT').doc(widget.id).delete();
                      FirebaseStorage.instance.ref().child('PRODUCT/${widget.name}.png').delete();
                      ScaffoldMessenger.of(widget.scaffoldKey.currentContext!).showSnackBar(const SnackBar(content: Text('delete')));
                    }
                  else{
                    print('No access');
                  }
                  },
              ),
            ]),
        body: Column(
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
                            child: Image.network(
                              '${widget.url}',
                              fit: BoxFit.fitWidth,
                            )
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Product: ${widget.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        )
                    ),
                    const SizedBox(
                      width: 20
                    ),
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      color: Colors.redAccent,
                      onPressed: (){
                        setState(() {
                          if (widget.thumb > 41)
                          {
                            ScaffoldMessenger.of(widget.scaffoldKey.currentContext!).showSnackBar(const SnackBar(content: Text(' YOU CAN DO IT ONLY OCNE')));
                          } else if(widget.thumb == 41)
                          {
                            widget.thumb ++;
                            FirebaseFirestore.instance.collection('PRODUCT').doc('${widget.id}').update({'thumb': widget.thumb});
                            ScaffoldMessenger.of(widget.scaffoldKey.currentContext!).showSnackBar(const SnackBar(content: Text('I LIKE IT')));
                            FirebaseFirestore.instance.collection('thumb').add(<String, dynamic>{
                              'Who clicked button uid': FirebaseAuth.instance.currentUser!.uid,
                              'Product name': widget.name
                            });
                          }
                        });
                        },
                    ),
                    Text('${widget.thumb}',style: TextStyle( color: Colors.redAccent, fontSize: 20),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('price: ${widget.price}\$',
                        style: const TextStyle(
                          fontSize: 25,
                        )
                    ),
                    const SizedBox(
                        width: 20
                    ),
                    FloatingActionButton(
                        onPressed: (){appState.toggleWish(widget.name, widget.price, widget.description, widget.url, widget.id);},
                        tooltip: 'Pick Image',
                        child: Icon(icon),
                      backgroundColor: Colors.indigoAccent,
                    )
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                Text('des: ${widget.description}',
                    style: const TextStyle(
                      fontSize: 20,
                    )
                ),
                SizedBox(
                  height: 60,
                ),
                Text('Creator(uid): <${widget.uid}>',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    )
                ),
                Text('Created time: ${widget.time}', style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                if(widget.uptime != null)
                  Text('Modified time: ${widget.uptime}', style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
