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

Vector::~Vector()
{
	delete[] _data;
}


void Vector::setElement(int index, int value)
{
	_data[index] = value;
}

void Vector::print()
{
	if (_size < 0)
		for (int i = 0; i < _size; i++)
			printf("%6d ", _data[i]);
	else printf("Output is to big!");
	printf("\n");
}

int Vector::getElement(int index)
{
	return _data[index];
}