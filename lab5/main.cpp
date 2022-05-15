#include <iostream>
#include <cstring>

using namespace std;

void find_most_freq_symb(int* freq)
{
    int max = 0;
    for (int i=32; i<256; i++) // первый 31 символ ASCII - служебные
    {
        if (freq[i] > max)
            max = freq[i];
    }
    cout << "The most frequent symbol(s): ";
    for (int i=32; i<256; i++) // первый 31 символ ASCII - служебные
    {
        if (freq[i] == max)
            cout << static_cast<char>(i) << " ";
    }
    cout << endl;
}

extern void analyze(char* text, int* pointer);

int main()
{
    char text[255] = {};
    int freq[256] = {0};
    cout << "Enter the text:\n";
    cin.getline(text, 255);
    analyze(text, freq);
    cout << "Frequency analysis of symbols:\n";
    for (int i=32; i<256; i++) // первый 31 символ ASCII - служебные
    {
        if (freq[i] != 0)
            cout << static_cast<char>(i) << " : " << freq[i] << "\t" << freq[i]/static_cast<float>(strlen(text)) << endl;
    }
}
