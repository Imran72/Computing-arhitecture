#include <stdlib.h>
#include <vector>
#include<numeric>
#include <iostream>
#include <queue>
#include <omp.h>

using namespace std;

void exam_session(vector<int>); //  сигнатура метода сессии

queue<int> studentsCheckList; // очередь студентов сдавших на проверку билет


void student_exam(int student) {
#pragma omp critical // обязательный процесс в потоке: вывод информации и добавление студентва в очередь
    {
        string b = "\nСтудент #" + to_string(student + 1) +
                   " подготовил ответ на свой билет и отдал его на проверку...\n";
        cout << b;
        studentsCheckList.push(student);
    }
#pragma omp critical // обязательный процесс в потоке: вывод информации об оценке студента + удаление информации о нем из очереди
    {
        string a = "\nРабота студента #" + to_string(studentsCheckList.front() + 1) + " была проверена. Оценка " +
                   to_string(rand() % 11) +
                   ".\n";
        cout << a;
        studentsCheckList.pop();
    }
}

bool IsNumber(string s) // проверка на число
{
    for (int i = 0; i < s.length(); i++)
        if (isdigit(s[i]) == false)
            return false;

    return true;
}

int main() {

    setlocale(LC_ALL, "ru"); // изменение локали

    string s; // number of students

    cout << "Введите число студентов в аудитории: ";
    while (cin >> s) { //считывание данных
        if (IsNumber(s) && stoi(s) <= 100 && stoi(s) > 0)
            break;
        cout << "Из-за короновируса в аудиторию может вместитить от 1 до 100 студентов." << endl;
        cout << "Повторите ввод: ";
    }

    int n = stoi(s);

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

    exam_session(students); // процесс сессии - запуск метода запускающего потоки

    return 0;
}


void exam_session(vector<int> students) {
#pragma omp parallel for //  создание параллельных потоков через цикл for
    {
        for (int i = 0; i < students.size(); i++) {
            srand(int(time(NULL)) ^ omp_get_thread_num()); // каждый раз задаем рандом, чтобы числа не повторялись
            student_exam(students[i]); // какой-то студент сдал билет на проверку
        }
    }
}