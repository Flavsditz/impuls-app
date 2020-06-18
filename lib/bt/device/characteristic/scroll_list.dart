import 'package:flutter/material.dart';

class ScrollList extends StatelessWidget {
  const ScrollList({
    Key key,
    @required List listData,
  })  : _listData = listData,
        super(key: key);

  final List _listData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 30,
          reverse: true,
          itemBuilder: (BuildContext ctxt, int index) {
            return Container(
                height: 30, child: Text((_listData != [] ? '$_listData' : '')));
          }),
    );
  }
}
