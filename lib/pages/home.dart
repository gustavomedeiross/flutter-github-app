import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../models/user.dart';
import '../widgets/user_card.dart';
import '../exceptions/app_exception.dart';
import '../repositories/fetch_user.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SharedPreferences _sharedPreferences;
  List<User> users = [];
  bool loading = false;
  String error = '';
  List usersBeingDragged = [];
  final inputController = TextEditingController();


  void _handleSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());

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

      _setUsersOnSharedPreferences(users);

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
  void initState() {
    super.initState();
    _getUsersFromSharedPreferences();
  }

  void _setUsersOnSharedPreferences(List<User> users) {
    _sharedPreferences.setStringList('users', users.map((user) => json.encode(user.toJson())).toList());
  }

  void _getUsersFromSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    final List usersJson = _sharedPreferences.getStringList('users');

    if (usersJson != null) {
      final List users = usersJson.map((user) => User.fromJson(json.decode(user))).toList();

      setState(() {
        this.users = users;
      });
    }
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

  Widget _buildUsernameInput() {
    return TextFormField(
      onFieldSubmitted: (_) => _handleSubmit(),
      onChanged: (username) {
        if (error.length > 0)
          setState(() => error = '');
      },
      controller: inputController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        filled: true,
        errorText: error.length > 0 ? error : null,
        labelText: 'Username',
        helperText: ' ',
        suffixIcon: _buildUsernameInputSuffixIcon(),
      ),
    );
  }

  Widget _buildUsernameInputSuffixIcon() {
    if (loading) {
      return Container(
        width: 20,
        height: 20,
        padding: EdgeInsets.all(10),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (error.length > 0) {
      return IconButton(
          icon: Icon(Icons.cancel),
          color: Colors.red,
          onPressed: () {
            setState(() => error = '');
            inputController.clear();
          },
      );
    }

    return IconButton(
      icon: Icon(Icons.add),
      onPressed: _handleSubmit,
    );
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
                  child: _buildUsernameInput(),
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
              bottom: usersBeingDragged.isEmpty ? -100 : 30,
              left: 0,
              right: 0,
              child: DragTarget<User>(
                onAccept: (draggedUser) {
                  setState(() => users = users.where((user) => user.id != draggedUser.id).toList());
                  _setUsersOnSharedPreferences(users);
                },
                builder: (BuildContext context, List incoming, List rejected) {

                  if (incoming.isNotEmpty) {
                    HapticFeedback.lightImpact();
                  }

                  return Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: incoming.isEmpty ? 60 : 100,
                      height: incoming.isEmpty ? 60 : 100,
                      child: Icon(Icons.delete, color: Colors.red),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red),
                      ),
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
