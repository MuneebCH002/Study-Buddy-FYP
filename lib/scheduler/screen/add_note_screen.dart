import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studybuddyapp/scheduler/data/firestor.dart';
import 'package:studybuddyapp/service/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;


import '../../shared/colors.dart';


class Add_creen extends StatefulWidget {
  const Add_creen({super.key,required this.onAdd});
  final void Function() onAdd;
  @override
  State<Add_creen> createState() => _Add_creenState();
}

class _Add_creenState extends State<Add_creen> {
  DateTime selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );
      print("picked time is: ${pickedTime!.hour}: ${pickedTime.minute}");
      if (pickedTime!=null) {
        setState(() {
          selectedDateTime =DateTime(pickedDate.year,pickedDate.month,pickedDate.day,pickedTime.hour,pickedTime.minute);
        });
      }
    }
  }

  final title = TextEditingController();
  final subtitle = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  int indexx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Create Task",
            style:TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27)),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Add Title:",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title_widgets(),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Add Subtitle:",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                subtite_wedgite(),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Select Category:",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                imagess(),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Select Data & Time:",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Text(
                    //   'Selected Date and Time: ${selectedDateTime.toLocal()}',
                    //   style: TextStyle(fontSize: 16, color: Colors.black),
                    // ),
                    const SizedBox(width: 5),
                    // ElevatedButton(
                    //   onPressed: () => ,
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.blue, // Background color
                    //     onPrimary: Colors.white, // Text color
                    //     padding:
                    //         EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    //   ),
                    //   child: Text(
                    //     'Select Date and Time',
                    //     style: TextStyle(fontSize: 16),
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomButton("Select Date & Time", () {
                            _selectDateTime(context);
                          }),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                button()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:Theme.of(context).primaryColor,
            minimumSize: const Size(170, 48),
          ),
          onPressed: () {
            FirestoreDatasource().AddNote(
              subtitle.text,
              title.text,
              indexx,
              selectedDateTime,
            );
            print('selectedDateTime $selectedDateTime');
             NotificationService().scheduleNotification(title.text, subtitle.text,selectedDateTime);
            Fluttertoast.showToast(
                msg: "Task Created Successfully",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.pop(context);
            widget.onAdd;
          },
          child: const Text('Add task',style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(170, 48),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }

  Container imagess() {
    return Container(
      height: 180,
      child: ListView.builder(
        itemCount: 5,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                indexx = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 7 : 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 2,
                    color: indexx == index ?Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
                width: 140,
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Image.asset('images/${index}.png'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget title_widgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: title,
          focusNode: _focusNode1,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              hintText: 'Title',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xffc5c5c5),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: custom_green,
                  width: 2.0,
                ),
              )),
        ),
      ),
    );
  }

  Padding subtite_wedgite() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          maxLines: 2,
          controller: subtitle,
          focusNode: _focusNode2,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            hintText: 'Subtitle',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xffc5c5c5),
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: custom_green,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget CustomButton(String text, VoidCallback onpressed) {
    return ElevatedButton(
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16,color: Colors.white),
      )
    );
  }
}
