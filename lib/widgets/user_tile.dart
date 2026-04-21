import 'package:flutter/material.dart';
import '../models/user.dart';

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData callIcon;

    if (user.isOnline) {
      statusColor = Colors.green;
      statusText = "Online";
      callIcon = Icons.call;
    } else if (user.isOnCall) {
      statusColor = Colors.orange;
      statusText = "On Call";
      callIcon = Icons.call;
    } else {
      statusColor = Colors.red;
      statusText = "Offline";
      callIcon = Icons.headset;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              user.image,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 10),

          /// TEXT SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  user.language,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text("${user.age} yrs"),
                    const SizedBox(width: 10),
                    const Icon(Icons.monetization_on, size: 14),
                    Text("${user.ratePerSec}/Sec"),
                  ],
                ),
              ],
            ),
          ),

          /// RIGHT SIDE (STATUS + CALL BUTTON)
          Column(
            children: [
              /// STATUS
              Row(
                children: [
                  Icon(Icons.circle, size: 10, color: statusColor),
                  const SizedBox(width: 5),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 12, color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              /// CALL BUTTON
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/call',
                    arguments: {
                      'name': user.name,
                      'image': user.image,
                      'coins': 100,
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: statusColor,
                  child: Icon(callIcon, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
