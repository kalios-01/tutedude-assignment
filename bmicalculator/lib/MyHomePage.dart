import 'dart:ui';

import 'package:bmicalculator/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bmicalculator/calculator_brain.dart';
import 'package:bmicalculator/ResultPage.dart';

enum Gender { male, female }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Gender? selectedGender;
  int UserHeight = 120;
  int UserWeight = 60;
  int UserAge = 25;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Calculator", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        maintainBottomViewPadding: true,
        top: true,
        right: true,
        left: true,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = Gender.male;
                        });
                      },
                      child: ReuseableCard(
                        Colour: selectedGender == Gender.male
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        Cardchild: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: FaIcon(
                                FontAwesomeIcons.male,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 100,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("MALE", style: kTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = Gender.female;
                        });
                      },
                      child: ReuseableCard(
                        Colour: selectedGender == Gender.female
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                            : Theme.of(context).colorScheme.surfaceVariant,
                        Cardchild: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: FaIcon(
                                FontAwesomeIcons.female,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 100,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("FEMALE", style: kTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReuseableCard(
                Colour: Theme.of(context).colorScheme.surfaceVariant,
                Cardchild: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("HEIGHT", style: kTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$UserHeight", style: kNumTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        SizedBox(width: 10),
                        Text("CM", style: kNumTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    Slider(
                      min: 0.0,
                      max: 500,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      thumbColor: Theme.of(context).colorScheme.secondary,
                      value: UserHeight.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          UserHeight = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ReuseableCard(
                      Colour: Theme.of(context).colorScheme.surfaceVariant,
                      Cardchild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("WEIGHT", style: kTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text("$UserWeight", style: kNumTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                heroTag: "weight_remove",
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                                onPressed: () {
                                  setState(() {
                                    UserWeight--;
                                  });
                                },
                                child: Icon(Icons.remove),
                              ),
                              SizedBox(width: 10),
                              FloatingActionButton(
                                heroTag: "weight_add",
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                                onPressed: () {
                                  setState(() {
                                    UserWeight++;
                                  });
                                },
                                child: Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReuseableCard(
                      Colour: Theme.of(context).colorScheme.surfaceVariant,
                      Cardchild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("AGE", style: kTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text("$UserAge", style: kNumTextStyle.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                heroTag: "age_remove",
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                                onPressed: () {
                                  setState(() {
                                    UserAge--;
                                  });
                                },
                                child: Icon(Icons.remove),
                              ),
                              SizedBox(width: 10),
                              FloatingActionButton(
                                heroTag: "age_add",
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary,
                                onPressed: () {
                                  setState(() {
                                    UserAge++;
                                  });
                                },
                                child: Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                BMI_Calculator calc = BMI_Calculator(height: UserHeight, weight: UserWeight);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResultPage(
                    bmiResult: calc.calculateBMI(),
                    resultText: calc.getResult(),
                    interpretation: calc.getInterpretation(),
                  )),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10),
                height: 55,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "CALCULATE YOUR BMI",
                    style: kTextStyle.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReuseableCard extends StatelessWidget {
  ReuseableCard({required this.Colour, required this.Cardchild});

  Color Colour;
  final Widget Cardchild;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colour,
      ),
      margin: EdgeInsets.all(10),
      child: Cardchild,
    );
  }
}
