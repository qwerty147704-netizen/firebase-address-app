import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_address_app/model/address.dart';
import 'package:firebase_address_app/view/insert.dart';
import 'package:firebase_address_app/view/update.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주소록 검색'),
        actions: [
          IconButton(
            onPressed: () => Get.to(Insert()), 
            icon: Icon(Icons.add_outlined)
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance // = sql query문장
                .collection('address')
                .orderBy('name', descending: false)
                .snapshots(), 
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = snapshot.data!.docs;
          return ListView(
            children: documents.map((e) => buildItemWidget(e)).toList(), // map: for문
          );
        }
      ),
    );
  }
 // build

  // --- Widgets ---
  Widget buildItemWidget(DocumentSnapshot doc){
    final address = Address(
      name: doc['name'], 
      phone: doc['phone'], 
      address: doc['address'], 
      relation: doc['relation'], 
      image: doc['image']
    );

    return Slidable(
        endActionPane: ActionPane(
          motion: BehindMotion(), 
          children: [
            SlidableAction(
              backgroundColor: Colors.red,
              icon: Icons.delete_forever,
              label: '삭제',
              onPressed: (context) async{
                FirebaseFirestore.instance
                                 .collection('address')
                                 .doc(doc.id)
                                 .delete();
                await deleteImage(address.name); // store 지우고 storage 지움
              }
            )
          ]
        ),
      child: GestureDetector(
        onTap: () {
        Get.to(
          Update(),
          arguments: [
            doc.id,
            address.name,
            address.phone,
            address.address,
            address.relation,
            address.image,
          ]
        );
        },
        child: Card(
            child: ListTile(
              title: Row(
                children: [
                  Image.network(
                    address.image,
                    width: 70,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text('이름: ${address.name} \n전화번호: ${address.phone}'),
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }

  // --- Functions ---
  Future<void> deleteImage(String name) async{
    final firebaseStorage = FirebaseStorage.instance.ref().child('images').child('$name.png');
    await firebaseStorage.delete();
  }
}