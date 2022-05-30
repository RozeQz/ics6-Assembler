#include <iostream>
#include <string>
#include <set>

using namespace std;

const set<char> sl_symbol{',', '*', ';', '(', ')', '!', '/', '\\', '.', '^', '#', '@', '$', '&', ' '};
const set<char> digit{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
const set<string> type{"char", "int", "float", "double", "bool", "short", "long"};
const set<string> sl_words{"void", "char", "int", "float", "double", "bool", "short", "long", "switch",
                           "true", "false", "return", "for", "while", "if", "else", "auto", "break",
                           "case", "catch", "class", "const", "continue", "default", "delete", "do",
                           "enum", "extern", "friend", "goto", "inline", "new", "operator", "private",
                           "protected", "public", "register", "signed", "sizeof", "static", "struct",
                           "template", "this", "throw", "try", "typedef", "union", "unsigned", "virtual", "volatile"};
set<char> alphabet;

void delSpace(string &str)
{ // Удаление лишних пробелов
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
    if (str.length())
    {
        while (str[str.length() - 1] == ' ')
        {
            str.erase(str.length() - 1, 1);
        }
    }
}

inline bool isSymbol(char x) { return (('a' <= x && x <= 'z') || ('A' <= x) && (x <= 'Z') || (x == '_')); }

bool isSlSymbol(char x)
{
    if (count(sl_symbol.begin(), sl_symbol.end(), x))
        return true;
    return false;
}

bool isType(string str)
{
    if (count(type.begin(), type.end(), str))
    {
        cout << "Тип: " << str << endl;
        return true;
    }
    cout << "Неизвестный тип: " << str << endl;
    return false;
}

bool isDigit(char x)
{
    if (count(digit.begin(), digit.end(), x))
        return true;
    return false;
}

bool isIdentificator(string str)
{
    if (str.empty())
    {
        throw string("Ожидался идентификатор");
        return false;
    }
    if (count(sl_words.begin(), sl_words.end(), str))
    {
        throw string("Недопустимое имя идентификатора: ").append(str);
        return false;
    }
    if (!isSymbol(str[0]))
    {
        throw string("Недопустимое имя идентификатора: ").append(str);
        ;
        return false;
    }
    for (int i = 1; i < str.length(); i++)
    {
        if (isSlSymbol(str[i]))
        {
            throw string("Недопустимое имя идентификатора: ").append(str);
            ;
            return false;
        }
    }
    cout << "Идентификатор: " << str << endl;
    return true;
}

bool isVoid(string str)
{
    if (str != "void")
    {
        throw string("Ожидалось встретить: void, а встречено: ").append(str);
        return false;
    }
    cout << "Служебное слово: " << str << endl;
    return true;
}

bool isParenOpen(string str)
{
    if (str != "(")
    {
        throw string("Ожидалось встретить: \'(\'");
        return false;
    }
    cout << "Служебный символ: " << str << endl;
    return true;
}

bool isParenClose(string str)
{
    if (str != ")")
    {
        throw string("Ожидалось встретить: \')\'");
        return false;
    }
    cout << "Служебный символ: " << str << endl;
    return true;
}

bool isSemicolon(string str)
{
    if (str != ";")
    {
        throw("Ожидалось встретить: \';\'");
        return false;
    }
    cout << "Служебный символ: " << str << endl;
    return true;
}

bool isStar(string str)
{
    if (str != "*")
    {
        throw("Ожидалось встретить: \'*\'");
        return false;
    }
    cout << "Служебный символ: " << str << endl;
    return true;
}

bool isParamFunc(string str)
{
    delSpace(str);
    if (str.empty())
        return true;

    if (!isType(str.substr(0, str.find(' '))))
        return false;
    str.erase(0, str.find(' ') + 1);
    if (!isIdentificator(str.substr(0, str.find_first_of(',', '\0'))))
        return false;
    str.erase(0, str.find_first_of(',', '\n'));
    return true;
}

bool isParamProc(string str)
{
    delSpace(str);
    if (str.empty())
        return true;

    if (!isType(str.substr(0, str.find(' '))))
        return false;
    str.erase(0, str.find(' ') + 1);
    if (!isParenOpen(str.substr(0, 1)))
        return false;
    str.erase(0, 1);
    if (!isStar(str.substr(0, 1)))
        return false;
    str.erase(0, 1);
    if (!isIdentificator(str.substr(0, str.find(')'))))
        return false;
    str.erase(0, str.find(')'));
    if (!isParenClose(str.substr(0, 1)))
        return false;
    str.erase(0, 1);
    if (!isParenOpen(str.substr(0, 1)))
        return false;
    str.erase(0, 1);
    if (!isParamFunc(str.substr(0, str.find_last_of(')'))))
        return false;
    str.erase(0, str.find_last_of(')'));
    if (!isParenClose(str.substr(0, 1)))
        return false;
    str.erase(0, 1);

    return true;
}

bool isProcedure(string str)
{
    if (!isVoid(str.substr(0, str.find(' '))))
        return false;
    str.erase(0, str.find(' ') + 1);
    if (!isIdentificator(str.substr(0, str.find('('))))
        return false;
    str.erase(0, str.find('('));
    if (!isParenOpen(str.substr(0, 1)))
        return false;
    str.erase(0, 1);
    if (!isParamProc(str.substr(0, str.find_last_of(')'))))
        return false;
    str.erase(0, str.find_last_of(')'));
    if (!isParenClose(str.substr(0, 1)))
        return false;
    str.erase(0, 1);
    if (!isSemicolon(str.substr(0, str.find('\0'))))
        return false;
    return true;
}

void analyze(string str)
{
    cout << isProcedure(str) << endl;
}

int main()
{
    setlocale(LC_ALL, "Russian");
    string str;
    while (cout << "Enter a string:\n", getline(cin, str), str != "end")
    {
        delSpace(str);
        try
        {
            analyze(str);
            cout << "\n\nCORRECT!\n"
                 << endl;
        }
        catch (const string str)
        {
            cerr << str << "\n\nINCORRECT\n"
                 << endl;
        }
    }
}