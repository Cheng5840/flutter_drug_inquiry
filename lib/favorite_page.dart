import 'package:flutter/material.dart';
import 'drug_card_widget.dart'; // 引入 DrugCardWidget
import 'drug_information_page.dart';
import 'package:http/http.dart' as http;

class FavoritePage extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteDrugs; // 保存完整藥物數據
  final List<String> favoriteDrugNames;

  FavoritePage({
    required this.favoriteDrugs,
    required this.favoriteDrugNames,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView.builder(
        itemCount: favoriteDrugs.length,
        itemBuilder: (context, index) {
          String imgSrc = "";
          String? imageLink =
          favoriteDrugs[index]["image_link"].toString();
          if (imageLink != "") {
            imgSrc = favoriteDrugs[index]["image_link"].toString();
          } else {
            imgSrc =
            "https://cyberdefender.hk/wp-content/uploads/2021/07/404-01-scaled.jpg";
          }
          return GestureDetector(
            onTap: () {
              print("favoritedrugs:$favoriteDrugs");
              print(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrugInformationPage(
                    data: favoriteDrugs[index],
                    imgSrc: imgSrc,
                  ),
                ),
              );
            },
            // DrugCardWidget show the drug card
            child: DrugCardWidget(
              favoriteDrugs: favoriteDrugs,
              favoriteDrugNames: favoriteDrugNames,
              item: favoriteDrugs[index],
              imgSrc: imgSrc,
            ),
          );
        },
      ),
    );
  }
}
