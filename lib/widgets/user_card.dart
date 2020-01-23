import 'package:flutter/material.dart';

import '../pages/user_detail.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final Function handleDragStarted;
  final Function handleDragEnd;

  UserCard({@required this.user, this.handleDragStarted, this.handleDragEnd});

  Widget _buildUserName(String name) {
    final bool nameIsSet = name != null && name.length > 0;
    return Text(
      nameIsSet ? name : 'Name not provided',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: nameIsSet ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUserBio(String bio) {
    final bool bioIsSet = bio != null && bio.length > 0;
    return Text(
      bioIsSet ? bio : 'Bio not provided',
      style: TextStyle(
        color: Colors.grey,
        fontStyle: bioIsSet ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

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
                _buildUserName(user.name),
                _buildUserBio(user.bio)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

