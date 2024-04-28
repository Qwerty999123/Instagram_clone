import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

pickImage(ImageSource source) async{
  ImagePicker _imagePicker = ImagePicker();
  XFile? im = await _imagePicker.pickImage(source: source);

  if(im!=null){
    return await im.readAsBytes();
  }

  print("Image not found");
  
}

showSnackBar(BuildContext context, String message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}