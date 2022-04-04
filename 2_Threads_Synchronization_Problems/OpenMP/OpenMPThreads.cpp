//Programming for parallel computer systems
//Laboratory work #4. OpenMP. Barriers, atomic, reduction, for, lock.
//Valeriy Demchik
//NTUU "KPI"
//FICT IO - 41
//12.04.2017
//Task: A=(B*C)*Z+max(Z)*T*(MO*MK)

#include "stdafx.h"
#include <iostream>
#include <fstream>
#include <windows.h>
#include "omp.h"

using namespace std;

//System parameters
int P = 6;
int N = 12;
int H = N / P;

//Grain of parallelism
int G = H / 2;

//Input and output values
Vector* A = new Vector(N, 0);
Vector* B;
Vector* C;
Vector* Z;
Vector* T;
Matrix* MO;
Matrix* MK;
int zmax = 0;
int bc = 0;

//Instruments of interaction
omp_lock_t copyLock;
omp_lock_t maxLock;
omp_lock_t writeLock;

int main()
{
	omp_init_lock(&copyLock);
	omp_init_lock(&maxLock);
	omp_init_lock(&writeLock);

#pragma omp parallel num_threads(P)
	{
		int threadID = omp_get_thread_num();

		//start report
		omp_set_lock(&writeLock);
		cout << "Thread " << threadID << " started!" << endl;
		omp_unset_lock(&writeLock);
		
		//data initialization
		switch (threadID)
		{
			case 0:
				B = new Vector(N, 1);
				MK = new Matrix(N, 1);
				break;
			case 1:
				C = new Vector(N, 1);
				break;
			case 4:
				Z = new Vector(N, 1);
				//Z->getData()[3] = 10;
				break;
			case 5:
				T = new Vector(N, 1);
				MO = new Matrix(N, 1);
				break;
			default:
				break;
		}

#pragma omp barrier

		//scalar B*C compute
#pragma omp for reduction(+:bc)
		for (int i = 0; i < N; i++)
			bc += B->getData()[i] * C->getData()[i];
		
		//atomic section
		int bci = 0;
#pragma omp atomic
		bci += bc;

		//local maximum
		int zmaxi = Z->getMax(threadID*H, (threadID + 1)*H);
		
		//global maximum
		omp_set_lock(&maxLock);
		if (zmaxi >= zmax)
		{
			zmax = zmaxi;
		}
		omp_unset_lock(&maxLock);
		
#pragma omp barrier

		//critical section
		omp_set_lock(&copyLock);
		zmaxi = zmax;
		Vector* Ti = new Vector(T);
		Matrix* MKi = new Matrix(MK);
		omp_unset_lock(&copyLock);

		//final compute
		Matrix* MA = new Matrix(N, 0);
		int i = 0;
		int j = 0;
		int k = 0;
#pragma omp for schedule(dynamic, G) private (i,j,k)
		for (i = 0; i < N; i++)
		{
			int buf = 0;
			for (j = 0; j < N; j++)
			{
				buf = 0;
				for (k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MKi->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (j = 0; j < N; j++)
			{
				buf += Ti->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = bci * Z->getData()[i] + zmaxi*buf;
		}

#pragma omp barrier

		//output result
		if (threadID == 0)
		{
			A->print();
		}
		delete MA;

#pragma omp barrier

		//finish report
		omp_set_lock(&writeLock);
		cout << "Thread " << threadID << " finished!" << endl;
		omp_unset_lock(&writeLock);
	}

	//clear memory
	omp_destroy_lock(&copyLock);
	omp_destroy_lock(&maxLock);
	omp_destroy_lock(&writeLock);

	delete A;
	delete B;
	delete C;
	delete Z;
	delete T;
	delete MO;
	delete MK;

	system("pause");
	return 0;
}



