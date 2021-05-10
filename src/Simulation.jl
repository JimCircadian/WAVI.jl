struct Simulation{T <: Real,N <: Int,R <: Real} <: AbstractSimulation{T,N,R}
    model::Model{T,N}
    timestepping_params::TimesteppingParams{T,N}
    output_params::OutputParams{T,R}
    clock::Clock{T,N}
end

function Simulation(;
                    model = nothing,
                    timestepping_params = nothing,
                    output_params = Output_params())

    (model === nothing) || Throw(ArgumentError("You must specify a model input"))
    (timestepping_params === nothing) || Throw(ArgumentError("You must specify a model input"))

    #initialize the clock
    clock = Clock(n_iter = 0, time = 0.0)

    #initialize number of steps in output
    if output.out_freq !== Inf #set the output number of timesteps, if it has been specifies
        n_iter_out = round(Int, output.out_freq/timestepping_params.dt) #compute the output timestep
        output = @set output.n_iter_out = n_iter_out
    end

    return Simulation(model, timestepping_params, output_params, clock)
end