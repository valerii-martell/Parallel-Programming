//Programming for parallel computer systems
//Laboratory work #2. WinAPI. Semaphores, mutexes, critical sections, events.
//Valeriy Demchik
//NTUU "KPI"
//FICT IO - 41
//09.03.2017
//Task: A=B+e*D*(MO*MK)+sort(B)


#include "stdafx.h"
#include <windows.h>
#include <iostream>

#define THREAD_STACK_SIZE 1000000 // 1MB

#pragma push_macro("max")
#undef max

void Thread1();
void Thread2();
void Thread3();
void Thread4();

const int N = 8;
const int P = 4;
const int H = N / P;

int e;
Vector* A = new Vector(N, 0);
Vector* B;
Vector* D;
Vector* S;
Matrix* MO;
Matrix* MK;

HANDLE Event_Copy, Event_Input, Sem_Sort, Sem_Sort_2, Sem_Sort_4, Sem_Sort_3, Events_Compute[3], Mutex;
CRITICAL_SECTION CrSec;

using namespace std;

int main()
{
	cout << "Main thread started" << endl;

	Event_Input = CreateEvent(NULL, TRUE, FALSE, NULL);

	Sem_Sort_2 = CreateSemaphore(NULL, 0, 1, NULL);
	Sem_Sort_4 = CreateSemaphore(NULL, 0, 1, NULL);
	Sem_Sort_3 = CreateSemaphore(NULL, 0, 1, NULL);

	Event_Copy = CreateEvent(NULL, FALSE, TRUE, NULL);

	InitializeCriticalSection(&CrSec);

	Mutex = CreateMutex(NULL, FALSE, NULL);

	Sem_Sort = CreateSemaphore(NULL, 0, 3, NULL);

	Events_Compute[0] = CreateEvent(NULL, TRUE, FALSE, NULL);
	Events_Compute[1] = CreateEvent(NULL, TRUE, FALSE, NULL);
	Events_Compute[2] = CreateEvent(NULL, TRUE, FALSE, NULL);

	DWORD Tid1, Tid2, Tid3, Tid4;

	HANDLE threads[] = { 
		CreateThread(NULL, THREAD_STACK_SIZE, (LPTHREAD_START_ROUTINE)Thread1, NULL, NULL, &Tid1),
		CreateThread(NULL, THREAD_STACK_SIZE, (LPTHREAD_START_ROUTINE)Thread2, NULL, NULL, &Tid2),
		CreateThread(NULL, THREAD_STACK_SIZE, (LPTHREAD_START_ROUTINE)Thread3, NULL, NULL, &Tid3),
		CreateThread(NULL, THREAD_STACK_SIZE, (LPTHREAD_START_ROUTINE)Thread4, NULL, NULL, &Tid4)};

	WaitForMultipleObjects(4, threads, TRUE, INFINITE);

	CloseHandle(threads[0]);
	CloseHandle(threads[1]);
	CloseHandle(threads[2]);
	CloseHandle(threads[3]);

	//delete A, B, D, S, MO, MK;

	cout << "Main thread finished";
	system("pause");
	return 0;
}

void Thread1()
{
	cout << "Thread 1 started!\n";

	//input B
	B = new Vector(N, 1);
	B->setElement(1, 10);
	S = new Vector(B);
	
	/*S->setElement(0, 2);
	S->setElement(1, 1);
	S->setElement(2, 4);
	S->setElement(3, 3);
	S->setElement(4, 5);
	S->setElement(5, 9);
	S->setElement(6, 3);
	S->setElement(7, 7);*/

	//signal to t. 2,3,4 about end of input
	SetEvent(Event_Input);

	//whait while another threads finish input
	//WaitForMultipleObjects(4, Sem_Input, TRUE, INFINITE);

	//sorting H part of vector
	S->sort(0, H);

	//wait while thread2 finish sorting
	WaitForSingleObject(Sem_Sort_2, INFINITE);

	//merge sorting 2H part of vector
	S->mergeSort(0, 2 * H);

	//wait while thread3 finish sotring
	WaitForSingleObject(Sem_Sort_3, INFINITE);
	
	//final merrge sorting all vector S
	S->mergeSort(0, N);
	//S->print();

	//signal to t. 2,3,4 about end of sort
	ReleaseSemaphore(Sem_Sort, 3, NULL);

	//critical section (automatic event use)
	WaitForSingleObject(Event_Copy, INFINITE);
	int e1 = e;
	SetEvent(Event_Copy);

	//critical section (mutex use)
	WaitForSingleObject(Mutex, INFINITE);
	Vector* D1 = new Vector(D);
	ReleaseMutex(Mutex);

	//critical section
	EnterCriticalSection(&CrSec);
	Matrix* MK1 = new Matrix(MK);
	LeaveCriticalSection(&CrSec);

	//computing
	A->AddVectors(B, MO->MulMatrices(MK1, 0, H)->MulVectorMatrix(D1, 0, H)->MulVectorNumber(e1), S, 0, H);

	//wait while another threads finish computing
	WaitForMultipleObjects(3, Events_Compute, TRUE, INFINITE);

	//Output result
	printf("A = ");
	A->print();

	delete D1, MK1;

	cout << "Thread 1 finished!\n";
}

void Thread2()
{
	cout << "Thread 2 started!\n";

	//input e
	e = 1;

	//whait while thread 1 finish input vector B
	WaitForSingleObject(Event_Input, INFINITE);

	//sorting part of vector
	S->sort(H, 2*H);

	//signal to thread 1 about end of sorting
	ReleaseSemaphore(Sem_Sort_2, 1, NULL);

	//whait while thread 1 finish final sorting
	WaitForSingleObject(Sem_Sort, INFINITE);

	//critical section (automatic event use)
	WaitForSingleObject(Event_Copy, INFINITE);
	int e2 = e;
	SetEvent(Event_Copy);

	//critical section (mutex use)
	WaitForSingleObject(Mutex, INFINITE);
	Vector* D2 = new Vector(D);
	ReleaseMutex(Mutex);

	//critical section
	EnterCriticalSection(&CrSec);
	Matrix* MK2 = new Matrix(MK);
	LeaveCriticalSection(&CrSec);

	//computing
	A->AddVectors(B, MO->MulMatrices(MK2, H, 2 * H)->MulVectorMatrix(D2, H, 2 * H)->MulVectorNumber(e2), S, H, 2 * H);

	//signal about end of computing
	SetEvent(Events_Compute[0]);

	delete D2, MK2;

	cout << "Thread 2 finished!\n";
}

void Thread3()
{
	cout << "Thread 3 started!\n";

	//input D, MO
	D = new Vector(N, 1);
	MO = new Matrix(N, 1);

	//whait while thread 1 finish input vector B
	WaitForSingleObject(Event_Input, INFINITE);

	//sorting part of vector
	S->sort(2 * H, 3 * H);

	//wait while thread4 finish sorting
	WaitForSingleObject(Sem_Sort_4, INFINITE);

	//merge sorting 2H part of vector
	S->mergeSort(2*H+1, N);

	//signal to thread 1 about end of sorting
	ReleaseSemaphore(Sem_Sort_3, 1, NULL);

	//whait while thread 1 finish final sorting
	WaitForSingleObject(Sem_Sort, INFINITE);

	//critical section (automatic event use)
	WaitForSingleObject(Event_Copy, INFINITE);
	int e3 = e;
	SetEvent(Event_Copy);

	//critical section (mutex use)
	WaitForSingleObject(Mutex, INFINITE);
	Vector* D3 = new Vector(D);
	ReleaseMutex(Mutex);

	//critical section
	EnterCriticalSection(&CrSec);
	Matrix* MK3 = new Matrix(MK);
	LeaveCriticalSection(&CrSec);

	//computing
	A->AddVectors(B, MO->MulMatrices(MK3, 2 * H, 3 * H)->MulVectorMatrix(D3, 2 * H, 3 * H)->MulVectorNumber(e3), S, 2 * H, 3 * H);

	//signal about end of computing
	SetEvent(Events_Compute[1]);

	delete D3, MK3;

	cout << "Thread 3 finished!\n";
}

void Thread4()
{
	cout << "Thread 4 started!\n";

	//input MK
	MK = new Matrix(N, 1);

	//whait while thread 1 finish input vector B
	WaitForSingleObject(Event_Input, INFINITE);

	//sorting part of vector
	S->sort(3 * H, N);

	//signal to thread 3 about end of sorting
	ReleaseSemaphore(Sem_Sort_4, 1, NULL);

	//whait while thread 1 finish final sorting
	WaitForSingleObject(Sem_Sort, INFINITE);

	//critical section (automatic event use)
	WaitForSingleObject(Event_Copy, INFINITE);
	int e4 = e;
	SetEvent(Event_Copy);

	//critical section (mutex use)
	WaitForSingleObject(Mutex, INFINITE);
	Vector* D4 = new Vector(D);
	ReleaseMutex(Mutex);

	//critical section
	EnterCriticalSection(&CrSec);
	Matrix* MK4 = new Matrix(MK);
	LeaveCriticalSection(&CrSec);

	//computing
	A->AddVectors(B, MO->MulMatrices(MK4, 3 * H, N)->MulVectorMatrix(D4, 3 * H, N)->MulVectorNumber(e4), S, 3 * H, N);

	//signal about end of computing
	SetEvent(Events_Compute[2]);

	delete D4, MK4;

	cout << "Thread 4 finished!\n";
}
