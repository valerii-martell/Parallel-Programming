#include "stdafx.h"
#include <iostream>
#include <cstdlib>

using namespace std;

Matrix::Matrix(int size, int number)
{
	_size = size;
	_data = new int*[size];
	for (int i = 0; i < size; i++)
		_data[i] = new int[size];

	for (int i = 0; i < size; i++)
		for (int j = 0; j < size; j++)
			_data[i][j] = number;
}

Matrix::Matrix(Matrix* matrix)
{
	_size = matrix->getSize();
	_data = new int*[_size];
	for (int i = 0; i < _size; i++)
		_data[i] = new int[_size];

	for (int i = 0; i < _size; i++)
		for (int j = 0; j < _size; j++)
			_data[i][j] = matrix->getElement(i, j);
}

Matrix::~Matrix()
{
	for (int i = 0; i < _size; i++)
		delete[] _data[i];
	delete[] _data;
}

Matrix* Matrix::MulMatrices(Matrix* matrix1, int up, int down)
{
	Matrix* result = new Matrix(_size, 0);
	for (int i = 0; i< _size; i++)
		for (int j = 0; j < _size; j++)
		{
			int buf = 0;
			for (int k = 0; k < _size; k++)
			{
				buf += matrix1->getElement(i, k)*_data[k][j];
			}
			result->setElement(i, j, buf);
		}
	return result;
}

Vector* Matrix::MulVectorMatrix(Vector* vector, int up, int down)
{
	Vector* result = new Vector(_size, 0);
	for (int j = 0; j < _size; j++)
	{
		int buf = 0;
		for (int k = 0; k < _size; k++)
		{
			buf += vector->getElement(k)*_data[k][j];
		}
		result->setElement(j, buf);
	}
	return result;
}

void Matrix::setElement(int indexI, int indexJ, int value)
{
	_data[indexI][indexJ] = value;
}

int Matrix::getElement(int indexI, int indexJ)
{
	return _data[indexI][indexJ];
}

int Matrix::getSize()
{
	return _size;
}

void Matrix::print()
{
	if (_size <= 10)
		for (int i = 0; i < _size; i++)
		{
			for (int j = 0; j < _size; j++)
				printf("%6d ", _data[i][j]);
			printf("\n");
		}
	else
		printf("Output is to big!\n");
}