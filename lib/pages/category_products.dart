import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/services/database.dart';
import 'package:shopping_app/widget/support_widget.dart';

class CategoryProduct extends StatefulWidget {
  final String category;
  CategoryProduct({required this.category});

  @override
  State<CategoryProduct> createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  Stream? categoryStream;

  getontheload() async {
    categoryStream = await DatabaseMethods().getProducts(widget.category);
    setState(() {}); // To rebuild the widget once the stream is set
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allProducts() {
    return StreamBuilder(
      stream: categoryStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator()); // Loading indicator
        }
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.6, mainAxisSpacing: 10),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return Container(
              margin: EdgeInsets.only(right: 5),
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Image.network(
                    ds["Image"],
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    ds["Name"],
                    style: AppWidget.semiboldTextFieldStyle(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "\$${ds["Price"].toString()}",
                        style: TextStyle(
                          color: Color(0xFFfd6f3e),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xFFfd6f3e),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: allProducts()),
          ],
        ),
      ),
    );
  }
}
