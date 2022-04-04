// OpenMP.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <fstream>
#include <windows.h>
#include "omp.h"
#include <ctime>

using namespace std;

//output files
ofstream oneProcFile;
ofstream coarseGrainedParallelismFile;
ofstream mediumGrainedParallelismFile;
ofstream fineGrainedParallelismFile;
ofstream withoutCopyFile;

//diagnostic parameters
int accuracy = 1;
int startDimension = 1500;
int finishDimension = 1500;
int stepDimension = 500;

//system parameters
int P = 50;
int G = (startDimension / P);

class OneProc
{
private:

	int N;

	double time;

	Matrix* MA;
	Matrix* MB;
	Matrix* MC;

public:

	OneProc(int n)
	{
		N = n;
	}

	void Compute()
	{
		MA = new Matrix(N, 0);

		int start_time = clock();

		MB = new Matrix(N, 1);
		MC = new Matrix(N, 1);

		for (int i = 0; i < N; i++)
		{
			for (int j = 0; j < N; j++)
			{
				int buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MB->getElement(i, k) * MC->getElement(k ,j);
				}
				MA->setElement(i, j, buf);
			}
		}

		//simulation of output
		MA->print();

		int end_time = clock();
		time =(double)(end_time - start_time) / 1000;

		delete MA;
		delete MB;
		delete MC;
	}

	double GetTime()
	{
		return time;
	}
		
};

class ÑoarseGrainedParallelism
{
private:

	int N;
	int H;
	int P;

	double time;

	Matrix* MA;
	Matrix* MB;
	Matrix* MC;

public:
	ÑoarseGrainedParallelism(int n, int p)
	{
		N = n;
		P = p;
		H = n / p;
	}

	void Compute()
	{
		MA = new Matrix(N, 0);

		omp_lock_t copyLock;
		omp_init_lock(&copyLock);

		unsigned int start_time = clock();

#pragma omp parallel num_threads(P)
		{
			int tid = omp_get_thread_num();

			if (tid == 0)
			{
				MB = new Matrix(N, 1);
				MC = new Matrix(N, 1);
			}

#pragma omp barrier

			omp_set_lock(&copyLock);
			Matrix* MCid = new Matrix(MC);
			omp_unset_lock(&copyLock);

			for (int i = tid*H; i < (tid + 1)*H; i++)
			{
				for (int j = 0; j < N; j++)
				{
					int buf = 0;
					for (int k = 0; k < N; k++)
					{
						buf += MB->getData()[i][k] * MCid->getData()[k][j];
					}
					MA->getData()[i][j]=buf;
				}
			}
#pragma omp barrier

			//simulation of output
			if (tid == 0)
			{
				MA->print();
			}

			delete MCid;
		}

		unsigned int end_time = clock();
		time =(double)(end_time - start_time) / 1000;

		omp_destroy_lock(&copyLock);
		delete MA;
		delete MB;
		delete MC;
	}

	double GetTime()
	{
		return time;
	}
};

class WithoutCopy
{
private:

	int N;
	int H;
	int P;

	double time;

	Matrix* MA;
	Matrix* MB;
	Matrix* MC;

public:
	WithoutCopy(int n, int p)
	{
		N = n;
		P = p;
		H = n / p;
	}

	void Compute()
	{
		MA = new Matrix(N, 0);

		int start_time = clock();

#pragma omp parallel num_threads(P)
		{
			int tid = omp_get_thread_num();

			if (tid == 0)
			{
				MB = new Matrix(N, 1);
				MC = new Matrix(N, 1);
			}

#pragma omp barrier

			for (int i = tid*H; i < (tid + 1)*H; i++)
			{
				for (int j = 0; j < N; j++)
				{
					int buf = 0;
					for (int k = 0; k < N; k++)
					{
						buf += MB->getElement(i, k) * MC->getElement(k ,j);
					}
					MA->setElement(i, j, buf);
				}
			}
#pragma omp barrier

			//simulation of output
			if (tid == 0)
			{
				MA->print();
			}

		}
		int end_time = clock();
		time =(double)(end_time - start_time) / 1000;
		delete MA;
		delete MB;
		delete MC;
	}

	double GetTime()
	{
		return time;
	}
};

class MediumGrainedParallelism
{
private:

	int N;
	int H;
	int P;

	double time;

	Matrix* MA;
	Matrix* MB;
	Matrix* MC;

public:
	MediumGrainedParallelism(int n, int p)
	{
		N = n;
		P = p;
		H = n / p;
	}

	void Compute()
	{
		MA = new Matrix(N, 0);

		omp_lock_t copyLock;
		omp_init_lock(&copyLock);

		unsigned int start_time = clock();

#pragma omp parallel num_threads(P)
		{
			int tid = omp_get_thread_num();

			if (tid == 0)
			{
				MB = new Matrix(N, 1);
				MC = new Matrix(N, 1);
			}

#pragma omp barrier

			//omp_set_lock(&copyLock);
			//Matrix* MCid = new Matrix(MC);
			//omp_unset_lock(&copyLock);

			int i=tid*H;
			int j=0;
			int k=0;

#pragma omp parallel for schedule(dynamic, H/4) private (i,j,k)
				for (i = tid*H; i < (tid + 1)*H; i++)
				{
					for (j = 0; j < N; j++)
					{
						int buf = 0;
						for (k = 0; k < N; k++)
						{
							buf += MB->getData()[i][k] * MC->getData()[k][j];
						}
						MA->getData()[i][j] = buf;
					}
				}

#pragma omp barrier

			//simulation of output
			if (tid == 0)
			{
				MA->print();
			}
			//delete MCid;
		}

		unsigned int end_time = clock();
		time =(double)(end_time - start_time) / 1000;

		omp_destroy_lock(&copyLock);
		delete MA;
		delete MB;
		delete MC;
	}

	double GetTime()
	{
		return time;
	}
};

class FineGrainedParallelism
{
private:

	int N;
	int P;
	int H;

	double time;

	Matrix* MA;
	Matrix* MB;
	Matrix* MC;

public:
	FineGrainedParallelism(int n, int p)
	{
		N = n;
		P = p;
		H = n / p;
	}

	void Compute()
	{
		MA = new Matrix(N, 0);

		unsigned int start_time = clock();

		MB = new Matrix(N, 1);
		MC = new Matrix(N, 1);

		int i = 0;
		int j = 0;
		int k = 0;
#pragma omp parallel for num_threads(P) schedule(dynamic, H) private (i,j,k)
		for (i = 0; i < N; i++)
		{
			for (int j = 0; j < N; j++)
			{
				int buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MB->getData()[i][k] * MC->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
		}

			//simulation of output
			MA->print();

		unsigned int end_time = clock();
		time =(double)(end_time - start_time) / 1000;

		delete MA;
		delete MB;
		delete MC;
	}

	double GetTime()
	{
		return time;
	}
};


int main()
{
	/*coarseGrainedParallelismFile.open("coarseGrainedParallelismFile.txt");
	withoutCopyFile.open("withoutCopyFile.txt");
	mediumGrainedParallelismFile.open("mediumGrainedParallelismFile.txt");
	fineGrainedParallelismFile.open("fineGrainedParallelismFile.txt");*/

	for (int dimension = startDimension; dimension <= finishDimension; dimension += stepDimension)
	{
		double timeCoarseGrainedParallelism = 0;
		double timeWithoutCopy = 0;
		double timeMediumGrainedParallelism = 0;
		double timeFineGrainedParallelism = 0;
		for (int j = 0; j < accuracy; j++)
		{
			/*ÑoarseGrainedParallelism* coarseGrainedParallelism = new ÑoarseGrainedParallelism(dimension, P);
			coarseGrainedParallelism->Compute();
			timeCoarseGrainedParallelism += coarseGrainedParallelism->GetTime();
			*/
			//MediumGrainedParallelism* mediumGrainedParallelism = new MediumGrainedParallelism(dimension, P);
			//mediumGrainedParallelism->Compute();
			//timeMediumGrainedParallelism += mediumGrainedParallelism->GetTime();

			FineGrainedParallelism* fineGrainedParallelism = new FineGrainedParallelism(dimension, P);
			fineGrainedParallelism->Compute();
			timeFineGrainedParallelism += fineGrainedParallelism->GetTime();

			//WithoutCopy* withoutCopy = new WithoutCopy(dimension, P);
			//withoutCopy->Compute();
			//timeWithoutCopy += withoutCopy->GetTime();
		}

		//cout << "C Proc: " << P << " Dim: " << dimension << " Time:" << timeCoarseGrainedParallelism / accuracy << endl;
		//cout << "M Proc: " << P << " Dim: " << dimension << " Time:" << timeMediumGrainedParallelism / accuracy << endl;
	cout << "F Proc: " << P << " Dim: " << dimension << " Time:" << timeFineGrainedParallelism / accuracy << endl;
	//	//cout << "Proc: " << P << " Dim: " << dimension << " Time:" << timeWithoutCopy / accuracy << endl;
	//	/*coarseGrainedParallelismFile<< dimension <<endl;
	//	coarseGrainedParallelismFile << timeCoarseGrainedParallelism / accuracy << endl;

	//	mediumGrainedParallelismFile << dimension << endl;
	//	mediumGrainedParallelismFile << timeMediumGrainedParallelism / accuracy << endl;

	//	fineGrainedParallelismFile << dimension << endl;
	//	fineGrainedParallelismFile << timeFineGrainedParallelism / accuracy << endl;

	//	withoutCopyFile << dimension << endl;
	//	withoutCopyFile << timeWithoutCopy / accuracy << endl;*/
	}
	//coarseGrainedParallelismFile.close();
	//mediumGrainedParallelismFile.close();
	//fineGrainedParallelismFile.close();
	//withoutCopyFile.close();

	//oneProcFile.open("oneProcFile.txt");
	//for (int dimension = startDimension; dimension <= finishDimension; dimension += stepDimension)
	//{
	//	double timeOneProc = 0;
	//	for (int j = 0; j < accuracy; j++)
	//	{
	//		OneProc* oneProc = new OneProc(dimension);
	//		
	//		oneProc->Compute();

	//		timeOneProc += oneProc->GetTime();
	//	}
	//cout << "O Proc: " << P << " Dim: " << dimension << " Time:" << timeOneProc / accuracy << endl;
	////oneProcFile<< dimension <<endl;
	////oneProcFile<< timeOneProc / accuracy <<endl;
	//}
	//oneProcFile.close();*/
	
	system("pause");
    return 0;
}

