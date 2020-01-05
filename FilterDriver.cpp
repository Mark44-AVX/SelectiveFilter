//FilterDriver.cpp - From an array of ints, count the number of elements larger than a specified value.
#include <iostream>
#include <random>

/* FilterTop parameters:
**   count  - number of elements in an array
**   Array  - address of the array
**   cutOff - smallest value in the array to count
**   sumOfValues - sum of values in the array larger than the cutoff value
** Returns the number of values in the array larger than the cutoff value
*/
extern "C" int FilterTop(unsigned int count, int Arr[], int cutOff, int* sumOfValues);
extern "C" unsigned long long readTime(void);
void PrintArray(int Arr[], int count);

const int ArrLen = 12800000;
using std::cout;
using std::endl;

int __declspec(align(64)) Arr[ArrLen];
int main()
{
	// Generate an array of random values, uniformly distributed between 0 and 100.
	std::mt19937 gen(1729);
	std::uniform_int_distribution<> distrib(0, 100);
	int sum_asm;
	int sum_cpp = 0;
	int count_asm = 0;
	int count_cpp = 0;
	int cutOff = 85;
	long long startT, endT, duration;

	// Fill the array with a uniform distribution (0 - 100) of integers
	for (int i = 0; i < ArrLen; i++)
		Arr[i] = distrib(gen);	

	startT = readTime();
	// 
	count_asm = FilterTop(ArrLen, Arr, cutOff, &sum_asm);
	endT = readTime();
	duration = endT - startT;
	cout << "Elapsed time (assembly): " << duration << " clocks" << endl;

	startT = readTime();
	// For comparison, use C++ to do the filtering
	for (int i = 0; i < ArrLen; i++)
	{
		if (Arr[i] >= cutOff)
		{
			sum_cpp += Arr[i];
			count_cpp++;
		}
		
	}
	endT = readTime();
	duration = endT - startT;
	cout << "Elapsed time (C++): " << duration << " clocks" << endl;

	cout << "Sum (assembly): " << sum_asm << " Count: " << count_asm << endl;
	cout << "Sum (C++): " << sum_cpp << " Count: " << count_cpp << endl;
	
	return 0;

}

void PrintArray(int Arr[], int count)
{
	for (int i = 0; i < count; i++)
	{
		cout << Arr[i] << '\t';
		if (i % 8 == 7) cout << endl;
	}
}