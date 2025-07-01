import 'package:pick_up_pal/src/controller/constant/linkers/linkers.dart';
class PickupOverviewWidget extends StatelessWidget {

  final String pickupScheduled;
  final String pickupCompleted;

   PickupOverviewWidget({super.key,
     required this.pickupScheduled,
     required this.pickupCompleted,
   });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return  Container(
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
            text: "pickup Overview",
            fontSize: 18,
            fontWeight: FontWeight.w700,

          ),
          SizedBox(height: screenHeight*.01),
          Row(
            children: [
              Expanded(
                child: GreenText(
                  text: "Pickups\nScheduled",
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                child: GreenText(
                  text: "Pickups\nCompleted",
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.start,
                ),
              ),
            ],),
          SizedBox(width: screenWidth*.01),
          Row(
            children: [
              Expanded(
                child: GreenText(
                  text: "8",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                child: GreenText(
                  text: "3",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.start,
                ),
              ),
            ],),
        ],),
    );
  }
}
