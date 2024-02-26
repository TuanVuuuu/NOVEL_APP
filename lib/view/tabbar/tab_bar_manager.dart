import 'package:audiobook/admin/view/auto_get_data.dart';
import 'package:audiobook/view/home_page/home_page.dart';
import 'package:audiobook/view/text_to_speech/text_to_speech.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabBarManager extends StatefulWidget {
  const TabBarManager({super.key});

  @override
  State<TabBarManager> createState() => _TabBarManagerState();
}

class _TabBarManagerState extends State<TabBarManager> {
  int menuIndex = 0;
  int tabIndex = 0;
  bool isGrid = false;
  List<String> listIndexTitle = [
    'Khám phá',
    'Tủ sách',
    'Hồ sơ',
    'Admin',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(listIndexTitle[menuIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const TextToSpeechPage());
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: IndexedStack(
        index: menuIndex,
        children: [
          const HomePage(),
          Container(),
          Container(),
          const AutoGetData()
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: menuIndex,
          onTap: (idx) {
            setState(() {
              menuIndex = idx;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: "Khám phá",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Tủ sách",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: "Admin",
            ),
          ],
        ),
      ),
    );
  }
}
