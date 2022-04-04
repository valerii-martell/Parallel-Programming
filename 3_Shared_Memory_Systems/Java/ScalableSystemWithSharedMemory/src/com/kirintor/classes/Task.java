package com.kirintor.classes;

import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.ForkJoinTask;
import java.util.concurrent.RecursiveAction;

public class Task extends Thread{
	
	private int threadID;
	
	private static final int N = Main.N;
	private static final int P = Main.P;
	private static final int H = N/P;
	
	private static Vector A = new Vector(N);
	private static Vector B;
	private static Vector Z;
	private static Matrix MO;
	private static Matrix MK;
	private static int e;
	
	private static CopyMonitor<Integer> eCopyMonitor = new CopyMonitor<Integer>();
	private static CopyMonitor<Vector> zCopyMonitor = new CopyMonitor<Vector>();
	private static CopyMonitor<Matrix> mkCopyMonitor = new CopyMonitor<Matrix>();
	private static BarrierMonitor inputBarrier = new BarrierMonitor(P);
	private static BarrierMonitor sortBarrier = new BarrierMonitor(P);
	private static BarrierMonitor computeBarrier = new BarrierMonitor(P);
	
	public Task(int threadID, int priority){
        this.setPriority(priority);
		this.threadID = threadID;
	}	       
	
	@Override
	public void run() {
		System.out.println("Thread "+threadID+" started!");

		switch (threadID) {
		case 0:
			B = new Vector(N, 1);
			//B.getData()[2] = 10;
			e = 1;
			eCopyMonitor.set(e);
			MO = new Matrix(N, 1);		
			break;
		case Main.P-1:
			MK = new Matrix(N, 1);
			mkCopyMonitor.set(MK);
			Z = new Vector(N, 1);
			zCopyMonitor.set(Z);
			break;	
		}	
		    	
		inputBarrier.signalAndWait();
		
		if (threadID==0){
			B = multiprocessingSort(B, P);
		}
		
		sortBarrier.signalAndWait();
		
		Matrix MKi = new Matrix(mkCopyMonitor.get());
		Vector Zi = new Vector(zCopyMonitor.get());
		int ei = eCopyMonitor.get().intValue();
			        
		ForkJoinPool pool = new ForkJoinPool(1); 
		pool.invoke(new ParallelFor(threadID*H, (threadID+1)*H, ei, Zi, MKi));
		
		computeBarrier.signalAndWait();
		
	    if (threadID == P-1) {
	    	A.print();
	    }
            
	    System.out.println("Thread "+threadID+" finished!");
	}
	
	@SuppressWarnings("serial")
	private class ParallelFor extends RecursiveAction {
		
		private int from;
		private int to;
			
		private Matrix MK;
		private Vector Z;
		private int e;
	
		public int TASK_LEN;
	
		public ParallelFor(int from, int to, int e, Vector Z, Matrix MK) {
			this.from = from;
			this.to = to;
			this.Z = new Vector(Z);
			this.MK = new Matrix(MK);
			this.e = e;
			this.TASK_LEN = Z.getN()/2;
		}

		@Override
		protected void compute() {
			int len = to - from;
			if (len < TASK_LEN) {
				work(from, to, e, Z, MK);
			} else{
				int mid = (from + to) >>> 1;
				ForkJoinTask<Void> parallelFor1 = new ParallelFor(from, mid, e, Z, MK).fork();
				ForkJoinTask<Void> parallelFor2 = new ParallelFor(mid, to, e, Z, MK).fork();
				parallelFor1.join();
				parallelFor2.join();
				
			}
		}
		
		private void work(int from, int to, int e, Vector Z, Matrix MK){
	    	Matrix MA = new Matrix(N);
	    	for (int i = from; i < to; i++){
	    		int buf;
                for (int j = 0; j < N; j++){
                    buf = 0;
                    for (int k = 0; k < N; k++){
                        buf += MO.getData()[i][k] * MK.getData()[k][j];
                    }
                    MA.getData()[i][j] = buf;
                }
                buf = 0;
                for (int j = 0; j < N; j++){
                    buf += Z.getData()[j] * MA.getData()[i][j];
                }
                A.getData()[i] = e*B.getData()[i] + buf;
	            }
	        }
	    }
	
	private static Vector multiprocessingSort(Vector vector, int procCount){
			Vector result = null;
			int newN = vector.getN()-getTwoPow(vector.getN());
			int newProcCount = procCount-getTwoPow(procCount);
				if((vector.getN()==getTwoPow(vector.getN()))&&(procCount==getTwoPow(procCount))){
					SortForkJoin sortForkJoin = new SortForkJoin(getTwoPow(procCount),0,getTwoPow(vector.getN()),vector);
					ForkJoinPool pool = new ForkJoinPool(getTwoPow(procCount)); 
			    	pool.invoke(sortForkJoin);
					result = sortForkJoin.getVector();
				}else if((procCount >=2)&&(newProcCount>1)&&(newN>=newProcCount)){			
					result = new Vector().mergeSort(multiprocessingSort(new Vector(vector, 0, getTwoPow(vector.getN())), getTwoPow(procCount)), 
								multiprocessingSort(new Vector(vector, getTwoPow(vector.getN()), vector.getN()), newProcCount));
				}else{
					result = new Vector().mergeSort(multiprocessingSort(new Vector(vector, 0, getTwoPow(vector.getN())), getTwoPow(procCount)), 
				             new Vector(vector, getTwoPow(vector.getN()), vector.getN()).sort());
				}	
			return result;		
		}
		
	private static int getTwoPow(int number){
			int result = 1;
			while(result <= number){
				result *= 2;
			};
			result /=2;
			return result;
		}	
}
