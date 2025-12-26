import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Insert extends StatefulWidget {
  const Insert({super.key});

  @override
  State<Insert> createState() => _InsertState();
}

class _InsertState extends State<Insert> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController relationController = TextEditingController();

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  File? imgFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert for Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '이름을 입력하세요'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: '전화번호를 입력하세요'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: '주소를 입력하세요'),
              ),
              TextField(
                controller: relationController,
                decoration: InputDecoration(labelText: '관계를 입력하세요'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () => getImageFromGallery(ImageSource.gallery), 
                  child: Text('Gallery')
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: imageFile == null
                  ? Text('Image is not selected')
                  : Image.file(File(imageFile!.path))
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () => insertAction(), 
                  child: Text('입력')
                ),
              )
            ],
          ),
        ),
      ),
    );
  } // build

  // --- Functions ---
  void getImageFromGallery(ImageSource imageSource) async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageFile = XFile(pickedFile!.path);
    imgFile = File(imageFile!.path);
    setState(() {});
  }

  void insertAction() async{
    String image = await preparingImage(); // firestorage에 image를 넣고 주소를 firestore에 넣음

    FirebaseFirestore.instance.collection('address').add(
      {
        'name' : nameController.text.trim(),
        'phone' : phoneController.text.trim(),
        'address' : addressController.text.trim(),
        'relation' : relationController.text.trim(),
        'image' : image
      }
    );
    _showDialog();
  }

  Future<String> preparingImage() async{
    final firebaseStorage = FirebaseStorage.instance
                                           .ref()
                                           .child('images')
                                           .child('${nameController.text.trim()}.png');
    await firebaseStorage.putFile(imgFile!);
    String downloadURL = await firebaseStorage.getDownloadURL();
    return downloadURL;
  }

  void _showDialog(){
    Get.defaultDialog(
      title: '입력 결과',
      middleText: '입력이 완료되었습니다.',
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          }, 
          child: Text('OK')
        )
      ]
    );
  }
}