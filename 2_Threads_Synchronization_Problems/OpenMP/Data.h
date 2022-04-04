#pragma once

class Vector {
private:

	int _size;
	int* _data;

public:

	Vector(int size);

	Vector(Vector* vector);

	Vector(int size, int number);

	Vector(int size, bool fill);

	~Vector();

	void setElement(int index, int value);

	void print();

	int getMax(int startIndex, int finishIndex);

	int getSize();

	int getElement(int index);

	int* getData();
};

class Matrix {
private:
	int _size;
	int** _data;
public:

	Matrix(int size, int number);

	Matrix(int size);

	Matrix(Matrix* matrix);

	~Matrix();

	void setElement(int indexI, int indexJ, int value);

	int getElement(int indexI, int indexJ);

	Matrix* copyTo();

	int** getData();

	int getSize();

	void print();
};
