import 'package:flutter/material.dart';
import 'package:github_viewer/models/user.dart';
import '../repositories/fetch_stars.dart';
import 'package:github_viewer/models/star.dart';

class StarList extends StatefulWidget {
  final List<Star> initialStars;
  final User user;

  StarList({this.initialStars, this.user});

  @override
  _StarListState createState() => _StarListState();
}

class _StarListState extends State<StarList> {
  List<Star> stars;
  int page = 1;
  bool isLoading = false;

  ScrollController _scrollController = ScrollController();

  void _addScrollListener() {
    _scrollController.addListener(handleInfiniteScroll);
  }

  void handleInfiniteScroll() async {
    final triggerFetchMoreSize = _scrollController.position.maxScrollExtent;

    if (_scrollController.position.pixels == triggerFetchMoreSize) {
      setState(() => page++);
      final lastStars = await _fetchMoreStars();

      if (lastStars.length == 0) {
        _scrollController.removeListener(handleInfiniteScroll);
      }
    }
  }

  Future<List<Star>> _fetchMoreStars() async {
    setState(() => isLoading = true);

    final response = await fetchStars(user: widget.user, page: page);

    setState(() {
      stars = stars + response;
    });

    setState(() => isLoading = false);

    return response;
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
        itemCount: stars.length + 1,
        itemBuilder: (context, index) {
          if (index == stars.length) {
            return Opacity(
              opacity: isLoading ? 1 : 0,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
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
