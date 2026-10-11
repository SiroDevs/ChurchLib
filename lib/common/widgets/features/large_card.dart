import 'package:flutter/material.dart';

import 'package:styled_widget/styled_widget.dart';

class LargeCard extends StatelessWidget {
  final String cardName;
  final String image;
  final void Function()? onTap;
  const LargeCard({
    super.key,
    required this.cardName,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          width: MediaQuery.of(context).size.width - 28,
          height: 230,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/messages.png"),
              Text(
                cardName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              )
            ],
          )
              .card(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
        ),
      ],
    )
        .padding(left: 14, right: 14, top: 14)
        .gestures(onTap: onTap);
  }
}
