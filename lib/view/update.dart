import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Update extends StatefulWidget {
  const Update({super.key});

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController relationController = TextEditingController();

  var value = Get.arguments ?? '____';

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();
  File? imgFile;
  int firstDisp = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = value[1];
    phoneController.text = value[2];
    addressController.text = value[3];
    relationController.text = value[4];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update for Firebase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '이름을 수정하세요'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: '전화번호를 수정하세요'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: '주소를 수정하세요'),
              ),
              TextField(
                controller: relationController,
                decoration: InputDecoration(labelText: '관계를 수정하세요'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () => getImageFromGallery(ImageSource.gallery), 
                  child: Text('Gallery')
                ),
              ),
              firstDisp == 0
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  color: Colors.grey[200],
                  child: Center(
                    child: Image.network(value[5])
                  ),
                )
              : Container(
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
                  onPressed: () {
                    if(firstDisp == 0){
                      updateAction();
                    }else{
                      updateActionAll();
                    }
                  }, 
                  child: Text('수정')
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
    firstDisp += 1;
    setState(() {});
  }

  void updateAction() {
    FirebaseFirestore.instance.collection('address').doc(value[0]).update(
      {
        'name' : nameController.text.trim(),
        'phone' : phoneController.text.trim(),
        'address' : addressController.text.trim(),
        'relation' : relationController.text.trim()
      }
    );
    _showDialog();
  }

  void updateActionAll() async{
    // file은 지우고 새롭게 넣어야 함
    await deleteImage();
    String image = await preparingImage(); // firestorage에 image 있던거 '지우고' firestore의 주소를 '수정'

    FirebaseFirestore.instance.collection('address').doc(value[0]).update(
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

  Future<void> deleteImage() async{
    final firebaseStorage = FirebaseStorage.instance.ref().child('images').child('${nameController.text}.png');
    await firebaseStorage.delete();
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
      title: '수정 결과',
      middleText: '수정이 완료되었습니다.',
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