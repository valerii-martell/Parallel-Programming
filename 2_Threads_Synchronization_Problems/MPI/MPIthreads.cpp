/// <summary>
/// Programming for parallel computer systems
/// Laboratory work #8. MPI
/// Valeriy Demchik
/// NTUU "KPI"
/// FICT IO - 41
/// 06.06.2017
/// Task: A=max(Z)*B + d*T*(MO*MK)
/// 
/// Main file
/// </summary>

#include "stdafx.h"
#include <iostream>
#include <windows.h>
#include "mpi.h"

using namespace std;

//System parameters
//System always included one main processor
const int F = 4;	//rays count
const int S = 4;	//rays length
const int P = F*S + 1;	//Summary, processors count in system is F*S + 1
const int N = 17;
const int H = N / P;

int main(int argc, char* argv[])
{

#pragma region MPIstart
	//#pragma comment(linker, "/STACK:400000000")

	//buffer for count of neighbours
	int neighbourNumber;

	//tags for MPI messages
	const int sizeTag = 0;
	const int dataTag = 1;

	//allocate memory for topology arrays
	int *index, *edges, *neighbours;
	index = (int*)malloc(P * sizeof(int));
	edges = (int*)malloc(2 * F * S * sizeof(int));
	neighbours = (int*)malloc(F * sizeof(int));

	//feel indexes of graph
	index[0] = F;
	for (int i = 1; i < P-F; i++)
	{
		index[i] = index[i - 1] + 2;
	}
	for (int i = P - F; i < P; i++)
	{
		index[i] = index[i - 1] + 1;
	}
	/*for (int i = 0; i < P; i++)
	{
		cout << index[i] << ' ';
	}*/

	//feel vector of graph incidence
	int i = 0;
	for (i = 0; i < F; i++)
	{
		edges[i] = i + 1;
	}
	int j = 0;
	while (j < F)
	{
		edges[i] = 0;
		edges[i + 1] = edges[i - 1] + 1;
		i += 2;
		j += 1;
	}
	int currentNode = F + 1;
	while (currentNode != P - F)
	{
		edges[i] = currentNode - F;
		edges[i + 1] = currentNode + F;
		i += 2;
		currentNode += 1;
	}
	while (currentNode<P)
	{
		edges[i] = currentNode - F;
		currentNode++;
		i++;
	}
	/*for (int i = 0; i < 2*F*S; i++)
	{
		cout << edges[i] << ' ';
	}*/

	//star communicator
	MPI_Comm StarComm;

	//start of environment of MPI
	MPI_Init(&argc, &argv);

	//graph create
	MPI_Graph_create(MPI_COMM_WORLD, P, index, edges, 1, &StarComm);

	//get rank of procces
	int rank;
	MPI_Comm_rank(StarComm, &rank);

	//get count of neighbors
	MPI_Graph_neighbors_count(StarComm, rank, &neighbourNumber);

	//get neighbors ranks
	MPI_Graph_neighbors(StarComm, rank, neighbourNumber, neighbours);

#pragma endregion

#pragma region PrintGraph
	
	printf("\nRank in StarComm: %d \t|", rank);
	printf(" Neighbours count: %d \t|", neighbourNumber);
	printf(" Neighbours: ");
	for (int i = 0; i<neighbourNumber; i++)
	{
		printf("%d,", neighbours[i]);
	}
	
#pragma endregion

#pragma region DataDeclarations
	//data handle
	Vector* A;
	Vector* B;
	Vector* Z;
	Vector* T;
	Matrix* MK;
	Matrix* MO;
	int d;
	int m;
#pragma endregion

#pragma region ProcessorsFunctions
	if (rank == 0)
	{
		//Input data
		B = new Vector(N, 1);
		//B->getData()[16] = 2;
		T = new Vector(N, 1);
		Z = new Vector(N, 1);
		//Z->getData()[9] = 10;
		MK = new Matrix(N, 1);
		MO = new Matrix(N, 1);
		d = 1;

		//Send size to childrens
		for (int i = 1; i <= F; i++)
		{
			int size = (N - H) / F;
			MPI_Send(&size, sizeof(int), MPI_INT, i, sizeTag, StarComm);
		}

		//Send B and Z to childrens 
		int div = (N - H) / F;
		int start = H;
		for (int i = 1; i <= F; i++)
		{
			Vector* BforSend = new Vector(B, start, start + div);
			Vector* ZforSend = new Vector(Z, start, start + div);
			MPI_Send(BforSend->getData(), BforSend->getSize(), MPI_INT, i, dataTag, StarComm);
			MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, i, dataTag, StarComm);
			start += div;
		}
		
		//Send parts of MO to childrens
		div = (N - H) / F;
		start = H;
		for (int i = 1; i <= F; i++)
		{
			for (int j = start; j < start + div; j++)
			{
				MPI_Send(MO->getData()[j], N, MPI_INT, i, dataTag, StarComm);
			}
			start += div;
		}

		//Send T to childrens
		for (int i = 1; i <= F; i++)
		{
			MPI_Send(T->getData(), T->getSize(), MPI_INT, i, dataTag, StarComm);
		}

		//Send MK to childrens
		for (int i = 1; i <= F; i++)
		{
			for (int j = 0; j < N; j++)
			{
				MPI_Send(MK->getData()[j], MK->getSize(), MPI_INT, i, dataTag, StarComm);
			}
		}
		
		//get first H-part of B and Z 
		B = new Vector(B, 0, H);
		Z = new Vector(Z, 0, H);

		m = Z->getMax();

		//Recive max from childrens
		int buf_m;
		for (int i = 1; i <= F; i++)
		{
			MPI_Recv(&buf_m, sizeof(int), MPI_INT, i, dataTag, StarComm, MPI_STATUS_IGNORE);
			m = max(m, buf_m);
		}

		//printf("\tMax= %d ", m);

		//Send max and d to childrens
		for (int i = 1; i <= F; i++)
		{
			MPI_Send(&m, sizeof(int), MPI_INT, i, dataTag, StarComm);
			MPI_Send(&d, sizeof(int), MPI_INT, i, dataTag, StarComm);
		}
		
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
			A->getData()[i] = m * B->getData()[i] + d * buf;
		}

		//Receive parts of A from childrens
		int recv_size = (N-H)/F;
		int *recv_data = (int*)malloc(recv_size * sizeof(int));
		int startIndex = H;
		for (int i = 1; i <= F; i++)
		{
			MPI_Recv(recv_data, recv_size, MPI_INT, i, dataTag, StarComm, MPI_STATUS_IGNORE);
			for (int j = startIndex; j < startIndex + recv_size; j++)
			{
				A->getData()[j] = recv_data[j-startIndex];
			}
			startIndex += recv_size;
		}

		//print result
		printf("\nA = ");
		A->print();
	}
	else if ((rank < P-F) && (rank != 0)) {

		//Recive size from parent
		int recv_size;
		MPI_Recv(&recv_size, sizeof(int), MPI_INT, neighbours[0], sizeTag, StarComm, MPI_STATUS_IGNORE);

		//Send size to children
		recv_size -= H;
		MPI_Send(&recv_size, sizeof(int), MPI_INT, neighbours[1], sizeTag, StarComm);
		recv_size += H;

		//Recive B and C from parent
		int *recv_data = (int*)malloc(recv_size * sizeof(int));
		MPI_Recv(recv_data, recv_size, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
		B = new Vector(recv_size, recv_data);
		MPI_Recv(recv_data, recv_size, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
		Z = new Vector(recv_size, recv_data);

		//Send B and C to children
		Vector* BforSend = new Vector(B, H, recv_size);
		Vector* ZforSend = new Vector(Z, H, recv_size);
		MPI_Send(BforSend->getData(), BforSend->getSize(), MPI_INT, neighbours[1], dataTag, StarComm);
		MPI_Send(ZforSend->getData(), ZforSend->getSize(), MPI_INT, neighbours[1], dataTag, StarComm);

		//Recive parts of MO from parent
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int j = 0; j < recv_size; j++)
		{
			MPI_Recv(&recv_dataMO, N, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
			MO->fillRow(j, recv_dataMO);
		}

		//Send parts of MO to children
		for (int j = H; j < recv_size; j++)
		{
			MPI_Send(MO->getData()[j], N, MPI_INT, neighbours[1], dataTag, StarComm);
		}

		//Recive T from parent
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Send T to childrens
		MPI_Send(T->getData(), T->getSize(), MPI_INT, neighbours[1], dataTag, StarComm);

		//Recive MK from parent
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		//Send MK to children
		for (int j = 0; j < N; j++)
		{
			MPI_Send(MK->getData()[j], MK->getSize(), MPI_INT, neighbours[1], dataTag, StarComm);
		}

		//get first H-part of B and Z
		B = new Vector(B, 0, H);
		Z = new Vector(Z, 0, H);

		m = Z->getMax();

		//Recive max from children
		int buf_m;
		MPI_Recv(&buf_m, sizeof(int), MPI_INT, neighbours[1], dataTag, StarComm, MPI_STATUS_IGNORE);
		m = max(m, buf_m);

		//Send max to parent
		MPI_Send(&m, sizeof(int), MPI_INT, neighbours[0], dataTag, StarComm);
		
		//Recive max from parent
		MPI_Recv(&m, sizeof(int), MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);

		//Recive d from parent
		MPI_Recv(&d, sizeof(int), MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);

		//Send max to children
		MPI_Send(&m, sizeof(int), MPI_INT, neighbours[1], dataTag, StarComm);

		//Send d to children
		MPI_Send(&d, sizeof(int), MPI_INT, neighbours[1], dataTag, StarComm);

		//final calculation
		A = new Vector(recv_size);
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
			A->getData()[i] = m * B->getData()[i] + d * buf;
		}

		//Receive parts of A from childrens
		recv_size -= H;
		recv_data = (int*)malloc(recv_size * sizeof(int));
		MPI_Recv(recv_data, recv_size, MPI_INT, neighbours[1], dataTag, StarComm, MPI_STATUS_IGNORE);
		for (int i = 0; i < recv_size; i++)
		{
			A->getData()[i+H] = recv_data[i];
		}		

		//Send parts of A to parent
		MPI_Send(A->getData(), A->getSize(), MPI_INT, neighbours[0], dataTag, StarComm);
	}
	else
	{
		//Recive size from parent
		int recv_size;
		MPI_Recv(&recv_size, sizeof(int), MPI_INT, neighbours[0], sizeTag, StarComm, MPI_STATUS_IGNORE);

		//Recive B and C from parent
		int *recv_data = (int*)malloc(recv_size * sizeof(int));
		MPI_Recv(recv_data, recv_size, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
		B = new Vector(recv_size, recv_data);
		MPI_Recv(recv_data, recv_size, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
		Z = new Vector(recv_size, recv_data);

		//Recive parts of MO from parent
		MO = new Matrix(N);
		int recv_dataMO[N];
		for (int j = 0; j < recv_size; j++)
		{
			MPI_Recv(&recv_dataMO, N, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
			MO->fillRow(j, recv_dataMO);
		}

		//Recive T from parent
		int recv_dataT[N];
		MPI_Recv(recv_dataT, N, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
		T = new Vector(N, recv_dataT);

		//Recive MK from parent
		MK = new Matrix(N);
		int recv_dataMK[N];
		for (int i = 0; i < N; i++)
		{
			MPI_Recv(recv_dataMK, N, MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);
			MK->fillRow(i, recv_dataMK);
		}

		//get first H-part of B and Z
		B = new Vector(B, 0, H);
		Z = new Vector(Z, 0, H);

		m = Z->getMax();

		//Send max to parent
		MPI_Send(&m, sizeof(int), MPI_INT, neighbours[0], dataTag, StarComm);

		//Recive max from parent
		MPI_Recv(&m, sizeof(int), MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);

		//Recive d from parent
		MPI_Recv(&d, sizeof(int), MPI_INT, neighbours[0], dataTag, StarComm, MPI_STATUS_IGNORE);

		//final calculation
		A = new Vector(H);
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
			A->getData()[i] = m * B->getData()[i] + d * buf;
		}

		//Send parts of A to parent
		MPI_Send(A->getData(), A->getSize(), MPI_INT, neighbours[0], dataTag, StarComm);
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

