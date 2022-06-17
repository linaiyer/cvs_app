import 'package:flutter/material.dart';
import 'package:resarch_csv/utils/common_widgets.dart';
import 'package:resarch_csv/utils/styles.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getSize(context).height,
      width: getSize(context).width,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: appColor.withOpacity(0.5),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  color: appColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(appColor),
                    ),
                  ),
                  sizedBox(height: 5),
                  Text(
                    "Loading...",
                    style: goldenRegular(size: 12, textColor: appColor),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
