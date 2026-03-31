class User {
  final String name;
  final int age;
  final String language;
  final String image;
  final bool isOnline;
  final bool isOnCall;
  final double ratePerSec;
  final String? callDate;      // add this
  final String? callDuration;

  User(
    
    
    {
    required this.name,
    required this.age,
    required this.language,
    required this.image,
    required  this.ratePerSec,
    this.isOnline = false,
    this.isOnCall = false,
   this.callDate,        // optional, only for call history
    this.callDuration,
    
  });
}
