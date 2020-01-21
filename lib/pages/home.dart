import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:github_viewer/pages/user_detail.dart';
import 'dart:convert';
import 'dart:async';

import '../models/user.dart';
import '../exceptions/app_exception.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<User> users = [];
  bool loading = false;
  String error = '';
  List usersBeingDragged = [];
  final inputController = TextEditingController();

  void _submit() async {
    setState(() {
      this.loading = true;
    });

    try {
      final username = inputController.text;

      final duplicatedUser = users.any((user) => user.login == username);

      if (duplicatedUser) {
        throw AppException('Duplicated User!');
      }

      final User user = await fetchUser(username);

      setState(() {
        users.insert(0, user);
        error = '';
      });

      inputController.clear();

    } on AppException catch(err) {
      setState(() {
        error = err.message;
      });
    } on HttpException catch(err) {
      error = err.message;
    }

    setState(() {
      this.loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    inputController.dispose();
  }

  void handleUserDragStarted(user) {
    setState(() => usersBeingDragged.add(user));
    HapticFeedback.lightImpact();
  }

  void handleUserDragEnd(user) {
    setState(() {
      usersBeingDragged = usersBeingDragged.where((usr) => usr.id != user.id).toList();
    });
    HapticFeedback.lightImpact();
  }

  Future<User> fetchUser(String user) async {
      final http.Response response = await http.get('https://api.github.com/users/$user');
//      final http.Response response = await http.get('$api/users/1');

      if (response.statusCode == 404) {
        throw HttpException('User not Found');
      }

      if (response.statusCode != 200) {
        throw HttpException('Error. Try Again Later');
      }

      return User.fromJson(json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        padding: EdgeInsets.all(25),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 25),
                  child: TextFormField(
                    onChanged: (username) {
                      if (error.length > 0)
                        setState(() => error = '');
                    },
                    controller: inputController,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (username) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _submit();
                    },
                    decoration: InputDecoration(
                        filled: true,
                        errorText: error.length > 0 ? error : null,
                        labelText: 'Username',
                        helperText: ' ',
                        suffixIcon: loading ? (
                            Container(
                              width: 20,
                              height: 20,
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                        ) : (
                            error.length > 0 ? (
                                IconButton(
                                  icon: Icon(Icons.cancel),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() => error = '');
                                    inputController.clear();
                                  },
                                )
                            ) : IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                _submit();
                              },
                            )
                        )
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: (users != null ? (
                        ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: UserCard(user: users[index], handleDragStarted: handleUserDragStarted, handleDragEnd: handleUserDragEnd),
                            );
                          },
                        )
                    ) : Text('Write down some users!')),
                  ),
                ),
              ],
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOutBack,
              bottom: usersBeingDragged.isEmpty ? -60 : 30,
              left: 0,
              right: 0,
              child: DragTarget<User>(
                onAccept: (draggedUser) => setState(() => users = users.where((user) => user.id != draggedUser.id).toList()),
                builder: (BuildContext context, List incoming, List rejected) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: incoming.isEmpty ? 60 : 90,
                    height: incoming.isEmpty ? 60 : 90,
                    child: Icon(Icons.delete, color: Colors.grey),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


class UserCard extends StatelessWidget {
  final User user;
  final Function handleDragStarted;
  final Function handleDragEnd;

  UserCard({@required this.user, this.handleDragStarted, this.handleDragEnd});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserDetail(user: user))
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                LongPressDraggable<User>(
                  data: user,
                  onDragStarted: () => handleDragStarted(user),
                  onDragEnd: (_) => handleDragEnd(user),
                  feedback: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        image: DecorationImage(
                          image: NetworkImage(user.avatarUrl),
                        )
                    ),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(user.avatarUrl)
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                ),
                Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(user.bio, style: TextStyle(color: Colors.grey), maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

