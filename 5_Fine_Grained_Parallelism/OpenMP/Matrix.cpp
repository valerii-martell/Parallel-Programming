#include "stdafx.h"
#include <iostream>
#include <cstdlib>
#include "Data.h"

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

Matrix::Matrix(int size)
{
	_size = size;
	_data = new int*[size];
	for (int i = 0; i < size; i++)
		_data[i] = new int[size];
}

Matrix::Matrix(Matrix* matrix)
{
	_size = matrix->getSize();
	_data = new int*[_size];
	for (int i = 0; i < _size; i++)
		_data[i] = new int[_size];

	for (int i = 0; i < _size; i++)
		for (int j = 0; j < _size; j++)
			_data[i][j] = matrix->getData()[i][j];
}

Matrix::~Matrix()
{
	for (int i = 0; i < _size; i++)
		delete[] _data[i];
	delete[] _data;
}

Matrix* Matrix::copyTo()
{
	Matrix* result = new Matrix(_size, false);
	for (int i = 0; i < _size; i++)
		for (int j = 0; j < _size; j++)
			result->setElement(i, j, _data[i][j]);
	return result;
}

void Matrix::setElement(int indexI, int indexJ, int value)
{
	this->_data[indexI][indexJ] = value;
}

int Matrix::getElement(int indexI, int indexJ)
{
	return this->_data[indexI][indexJ];
}

int Matrix::getSize()
{
	return _size;
}

int** Matrix::getData()
{
	return _data;
}

void Matrix::print()
{
	if (_size < 0)
		for (int i = 0; i < _size; i++)
		{
			for (int j = 0; j < _size; j++)
				printf("%6d ", _data[i][j]);
			printf("\n");
		}
	else
		printf("Output is too big!\n");
}