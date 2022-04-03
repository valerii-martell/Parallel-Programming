from multiprocessing import Process
import threading

#
#        Lab #7
# Author:  Valeriy Demchik
# Group:   IO-41
# Date:    24.11.2016
#
# F1: MC = MIN(A)*(MA*MD)
# F2: MK = TRANS(MA)* TRANS(MB* MM)+MX
# F3:  O = SORT(P)*(MR* MS)
#

N=4

def InputVector():
      vector = [1 for col in range(N)]
      return vector

def InputMatrix():
      matrix = [[1 for row in range(N)] for col in range(N)]
      return matrix

def OutputVector(vector):
      if N <= 5:
          print(vector)

def OutputMatrix(matrix):
      if N <= 5:
          for i in range(N):
              print(matrix[i])


def AddVectors(vector1, vector2):
     result = InputVector()
     for i in range(N):
         result[i] = vector1[i] + vector2[i]
     return result

def SortVector(vector):
     for i in range(N):
         for j in range(i, N):
             if (vector[i] > vector[j]):
                 buffer = vector[i]
                 vector[i] = vector[j]
                 vector[j] = buffer
     return vector

def MultiplyVectorOnMatrix(vector, matrix):
      result = InputVector()
      for i in range(N):
          result[i] = 0
          for j in range(N):
              result[i] = result[i] + vector[j]*matrix[j][i]
      return result

def MultiplyMatrices(matrix1, matrix2):
      result = [[0 for row in range(len(matrix1))] for col in range(len(matrix2[0]))]
      for i in range(len(matrix1)):
          for j in range(len(matrix2[0])):
              for k in range(len(matrix2)):
                  result[i][j] += matrix1[i][k]*matrix2[k][j]
      return result

def TransMatrix(matrix):
      for i in range(N):
          for j in range(i, N):
              buf = matrix[i][j]
              matrix[i][j] = matrix[j][i]
              matrix[j][i] = buf
      return matrix

def FindMinVector(vector):
    min = vector[0]
    for i in range(len(vector)):
        if min > vector[i]:
            min = vector[i]
    return min

def MultNumbMatr(a, matrix):
    for i in range(len(matrix)):
        for j in range(len(matrix)):
            matrix[i][j] = a*matrix[i][j]
    return matrix;

def AddMatr(matrix1, matrix2):
    result = [[0 for x in range(len(matrix1))] for x in range(len(matrix1))]
    for i in range(len(matrix1)):
        for j in range(len(matrix1)):           
            result[i][j] = matrix1[i][j]+matrix2[i][j]
    return result


# F1: MC = MIN(A)*(MA*MD)
def F1():
      print("Function 1 started.")
      A = InputVector()
      MA = InputMatrix()
      MD = InputMatrix()
      MC =  MultNumbMatr(FindMinVector(A), MultiplyMatrices(MA, MD))
      OutputMatrix(MC)
      print("Function 1 ended.")

# F2: MK = TRANS(MA)* TRANS(MB* MM)+MX
def F2():
      print("Function 2 started.")
      MA = InputMatrix()
      MB = InputMatrix()
      MM = InputMatrix()
      MX = InputMatrix()
      MK= AddMatr(MultiplyMatrices(TransMatrix(MA), TransMatrix(MultiplyMatrices(MB,MM))),MX)
      OutputMatrix(MK)
      print("Function 2 ended.")

# F3:  O = SORT(P)*(MR* MS)
def F3():
      print("Function 3 started.")
      O = InputVector()
      P = InputVector()
      MR = InputMatrix()
      MS = InputMatrix()
      O = MultiplyVectorOnMatrix(SortVector(P), MultiplyMatrices(MR,MS))
      OutputVector(O)
      print("Function 3 ended.")


if __name__ == "__main__":
    print("Main started.")

    process1 = Process(target=F1)
    process2 = Process(target=F2)
    process3 = Process(target=F3)

    process1.start()
    process2.start()
    process3.start()

    process1.join()
    process2.join()
    process3.join()

    print("Main ended.")

    input()
