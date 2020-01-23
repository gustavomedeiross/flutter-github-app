import 'package:flutter/material.dart';

import 'package:github_viewer/models/star.dart';
import 'package:github_viewer/models/user.dart';
import '../repositories/fetch_stars.dart';
import '../widgets/stars_list.dart';

class UserDetail extends StatefulWidget {
  final User user;
  UserDetail({Key key, @required this.user}) : super(key: key);

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  User user;
  Future<List<Star>> initialStars;
  int page = 1;


  @override
  void initState() {
    super.initState();

    user = widget.user;
  }

  Widget _buildUserBio(String bio) {
    final bool bioExists = bio != null && bio.length > 0;
    return Text(
      bioExists ? bio : 'Bio not provided',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontStyle: bioExists ? FontStyle.normal : FontStyle.italic,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Container(
        padding: EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(user.avatarUrl),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      )
                  ),
                  Container(
                    child: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: _buildUserBio(user.bio),
                  )
                ],
              ),
            ),

            Container(
             child: Divider(),
              margin: EdgeInsets.symmetric(vertical: 10),
            ),

            Expanded(
              child: Container(
                child: FutureBuilder(
                  future: fetchStars(user: user),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return StarList(initialStars: snapshot.data, user: user);
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child: Text('ERRO!', style: TextStyle(color: Colors.red)),
                      );
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

