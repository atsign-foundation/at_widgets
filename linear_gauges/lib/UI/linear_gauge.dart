import 'package:flutter/material.dart';

enum GaugeOrientation {vertical, horizontal}

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: const Center(child: LinearGauge()),
      ),
    );
  }
}

class LinearGauge extends StatelessWidget {
  const LinearGauge({Key? key}) : super(key: key);

  final int min = 0, max = 10000, divisions = 5, subDivisions = 5;
  final Color primaryColor = const Color(0xFFE9E9E9);
  final Color secondaryColor = const Color(0xFFBCC5C8);

  final double mazorLineWidth = 300;
  final double subDivisionThickness = 1;

  final double value = 4672;

  final orientation = GaugeOrientation.horizontal;

  @override
  Widget build(BuildContext context) {
    return parentWidgetBasedOnOrientation();
  }

  Widget parentWidgetBasedOnOrientation() {
    return (orientation == GaugeOrientation.vertical) ? 
      SizedBox(
        height: mazorLineWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _parentWidgetsChildren(),
        ),
      ) : SizedBox(
        width: mazorLineWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _parentWidgetsChildren(),
        ),
      );
  }

  List<Widget> _parentWidgetsChildren() {
    /// used to display the actual value of at an index
    final double multiplier = (max-min)/(divisions * subDivisions); 
    print('multiplier $multiplier');
    final double valueWidth = (mazorLineWidth/(max - min))*(value) ;
    print('valueWidth $valueWidth');

    /// number of lines that fall behind the value * thickness of one subDivision
    final double valueWidthAdditionalThickness = ((value / ( max/(divisions*subDivisions) )) - 1) * subDivisionThickness ;
  
    return [
          gradientShader(valueWidth + valueWidthAdditionalThickness),
          (orientation == GaugeOrientation.vertical) ? 
            const SizedBox(width: 2,) : 
            const SizedBox(height: 2,),
          mazorStraightLine(),
          orientation == GaugeOrientation.vertical ? 
            Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _childWidgetsChildren(multiplier),
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _childWidgetsChildren(multiplier),
          )
        ];
  }

  List<Widget> _childWidgetsChildren(double multiplier) {
    return List.generate( divisions * subDivisions, (index) {
      /// only for last index
      if(index == ((divisions * subDivisions)-1)){
        return majorSubDivision(((index + 1) * multiplier).ceil());
      }

      if(index%subDivisions == 0){
        /// if 0 (1st index) then send 0
        return majorSubDivision(index == 0 ? 0 : (index * multiplier ).ceil() );
      }

      return minorSubDivision();   

    });
  }

  Widget mazorStraightLine() {
    return orientation == GaugeOrientation.vertical ? 
      Container(
        width: 3,
        decoration: BoxDecoration(
          color: primaryColor,
        ),
      ) : Container(
        height: 3,
        decoration: BoxDecoration(
          color: primaryColor,
        ),
      );
  }

  Widget majorSubDivision(int index) {
    /// used Stack as we don't want the numbers to take size in the Row division
    return Stack(
      clipBehavior: Clip.none,
      children: [

        orientation == GaugeOrientation.vertical ?  
          Container(
            width: 10,
            height: subDivisionThickness,
            decoration: BoxDecoration(
              color: secondaryColor,
            ),
          ) 
        : Container(
          height: 10,
          width: subDivisionThickness,
          decoration: BoxDecoration(
            color: secondaryColor,
          ),
        ),

        orientation == GaugeOrientation.vertical ? 
          Positioned(
            left: 15, // 10(height) + 5(space) 
            top: -7, // random value that looks correct
            child: Text('\$$index')
          )
        : Positioned(
            top: 15, // 10(height) + 5(space) 
            left: -7, // random value that looks correct
            child: Text('\$$index')
        ),
      ],
    );
  }

  Widget minorSubDivision() {
    return orientation == GaugeOrientation.vertical ? 
      Container(
        width: 6,
        height: subDivisionThickness,
        decoration: BoxDecoration(
          color: primaryColor,
        ),
      ):
     Container(
      height: 6,
      width: subDivisionThickness,
      decoration: BoxDecoration(
        color: primaryColor,
      ),
    );
  }

  Widget gradientShader(double width) {
    return orientation == GaugeOrientation.vertical ? 
      Container(
        width: 10,
        height: width,
        decoration: BoxDecoration(
          color: Colors.green,
          border: const Border(),
          borderRadius: BorderRadius.circular( 4)
        ),
      )
    : Container(
      height: 10,
      width: width,
      decoration: BoxDecoration(
        color: Colors.green,
        border: const Border(),
        borderRadius: BorderRadius.circular( 4)
      ),
    );
  }
}