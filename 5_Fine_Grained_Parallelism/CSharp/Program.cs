using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSharp
{
    class Program
    {
        //System parameters
        public const int P = 50;
        public const int MaxElevementsForShow = 20;

        //diagnostic parameters
        static int accuracy = 1;
        static int startDimension = 1500;
        static int finishDimension = 1500;
        static int stepDimension = 500;

        /*//output files
        private static StreamWriter oneProcFile =
            new StreamWriter(@"D:\projects\ParallelTest\ParallelTest\CSharp\oneproc.txt", true);
        private static StreamWriter coarseGrainedParallelismFile =
            new StreamWriter(@"D:\projects\ParallelTest\ParallelTest\CSharp\coarseGrainedParallelism.txt", true);
        private static StreamWriter mediumGrainedParallelismFile =
            new StreamWriter(@"D:\projects\ParallelTest\ParallelTest\CSharp\mediumGrainedParallelism.txt", true);
        private static StreamWriter fineGrainedParallelismFile =
            new StreamWriter(@"D:\projects\ParallelTest\ParallelTest\CSharp\fineGrainedParallelism.txt", true);
        private static StreamWriter withoutCopyFile =
            new StreamWriter(@"D:\projects\ParallelTest\ParallelTest\CSharp\withoutCopy.txt", true);*/
        static void Main(string[] args)
        {
            Console.WriteLine("C# started");

            for(int dimension = startDimension; dimension <= finishDimension; dimension+=stepDimension)
            {
                double timeCoarse = 0;
                double timeMedium = 0;
                double timeFine = 0;
                double timeWithoutCopy = 0;
                for (int j = 0; j < accuracy; j++)
                {
                    /*CoarseGrainedParallelism coarseGrainedParallelism = new CoarseGrainedParallelism(dimension);
                    coarseGrainedParallelism.Compute();
                    timeCoarse += coarseGrainedParallelism.Time;*/

                    //MediumGrainedParallelism mediumGrainedParallelism = new MediumGrainedParallelism(dimension);
                    //mediumGrainedParallelism.Compute();
                    //timeMedium += mediumGrainedParallelism.Time;

                    FineGrainedParallelism fineGrainedParallelism = new FineGrainedParallelism(dimension);
                    fineGrainedParallelism.Compute();
                    timeFine += fineGrainedParallelism.Time;

                    //WithoutCopy withoutCopy = new WithoutCopy(dimension);
                    //withoutCopy.Compute();
                    //timeWithoutCopy += withoutCopy.Time;
                }
                //Console.WriteLine("C: Proc: " + P + " Dim: " + dimension + " Time: " + timeCoarse / accuracy);
                //Console.WriteLine("M: Proc: " + P + " Dim: " + dimension + " Time: " + timeMedium / accuracy);
                Console.WriteLine("F: Proc: " + P + " Dim: " + dimension + " Time: " + timeFine / accuracy);
                //Console.WriteLine("W: Proc: " + P + " Dim: " + dimension + " Time: " + timeWithoutCopy / accuracy);

                /*coarseGrainedParallelismFile.WriteLine(dimension);
                coarseGrainedParallelismFile.WriteLine(timeCoarse / accuracy);
                mediumGrainedParallelismFile.WriteLine(dimension);
                mediumGrainedParallelismFile.WriteLine(timeMedium / accuracy);
                fineGrainedParallelismFile.WriteLine(dimension);
                fineGrainedParallelismFile.WriteLine(timeFine / accuracy);
                withoutCopyFile.WriteLine(dimension);
                withoutCopyFile.WriteLine(timeWithoutCopy / accuracy);*/
            }
            /*coarseGrainedParallelismFile.Close();
            mediumGrainedParallelismFile.Close();
            fineGrainedParallelismFile.Close();
            withoutCopyFile.Close();*/

            /*
            for (int dimension = startDimension; dimension <= finishDimension; dimension += stepDimension)
            {
                double timeOneProc = 0;
                for (int j = 0; j < accuracy; j++)
                {
                    OneProc oneProc = new OneProc(dimension);

                    oneProc.Compute();

                    timeOneProc += oneProc.Time;
                }
                Console.WriteLine("O: Proc: " + P + " Dim: " + dimension + " Time: " + timeOneProc / accuracy);

                //oneProcFile.WriteLine(dimension);
                //oneProcFile.WriteLine(timeOneProc / accuracy);
            }
            //oneProcFile.Close();
            */
            Console.WriteLine("C# finished");
            Console.ReadKey();
        }
    }
}
