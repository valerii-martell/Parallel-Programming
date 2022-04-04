package com.kirintor.classes;

import java.util.concurrent.ForkJoinPool;

public class Main{
	
	public static final int N = 32;
	public static final int P = 16;
	public static final int H = N/P;

	
	public static void main(String[] args) throws InterruptedException{
		
		System.out.println("Java started");
		
		
		Vector B = new Vector(N, true);
		
		B.Print();
		
		SortForkJoin sortForkJoin = new SortForkJoin(0, N, B);
		ForkJoinPool pool = new ForkJoinPool(P); 
    	pool.invoke(sortForkJoin);
		
		B =  sortForkJoin.getVector();
		
		B.Print();

        System.out.println("Java finished");
		
    }
}