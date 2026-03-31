import 'package:flutter/material.dart';
import 'package:kathoram_app/models/user.dart';
import 'package:kathoram_app/theme/app_colors.dart';
import 'package:kathoram_app/widgets/user_tile.dart';

class ChatHomeScreen extends StatefulWidget {
  ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<User> users = [
    User(
        name: "Isha Fathima",
        age: 25,
        language: "Malayali",
        image: "assets/images/girl1.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Priya Kumar",
        age: 23,
        language: "Malayali",
        image: "assets/images/girl2.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Julie James",
        age: 24,
        language: "Malayali",
        image: "assets/images/girl3.png",
        isOnCall: true,
        ratePerSec: 5),
    User(
        name: "Riya",
        age: 24,
        language: "Malayali",
        image: "assets/images/girl4.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Geetha",
        age: 26,
        language: "Malayali",
        image: "assets/images/girl5.png",
        isOnline: true,
        ratePerSec: 5),
    User(
        name: "Diya Krishna",
        age: 22,
        language: "Malayali",
        image: "assets/images/girl6.png",
        isOnline: false,
        ratePerSec: 5),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildTabContent() {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserTile(
          user: users[index],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:AppColors.bgcolor,

        /// 📱 BODY
        body: Column(
          children: [
            Stack(
              children: [
                Image.asset("assets/images/Rectangle2.png"),
                //1
                Positioned(
                    top: 100,
                    left: 20,
                    child: Image.asset("assets/images/text.png", width: 150)),
                //2
                Positioned(
                  top: 50,
                  right: 25,
                  child: Row(
                    children: [
                      Image.asset("assets/images/coin.png",
                          width: 50, height: 90),
                      //SizedBox(width: 5),
                      Text("100",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
        
                //3
                Positioned(
                    right: 30,
                    top: 150,
                    bottom: 10,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add, color: AppColors.primary),
                      label: Text('Add Coins',
                          style: TextStyle(color: AppColors.primary)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        textStyle: TextStyle(fontSize: 13),
                      ),
                    )),
              ],
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgcolor,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
        
                    // ✅ TABBAR (SEPARATED FROM APPBAR)
        
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color(0xFFE0E0E0), // grey background
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white, // selected tab
                          borderRadius: BorderRadius.circular(30),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.black, // selected text
                        unselectedLabelColor: Colors.grey, // unselected text
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: "All"),
                          Tab(text: "New"),
                          Tab(text: "Popular"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
        
                    // TAB VIEW
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          buildTabContent(),
                          buildTabContent(),
                          buildTabContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        ///  BOTTOM NAVIGATION
      ),
    );
  }
}


