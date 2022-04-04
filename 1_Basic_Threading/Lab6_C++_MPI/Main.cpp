//          Lab #6
//    Author: Valerii Martell
//    Group:   IO-41
//    Date:    23.11.2016
//
//    F1: MC = MIN(A)*(MA*MD)
//    F2: MK = TRANS(MA)* TRANS(MB* MM)+MX
//    F3:  O = SORT(P)*(MR* MS)


#include "Data.h"

#include <windows.h>
#include <iostream>
#include <mpi.h>

#define N 5

#pragma push_macro("max")
#undef max

void Task1();
void Task2();
void Task3();

using namespace std;

int main(int argc, char** argv)
{

	MPI_Init(&argc, &argv);
#pragma comment(linker, "/STACK:400000000")

	int tid;

	MPI_Comm_rank(MPI_COMM_WORLD, &tid);

	switch (tid)
	{
	case 0:
		Task1();
		break;
	case 1:
		Task2();
		break;
	case 2:
		Task3();
		break;
	}

	//Task1();

	MPI_Finalize();

	//system("pause");
	return 0;
}

//F1: MC = MIN(A)*(MA*MD)
void Task1()
{
	cout << "Task 1 started!\n";

	Vector* A = new Vector(N, true);
	Matrix* MA = new Matrix(N, true);
	Matrix* MD = new Matrix(N, true);

	int Amax = A->max();
	Matrix* MC = *(*MA * *MD) * Amax;
	delete A, MA, MD;
	Sleep(1000);
	printf("F1 = \n");
	MC->print();
	cout << "Task 1 finished!\n";
}

//F2: MK = TRANS(MA)* TRANS(MB* MM)+MX
void Task2()
{
	cout << "Task 2 started!\n";

	Matrix* MA = new Matrix(N, true);
	Matrix* MB = new Matrix(N, true);
	Matrix* MM = new Matrix(N, true);
	Matrix* MX = new Matrix(N, true);

	Matrix* MK = *(*MA->transpose() * *(*MB* *MM)->transpose()) + *MX;

	Sleep(100);
	printf("F2 = \n");
	MK->print();
	delete MA, MB, MM, MX;

	cout << "Task 2 finished!\n";
}

//F3:  O = SORT(P)*(MR* MS)
void Task3()
{
	cout << "Task 3 started!\n";

	Vector* P = new Vector(N, true);
	Matrix* MR = new Matrix(N, true);
	Matrix* MS = new Matrix(N, true);

	Vector* O = *(*MR * *MS) * *(P->sort());

	delete P, MR, MS;
	printf("F3 = \n");
	O->print();

	cout << "Task 3 finished!\n";
}