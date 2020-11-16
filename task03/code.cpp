#include <stdlib.h>
#include <vector>
#include<numeric>
#include <iostream>
#include <pthread.h>

using namespace std;

void exam_session(vector<int>); // метод начала сессии

void *student_exam(void *n);// потоковый метод

int main() {

    setlocale(LC_ALL, "ru"); // устанавливаю русскую локаль

    int n = 0; // number of students

    cout << "Введите число студентов в аудитории: "; // ввод числа студентов
    cin >> n;
    while( n > 100 || n < 1) // повторный ввод в случае ошибки
    {
        cout << "Из-за короновируса в аудиторию может вместитить от 1 до 100 студентов." << endl;
        cout << "Повторите ввод: ";
        cin >> n;
    }

    // создание массива студентов в беспорядке
    int numbers[n];
    for (int i = 0; i < n; ++i) {
        numbers[i] = 1;
    }
    vector<int> students(n);
    for (int i = 0; i < n;) {
        int a = rand() % n;
        if (numbers[a] == 1) {
            students[i] = a;
            numbers[a] = 0;
            i++;
        }
    }

    exam_session(students); // начало экзамена

    return 0;
}


void exam_session(vector<int> students) {
    vector<pthread_t> threads; // создание вектора потоков pthread
    for (int i = 0; i < students.size(); ++i) {
        pthread_t thread; // инициализация ссылки на поток
        pthread_create(&thread, NULL, student_exam, &students[i]); // инициализация потока
        threads.push_back(thread); // добавление ссылки на поток в вектор
    }

    for (int i = 0; i < threads.size(); ++i) {
        pthread_join(threads[i], NULL); // джойним и ждем пока все потоки отработают - все студенты сдадут экзамен
    }
}

void *student_exam(void *n) { // потоковый метод
    int *student = (int *) n;
    string b = "\nСтудент #" + to_string(*student + 1) + " подготовил ответ на свой билет и отдал его на проверку...\n"; // студент сдал работу
    cout << b;
    string a = "\nРабота студента #" + to_string(*student + 1) +  " была проверена. Оценка " + to_string(rand() % 10) + ".\n"; // преподаватель проверил работу
    cout << a;
    pthread_exit(0); // закрываем поток
}