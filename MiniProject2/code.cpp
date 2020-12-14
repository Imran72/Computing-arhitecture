#include <iostream>
#include <vector>
#include "thread"
#include "mutex"

using namespace std;


/*
* Задача о магазине - 2 (Вариант 21).
* ФИО: Тимканов Имран Алимович. БПИ-193
* ================ Условие ================
* В магазине работают два отдела, каждый отдел обладает уникальным ассортиментом. В
* каждом отделе работает один продавец. В магазин ходят исключительно забывчивые покупатели,
* поэтому каждый покупатель носит с собой список товаров, которые желает купить.
* Покупатель приобретает товары точно в том порядке, в каком они записаны в его списке.
* Продавец может обслужить только одного покупателя за раз. Покупатель, вставший в очередь, засыпает
* пока не дойдет до продавца. Продавец засыпает, если в его отделе нет покупателей, и просыпается,
* если появится хотя бы один. Создать  многопоточное приложение, моделирующее работу магазина.
* ================ Условие ================
*
*
*/





// пусть в магазине два отдела - отдел "Питания", отдел "Игрушек"
class Client {
public:
    // список покупок у клиента
    vector<pair<string, string>> good_list;
    // номер клиента
    int client_number;

    // конструктор
    Client(int a, int number) {
        good_list = get_list(a); // собираем список товаров
        client_number = number;
    }

    // деструктор
    ~Client() {
        good_list.erase(good_list.begin(), good_list.end());
    }


private:
    // списки товаров
    vector<string> food_list = {"хлеб", "молоко", "помидоры", "огурцы",
                                "картошка", "бананы", "чай", "сахар", "печенье"};

    vector<string> toys_list = {"лего-набор", "футбольный мяч", "шахматы", "кукла",
                                "солдатики", "пластилин", "плюшевый медведь", "спортивная машинка", "динозавр"};


    // собираем гибридный список товаров
    vector<pair<string, string>> get_list(int n) {
        // вектор пар <название категории товара, название товара>
        vector<pair<string, string>> list;
        // индекс товара в списке
        int index = 0;
        int number;
        pair<string, string> good;
        while (index <= n) {
            number = rand() % 9;
            if (rand() % 2 == 0)
                good = make_pair("food", food_list.at(number));
            else
                good = make_pair("toy", toys_list.at(number));

            if (find(list.begin(), list.end(), good) == list.end()) {
                list.push_back(good);
                index++;
            }
        }

        return list;
    }
};

// подключаем mutex
mutex mtx;


// // Поток покупателя
void ServeClient(Client client) {
    // Идем по списку покупок:
    while (client.good_list.size() != 0) {
        string a;
        mtx.lock();
        cout << "Продавец продуктов начал обслуживать клиента #" << client.client_number << endl;
        a = "";
        // Пока очередной товар по списку есть в отделе продуктов:
        while (client.good_list.size() != 0 && client.good_list.at(0).first == "food") {
            // добавляем купленный продукт в список для выводы
            a += "\'" + client.good_list.at(0).second + "\'";
            // удаляем объект из списка товаров
            client.good_list.erase(client.good_list.begin() + 0);
        }
        if (a != "")
            cout << "Клиент #" << client.client_number << " купил у продавца продуктов: " << a << endl;
        if (client.good_list.size() != 0)
            cout  << "Клиент #" << client.client_number << " пошел в отдел игрушек" << endl;
        else
            cout  << "Клиент #" << client.client_number << " закупился и покинул магазин" << endl;
        a = "";
        mtx.unlock();
        if (client.good_list.size() == 0)
            break;
        //  время на переход из отдела в отдел
        this_thread::sleep_for(chrono::milliseconds(500));
        mtx.lock();
        cout << "Продавец игрушек начал обслуживать клиента #" << client.client_number << endl;
        // Пока очередной товар по списку есть в отделе игрушек:
        while (client.good_list.size() != 0 && client.good_list.at(0).first == "toy") {
            a += "\'" + client.good_list.at(0).second + "\'";
            // удаляем объект из списка товаров
            client.good_list.erase(client.good_list.begin() + 0);
        }
        if (a != "")
            cout << "Клиент #" << client.client_number << " купил у продавца игрушек: " << a << endl;
        if (client.good_list.size() != 0)
            cout  << "Клиент #" << client.client_number << " пошел в отдел продуктов" << endl;
        else
            cout  << "Клиент #" << client.client_number << " закупился и покинул магазин" << endl;
        a = "";
        mtx.unlock();
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

    setlocale(LC_ALL, "Russian");//русская локаль

    // настраиваем рандом
    srand(int(time(NULL)));

    string s;
    // количество клиентов, посетивших магазин
    cout << "Введите число покупателей магазина: ";
    while (cin >> s) { //считывание данных
        if (IsNumber(s) && stoi(s) <= 100 && stoi(s) > 0)
            break;
        cout << "Из-за короновируса в магазин может обслуживать в день от 1 до 100 покупателей." << endl;
        cout << "Повторите ввод: ";
    }

    int clients_number = stoi(s);

    // вектор клинетов
    vector<Client> clients_list;

    for (int i = 0; i < clients_number; ++i)
        clients_list.push_back(Client(rand() % 9, i + 1));



    vector<thread> thread_list;
    for (Client i:clients_list) {
        // Пауза перед новым покупателем:
        this_thread::sleep_for(chrono::milliseconds(300));
        cout << "Покупатель #" << i.client_number << " зашёл в магазин." << endl;
        thread_list.push_back(thread(ServeClient, i));
    }

    // Оожидаем их завершения:
    for (int i = 0; i < thread_list.size(); i++) {
        thread_list.at(i).join();
    }

    //Подчищаем память:
    return 0;
}
