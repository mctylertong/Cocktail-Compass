class Drink {
  final String idDrink;
  final String strDrink;
  final String? strDrinkThumb;
  final String? strInstructions;
  final String? strCategory;
  final String? strAlcoholic;
  final String? strGlass;
  final String? strIBA;
  final String? strTags;

  final String? strIngredient1;
  final String? strIngredient2;
  final String? strIngredient3;
  final String? strIngredient4;
  final String? strIngredient5;
  final String? strIngredient6;
  final String? strIngredient7;
  final String? strIngredient8;
  final String? strIngredient9;
  final String? strIngredient10;
  final String? strIngredient11;
  final String? strIngredient12;
  final String? strIngredient13;
  final String? strIngredient14;
  final String? strIngredient15;
  
  final String? strMeasure1;
  final String? strMeasure2;
  final String? strMeasure3;
  final String? strMeasure4;
  final String? strMeasure5;
  final String? strMeasure6;
  final String? strMeasure7;
  final String? strMeasure8;
  final String? strMeasure9;
  final String? strMeasure10;
  final String? strMeasure11;
  final String? strMeasure12;
  final String? strMeasure13;
  final String? strMeasure14;
  final String? strMeasure15;

  Drink({
    required this.idDrink,
    required this.strDrink,
    this.strDrinkThumb,
    this.strInstructions,
    this.strCategory,
    this.strAlcoholic,
    this.strGlass,
    this.strIBA,
    this.strTags,
    this.strIngredient1,
    this.strIngredient2,
    this.strIngredient3,
    this.strIngredient4,
    this.strIngredient5,
    this.strIngredient6,
    this.strIngredient7,
    this.strIngredient8,
    this.strIngredient9,
    this.strIngredient10,
    this.strIngredient11,
    this.strIngredient12,
    this.strIngredient13,
    this.strIngredient14,
    this.strIngredient15,
    this.strMeasure1,
    this.strMeasure2,
    this.strMeasure3,
    this.strMeasure4,
    this.strMeasure5,
    this.strMeasure6,
    this.strMeasure7,
    this.strMeasure8,
    this.strMeasure9,
    this.strMeasure10,
    this.strMeasure11,
    this.strMeasure12,
    this.strMeasure13,
    this.strMeasure14,
    this.strMeasure15,
  });

  String get id => idDrink;
  String get name => strDrink;
  String? get thumbnailURL => strDrinkThumb;
  String? get category => strCategory;
  String? get glass => strGlass;
  String? get instructions => strInstructions;
  bool get isAlcoholic => strAlcoholic?.toLowerCase() == 'alcoholic';
  bool get isNonAlcoholic => strAlcoholic?.toLowerCase() == 'non alcoholic';
  String? get alcoholicType => strAlcoholic;
  List<String> get tags => strTags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? [];

  /// Get just the ingredient names without measures
  List<String> get ingredientNames {
    List<String?> ingredientList = [
      strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
      strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
      strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
    ];
    return ingredientList.where((i) => i != null && i.isNotEmpty).cast<String>().toList();
  }

  List<String> get ingredients {
    List<String> result = [];
    
    List<String?> ingredientList = [
      strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
      strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
      strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
    ];
    
    List<String?> measureList = [
      strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
      strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
      strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
    ];
    
    for (int i = 0; i < ingredientList.length; i++) {
      String? ingredient = ingredientList[i];
      String? measure = measureList[i];
      
      if (ingredient != null && ingredient.isNotEmpty) {
        String measurement = measure?.trim() ?? '';
        String ingredientWithMeasure = measurement.isEmpty 
            ? ingredient 
            : '$measurement $ingredient';
        result.add(ingredientWithMeasure);
      }
    }
    
    return result;
  }

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      idDrink: json['idDrink'] ?? '',
      strDrink: json['strDrink'] ?? '',
      strDrinkThumb: json['strDrinkThumb'],
      strInstructions: json['strInstructions'],
      strCategory: json['strCategory'],
      strAlcoholic: json['strAlcoholic'],
      strGlass: json['strGlass'],
      strIBA: json['strIBA'],
      strTags: json['strTags'],
      strIngredient1: json['strIngredient1'],
      strIngredient2: json['strIngredient2'],
      strIngredient3: json['strIngredient3'],
      strIngredient4: json['strIngredient4'],
      strIngredient5: json['strIngredient5'],
      strIngredient6: json['strIngredient6'],
      strIngredient7: json['strIngredient7'],
      strIngredient8: json['strIngredient8'],
      strIngredient9: json['strIngredient9'],
      strIngredient10: json['strIngredient10'],
      strIngredient11: json['strIngredient11'],
      strIngredient12: json['strIngredient12'],
      strIngredient13: json['strIngredient13'],
      strIngredient14: json['strIngredient14'],
      strIngredient15: json['strIngredient15'],
      strMeasure1: json['strMeasure1'],
      strMeasure2: json['strMeasure2'],
      strMeasure3: json['strMeasure3'],
      strMeasure4: json['strMeasure4'],
      strMeasure5: json['strMeasure5'],
      strMeasure6: json['strMeasure6'],
      strMeasure7: json['strMeasure7'],
      strMeasure8: json['strMeasure8'],
      strMeasure9: json['strMeasure9'],
      strMeasure10: json['strMeasure10'],
      strMeasure11: json['strMeasure11'],
      strMeasure12: json['strMeasure12'],
      strMeasure13: json['strMeasure13'],
      strMeasure14: json['strMeasure14'],
      strMeasure15: json['strMeasure15'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDrink': idDrink,
      'strDrink': strDrink,
      'strDrinkThumb': strDrinkThumb,
      'strInstructions': strInstructions,
      'strCategory': strCategory,
      'strAlcoholic': strAlcoholic,
      'strGlass': strGlass,
      'strIBA': strIBA,
      'strTags': strTags,
      'strIngredient1': strIngredient1,
      'strIngredient2': strIngredient2,
      'strIngredient3': strIngredient3,
      'strIngredient4': strIngredient4,
      'strIngredient5': strIngredient5,
      'strIngredient6': strIngredient6,
      'strIngredient7': strIngredient7,
      'strIngredient8': strIngredient8,
      'strIngredient9': strIngredient9,
      'strIngredient10': strIngredient10,
      'strIngredient11': strIngredient11,
      'strIngredient12': strIngredient12,
      'strIngredient13': strIngredient13,
      'strIngredient14': strIngredient14,
      'strIngredient15': strIngredient15,
      'strMeasure1': strMeasure1,
      'strMeasure2': strMeasure2,
      'strMeasure3': strMeasure3,
      'strMeasure4': strMeasure4,
      'strMeasure5': strMeasure5,
      'strMeasure6': strMeasure6,
      'strMeasure7': strMeasure7,
      'strMeasure8': strMeasure8,
      'strMeasure9': strMeasure9,
      'strMeasure10': strMeasure10,
      'strMeasure11': strMeasure11,
      'strMeasure12': strMeasure12,
      'strMeasure13': strMeasure13,
      'strMeasure14': strMeasure14,
      'strMeasure15': strMeasure15,
    };
  }
}

class DrinkResponse {
  final List<Drink>? drinks;

  DrinkResponse({this.drinks});

  factory DrinkResponse.fromJson(Map<String, dynamic> json) {
    return DrinkResponse(
      drinks: json['drinks'] != null
          ? (json['drinks'] as List).map((drink) => Drink.fromJson(drink)).toList()
          : null,
    );
  }
}
