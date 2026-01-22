import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cost_config_model.dart';

class CostConfigProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  
  CostConfigModel _config = CostConfigModel(
    id: const Uuid().v4(),
    materialCosts: _getDefaultMaterialCosts(),
    laborRates: _getDefaultLaborRates(),
    designFees: const DesignFeeConfig(),
    updatedAt: DateTime.now(),
  );

  CostConfigModel get config => _config;

  /// Update entire config
  void updateConfig(CostConfigModel newConfig) {
    _config = newConfig.copyWith(updatedAt: DateTime.now());
    notifyListeners();
  }

  /// Update tax percentage
  void updateTaxPercentage(double percentage) {
    _config = _config.copyWith(
      taxPercentage: percentage,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Update markup percentage
  void updateMarkupPercentage(double percentage) {
    _config = _config.copyWith(
      markupPercentage: percentage,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Update design fees
  void updateDesignFees(DesignFeeConfig fees) {
    _config = _config.copyWith(
      designFees: fees,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Add or update material cost
  void updateMaterialCost(String key, MaterialCost cost) {
    final updatedMaterials = Map<String, MaterialCost>.from(_config.materialCosts);
    updatedMaterials[key] = cost;
    _config = _config.copyWith(
      materialCosts: updatedMaterials,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Remove material cost
  void removeMaterialCost(String key) {
    final updatedMaterials = Map<String, MaterialCost>.from(_config.materialCosts);
    updatedMaterials.remove(key);
    _config = _config.copyWith(
      materialCosts: updatedMaterials,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Add or update labor rate
  void updateLaborRate(String key, LaborRate rate) {
    final updatedRates = Map<String, LaborRate>.from(_config.laborRates);
    updatedRates[key] = rate;
    _config = _config.copyWith(
      laborRates: updatedRates,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Remove labor rate
  void removeLaborRate(String key) {
    final updatedRates = Map<String, LaborRate>.from(_config.laborRates);
    updatedRates.remove(key);
    _config = _config.copyWith(
      laborRates: updatedRates,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Reset to defaults
  void resetToDefaults() {
    _config = CostConfigModel(
      id: _uuid.v4(),
      materialCosts: _getDefaultMaterialCosts(),
      laborRates: _getDefaultLaborRates(),
      designFees: const DesignFeeConfig(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Get default material costs
  static Map<String, MaterialCost> _getDefaultMaterialCosts() {
    return {
      'tiles_vitrified': const MaterialCost(
        category: 'Flooring',
        item: 'Vitrified Tiles',
        unit: 'sq ft',
        pricePerUnit: 80,
        quality: 'Premium',
      ),
      'tiles_ceramic': const MaterialCost(
        category: 'Flooring',
        item: 'Ceramic Tiles',
        unit: 'sq ft',
        pricePerUnit: 50,
        quality: 'Standard',
      ),
      'wood_flooring': const MaterialCost(
        category: 'Flooring',
        item: 'Wooden Flooring',
        unit: 'sq ft',
        pricePerUnit: 200,
        quality: 'Premium',
      ),
      'paint_emulsion': const MaterialCost(
        category: 'Paint',
        item: 'Emulsion Paint',
        unit: 'sq ft',
        pricePerUnit: 35,
        brand: 'Asian Paints',
        quality: 'Premium',
      ),
      'paint_texture': const MaterialCost(
        category: 'Paint',
        item: 'Texture Paint',
        unit: 'sq ft',
        pricePerUnit: 60,
        brand: 'Asian Paints',
        quality: 'Premium',
      ),
      'gypsum_board': const MaterialCost(
        category: 'Ceiling',
        item: 'Gypsum Board',
        unit: 'sq ft',
        pricePerUnit: 120,
        quality: 'Standard',
      ),
      'electrical_wiring': const MaterialCost(
        category: 'Electrical',
        item: 'Wiring & Fittings',
        unit: 'sq ft',
        pricePerUnit: 60,
        quality: 'Standard',
      ),
      'plumbing': const MaterialCost(
        category: 'Plumbing',
        item: 'Pipes & Fittings',
        unit: 'sq ft',
        pricePerUnit: 40,
        quality: 'Standard',
      ),
    };
  }

  /// Get default labor rates
  static Map<String, LaborRate> _getDefaultLaborRates() {
    return {
      'helper': const LaborRate(
        skillLevel: 'Helper',
        rateType: RateType.perDay,
        amount: 500,
        description: 'General helper labor',
      ),
      'skilled': const LaborRate(
        skillLevel: 'Skilled',
        rateType: RateType.perDay,
        amount: 800,
        description: 'Skilled mason/carpenter',
      ),
      'expert': const LaborRate(
        skillLevel: 'Expert',
        rateType: RateType.perDay,
        amount: 1200,
        description: 'Expert craftsman',
      ),
      'electrician': const LaborRate(
        skillLevel: 'Skilled',
        rateType: RateType.perDay,
        amount: 1000,
        description: 'Licensed electrician',
      ),
      'plumber': const LaborRate(
        skillLevel: 'Skilled',
        rateType: RateType.perDay,
        amount: 900,
        description: 'Licensed plumber',
      ),
      'painter': const LaborRate(
        skillLevel: 'Skilled',
        rateType: RateType.perSqFt,
        amount: 25,
        description: 'Professional painter',
      ),
    };
  }
}
