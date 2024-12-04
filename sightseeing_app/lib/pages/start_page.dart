
import 'package:flutter/material.dart';
import 'package:sightseeing_app/pages/options_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/map.jpg'), context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/map.jpg'),
                fit: BoxFit.cover,
                opacity: 1.0,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.darken))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sightseeing App',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.blue,
                          offset: Offset(5, 5),
                        ),
                      ]),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OptionsPage()))
                                  },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                elevation: 8,
                                padding: EdgeInsetsDirectional.symmetric(
                                    vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                'Start',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              )))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: ElevatedButton(
                            onPressed: () => print('Resume'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                  strokeAlign: BorderSide.strokeAlignInside),
                              elevation: 8,
                              padding:
                                  EdgeInsetsDirectional.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: Text(
                              'Resume',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 24),
                            )),
                      ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () => print('History'),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignInside),
                                elevation: 8,
                                padding: EdgeInsetsDirectional.symmetric(
                                    vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: Text(
                                'History',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 24),
                              )))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
