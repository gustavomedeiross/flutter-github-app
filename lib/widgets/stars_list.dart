import 'package:flutter/material.dart';
import '../repositories/fetch_stars.dart';
import 'package:github_viewer/models/star.dart';

class StarList extends StatefulWidget {
  final List<Star> initialStars;

  StarList({this.initialStars});

  @override
  _StarListState createState() => _StarListState();
}

class _StarListState extends State<StarList> {
  List<Star> stars;
  int page = 1;
  bool isLoading = false;

  ScrollController _scrollController = ScrollController();

  void _addScrollListener() {
    _scrollController.addListener(() {
      handleInfiniteScroll();
    });
  }

  void handleInfiniteScroll() async {
    final triggerFetchMoreSize = 0.9 * _scrollController.position.maxScrollExtent;

    if (_scrollController.position.pixels > triggerFetchMoreSize) {
      setState(() => page++);
      final lastStars = await _fetchMoreStars();

      if (lastStars.length == 0) {
        _scrollController.dispose();
      }
    }
  }

  Future<List<Star>> _fetchMoreStars() async {
    setState(() => isLoading = true);

    final response = await fetchStars(page: page);

    print ('length: ${response.length}');

    setState(() {
      stars = stars + response;
    });

    setState(() => isLoading = false);

    return stars;
  }

  @override
  void initState() {
    super.initState();
    setState(() => stars = widget.initialStars);
    this._addScrollListener();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: isLoading ? (stars.length + 1) : stars.length,
        itemBuilder: (context, index) {
          if (isLoading && index == (stars.length - 1)) {
            return Container(
              child: CircularProgressIndicator(),
            );
          }

          return Card(
            child: Container(
              padding: EdgeInsets.all(10),
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: NetworkImage(stars[index].owner.avatarUrl),
                      )
                  ),
                ),
                title: Text(stars[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(stars[index].owner.login),
              ),
            ),
          );
        },
      ),
    );
  }
}
