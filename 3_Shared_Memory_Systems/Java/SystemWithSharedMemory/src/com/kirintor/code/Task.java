package com.kirintor.code;

import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.ForkJoinTask;
import java.util.concurrent.RecursiveAction;

import com.kirintor.code.Main;

public class Task extends Thread{
	
	private int threadID;
	
	public static final int N = Main.N;
	public static final int P = Main.P;
	public static final int H = Main.H;
	
	private static Matrix MA = Main.MA;
    private static Matrix MB = Main.MB;
    private static Matrix MC = Main.MC;
    private static Matrix MO = Main.MO;
    private static Matrix MK = Main.MK;
    private static Vector Z = Main.Z;
    
    private static SynchronizeMonitor inputBarrierMonitor = Main.inputBarrierMonitor;
    private static SynchronizeMonitor maxBarrierMonitor = Main.maxBarrierMonitor;
    private static SynchronizeMonitor computeBarrierMonitor = Main.computeBarrierMonitor;
    private static ResourceMonitor<Matrix> mcCopyMonitor = Main.mcCopyMonitor;
    private static ResourceMonitor<Matrix> mkCopyMonitor = Main.mkCopyMonitor;
    private static ResourceMonitor<Integer> zCopyMonitor = Main.zCopyMonitor;
    
	
	public Task(int threadID, int priority){
        this.setPriority(priority);
		this.threadID = threadID;
	}	       
	
	@Override
	public void run() {
	System.out.println("Thread "+threadID+" started!");

	switch (threadID) {
	case 0:
		MB = new Matrix(N, 1);
		MK = new Matrix(N, 1);
		mkCopyMonitor.set(MK);
		break;
	case Main.P-1:
		MC = new Matrix(N, 1);
		mcCopyMonitor.set(MC);
		MO = new Matrix(N, 1);
		Z = new Vector(N, 1);
		//Z.getData()[4] = 10;
		zCopyMonitor.set(Integer.MIN_VALUE);
		break;	
	}
	    	
	inputBarrierMonitor.signalAndWait();
	        
	int zi = Z.max(threadID*H, (threadID+1)*H);
	        
	if (zCopyMonitor.get().intValue() < zi)
	  	zCopyMonitor.set(zi);
	        
	maxBarrierMonitor.signalAndWait();
	        
	Matrix MKi = new Matrix(mkCopyMonitor.get());
	Matrix MCi = new Matrix(mcCopyMonitor.get());
	zi = zCopyMonitor.get().intValue();
	        
	ForkJoinPool pool = new ForkJoinPool(4); 
	pool.invoke(new ParallelFor(threadID*H, (threadID+1)*H, MCi, MKi, zi));
	
	computeBarrierMonitor.signalAndWait();
    if (threadID == 0) {
    	MA.print();
    }
            
	System.out.println("Thread "+threadID+" finished!");
	}
	
	@SuppressWarnings("serial")
	private class ParallelFor extends RecursiveAction {
		
		private int from;
		private int to;
			
		private Matrix MC;
		private Matrix MK;
		private int z;
	
		public final int TASK_LEN = N/4;
	
		public ParallelFor(int from, int to, Matrix MC, Matrix MK, int z) {
			this.from = from;
			this.to = to;
			this.MC = MC;
			this.MK = MK;
			this.z = z;
		}

		@Override
		protected void compute() {
			int len = to - from;
			if (len < TASK_LEN) {
				work(from, to, MC, MK, z);
			} else{
				int mid = (from + to) >>> 1;
				ForkJoinTask<Void> parallelFor1 = new ParallelFor(from, mid, MC, MK, z).fork();
				ForkJoinTask<Void> parallelFor2 = new ParallelFor(mid, to, MC, MK, z).fork();
				parallelFor1.join();
				parallelFor2.join();
				
			}
		}
	}
	
    private void work(int from, int to, Matrix MC, Matrix MK, int z){
    	
    	for (int i = from; i < to; i++)
        {
            for (int j = 0; j < N; j++)
            {
                int bufmbmc = 0;
                int bufmomk = 0;
                for (int k = 0; k < N; k++)
                {
                    bufmbmc += MB.getData()[i][k] * MC.getData()[k][j];
                    bufmomk += MO.getData()[i][k] * MK.getData()[k][j];
                }
                MA.getData()[i][j]=bufmbmc+bufmomk*z;
            }
        }
    }
}