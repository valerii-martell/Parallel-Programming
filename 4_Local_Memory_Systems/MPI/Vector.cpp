/// <summary>
/// Programming for parallel computer systems
/// Curse work part 2. Scalable system with local memory
/// Valeriy Demchik
/// NTUU "KPI"
/// FICT IO - 41
/// 20.04.2017
/// 
/// Containing C++ source code for Vector class
/// </summary>
#include "Data.h"
#include "stdafx.h"
#include <iostream>
#include <cstdlib>

using namespace std;

Vector::Vector(int size, bool fill)
{
	_size = size;
	_data = new int[size];
	if (fill)
		for (int i = 0; i < _size; i++)
			_data[i] = rand() % 100 + 1;
	else
		for (int i = 0; i < _size; i++)
			_data[i] = 0;
}

Vector::Vector(int size, int number)
{
	_size = size;
	_data = new int[size];
	for (int i = 0; i < _size; i++)
		_data[i] = number;
}

Vector::Vector(int size)
{
	_size = size;
	_data = new int[size];
}

Vector::Vector(Vector* vector)
{
	_size = vector->getSize();
	_data = new int[_size];
	for (int i = 0; i < _size; i++)
		_data[i] = vector->getData()[i];
}

Vector::Vector(Vector* vector, int startIndex, int finishIndex)
{
	_size = finishIndex - startIndex;
	_data = new int[_size];
	for (int i = 0; i < _size; i++)
		_data[i] = vector->getData()[i + startIndex];
}

Vector::Vector(int size, int* data)
{
	_size = size;
	_data = new int[_size];
	for (int i = 0; i < _size; i++)
		_data[i] = data[i];
}

Vector::~Vector()
{
	delete[] _data;
}

void Vector::setElement(int index, int value)
{
	_data[index] = value;
}

void Vector::setPart(int startIndex, int* data)
{
	for (int i = 0; i < sizeof(data) / sizeof(data[0]); i++)
		_data[i + startIndex] = data[i];
}

int* Vector::getPart(int startIndex, int size)
{
	int* result = (int*)malloc(size * sizeof(int));
	for (int i = 0; i < size; i++)
		result[i] = _data[i + startIndex];
	return result;
}

void Vector::print()
{
	if (_size <= 100)
		for (int i = 0; i < _size; i++)
			printf("%6d ", _data[i]);
	else printf("Output is to big!");
	printf("\n");
}

int Vector::getMax(int startIndex, int finishIndex)
{
	int max = INT32_MIN;
	for (int i = startIndex; i < finishIndex; i++)
	{
		if (_data[i] >= max) max = _data[i];
	}
	return max;
}

int Vector::getMax()
{
	int max = INT32_MIN;
	for (int i = 0; i < _size; i++)
	{
		if (_data[i] >= max) max = _data[i];
	}
	return max;
}

int Vector::getElement(int index)
{
	return _data[index];
}

int Vector::getSize()
{
	return _size;
}

int* Vector::getData()
{
	return _data;
}