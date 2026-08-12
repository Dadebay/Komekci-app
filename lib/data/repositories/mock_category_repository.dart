import '../models/service_category.dart';

class MockCategoryRepository {
  List<ServiceCategory> all() => const [
    ServiceCategory(
      id: 'beauty',
      nameTk: 'Gözellik we ideg',
      nameRu: 'Красота и уход',
    ),
    ServiceCategory(id: 'health', nameTk: 'Saglyk', nameRu: 'Здоровье'),
    ServiceCategory(
      id: 'home',
      nameTk: 'Öý hyzmatlary',
      nameRu: 'Домашние услуги',
    ),
    ServiceCategory(id: 'auto', nameTk: 'Awtoulag', nameRu: 'Автоуслуги'),
    ServiceCategory(id: 'education', nameTk: 'Bilim', nameRu: 'Обучение'),
    ServiceCategory(
      id: 'business',
      nameTk: 'Biznes hyzmatlary',
      nameRu: 'Бизнес-услуги',
    ),
  ];
}
