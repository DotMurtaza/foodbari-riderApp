import 'package:flutter/material.dart';
import 'package:foodbari_deliver_app/Controller/auth_controller.dart';
import 'package:get/get.dart';

import '../message/chat_list_screen.dart';
import '../order/order_screen.dart';
import '../order_history/order_history_screen.dart';
import '../profile/profile_screen.dart';
import 'component/bottom_navigation_bar.dart';
import 'main_controller.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _homeController = MainController();
  final authController = Get.find<AuthController>();

  late List<Widget> pageList;

  @override
  void initState() {
    super.initState();
    authController.getDeliveryBoyInfo();
    authController.getCurrentLocation().then((value) async {
      await authController.updateLocation();
    });

    pageList = [
      const OrderHistoryScreen(),
      const OrderScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      //  key: _homeController.scaffoldKey,
      // drawer: const DrawerWidget(),
      body: StreamBuilder<int>(
        initialData: 0,
        stream: _homeController.naveListener.stream,
        builder: (context, AsyncSnapshot<int> snapshot) {
          int index = snapshot.data ?? 0;
          return pageList[index];
        },
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }
}
