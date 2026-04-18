import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../models/plant.dart';
import '../providers/plant_provider.dart';

class AddEditPlantScreen extends StatefulWidget {
  final Plant? plant;
  const AddEditPlantScreen({super.key, this.plant});

  @override
  State<AddEditPlantScreen> createState() => _AddEditPlantScreenState();
}

class _AddEditPlantScreenState extends State<AddEditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _waterController = TextEditingController();
  final _mistController = TextEditingController();
  final _fertilizerController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _nameController.text = widget.plant!.name;
      _speciesController.text = widget.plant!.species;
      _waterController.text = widget.plant!.waterIntervalDays.toString();
      _mistController.text = widget.plant!.mistIntervalDays.toString();
      _fertilizerController.text = widget.plant!.fertilizerIntervalDays
          .toString();
      if (widget.plant!.imagePath != null) {
        _imageFile = File(widget.plant!.imagePath!);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
  }

  Future<void> _cropImage(String path) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Plant Photo',
          toolbarColor: Colors.green[700],
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Plant Photo'),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  void _savePlant() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      final plant = Plant(
        id: widget.plant?.id ?? const Uuid().v4(),
        name: _nameController.text,
        species: _speciesController.text,
        imagePath: _imageFile?.path,
        waterIntervalDays: int.tryParse(_waterController.text) ?? 0,
        mistIntervalDays: int.tryParse(_mistController.text) ?? 0,
        fertilizerIntervalDays: int.tryParse(_fertilizerController.text) ?? 0,
        nextWaterDate:
            widget.plant?.nextWaterDate ??
            now.add(Duration(days: int.tryParse(_waterController.text) ?? 0)),
        nextMistDate:
            widget.plant?.nextMistDate ??
            now.add(Duration(days: int.tryParse(_mistController.text) ?? 0)),
        nextFertilizerDate:
            widget.plant?.nextFertilizerDate ??
            now.add(
              Duration(days: int.tryParse(_fertilizerController.text) ?? 0),
            ),
      );

      if (widget.plant == null) {
        Provider.of<PlantProvider>(context, listen: false).addPlant(plant);
      } else {
        Provider.of<PlantProvider>(context, listen: false).updatePlant(plant);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant == null ? 'Add Plant' : 'Edit Plant'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plant Name (e.g. Fernie)',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: 'Species (e.g. Boston Fern)',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Care Intervals (Days) - Enter 0 to disable",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _waterController,
              decoration: const InputDecoration(
                labelText: 'Water Every X Days',
                prefixIcon: Icon(Icons.water_drop),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mistController,
              decoration: const InputDecoration(
                labelText: 'Mist Every X Days',
                prefixIcon: Icon(Icons.cloud),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fertilizerController,
              decoration: const InputDecoration(
                labelText: 'Fertilize Every X Days',
                prefixIcon: Icon(Icons.eco),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePlant,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('SAVE PLANT'),
            ),
          ],
        ),
      ),
    );
  }
}
