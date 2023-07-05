
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:shrine/more.dart';

import 'app.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<String> imageUrls = [];
  ThemeData get theme => Theme.of(context);

  @override
  void initState() {
    super.initState();
    getImageUrls();
  }

  Future<void> getImageUrls() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('PRODUCT').get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;
    List<String> urls = [];
    for (QueryDocumentSnapshot doc in docs) {
      String imageUrl = await FirebaseStorage.instance.ref().child('PRODUCT/${doc['name']}.png').getDownloadURL();
      urls.add(imageUrl);
    }
    setState(() {
      imageUrls = urls;
    });
  }

  String dropdownvalue = 'ASC';
  // List of items in our dropdown menu
  var items = [
    'ASC',
    'DESC',
  ];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.person,
                  semanticLabel: 'person',
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/profile');
                },
              ),
              title: const Text('Main'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/wish');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/add');
                  },
                ),
              ]),
          body: Column(
            children: [
              DropdownButton(
                value: dropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                },
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('PRODUCT').orderBy('price', descending: dropdownvalue == 'DESC').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        imageUrls.isEmpty) {
                      return const CircularProgressIndicator();
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data?.docs[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 15 / 7,
                                    child: FutureBuilder<String>(
                                      future: FirebaseStorage.instance
                                          .ref()
                                          .child('PRODUCT/${doc!['name']}.png')
                                          .getDownloadURL(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.network(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.fromLTRB(16.0, 0.0, 0, 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc!['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            doc!['price'],
                                            style: theme.textTheme.headline6
                                                ?.copyWith(fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child : TextButton(
                                              style: TextButton.styleFrom(
                                                textStyle: const TextStyle(fontSize: 15),
                                              ),
                                              onPressed: () async {
                                                String? uptime;
                                                if(doc['update time'] == null)
                                                  {
                                                    uptime = null;
                                                  }
                                                else
                                                  {
                                                    uptime = doc['update time'].toDate().toString();
                                                  }
                                                //print('${doc!['time']},${doc!['price']}, ${doc!['description']}, ${doc!['user']},${FirebaseAuth.instance.currentUser!.uid}');
                                                String url = await FirebaseStorage.instance.ref().child('PRODUCT/${doc!['name']}.png').getDownloadURL();
                                                Navigator.push(context,MaterialPageRoute(
                                                    builder: (context) => DetailPage(doc!['name'],
                                                        doc!['price'], doc!['description'],
                                                        doc!['user'],url, doc.id,
                                                        doc!['uid'],uptime,doc!['time'].toDate().toString(),doc!['thumb'],
                                                    )
                                                )
                                                );
                                                },
                                              child: const Text('more'),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if(appState.wishs.contains(doc!['name']))
                                Container(
                                  padding: const EdgeInsets.fromLTRB(160, 2, 0, 0),
                                  child: const Icon(Icons.check_box, color: Colors.blue,),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )
      ),
    );
  }
}
