load("pkg")
Pkg.init()
Pkg.add("Distributions")
Pkg.update("Distributions")
Pkg.add("DataFrames")

require("../../.julia/Distributions.jl/src/Distributions.jl")
################################
model = quote
    x::real
    x ~ Normal(0, 1.0)  
end
model = :(x::real ; x ~ Normal(0, 1))
model = :(x::real ; x ~ Uniform(0, 1))
model = :(x::real ; x ~ Weibull(1, 1))

include("../src/SimpleMCMC.jl")

function summary(res)
    println("accept $(mean(res[:,2])), mean : $(mean(res[:,3])), std : $(std(res[:,3]))")
end

summary(SimpleMCMC.simpleRWM(model, 10000, 0, [0.5]))
summary(SimpleMCMC.simpleHMC(model, 100000, 0, [0.9], 2, 0.9))
summary(SimpleMCMC.simpleNUTS(model, 10000, 0, [0.5]))

dlmwrite("c:/temp/dump.txt", res)

########################################################################
myf, np = SimpleMCMC.buildFunctionWithGradient(model)
eval(myf)

res = SimpleMCMC.simpleHMC(model,100, 5, 1.5, 10, 0.1)

l0, grad = __loglik(ones(2))
[ [ (beta=ones(2) ; beta[i] += 0.01 ; ((__loglik(beta)[1]-l0)*100)::Float64) for i in 1:2 ] grad]


################################################

Y = [1,2,3]
model = :(x::real(3); y=Y; y[2] = x[1] ; y ~ TestDiff())

## ERROR : marche pas, notamment parce que la subst des noms de variable ne fonctionne pas

################################


model = quote
    x::real
    x ~ Normal(0,1)
end

res = SimpleMCMC.simpleRWM(model, 10000)
res2 = {:llik=>[1,2,3,3,4], :accept=>[0,1,0,1,0,1,1,1,0,0,0],
:x=>[4,4,4,5,5,5,6,6,3,22,3]}
mean(res2[:accept])
dump(res2)

res = SimpleMCMC.simpleHMC(model, 10000, 5000, 3, 0.5)
[ (mean(res[:,i]), std(res[:,i])) for i in 3:size(res,2)]
=======
dump(:(b = x==0 ? x : y))
dump(:(x==0 ))
dump(:(x!=0 ))
dump(:(x!=0 ))


################################


dat = dlmread("c:/temp/ts.txt")
size(dat)

tx = dat[:,2]
dt = dat[2:end,1] - dat[1:end-1,1]

model = quote
    mu::real
    tau::real
    sigma::real

    tau ~ Weibull(2,1)
    sigma ~ Weibull(2, 0.01)
    mu ~ Uniform(0,1)

    f2 = exp(-dt / tau / 1000)
    resid = tx[2:end] - tx[1:end-1] .* f2 - mu * (1.-f2)
    resid ~ Normal(0, sigma^2)
end

res = SimpleMCMC.simpleRWM(model, 10000, 1000, [0.5, 30, 0.01])
res = SimpleMCMC.simpleRWM(model, 101000, 1000)
mean(res[:,2])

res = SimpleMCMC.simpleHMC(model, 10000, 500, [0.5, 0.01, 0.01], 2, 0.001)
res = SimpleMCMC.simpleHMC(model, 1000, 1, 0.1)
mean(res[:,2])

dlmwrite("c:/temp/dump.txt", res)
mean(Weibull(2,1))

###
model = quote
    mu::real
    scale::real

    scale ~ Weibull(2,1)
    mu ~ Uniform(0,1)

    f2 = exp(-dt * scale)
    resid = tx[2:end] - tx[1:end-1] .* f2 - mu * (1.-f2)
    resid ~ Normal(0, 0.01)
end

res = SimpleMCMC.simpleRWM(model, 10000, 500, [0.5, 0.01])
res = SimpleMCMC.simpleRWM(model, 101000, 1000)
mean(res[:,2])

res = SimpleMCMC.simpleHMC(model, 10000, 500, [0.5, 0.01], 5, 0.001)
res = SimpleMCMC.simpleHMC(model, 1000, 1, 0.1)
mean(res[:,2])

dlmwrite("c:/temp/dump.txt", res)
