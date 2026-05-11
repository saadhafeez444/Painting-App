import 'package:flutter/material.dart';
import 'package:painting_app/models/onboarding_model.dart';
import 'package:painting_app/screens/login_screen.dart';



class ModelElements extends StatelessWidget {
  final ModelClass modelClass;

  const ModelElements({super.key, required this.modelClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      
      child: Column(
        children: [
      
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child:Container(
      
              width: MediaQuery.of(context).size.width * 1, height: 210,
              decoration: BoxDecoration(
           
                  image: DecorationImage(
                      image: AssetImage(modelClass.image.toString()), fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(14)
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Center(
              child: Text(
                modelClass.name.toString(),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color:Colors.teal,),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                modelClass.description.toString(),
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: Colors.teal,),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

