package com.kirintor.classes;

import java.util.ArrayList;
import java.util.Random;

public class Vector {

	private int n;
	private int[] data;
	
	public Vector(){		
	}
	
	public Vector(int n, int number){
		data = new int[n];
        this.n = n;
        for (int i = 0; i < n; i++)
        {
        	data[i] = number;
        }
	}
	
	public Vector(int n, boolean isRandom) {
        this.n = n;
        this.data = new int[n];
        if (isRandom) {
            Random rnd = new Random();
            for (int i = 0; i < n; i++) {
                this.data[i] = rnd.nextInt(100);
            }
        }
    }
	
	public Vector(int n) {
        this.n = n;
        this.data = new int[n];
    }
	
	public Vector(Vector vector){
		this.n = vector.getN();
		data = new int[n];
		for(int i =0; i<n; i++)
		{
			data[i] = vector.getElement(i);
		}
	}
	
	public Vector(Vector vector, int startIndex, int finishIndex){
		this.n = finishIndex-startIndex;
		data = new int[n];
		for(int i =0; i<n; i++)
		{
			data[i] = vector.getElement(startIndex);
			startIndex++;
		}
	}
	
	public Vector sort(){
		int tmp;
		for (int i = 0; i < n; i++)
			for (int j = 1; j < n - i; j++)
				if (data[j - 1] > data[j])
				{
					tmp = data[j - 1];
					data[j - 1] = data[j];
					data[j] = tmp;
				}
		return this;
	}
	
	public void sort(int startIndex, int finishIndex){
		int tmp;
		for (int i = startIndex; i < finishIndex; i++)
			for (int j = 1; j < n - i; j++)
				if (data[j - 1] > data[j])
				{
					tmp = data[j - 1];
					data[j - 1] = data[j];
					data[j] = tmp;
				}
	}

	@SuppressWarnings("unused")
	private void swap(int indexI, int indexJ){
		int buf = data[indexI];
		data[indexI] = data[indexJ];
		data[indexJ] = buf;
	}

	public Vector mergeSort(Vector vector1, Vector vector2){
		Vector result = new Vector(vector1.getN()+vector2.getN(), 0);
		ArrayList<Integer> array1 = new ArrayList<Integer>(vector1.getN());
		ArrayList<Integer> array2 = new ArrayList<Integer>(vector2.getN());
		ArrayList<Integer> resultList = new ArrayList<Integer>(result.getN());
		
		for(int i = 0; i<vector1.getN(); i++){
			array1.add(Integer.valueOf(vector1.data[i]));
		}
		for(int j = 0; j<vector2.getN(); j++){
			array2.add(Integer.valueOf(vector2.data[j]));
		}
		
		while(((!array1.isEmpty())
			 &&(!array2.isEmpty()))){
			if (array1.get(0) <= array2.get(0)){
				resultList.add(array1.get(0));
				array1.remove(0);
			}else{
				resultList.add(array2.get(0));
				array2.remove(0);
			}
		}
		if(array1.isEmpty()){
			while(!array2.isEmpty()){
				resultList.add(array2.get(0));
				array2.remove(0);
			}
		}else{
			while(!array1.isEmpty()){
				resultList.add(array1.get(0));
				array1.remove(0);
			}
		}
		
		for(int i = 0; i<result.getN(); i++){
			result.setElement(resultList.get(i), i);
		}
		
		return result;
	}
	
	public void print(){
        if (n <= 20){
        	System.out.print("[");
            for (int i = 0; i < n-1; i++){
            	System.out.print(data[i] + ", ");
            }
            System.out.println(data[n-1]+"]");
        }
        else{
        	System.out.println("Output is too big!");
        }
    }
	
	public String toString(){
		String result = "[";
		for (int i = 0; i < n-1; i++)
        {
        	result += data[i] + ", ";
        }
		result += data[n-1]+"]";
		return result;		
	}

	public int getN() {
		return n;
	}

	public void setN(int n) {
		this.n = n;
	}
	
	public int[] getData()
	{
		return this.data;
	}

	public int getElement(int index) {
		return data[index];
	}

	public void setElement(int element, int index) {
		data[index] = element;
	}
	
}
