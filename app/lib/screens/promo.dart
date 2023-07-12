import 'package:app/screens/login_register.dart';
import 'package:app/widgets/app_padding.dart';
import 'package:app/widgets/margin.dart';
import 'package:app/widgets/promo_item.dart';
import 'package:app/widgets/title_and_caption.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({
    super.key,
    required this.prevContext,
  });

  final BuildContext prevContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPadding(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Margin(
                margin: EdgeInsets.only(bottom: 50),
                child: TitleAndCaption(),
              ),
              const Margin(
                margin: EdgeInsets.only(bottom: 20),
                child: PromoItem(
                  text:
                      "Attendance has never been so easy, with facial recognition.",
                  iconPath: "assets/images/Face Recognition icon.svg",
                ),
              ),
              const Margin(
                margin: EdgeInsets.only(bottom: 20),
                child: PromoItem(
                  text: "Easily contact students via SMS or email.",
                  iconPath: "assets/images/Mail icon.svg",
                ),
              ),
              const Margin(
                margin: EdgeInsets.only(bottom: 50),
                child: PromoItem(
                  text:
                      "Manage your different classes and students effortlessly.",
                  iconPath: "assets/images/List icon.svg",
                ),
              ),
              Margin(
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(prevContext).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return const LoginRegisterScreen(isLogin: false);
                        },
                      ),
                    );
                  },
                  child: const Text("Get started"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(prevContext).push(
                    MaterialPageRoute(
                      builder: (_) {
                        return const LoginRegisterScreen(isLogin: true);
                      },
                    ),
                  );
                },
                child: const Text("I already have an account..."),
              )
            ],
          ),
        ),
      ),
    );
  }
}
