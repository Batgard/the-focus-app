import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thefocusapp/data/persistence/KeyValueStorage.dart';
import 'package:thefocusapp/data/persistence/LocalKeyValueStorage.dart';
import 'package:thefocusapp/scenes/favorite/presentation/FavoriteScreenView.dart';

class FavoriteState extends State<FavoriteScreenView> {
  final KeyValueStorage storage = LocalKeyValueStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFavorites(),
      builder: buildUi,
    );
  }

  Widget buildUi(BuildContext context, AsyncSnapshot asyncSnapshot) {
    return asyncSnapshot.hasData
        ? Scaffold(
            appBar: AppBar(
              title: Text("Favorites"),
            ),
            body: buildList(asyncSnapshot.data))
        : Scaffold(
            appBar: AppBar(
              title: Text("Favorites"),
            ),
            body: Center(
              child: const CircularProgressIndicator(),
            )
    );
  }

  Widget buildList(List<String> data) {
    return ListView.builder(
        padding: EdgeInsets.all(16),
        itemBuilder: (BuildContext context, int position) {
          return data.length > position? ListTile(title: Text(data[position]))
              : Divider();
        }).build(context);
  }

  Future<List<String>> getFavorites() async {
    return storage.load("favoriteWordPair");
  }
}
