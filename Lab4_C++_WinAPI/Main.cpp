//          Lab #4
//    Author: Valeriy Demchik
//    Group:   IO-41
//    Date:    30.10.2016
//
//    F1: MC = MIN(A)*(MA*MD)
//    F2: MK = TRANS(MA)* TRANS(MB* MM)+MX
//    F3:  O = SORT(P)*(MR* MS)


#include "Data.h"

#include <windows.h>
#include <iostream>

#define THREAD_STACK_SIZE 1000000 // 1MB
#define N 1500

#pragma push_macro("max")
#undef max

void Thread1();
void Thread2();
void Thread3();

using namespace std;

int main()
{
	DWORD Tid1, Tid2, Tid3;
	HANDLE T1 = CreateThread(NULL, THREAD_STACK_SIZE, (LPTHREAD_START_ROUTINE)Thread1, NULL, CREATE_SUSPENDED, &Tid1);
	HANDLE T2 = CreateThread(NULL, THREAD_STACK_SIZE, (LPTHREAD_START_ROUTINE)Thread2, NULL, CREATE_SUSPENDED, &Tid2);
	HANDLE T3 = CreateThread(NULL, THREAD_STACK_SIZE, (LPTHREAD_START_ROUTINE)Thread3, NULL, CREATE_SUSPENDED, &Tid3);

	SetThreadPriority(T1, 1);
	SetThreadPriority(T2, 2);
	SetThreadPriority(T3, 3);

	ResumeThread(T1);
	ResumeThread(T2);
	ResumeThread(T3);

	WaitForSingleObject(T1, INFINITE);
	WaitForSingleObject(T2, INFINITE);
	WaitForSingleObject(T3, INFINITE);

	CloseHandle(T1);
	CloseHandle(T2);
	CloseHandle(T3);

	cout << "Main thread finished execution!\n";
	system("pause");
	return 0;
}


//F1: MC = MAX(A)*(MA*MD)
void Thread1()
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
void Thread2()
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
void Thread3()
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