import 'package:flutter/material.dart';
import 'package:kathoram_app/models/user.dart';

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // 🔵 PROFILE IMAGE
         
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                 
                  image: DecorationImage(
                    image: AssetImage(user.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(width: 12),

          // 🧾 USER INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 const SizedBox(height: 8),
                Text(
                  " ${user.language}",
                  style:
                      TextStyle(color: const Color.fromARGB(255, 100, 92, 92)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${user.age} yrs  ",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 17, 17, 17)),
                    ),
                    const SizedBox(width: 19),
                     Image.asset('assets/Images/coin.png'),
                    const SizedBox(width: 2),
                    Text(
                      '${user.ratePerSec.toInt()}/Sec',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                if (user.callDate != null && user.callDuration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "${user.callDate}            ${user.callDuration}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),)
              ],
            ),
          ),

          // 📞 CALL + STATUS
          Column(
            children: [
              // STATUS TEXT
              if (user.isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                  child: Row(
                    children: [
                      Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10),
                      const Text(
                        "Online",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else if (user.isOnCall)
                Container(
                  padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                  child: Row(
                    children: [
                      Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 238, 112, 9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                               SizedBox(width: 10),
                      const Text(
                        "On call",
                        style: TextStyle(color: Color.fromARGB(255, 221, 106, 39), fontSize: 12),
                      ),
                    ],
                  ),
                )else(
                  Container(
                  padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                  child: Row(
                    children: [
                      Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 233, 68, 27),
                                  shape: BoxShape.circle,
                                ),
                              ),
                               SizedBox(width: 10),
                      const Text(
                        "Offline",
                        style: TextStyle(color: Color.fromARGB(255, 238, 72, 7), fontSize: 12),
                      ),
                    ],
                  ),
                )
                ),



              const SizedBox(height: 20),

              // CALL BUTTON
              GestureDetector(onTap: () => Navigator.pushNamed(context, '/call'),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: user.isOnCall
                   ? Colors.orange 
                    : user.isOnline
                  ?Colors.green
                  :Colors.red,
                  child: const Icon(Icons.call, color: Colors.white, size: 20),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
