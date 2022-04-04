#include "stdafx.h"

#include <iostream>
#include <cstdlib>

using namespace std;

Vector::Vector(int size, int number)
{
	_size = size;
	_data = new int[size];

	for (int i = 0; i < size; i++)
			_data[i] = number;
}

Vector::Vector(Vector* vector)
{
	_size = vector->getSize();
	_data = new int[_size];

	for (int i = 0; i < _size; i++)
		_data[i] = vector->getElement(i);
}

Vector::~Vector()
{
	delete[] _data;
}

void Vector::sort(int startIndex, int finishIndex)
{
	int tmp;
	for (int i = startIndex; i <= finishIndex; i++)
		for (int j = 1; j < _size - i; j++)
			if (_data[j - 1] > _data[j])
			{
				tmp = _data[j - 1];
				_data[j - 1] = _data[j];
				_data[j] = tmp;
			}
}

void Vector::Swap(int indexI, int indexJ)
{
	int buf = _data[indexI];
	_data[indexI] = _data[indexJ];
	_data[indexJ] = buf;
}

void Vector::mergeSort(int startIndex, int finishIndex)
{
	int h = (finishIndex - startIndex) / 2;
	for (int i = startIndex; i < (finishIndex + startIndex) / 2; i++)
		if (_data[i] > _data[i + h])
		{
			Swap(i, i + h);
		}
}

Vector* Vector::MulVectorNumber(int number)
{
	Vector* result = new Vector(_size, 0);
	for (int i = 0; i < _size; i++)
	{
		result->setElement(i, _data[i]*number);
	}
	return result;
}

void Vector::AddVectors(Vector* vector1, Vector* vector2, Vector* vector3, int up, int down)
{
	for (int i = 0; i < _size; i++)
		_data[i] = vector1->getElement(i) + vector2->getElement(i) + vector3->getElement(i);
}


void Vector::setElement(int index, int value)
{
	_data[index] = value;
}

void Vector::print()
{
	if (_size <= 10)
		for (int i = 0; i < _size; i++)
			printf("%6d ", _data[i]);
	else printf("Output is to big!");
	printf("\n");
}

int Vector::getElement(int index)
{
	return _data[index];
}

int Vector::getSize()
{
	return _size;
}