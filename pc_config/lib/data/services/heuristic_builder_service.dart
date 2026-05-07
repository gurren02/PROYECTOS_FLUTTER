import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/isar_provider.dart';
import '../repositories/pc_part_repository.dart';
import '../models/pc_part_model.dart';
import '../../presentation/providers/build_state_provider.dart';
import '../../domain/usecases/compatibility_validator.dart';

final heuristicBuilderServiceProvider = Provider<HeuristicBuilderService>((ref) {
  final isar = ref.watch(isarProvider);
  return HeuristicBuilderService(PCPartRepository(isar));
});

class HeuristicBuilderService {
  final PCPartRepository _repository;

  HeuristicBuilderService(this._repository);

  /// Genera una configuración desde cero o refina una existente.
  Future<List<String>> generateConfigFromPrompt(String prompt, {BuildState? currentState}) async {
    final lowerPrompt = prompt.toLowerCase();
    
    // 1. Extraer presupuesto
    double? maxBudget = _extractBudget(lowerPrompt);
    
    // Si no hay presupuesto explícito pero pide "más barata", bajamos el total actual
    if (currentState != null && maxBudget == null) {
      if (lowerPrompt.contains('barata') || lowerPrompt.contains('costosa') || lowerPrompt.contains('precio')) {
        if (lowerPrompt.contains('menos') || lowerPrompt.contains('baja') || lowerPrompt.contains('barata')) {
           maxBudget = currentState.totalPrice * 0.8;
        }
      }
    }

    // 2. Extraer etiquetas (intención)
    List<String> activeTags = _extractTags(lowerPrompt);
    
    // Si estamos refinando, podemos heredar tags o simplemente usar las nuevas
    if (activeTags.isEmpty && currentState == null) {
      activeTags.add('gaming'); // Default a gaming
    }

    // 3. Extraer marcas preferidas
    List<String> preferredBrands = _extractBrands(lowerPrompt);

    // 4. Obtener todas las piezas
    final allParts = await _repository.getAllParts();
    
    final categories = ['CPU', 'Motherboard', 'RAM', 'GPU', 'PSU', 'Storage', 'Case'];
    
    final budgetDistribution = {
      'CPU': 0.20,
      'Motherboard': 0.10,
      'RAM': 0.10,
      'GPU': 0.35,
      'PSU': 0.08,
      'Storage': 0.07,
      'Case': 0.10,
    };

    List<String> selectedPartIds = [];
    BuildState tempState = BuildState(
      selectedParts: {},
      totalPrice: 0,
      totalWatts: 0,
      compatibilityErrors: []
    );

    double totalSpent = 0;

    for (final category in categories) {
      final partsInCategory = allParts.where((p) => p.type == category).toList();
      
      List<Map<String, dynamic>> scoredParts = partsInCategory.map((part) {
        double score = 0;
        
        // Bonus por tags
        if (part.tags != null) {
          for (final tag in activeTags) {
            if (part.tags!.contains(tag)) score += 15;
          }
        }

        // Bonus por marca preferida
        final partNameLower = part.name.toLowerCase();
        for (final brand in preferredBrands) {
          if (partNameLower.contains(brand.toLowerCase())) {
            score += 50; // Gran prioridad a la marca
          }
        }

        // Penalización/Bonus por presupuesto
        if (maxBudget != null) {
          final targetBudget = maxBudget * (budgetDistribution[category] ?? 1.0);
          if (part.price > targetBudget) {
            score -= 30; 
          } else {
             score += (part.price / targetBudget) * 10; 
          }
        }

        return {'part': part, 'score': score};
      }).toList();

      scoredParts.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

      bool found = false;
      for (final scoredPart in scoredParts) {
        final PCPartModel part = scoredPart['part'];
        final validation = CompatibilityValidator.validate(part, tempState);
        
        if (validation.isCompatible) {
          if (maxBudget != null) {
             double remainingBudget = maxBudget - totalSpent;
             // Si nos pasamos mucho del presupuesto restante, intentamos buscar una opción más barata
             // a menos que sea la única compatible.
             if (part.price > remainingBudget * 1.2 && scoredParts.any((p) => (p['part'] as PCPartModel).price <= remainingBudget)) {
                continue;
             }
          }

          selectedPartIds.add(part.partId!);
          final newSelected = Map<String, PCPartModel>.from(tempState.selectedParts);
          newSelected[category] = part;
          tempState = tempState.copyWith(selectedParts: newSelected);
          totalSpent += part.price;
          found = true;
          break;
        }
      }

      if (!found) {
        // Fallback al más compatible/barato
        for (final scoredPart in scoredParts) {
           final PCPartModel part = scoredPart['part'];
           final validation = CompatibilityValidator.validate(part, tempState);
           if (validation.isCompatible) {
              selectedPartIds.add(part.partId!);
              final newSelected = Map<String, PCPartModel>.from(tempState.selectedParts);
              newSelected[category] = part;
              tempState = tempState.copyWith(selectedParts: newSelected);
              totalSpent += part.price;
              break;
           }
        }
      }
    }

    return selectedPartIds;
  }

  double? _extractBudget(String prompt) {
    final RegExp budgetRegex = RegExp(r'\$?\s?(\d+(?:,\d{3})*(?:\.\d+)?)');
    final matches = budgetRegex.allMatches(prompt);
    for (final match in matches) {
      final valueStr = match.group(1)?.replaceAll(',', '');
      if (valueStr != null) {
        final val = double.tryParse(valueStr);
        if (val != null && val > 1000) return val;
      }
    }
    return null;
  }

  List<String> _extractTags(String prompt) {
    List<String> activeTags = [];
    final tagKeywords = {
      'gaming': ['jugar', 'juegos', 'gaming', 'gamer', 'videojuegos'],
      'diseño': ['diseño', 'render', 'edicion', 'autocad', 'blender', '3d'],
      'economica': ['barata', 'economica', 'bajo presupuesto', 'estudio', 'ofimatica', 'basica'],
      '4k': ['4k', 'ultra', 'maximo', 'entusiasta', 'high end'],
      '1080p': ['1080p', 'full hd', 'calidad precio', 'media'],
      'ssd': ['ssd', 'rapido', 'veloz', 'm.2', 'nvme'],
      'espacioso': ['espacio', 'grande', 'gabinete', 'espacioso', 'atx', 'flujo', 'aire'],
      'blanco': ['blanco', 'white', 'estetica'],
      'rgb': ['rgb', 'luces', 'colores', 'gamer']
    };

    tagKeywords.forEach((tag, keywords) {
      for (final kw in keywords) {
        if (prompt.contains(kw)) {
          activeTags.add(tag);
          break;
        }
      }
    });
    return activeTags;
  }

  List<String> _extractBrands(String prompt) {
    final brands = ['asus', 'gigabyte', 'aorus', 'xpg', 'nzxt', 'samsung', 'kingston', 'intel', 'amd', 'nvidia', 'corsair'];
    List<String> detected = [];
    for (final brand in brands) {
      if (prompt.contains(brand)) {
        detected.add(brand);
      }
    }
    return detected;
  }
}
