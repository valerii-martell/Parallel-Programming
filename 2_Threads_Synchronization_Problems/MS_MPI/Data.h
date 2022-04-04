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

	Vector(int size, int* data);

	Vector(Vector* vector, int startIndex, int finishIndex);

	~Vector();

	void setElement(int index, int value);

	void print();

	int getMax(int startIndex, int finishIndex);

	int getMax();

	int getSize();

	void setPart(int startIndex, int* data);

	int* getPart(int startIndex, int size);

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

	void fillRow(int indeRow, int* data);

	int getElement(int indexI, int indexJ);

	Matrix* copyTo();

	int** getData();

	int getSize();

	void print();
};
