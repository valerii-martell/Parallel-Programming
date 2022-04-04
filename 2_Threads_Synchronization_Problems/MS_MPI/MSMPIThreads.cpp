/// <summary>
/// Programming for parallel computer systems
/// Laboratory work #8. MPI
/// Liudmyla Mishchenko
/// NTUU "KPI"
/// FICT IO - 41
/// 20.04.2017
/// Task: A=d*B + max(Z)*T*(MO*MK)
/// 
/// Main file
/// </summary>

#include "stdafx.h"
#include <iostream>
#include <windows.h>
#include "mpi.h"

using namespace std;

//System parameters
const int P = 8;
const int N = 8;
const int H = N / P;

int main(int argc, char* argv[])
{
#pragma region MPIstart
	//#pragma comment(linker, "/STACK:400000000")

	//buffer for count of neighbours
	int neighbourNumber;

	//tags for MPI messages
	const int indexTag = 0;
	const int dataTag = 1;

	//allocate memory for topology arrays
	int *index, *edges, *neighbours;
	index = (int*)malloc(8 * sizeof(int));
	edges = (int*)malloc(14 * sizeof(int));
	neighbours = (int*)malloc(3 * sizeof(int));

	//feel indexes of graph
	index[0] = 1;
	index[1] = 4;
	index[2] = 5;
	index[3] = 8;
	index[4] = 9;
	index[5] = 11;
	index[6] = 13;
	index[7] = 14;

	//feel vector of graph incidence
	//0
	edges[0] = 1;
	//1
	edges[1] = 0;
	edges[2] = 2;
	edges[3] = 3;
	//2
	edges[4] = 1;
	//3
	edges[5] = 1;
	edges[6] = 4;
	edges[7] = 5;
	//4
	edges[8] = 3;
	//5
	edges[9] = 3;
	edges[10] = 6;
	//6
	edges[11] = 5;
	edges[12] = 7;
	//7
	edges[13] = 6;

	//star communicator
	MPI_Comm GraphComm;

	//start of environment of MPI
	MPI_Init(&argc, &argv);

	//graph create
	MPI_Graph_create(MPI_COMM_WORLD, P, index, edges, 1, &GraphComm);

	//get rank of procces
	int rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	//get count of neighbors
	MPI_Graph_neighbors_count(GraphComm, rank, &neighbourNumber);

	//get neighbors ranks
	MPI_Graph_neighbors(GraphComm, rank, neighbourNumber, neighbours);

#pragma endregion


#pragma region DataDeclarations
	//data handle
	Vector* A;
	Vector* B;
	Vector* T;
	Vector* Z;
	Matrix* MK;
	Matrix* MO;
	int a = INT32_MIN;
	int d;
#pragma endregion

#pragma region ProcessorsFunctions
	if (rank == 0)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//Input data
		B = new Vector(N, 1);
		Z = new Vector(N, 1);
		Z->getData()[4] = 10;

		//Send Z to T1
		Vector* ZforSend = new Vector(Z, H, N);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, 1, dataTag, GraphComm);
		Z = new Vector(Z, 0, H);

		//Send B to T1
		MPI_Send(B->getData(), B->getSize(), MPI_INT, 1, dataTag, GraphComm);

		//Recive T from T1
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MO from T1
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMO, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MO->fillRow(i, recv_dataMO);
		}

		//recive d from T1
		MPI_Recv(&d, sizeof(int), MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Recive MK from T1
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		int ai = Z->getMax();

		//Send max to T1
		MPI_Send(&ai, sizeof(int), MPI_INT, 1, dataTag, GraphComm);

		//recive max from T1
		MPI_Recv(&a, sizeof(int), MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = 0; i < H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Send part of A to T1
		int element;
		for (int j = 0; j < H; j++)
		{
			element = A->getData()[j];
			MPI_Send(&element, sizeof(int), MPI_INT, 1, dataTag, GraphComm);
		}

		printf("\nProcess %d finished!", rank);
	}
	if (rank == 1)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//Recive Z from T0
		int recv_data[N - H];
		MPI_Recv(recv_data, N - H, MPI_INT, 0, dataTag, GraphComm, MPI_STATUS_IGNORE);
		Z = new Vector(N - H, recv_data);

		//Recive B from T0
		int recv_dataB[N];
		MPI_Recv(recv_dataB, N, MPI_INT, 0, dataTag, GraphComm, MPI_STATUS_IGNORE);
		B = new Vector(N, recv_dataB);

		//Send Z to T3
		Vector* ZforSend = new Vector(Z, 2 * H, 7 * H);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, 3, dataTag, GraphComm);

		//Send B to T3
		MPI_Send(B->getData(), B->getSize(), MPI_INT, 3, dataTag, GraphComm);

		//Recive T from T3
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MO from T3
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMO, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MO->fillRow(i, recv_dataMO);
		}

		//recive d from T3
		MPI_Recv(&d, sizeof(int), MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Recive MK from T3
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		//send T to T0
		MPI_Send(T->getData(), T->getSize(), MPI_INT, 0, dataTag, GraphComm);

		//send MO to T0
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, 0, dataTag, GraphComm);
		}

		//send d to T0
		MPI_Send(&d, sizeof(int), MPI_INT, 0, dataTag, GraphComm);

		//send MK to T0
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], N, MPI_INT, 0, dataTag, GraphComm);
		}

		//Send Z to T2
		ZforSend = new Vector(Z, H, 2 * H);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, 2, dataTag, GraphComm);
		Z = new Vector(Z, 0, H);

		//Send B to T2
		MPI_Send(B->getData(), B->getSize(), MPI_INT, 2, dataTag, GraphComm);

		//send T to T2
		MPI_Send(T->getData(), T->getSize(), MPI_INT, 2, dataTag, GraphComm);

		//send MO to T2
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, 2, dataTag, GraphComm);
		}

		//send d to T2
		MPI_Send(&d, sizeof(int), MPI_INT, 2, dataTag, GraphComm);

		//send MK to T2
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], N, MPI_INT, 2, dataTag, GraphComm);
		}

		int ai = Z->getMax();

		//recive max from T0
		MPI_Recv(&a, sizeof(int), MPI_INT, 0, dataTag, GraphComm, MPI_STATUS_IGNORE);
		if (a > ai) ai = a;

		//recive max from T2
		MPI_Recv(&a, sizeof(int), MPI_INT, 2, dataTag, GraphComm, MPI_STATUS_IGNORE);
		if (a > ai) ai = a;

		//Send max to T3
		MPI_Send(&ai, sizeof(int), MPI_INT, 3, dataTag, GraphComm);

		//recive max from T3
		MPI_Recv(&a, sizeof(int), MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Send max to T0
		MPI_Send(&a, sizeof(int), MPI_INT, 0, dataTag, GraphComm);

		//Send max to T2
		MPI_Send(&a, sizeof(int), MPI_INT, 2, dataTag, GraphComm);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = H; i < 2 * H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Receive part of A from T0
		int element;
		for (int j = 0; j < H; j++)
		{
			MPI_Recv(&element, sizeof(int), MPI_INT, 0, dataTag, GraphComm, MPI_STATUS_IGNORE);
			A->getData()[j] = element;
		}

		//Receive part of A from T2
		for (int j = 2 * H; j < 3 * H; j++)
		{
			MPI_Recv(&element, sizeof(int), MPI_INT, 2, dataTag, GraphComm, MPI_STATUS_IGNORE);
			A->getData()[j] = element;
		}

		//Send part of A to T3
		for (int j = 0; j < 3 * H; j++)
		{
			element = A->getData()[j];
			MPI_Send(&element, sizeof(int), MPI_INT, 3, dataTag, GraphComm);
		}

		printf("\nProcess %d finished!", rank);
	}
	if (rank == 2)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//recive Z
		int recv_data[H];
		MPI_Recv(recv_data, H, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
		Z = new Vector(H, recv_data);

		//Recive B from parent
		int recv_dataB[N];
		MPI_Recv(recv_dataB, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
		B = new Vector(N, recv_dataB);

		//Recive T from parent
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MO from parent
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMO, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MO->fillRow(i, recv_dataMO);
		}

		//recive d
		MPI_Recv(&d, sizeof(int), MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Recive MK from parent
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		int ai = Z->getMax();

		//Send max to T1
		MPI_Send(&ai, sizeof(int), MPI_INT, 1, dataTag, GraphComm);

		//recive max from T1
		MPI_Recv(&a, sizeof(int), MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = 2 * H; i < 3 * H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Send part of A to T1
		int element;
		for (int j = 2 * H; j < 3 * H; j++)
		{
			element = A->getData()[j];
			MPI_Send(&element, sizeof(int), MPI_INT, 1, dataTag, GraphComm);
		}

		printf("\nProcess %d finished!", rank);
	}
	if (rank == 3)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//recive Z
		int recv_data[5 * H];
		MPI_Recv(recv_data, 5 * H, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
		Z = new Vector(5 * H, recv_data);

		//Recive B from parent
		int recv_dataB[N];
		MPI_Recv(recv_dataB, N, MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
		B = new Vector(N, recv_dataB);

		//Recive T from parent
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MO from parent
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMO, N, MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MO->fillRow(i, recv_dataMO);
		}

		//recive d
		MPI_Recv(&d, sizeof(int), MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Recive MK from parent
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		//Send Z to T5
		Vector* ZforSend = new Vector(Z, 2 * H, 5 * H);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, 5, dataTag, GraphComm);

		//Send B to T5
		MPI_Send(B->getData(), B->getSize(), MPI_INT, 5, dataTag, GraphComm);

		//Send T to T1
		MPI_Send(T->getData(), T->getSize(), MPI_INT, 1, dataTag, GraphComm);

		//Send MO to T1
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, 1, dataTag, GraphComm);
		}

		//Send d to T1
		MPI_Send(&d, sizeof(int), MPI_INT, 1, dataTag, GraphComm);

		//Send MK to T1
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], N, MPI_INT, 1, dataTag, GraphComm);
		}

		//Send Z to T4
		ZforSend = new Vector(Z, H, 2 * H);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, 4, dataTag, GraphComm);
		Z = new Vector(Z, 0, H);

		//Send B to T4
		MPI_Send(B->getData(), B->getSize(), MPI_INT, 4, dataTag, GraphComm);

		MPI_Send(T->getData(), T->getSize(), MPI_INT, 4, dataTag, GraphComm);

		//Send MO to T4
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, 4, dataTag, GraphComm);
		}

		//Send d to T4
		MPI_Send(&d, sizeof(int), MPI_INT, 4, dataTag, GraphComm);

		//Send MK to T4
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], N, MPI_INT, 4, dataTag, GraphComm);
		}

		int ai = Z->getMax();

		//recive max from T4
		MPI_Recv(&a, sizeof(int), MPI_INT, 4, dataTag, GraphComm, MPI_STATUS_IGNORE);
		if (a > ai) ai = a;

		//recive max from T1
		MPI_Recv(&a, sizeof(int), MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
		if (a > ai) ai = a;

		//recive max from T5
		MPI_Recv(&a, sizeof(int), MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
		if (a > ai) ai = a; else a = ai;

		//Send max to T5
		MPI_Send(&ai, sizeof(int), MPI_INT, 5, dataTag, GraphComm);

		//Send max to T1
		MPI_Send(&ai, sizeof(int), MPI_INT, 1, dataTag, GraphComm);

		//Send max to T4
		MPI_Send(&ai, sizeof(int), MPI_INT, 4, dataTag, GraphComm);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = 3 * H; i < 4 * H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Receive part of A from T1
		int element;
		for (int j = 0; j < 3 * H; j++)
		{
			MPI_Recv(&element, sizeof(int), MPI_INT, 1, dataTag, GraphComm, MPI_STATUS_IGNORE);
			A->getData()[j] = element;
		}

		//Receive part of A from T4
		for (int j = 4 * H; j < 5 * H; j++)
		{
			MPI_Recv(&element, sizeof(int), MPI_INT, 4, dataTag, GraphComm, MPI_STATUS_IGNORE);
			A->getData()[j] = element;
		}

		//Send part of A to T5
		for (int j = 0; j < 5 * H; j++)
		{
			element = A->getData()[j];
			MPI_Send(&element, sizeof(int), MPI_INT, 5, dataTag, GraphComm);
		}

		printf("\nProcess %d finished!", rank);
	}
	if (rank == 4)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//recive Z
		int recv_data[H];
		MPI_Recv(recv_data, H, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
		Z = new Vector(H, recv_data);

		//Recive B from parent
		int recv_dataB[N];
		MPI_Recv(recv_dataB, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
		B = new Vector(N, recv_dataB);

		//Recive T from parent
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MO from parent
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMO, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MO->fillRow(i, recv_dataMO);
		}

		//recive d
		MPI_Recv(&d, sizeof(int), MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Recive MK from parent
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		int ai = Z->getMax();

		//Send max to T3
		MPI_Send(&ai, sizeof(int), MPI_INT, 3, dataTag, GraphComm);

		//recive max from T3
		MPI_Recv(&a, sizeof(int), MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = 4 * H; i < 5 * H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Send part of A to T3
		int element;
		for (int j = 4 * H; j < 5 * H; j++)
		{
			element = A->getData()[j];
			MPI_Send(&element, sizeof(int), MPI_INT, 3, dataTag, GraphComm);
		}

		printf("\nProcess %d finished!", rank);
	}
	if (rank == 5)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//input data
		MK = new Matrix(N, 1);

		//Recive T from parent
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MO from T6
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMO, N, MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MO->fillRow(i, recv_dataMO);
		}

		//recive d from T6
		MPI_Recv(&d, sizeof(int), MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Send T to T3
		MPI_Send(T->getData(), T->getSize(), MPI_INT, 3, dataTag, GraphComm);

		//Send MO to T3
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, 3, dataTag, GraphComm);
		}

		//Send d to T3
		MPI_Send(&d, sizeof(int), MPI_INT, 3, dataTag, GraphComm);

		//Send MK to T3
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], N, MPI_INT, 3, dataTag, GraphComm);
		}

		//recive Z form T3
		int recv_data[3 * H];
		MPI_Recv(recv_data, 3 * H, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
		Z = new Vector(3 * H, recv_data);

		//Recive B from T3
		int recv_dataB[N];
		MPI_Recv(recv_dataB, N, MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
		B = new Vector(N, recv_dataB);

		//Send Z to T6
		Vector* ZforSend = new Vector(Z, H, 3 * H);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, 6, dataTag, GraphComm);
		Z = new Vector(Z, 0, H);

		//Send B to T6
		MPI_Send(B->getData(), B->getSize(), MPI_INT, 6, dataTag, GraphComm);

		//Send MK to T6
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], N, MPI_INT, 6, dataTag, GraphComm);
		}

		int ai = Z->getMax();

		//recive max from T6
		MPI_Recv(&a, sizeof(int), MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);
		if (a > ai) ai = a;

		//Send max to T3
		MPI_Send(&ai, sizeof(int), MPI_INT, 3, dataTag, GraphComm);

		//recive max from T3
		MPI_Recv(&a, sizeof(int), MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Send max to T6
		MPI_Send(&a, sizeof(int), MPI_INT, 6, dataTag, GraphComm);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = 5 * H; i < 6 * H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Receive part of A from T3
		int element;
		for (int j = 0; j < 5 * H; j++)
		{
			MPI_Recv(&element, sizeof(int), MPI_INT, 3, dataTag, GraphComm, MPI_STATUS_IGNORE);
			A->getData()[j] = element;
		}

		//Send part of A to T6
		for (int j = 0; j < 6 * H; j++)
		{
			element = A->getData()[j];
			MPI_Send(&element, sizeof(int), MPI_INT, 6, dataTag, GraphComm);
		}

		printf("\nProcess %d finished!", rank);
	}
	if (rank == 6)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//Recive T from T7
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, 7, dataTag, GraphComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MO from T7
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMO, N, MPI_INT, 7, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MO->fillRow(i, recv_dataMO);
		}

		//recive d from T3
		MPI_Recv(&d, sizeof(int), MPI_INT, 7, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Send T to T5
		MPI_Send(T->getData(), T->getSize(), MPI_INT, 5, dataTag, GraphComm);

		//Send MO to T5
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, 5, dataTag, GraphComm);
		}

		//Send d to T5
		MPI_Send(&d, sizeof(int), MPI_INT, 5, dataTag, GraphComm);

		//recive Z from T5
		int recv_data[2 * H];
		MPI_Recv(recv_data, 2 * H, MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
		Z = new Vector(2 * H, recv_data);

		//Recive B from T5
		int recv_dataB[N];
		MPI_Recv(recv_dataB, N, MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
		B = new Vector(N, recv_dataB);

		//Recive MK from T5
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		//Send Z to T7
		Vector* ZforSend = new Vector(Z, H, 2 * H);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, 7, dataTag, GraphComm);
		Z = new Vector(Z, 0, H);

		//Send B to T7
		MPI_Send(B->getData(), B->getSize(), MPI_INT, 7, dataTag, GraphComm);

		//Send MK to T7
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], N, MPI_INT, 7, dataTag, GraphComm);
		}

		int ai = Z->getMax();

		//recive max from T7
		MPI_Recv(&a, sizeof(int), MPI_INT, 7, dataTag, GraphComm, MPI_STATUS_IGNORE);
		if (a > ai) ai = a;

		//Send max to T5
		MPI_Send(&ai, sizeof(int), MPI_INT, 5, dataTag, GraphComm);

		//recive max from T5
		MPI_Recv(&a, sizeof(int), MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//Send max to T7
		MPI_Send(&a, sizeof(int), MPI_INT, 7, dataTag, GraphComm);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = 6 * H; i < 7 * H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Receive part of A from T5
		int element;
		for (int j = 0; j < 6 * H; j++)
		{
			MPI_Recv(&element, sizeof(int), MPI_INT, 5, dataTag, GraphComm, MPI_STATUS_IGNORE);
			A->getData()[j] = element;
		}

		//Send part of A to T7
		for (int j = 0; j < 7 * H; j++)
		{
			element = A->getData()[j];
			MPI_Send(&element, sizeof(int), MPI_INT, 7, dataTag, GraphComm);
		}

		printf("\nProcess %d finished!", rank);
	}
	if (rank == 7)
	{
		printf("\nProcess started! Rank in GraphComm: %d", rank);
		printf(" Neighbours count: %d ", neighbourNumber);
		printf(" Neighbours ranks: ");
		for (int i = 0; i<neighbourNumber; i++)
		{
			printf("%d,", neighbours[i]);
		}

		//Input data
		d = 1;
		T = new Vector(N, 1);
		MO = new Matrix(N, 1);

		//Send T to T6
		MPI_Send(T->getData(), T->getSize(), MPI_INT, 6, dataTag, GraphComm);

		//Send MO to T6
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, 6, dataTag, GraphComm);
		}

		//Send d to T6
		MPI_Send(&d, sizeof(int), MPI_INT, 6, dataTag, GraphComm);

		//recive Z from T6
		int recv_data[H];
		MPI_Recv(recv_data, H, MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);
		Z = new Vector(H, recv_data);

		//Recive B from T6
		int recv_dataB[N];
		MPI_Recv(recv_dataB, N, MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);
		B = new Vector(N, recv_dataB);

		//Recive MK from T6
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		int ai = Z->getMax();

		//Send max to T6
		MPI_Send(&ai, sizeof(int), MPI_INT, 6, dataTag, GraphComm);

		//recive max from T6
		MPI_Recv(&a, sizeof(int), MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);

		//final calculation
		A = new Vector(N);
		Matrix* MA = new Matrix(N);
		for (int i = 7 * H; i < 8 * H; i++)
		{
			int buf;
			for (int j = 0; j < N; j++)
			{
				buf = 0;
				for (int k = 0; k < N; k++)
				{
					buf += MO->getData()[i][k] * MK->getData()[k][j];
				}
				MA->getData()[i][j] = buf;
			}
			buf = 0;
			for (int j = 0; j < N; j++)
			{
				buf += T->getData()[j] * MA->getData()[i][j];
			}
			A->getData()[i] = d * B->getData()[i] + a * buf;
		}

		//Receive part of A from T6
		int element;
		for (int j = 0; j < 7 * H; j++)
		{
			MPI_Recv(&element, sizeof(int), MPI_INT, 6, dataTag, GraphComm, MPI_STATUS_IGNORE);
			A->getData()[j] = element;
		}

		//print result
		printf("\nA = ");
		A->print();

		printf("\nProcess %d finished!", rank);
	}
#pragma endregion

#pragma region MemoryFree
	//Return the allocated memory to the system.
	free(index);
	free(edges);
	free(neighbours);
#pragma endregion

#pragma region MPIstop
	//stop of environment of MPI
	MPI_Finalize();
#pragma endregion

	//finish
	return 0;
}

