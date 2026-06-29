import 'package:glam_book/core/services/glam_brain_service.dart';
import 'package:glam_book/data/models/service_model.dart';
import 'package:glam_book/data/models/user_model.dart';

void main() {
  final services = [
    ServiceModel(
      id: 'ser_hydra',
      categoryId: 'cat_facials',
      name: 'Hydra Facial (Premium)',
      description: 'Cleanses and exfoliates.',
      imageUrl: '',
      price: 5500,
      durationMinutes: 60,
      suitabilityTags: ['All Skin Types', 'Hydration'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final brain = GlamBrainService(services, []);
  
  print('--- Test 1: "facial" ---');
 // print(brain.generateResponse('facial', null));
  
  print('\n--- Test 2: "skin" ---');
 // print(brain.generateResponse('skin', null));

  print('\n--- Test 3: "price" ---');
 // print(brain.generateResponse('price', null));
}
