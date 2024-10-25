import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:shopping_app/services/database.dart';
import 'package:shopping_app/widget/support_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();

  Future getImage() async {
    // Check for storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    try {
      var image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage = File(image.path);
        setState(() {});
      } else {
        // Handle case when no image is selected
        print('No image selected');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No image selected")),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image")),
      );
    }
  }

  uploadItem() async {
    if (selectedImage != null &&
        nameController.text.isNotEmpty &&
        value != null) {
      String addId = randomAlphaNumeric(10);

      // Upload the image to Firebase Storage
      try {
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child("blogImage").child(addId);

        UploadTask task = firebaseStorageRef.putFile(selectedImage!);
        TaskSnapshot snapshot = await task;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Creating a product data map
        Map<String, dynamic> addProduct = {
          "Name": nameController.text,
          "Image": downloadUrl,
          "Price": priceController.text,
          "Details": detailController.text,
        };

        // Adding the product to Firestore
        await DatabaseMethods().addProduct(addProduct, value!).then((_) {
          selectedImage = null;
          nameController.text = "";
          value = null;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Product has been uploaded successfully!",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ));
        });
      } catch (e) {
        print('Error uploading product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Failed to upload product"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Please fill all the details before uploading!",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ));
    }
  }

  String? value;
  final List<String> categoryItem = ['Watch', 'Laptop', 'TV', 'Headphones'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text(
          "Add Product",
          style: AppWidget.semiboldTextFieldStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload the Product Image",
                style: AppWidget.lightTextFieldStyle(),
              ),
              SizedBox(
                height: 20,
              ),
              selectedImage == null
                  ? GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20)),
                          child: Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    )
                  : Center(
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Product Name",
                style: AppWidget.lightTextFieldStyle(),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Product Price",
                style: AppWidget.lightTextFieldStyle(),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: priceController,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Product Details",
                style: AppWidget.lightTextFieldStyle(),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  maxLines: 6,
                  controller: detailController,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                "Product Category",
                style: AppWidget.lightTextFieldStyle(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: categoryItem
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: AppWidget.semiboldTextFieldStyle(),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: ((value) => setState(
                          () {
                            this.value = value;
                          },
                        )),
                    dropdownColor: Colors.white,
                    hint: Text("Select Category"),
                    iconSize: 36,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    value: value,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    uploadItem();
                  },
                  child: Text(
                    "Add Product",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
