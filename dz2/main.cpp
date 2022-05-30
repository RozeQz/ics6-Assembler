#include <iostream>
#include <string>
#include <set>

using namespace std;

const set<char> sl_symbol{ ',', '*', ';', '(', ')', '!', '/', '\\', '.', '^', '#', '@', '$', '&', ' '};
const set<char> digit{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };
const set<string> type{ "char", "int", "float", "double", "bool", "short", "long", "void" };
const set<string> sl_words{ "void", "char", "int", "float", "double", "bool", "short", "long", "switch",
                            "true", "false", "return", "for", "while", "if", "else", "auto", "break",
                            "case", "catch", "class", "const", "continue", "default", "delete", "do",
                            "enum", "extern", "friend", "goto", "inline", "new", "operator", "private",
                            "protected", "public", "register", "signed", "sizeof", "static", "struct",
                            "template", "this", "throw", "try", "typedef", "union", "unsigned", "virtual", "volatile" };

void delSpace(string& str) { // Удаление лишних пробелов
    int d = str.length();
    for (int i = 0; i < d; i++)
    {
        if ((str[i] == ' ') && (str[i + 1] == ' '))
        {
            str.erase(i + 1, 1);
            d--;
            i--;
        }
        else if ((i == 0) && (str[i] == ' '))
        {
            str.erase(i, 1);
        }
    }
    if (str.length()) {
        while (str[str.length() - 1] == ' ') { str.erase(str.length() - 1, 1); }
    }
}

inline bool isSymbol(char x) { return (('a' <= x && x <= 'z') || ('A' <= x) && (x <= 'Z') || (x == '_')); }

bool isSlSymbol(char x) {
    if (count(sl_symbol.begin(), sl_symbol.end(), x)) return true;
    return false;
}

bool isDigit(char x) {
    if (count(digit.begin(), digit.end(), x)) return true;
    return false;
}

void typeWord(string str) {
    if (count(type.begin(), type.end(), str)) cout << "Тип: \t\t\t\"" << str << '\"' << endl;
    else throw string("Неизвестный тип: \t\"").append(str + '"');
}

void voidWord(string str) {
    if (str != "void") throw string("Ожидалось встретить: \"void\", а встречено: \"").append(str + '"');
    else cout << "Служебное слово: \t\"" << str << '\"' << endl;
}

void parenOpen(string str) {
    if (str != "(") throw string("Ожидалось встретить: \t\'(\'");
    else cout << "Служебный символ: \t\"" << str << '\"' << endl;
}

void parenClose(string str) {
    if (str != ")") throw string("Ожидалось встретить: \t\')\'");
    else cout << "Служебный символ: \t\"" << str << '\"' << endl;
}

void semicolon(string &str) {
    if (str != ";") throw string("Ожидалось встретить: \t\';\'");
    else cout << "Служебный символ: \t\"" << str << '\"' << endl;
}

void star(string str) {
    if (str != "*") throw string("Ожидалось встретить: \t\'*\'");
    else cout << "Служебный символ: \t\"" << str << '\"' << endl;
}

void comma(string str) {
    if (str != ",") throw string("Ожидалось встретить: \t\',\'");
    else cout << "Служебный символ: \t\"" << str << '\"' << endl;
}

void identificator(string str) {
    if (str.empty()) throw string("Ожидался идентификатор");
    if (count(sl_words.begin(), sl_words.end(), str)) throw string("Недопустимое имя идентификатора: \"").append(str + '"');
    if (!isSymbol(str[0])) throw string("Недопустимое имя идентификатора: \"").append(str + '"');
    for (int i = 1; i < str.length(); i++) {
        if (isSlSymbol(str[i])) throw string("Недопустимое имя идентификатора: \"").append(str + '"');
    }
    cout << "Идентификатор: \t\t\"" << str << '\"' << endl;
}

void paramFunc(string str) {
    delSpace(str);
    if (!str.empty()) {
        int n = count(str.begin(), str.end(), ',');
        typeWord(str.substr(0, str.find(' ')));
        str.erase(0, str.find(' ') + 1);
        if (n == 0) {
            identificator(str.substr(0, str.find('\0')));
            str.erase(0, str.find('\0'));
        }
        else {
            identificator(str.substr(0, str.find_first_of(',')));
            str.erase(0, str.find_first_of(','));
            for (int i = 0; i < n; i++) {
                comma(str.substr(0, 1));
                str.erase(0, 1);
                paramFunc(str.substr(0, str.find('\n')));
            }
        }
    }
}

void paramProc(string str) {
    delSpace(str);
    if (!str.empty()) {
        typeWord(str.substr(0, str.find(' ')));
        str.erase(0, str.find(' ') + 1);
        parenOpen(str.substr(0, 1));
        str.erase(0, 1);
        star(str.substr(0, 1));
        str.erase(0, 1);
        identificator(str.substr(0, str.find(')')));
        str.erase(0, str.find(')'));
        parenClose(str.substr(0, 1));
        str.erase(0, 1);
        parenOpen(str.substr(0, 1));
        str.erase(0, 1);
        paramFunc(str.substr(0, str.find_first_of(')')));
        str.erase(0, str.find_first_of(')'));
        parenClose(str.substr(0, 1));
        str.erase(0, 1);
        if (!str.empty()) {
            comma(str.substr(0, 1));
            str.erase(0, 1);
            paramProc(str.substr(0, str.find('\n')));
        }
    }
}

void procedure(string str) {
    voidWord(str.substr(0, str.find(' ')));
    str.erase(0, str.find(' '));
    str.erase(0, 1);

    identificator(str.substr(0, str.find('(')));
    str.erase(0, str.find('('));

    parenOpen(str.substr(0, 1));
    str.erase(0, 1);

    paramProc(str.substr(0, str.find_last_of(')')));
    str.erase(0, str.find_last_of(')'));

    parenClose(str.substr(0, 1));
    str.erase(0, 1);

    semicolon(str);
    str.erase(0, 1);
}

int main()
{
    setlocale(LC_ALL, "Russian");
    string str;
    while (cout << "Введите строку:\n", getline(cin, str), str != "end") {
        delSpace(str);
        try {
            procedure(str);
            cout << "\nПравильно!\n" << endl;
        }
        catch (const string str) {
            cerr << str << "\nНеверно!\n" << endl;
        }
        cout << "Если Вы хотите закончить, введите \"end\".\n" << endl;
    }
}