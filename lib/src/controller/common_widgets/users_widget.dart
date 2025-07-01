import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
class UsersWidget extends StatelessWidget {

  final String parents;
  final String driver;
  final String teachers;

  const UsersWidget({super.key,
    required this.parents,
    required this.driver,
    required this.teachers,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth*.025,vertical: screenHeight*.025),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreenText(
            text: "Users",
            fontSize: 18,
            fontWeight: FontWeight.w700,

          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GreenText(
                text: "Parents",
                fontSize: 16,
                fontWeight: FontWeight.w700,

              ),
              GreenText(
                text: parents,
                fontSize: 16,
                fontWeight: FontWeight.w700,

              ),
            ],),
          SizedBox(height: screenHeight * 0.005),
          Divider(color: Colors.blue),
          SizedBox(height: screenHeight * 0.005),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GreenText(
                text: "Drivers",
                fontSize: 16,
                fontWeight: FontWeight.w700,

              ),
              GreenText(
                text: driver,
                fontSize: 16,
                fontWeight: FontWeight.w700,

              ),
            ],),
          SizedBox(height: screenHeight * 0.005),
          Divider(color: Colors.blue),
          SizedBox(height: screenHeight * 0.005),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GreenText(
                text: "Teachers",
                fontSize: 16,
                fontWeight: FontWeight.w700,

              ),
              GreenText(
                text: teachers,
                fontSize: 16,
                fontWeight: FontWeight.w700,

              ),
            ],),
        ],),
    );
  }
}
