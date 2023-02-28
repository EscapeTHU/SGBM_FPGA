#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <cstring>
#include <algorithm> // needed for std::remove_if()


int main() {
    std::ifstream infile("../Data/FPGA_proc/cost/cost_init_X.txt");
    std::ofstream outfile("../Data/FPGA_proc/cost/cost_init_Xs.txt");
    std::string line;
    while (std::getline(infile, line)) {
        // remove spaces from the line
        line.erase(std::remove_if(line.begin(), line.end(), ::isspace), line.end());

        // write the modified line to the output file
        outfile << line << std::endl;
        
    }
    // Close files
    infile.close();
    outfile.close();
    return 0;
}

using namespace std;
// Convert a hexadecimal character to its corresponding integer value
unsigned int hexCharToInt(char c)
{
    if (c >= '0' && c <= '9')
    {
        return c - '0';
    }
    else if (c >= 'A' && c <= 'F')
    {
        return 10 + c - 'A';
    }
    else if (c >= 'a' && c <= 'f')
    {
        return 10 + c - 'a';
    }
    else
    {
        return 0;
    }
}


// Convert a decimal number to its binary representation
void decToBin(unsigned int num, char* bin, int binSize) {
    for (int i = 0; i < binSize; i++) {
        bin[i] = '0';
    }

    int i = binSize - 1;
    while (num > 0) {
        bin[i] = (num % 2) ? '1' : '0';
        num /= 2;
        i--;
    }
}

// Convert a binary string to its hexadecimal representation
string binToHex(const string& binary) {
    stringstream ss;
    ss << hex << stoull(binary, 0, 2);
    return ss.str();
}

int mains()
{
    string inputFileName = "../Data/FPGA_proc/cost/cost_init_X_s.txt";
    string outputFileName = "../Data/FPGA_proc/cost/test.txt";

    // Open input file
    ifstream inputFile(inputFileName);

    if (!inputFile)
    {
        cerr << "Failed to open input file " << inputFileName << endl;
        return 1;
    }

    // Open output file
    ofstream outputFile(outputFileName);

    if (!outputFile)
    {
        cerr << "Failed to open output file " << outputFileName << endl;
        return 1;
    }

    // Process each row of input data
    string line;

    while (getline(inputFile, line))
    {
        char temp[6*128] = {0};
        // Process every 2 characters of the line
        for (size_t i = 0; i < line.length(); i += 2)
        {
            char binary[6] = {0};
            // Convert 2 characters to binary
            char hexChar1 = line[i];
            char hexChar2 = line[i + 1];

            unsigned int hexValue1 = hexCharToInt(hexChar1);
            unsigned int hexValue2 = hexCharToInt(hexChar2);

            // Combine the 2 hexadecimal values into an 8-bit binary value
            unsigned int binaryValue = (hexValue1 << 4) | hexValue2;

            // Shift right by 2 bits
            binaryValue >>= 2;
            // Write result to output file as hexadecimal
            decToBin(binaryValue,binary,6);
            outputFile << binary << endl;
        }

    }

    // Close files
    inputFile.close();
    outputFile.close();

    return 0;
}
