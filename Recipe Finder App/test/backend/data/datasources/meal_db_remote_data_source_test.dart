import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:recipe_finder_app/backend/core/api_config.dart';
import 'package:recipe_finder_app/backend/data/datasources/meal_db_remote_data_source.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late Dio dio;
  late MealDbRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = MealDbRemoteDataSourceImpl(dio);
  });

  Response<dynamic> response(Map<String, dynamic> data) => Response(
    data: data,
    statusCode: 200,
    requestOptions: RequestOptions(path: ''),
  );

  group('searchMealsByName', () {
    test('hits API and maps meals', () async {
      when(
        () => dio.get(
          any(that: equals('$mealDbBaseUrl/search.php')),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => response({
          'meals': [
            {
              'idMeal': '1',
              'strMeal': 'Chicken',
              'strCategory': 'Poultry',
              'strArea': 'Canadian',
              'strMealThumb': 'thumb.jpg',
              'strInstructions': 'Cook it.',
            },
          ],
        }),
      );

      final meals = await dataSource.searchMealsByName('chicken');

      expect(meals, hasLength(1));
      expect(meals.first.name, 'Chicken');
      verify(
        () => dio.get(
          '$mealDbBaseUrl/search.php',
          queryParameters: {'s': 'chicken'},
        ),
      ).called(1);
    });
  });

  group('getMealDetails', () {
    test('returns null when API has no data', () async {
      when(
        () =>
            dio.get('$mealDbBaseUrl/lookup.php', queryParameters: {'i': '123'}),
      ).thenAnswer((_) async => response({'meals': null}));

      final meal = await dataSource.getMealDetails('123');

      expect(meal, isNull);
    });
  });
}
