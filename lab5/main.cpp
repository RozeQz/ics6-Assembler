#include <iostream>
#include <cstring>

using namespace std;

char find_most_freq_symb(char* text)
{
    return text[1];  // заглушка
}

extern void analyze(char* text, int* pointer);

int main()
{
    char text[255] = {};
    int freq[256] = {0};
    cout << "Enter the text:\n";
    cin.getline(text, 255);
    analyze(text, freq);
    for (int i=32; i<256; i++) // первый 31 символ ASCII - служебные
    {
        if (freq[i] != 0)
            cout << static_cast<char>(i) << " : " << freq[i] << "\t" << freq[i]/(float)strlen(text) << endl;
    }
}
