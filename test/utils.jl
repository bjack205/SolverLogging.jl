@test SolverLogging.getwidth("%0.24e") == -1
@test SolverLogging.getwidth("%01.24e") == 1
@test SolverLogging.getwidth("%0112.24e") == 112
@test SolverLogging.getwidth("%-1.24e") == 1
@test SolverLogging.getwidth("012%-13.24e") == 13
@test SolverLogging.getwidth("%.24e") == -1
@test SolverLogging.getwidth("%e") == -1
@test SolverLogging.getwidth("%5d") == 5 
@test SolverLogging.getwidth("%512d") == 512
@test SolverLogging.getwidth("%0512d") == 512
