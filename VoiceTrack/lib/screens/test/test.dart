import 'package:flutter/material.dart';
import 'package:voicetrack/widgets/navigationbar.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leadingWidth: double.infinity,
        leading: Row(children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text('광안제3동',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
          Icon(Icons.keyboard_arrow_down_outlined)
        ]),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 10), child: Icon(Icons.search)),
          Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.menu)),
          Icon(Icons.notifications_none)
        ],
      ),
      body: Container(
        height: 130,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/image/cat.jpg',
                  cacheWidth: 130,
                  cacheHeight: 130,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        '귀여운 고양이 (귀여움, 길냥이, zZZ)',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      // width: 160,
                    ),
                    Text(
                      '수영구 광안동 끌올 10분 전',
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 11),
                    ),
                    Text(
                      '999,999원',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: Colors.grey,
                        ),
                        Text(
                          '99',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigationbar(),
    ));
  }
}
