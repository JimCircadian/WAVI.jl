"""
    driver(n_timesteps)

Driver routine for WAVI. Defines parameters, initialises state, and runs n_timesteps.
"""
function driver(n_timesteps=1000)

    #Number of timesteps between plots
    n_steps_plot=100

    # MISMIP+
    nx = 64
    ny = 8
    nσ = 4
    x0 = 0.0
    y0 = -40000.0
    dx = 10000.0
    dy = 10000.0
    dt = 1.0
    xx=[x0+(i-0.5)*dx for i=1:nx, j=1:ny]
    yy=[y0+(j-0.5)*dy for i=1:nx, j=1:ny]
    starting_thickness=100.0.*ones(nx,ny)
    accumulation_rate=0.3

    #Model domain mask on h-grid
    h_mask=trues(nx,ny)

    #Homogenous Dirichlet boundary conditions
    u_iszero=falses(nx+1,ny)
    u_iszero[1,:].=true
    v_iszero=falses(nx,ny+1)
    v_iszero[:,1].=true
    v_iszero[:,end].=true

    #MISMIP+ bed elevation
    function bed_elev_function(x,y)
        xbar = 300000.0
        b0 = -150.0; b2 = -728.8; b4 = 343.91; b6 = -50.75
        wc = 24000.0; fc = 4000.0; dc = 500.0
        bx(x)=b0+b2*(x/xbar)^2+b4*(x/xbar)^4+b6*(x/xbar)^6
        by(y)= dc*( (1+exp(-2(y-wc)/fc))^(-1) + (1+exp(2(y+wc)/fc))^(-1) )
        b = max(bx(x) + by(y), -720.0)
        return b
    end
    bed_elevation=bed_elev_function.(xx,yy)

    maxiter_picard=1 #No need for Picard iteration if runninng to steady state

    params = Params(nx=nx,
                    ny=ny,
                    nσ=nσ,
                    x0=x0,
                    y0=y0,
                    dx=dx,
                    dy=dy,
                    dt=dt,
                    bed_elevation=bed_elevation,
                    starting_thickness=starting_thickness,
                    accumulation_rate=accumulation_rate,
                    h_mask=h_mask,
                    u_iszero=u_iszero,
                    v_iszero=v_iszero,
                    maxiter_picard=maxiter_picard
                    )

    wavi=start(params)

    for i=1:n_timesteps
        run!(wavi)
        print("\r")
        print("Completed: ",round(i*params.dt),
              " years (", round(100.0*i/n_timesteps),"%)")
        if mod(i,n_steps_plot)==0
          #IJulia.clear_output(true)
          plot_output(wavi)
        end
    end

    return wavi
end

driver()