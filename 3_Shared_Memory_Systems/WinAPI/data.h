#pragma once
class Vector {
private:
	int _size;
	int* _data;

public:
	Vector(int size, int number);

	Vector(Vector* vector);

	~Vector();

	Vector* MulVectorNumber(int number);

	void AddVectors(Vector* vector1, Vector* vector2, Vector* vector3, int up, int down);

	void sort(int startIndex, int finishIndex);

	void mergeSort(int startIndex, int finishIndex);

	void Vector::Swap(int indexI, int indexJ);

	void setElement(int index, int value);

	void print();

	int getElement(int index);

	int getSize();

};

class Matrix {
private:
	int _size;
	int** _data;
public:

	Matrix(int size, int number);

	Matrix(Matrix* matrix);

	~Matrix();

	Matrix* MulMatrices(Matrix* matrix1, int up, int down);

	Vector* MulVectorMatrix(Vector* vector, int up, int down);

	void setElement(int indexI, int indexJ, int value);

	int getElement(int indexI, int indexJ);

	int getSize();

	void print();
};