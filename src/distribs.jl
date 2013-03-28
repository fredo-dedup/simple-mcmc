##########################################################################################
#
#    Definition of distributions
#
##########################################################################################

########### distributions using libRmath ######### 
_jl_libRmath = dlopen("libRmath")

# TODO : use the signature length parameter 
for d in {(:Normal,  	"dnorm4",	2),
		  (:Weibull, 	"dweibull", 2),
		  (:Uniform, 	"dunif", 	2)}

	sig = tuple([Float64 for i in 1:(d[3]+1)]..., Int32)
	fsym = symbol("logpdf$(d[1])")

	eval(quote

		function ($fsym)(a::Real, b::Real, x::Real)
			local res
			res = ccall(dlsym(_jl_libRmath, $(d[2])), Float64, 
				(Float64, Float64, Float64, Int32), 
					x, a, b, 1)
			if res == -Inf
				throw("give up eval")
			elseif res == NaN
				error(string("calling ", $fsym, "with $x, $a, $b returned an error"))
			else
				return(res)
			end
		end

		function ($fsym)(a::Union(Real, AbstractArray), 
			             b::Union(Real, AbstractArray), 
			             x::Union(Real, AbstractArray))
			local res, acc

			acc = 0.0
			for i in 1:max(length(a), length(b), length(x))
				res = ($fsym)(next(a,i)[1], next(b,i)[1], next(x,i)[1])
				acc += res
			end
			acc
		end

	end) 

end

########## locally defined distributions #############

function logpdfBernoulli(prob::Real, x::Real)
	prob > 1. || prob < 0. ? error("calling Bernoulli with prob > 1. or < 0.") : nothing
	if x == 0.
		prob == 1. ? throw("give up eval") : return(log(1. - prob))
	elseif x == 1.
		prob == 0. ? throw("give up eval") : return(log(prob))
	elseif
	 	error("calling Bernoulli with variable other than 0 or 1 (false or true)")
	end
end

for d in [:Bernoulli]
	fsym = symbol("logpdf$d")

	eval(quote
		function ($fsym)(a::Union(Real, AbstractArray), x::Union(Real, AbstractArray))
			res = 0.0
			for i in 1:max(length(a), length(x))
				res += ($fsym)(next(a,i)[1], next(x,i)[1])
			end
			res
		end
	end) 
end

############# dummy distrib for testing ############

logpdfTestDiff(x) = sum([x]) 
