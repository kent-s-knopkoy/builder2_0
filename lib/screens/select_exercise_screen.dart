import 'package:flutter/material.dart';

class SelectExerciseScreen extends StatefulWidget {
  const SelectExerciseScreen({super.key});

  @override
  State<SelectExerciseScreen> createState() => _SelectExerciseScreenState();
}

class _SelectExerciseScreenState extends State<SelectExerciseScreen> {
  final Map<String, List<String>> allExercises = {
    'Ноги': [
      'Выпады',
      'Жим ногами',
      'Приседания',
      'Разгибание ног',
      'Сгибание ног',
    ],
    'Грудь': ['Жим лёжа', 'Разводка гантелей', 'Кроссовер', 'Отжимания'],
    'Спина': [
      'Подтягивания',
      'Тяга верхнего блока',
      'Тяга гантели',
      'Тяга штанги в наклоне',
    ],
    'Руки': [
      'Сгибание рук с гантелями',
      'Молотковые сгибания',
      'Французский жим',
      'Разгибание рук на блоке',
    ],
    'Пресс': ['Скручивания', 'Подъём ног', 'Планка'],
  };

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор упражнения'), centerTitle: true),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск упражнения...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Список упражнений с прокруткой
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children:
                    allExercises.entries.map((entry) {
                      final group = entry.key;
                      final filtered =
                          entry.value
                              .where(
                                (e) => e.toLowerCase().contains(searchQuery),
                              )
                              .toList()
                            ..sort();

                      if (filtered.isEmpty) return const SizedBox();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...filtered.map((exercise) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  title: Text(
                                    exercise,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: () => Navigator.pop(context, exercise),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
