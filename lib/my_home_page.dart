import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:number_paginator/number_paginator.dart';

import 'drug_card_widget.dart';
import 'drug_information_page.dart';
import 'favorite_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pageIndex = 0;
  int pagesElementNumber = 10;
  int total = 0;
  String keyWord = "";

  List<Map<String, dynamic>> favoriteDrugs = [];
  List<String> favoriteDrugNames = [];

  // Load data
  Future<Map<String, dynamic>> loadData() async {
    final response =
    await http.post(Uri.parse('http://10.0.2.2:3009/get_drug_list'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(<String, String>{
          'keyWord': keyWord,
          'start': ((pageIndex) * pagesElementNumber).toString(),
          'end': ((pageIndex + 1) * pagesElementNumber - 1).toString(),
        }));
    late dynamic data;

    if (response.statusCode == 200) {
      // Successful response
      data = json.decode(response.body)["data"];
      total = json.decode(response.body)["length"];
      log('Received data from Flask backend: $data');
    } else {
      // Error handling for unsuccessful response
      log('Failed to fetch data. Status code: ${response.statusCode}');
    }
    return {"data": data};
  }

  @override
  Widget build(BuildContext context) {
    late dynamic data;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title),
        // Heart icon in app bar
        actions: [
          IconButton(
            onPressed: () {
            // 當按下IconButton時導航到 FavoritePage，並傳遞 favoriteDrugNames
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritePage(
                    favoriteDrugs: favoriteDrugs,
                    favoriteDrugNames: favoriteDrugNames,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border),
          )
        ],
      ),
      body: FutureBuilder(
        future: loadData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            // Get the data from the snapshot
            data = snapshot.data;
            print(data);
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          pageIndex = 0;
                          keyWord = value;
                          if (keyWord == "") {
                            setState(() {
                              // refresh
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            // refresh
                          });
                        },
                        icon: const Icon(Icons.search))
                  ],
                ),
                Expanded(
                  // Dynamic show the drug list
                  child: ListView.builder(
                    itemCount: data!["data"].length,
                    itemBuilder: (BuildContext context, int index) {
                      String imgSrc = "";
                      String? imageLink =
                      data["data"][index]["image_link"].toString();
                      if (imageLink != "") {
                        imgSrc = data["data"][index]["image_link"].toString();
                      } else {
                        imgSrc =
                        "https://cyberdefender.hk/wp-content/uploads/2021/07/404-01-scaled.jpg";
                      }
                      // ListTile show the drug info
                      return GestureDetector(
                        onTap: () {
                          print(data['data']);
                          print(index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrugInformationPage(
                                data: data['data'][index],
                                imgSrc: imgSrc,
                              ),
                            ),
                          );
                        },
                        // DrugCardWidget show the drug card
                        child: DrugCardWidget(
                          favoriteDrugs: favoriteDrugs,
                          favoriteDrugNames: favoriteDrugNames,
                          item: data['data'][index],
                          imgSrc: imgSrc,
                        ),
                      );
                    },
                  ),
                ),
                NumberPaginator(
                  numberPages: (total / 50).ceil(),
                  onPageChange: (int index) {
                    setState(() {
                      pageIndex = index;
                    });
                  },
                  config: const NumberPaginatorUIConfig(
                    height: 54.0,
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}