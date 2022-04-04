package com.kirintor.classes;

public class Main{
	
	//system parameters
	public static final int N = 5;
	public static final int P = 5;
	
	private static Thread[] threads = new Thread[P];
	
	public static void main(String[] args) throws InterruptedException{
		
		System.out.println("Java started");
		
		long timer = -System.nanoTime();
		
		for(int i = 0; i< P; i++){
			threads[i] = new Task(i, Thread.NORM_PRIORITY);      
	        threads[i].start();
		}
		
		for(int i = 0; i< P; i++){
	        threads[i].join();
		}
		
		timer += System.nanoTime();
		
		System.out.println("Time (sec): " + (double)timer/1000000000);

        System.out.println("Java finished");
		
    }
	
	
}