
# require(lmrob)
# require(penseinit)
# require(quantreg)
 

mscale <- function(u, tol, delta, max.it=100) {
  # M-scale of a sample u  
  # tol: accuracy
  # delta: breakdown point (right side)
  # Initial 
  s0 <- median(abs(u))/.6745
  err <- tol + 1
  it <- 0
  while( (err > ep) & ( it < max.it) ) {
    it <- it+1
    s1 <- sqrt( s0^2 * mean(rho.bi((u/s0),1.547)) / delta )
    err <- abs(s1-s0)/s0
    s0 <- s1
  }
  return(s0)
}



covdcml=function(resLS,res0,C,sig0,t0,p,n)
##Computation of the asymptotic covariance matrix of the DCML estimator
{t0=1-t0
c=mean(psibs(res0/sig0,3.44)*resLS)
a1=mean(psibs(res0/sig0,3.44)^2)
b=mean(psibspri(res0/sig0,3.44))
deltasca=0.5*(1-(p/n))
a2=mscale(resLS,.00001,deltasca)^2
tuti=t0^2*sig0^2*a1/b^2 + a2*(1-t0)^2 +2*t0*(1-t0)*sig0*c/b
V=tuti*solve(C)
V
}


rho <- function(u, cc=1.5477) {
  w <- as.numeric( abs(u) <= cc )
  v <- (u^2/(2)*(1-(u^2/(cc^2))+(u^4/(3*cc^4))))*w +(1-w)*(cc^2/6)
  v <- v*6/cc^2
  return(v)
}

# rhoint <- function(e)
#   return(integrate(function(a, cc) rho(a, cc)*dnorm(a), cc=e, lower=-Inf, upper=+Inf)$value)
# 
# uniroot( function(e) (rhoint(e)-.5), lower=1, upper=2)$root
# 

rhoprime <- function(r, cc) { 
  # bisquare rho' = psi function
  r <- r / cc
  gg <- r*(1-r^2)^2*as.numeric(abs(r)<=1)
  return(gg)
}

rhoprime2 <- function(r, cc) {
  #Derivative of the bisquare psi function
  r <- r/cc
  gg <- (1-r^2)*(1-5*r^2)*as.numeric(abs(r)<=1)/cc
  return(gg)
}

# effi <- function(e) {
#   a <- integrate(function(a, cc) (rhoprime(a, cc)^2)*dnorm(a), cc=e, lower=-Inf, upper=+Inf)$value
#   b <- integrate(function(a, cc) rhoprime2(a, cc)*dnorm(a), cc=e, lower=-Inf, upper=+Inf)$value
#   return( 1/(a/b^2) ) # efficiency!
# }
# 
# uniroot( function(e) (effi(e)-.85), lower=3, upper=4)$root

  psibs=function(t,c)  
# bisquare psi function
 {r=t/c
 gg=r*(1-r^2)^2*(abs(r)<=1)
 gg
}
        
 
 psibspri=function (t,c)   
#Derivative of the bisquare psi function
{ r=t/c
 gg=(1-r^2)*(1-5*r^2)*(abs(r)<=1)/c
gg
}
        
 MMPY <- function(X, y, control, mf) {
   # This function will be called from lmrob, so control will be valid
   # X will already contain a column of ones if needed
   #Compute an MM-estimator taking as initial Pe?a Yohai
   #INPUT
   #X nxp matrix, where n is the number of observations and p the number of  columns
   #y vector of dimension  n with the responses
   #
   #OUTPUT
   #outMM output of the MM estimator (lmrob) with 85% of efficiency and PY as initial
   #
   # 
   # cont1=lmrob.control(tuning.psi=3.44)
   n <- nrow(X)
   p <- ncol(X)
   # if(intercept==TRUE )
   # { p=p+1}
   dee <- .5*(1-(p/n))
   print(dee)
   a <- pyinit(X=X, y=y, intercept=FALSE, deltaesc=dee, 
               cc.scale=control$tuning.chi, 
               prosac=.5, clean.method='threshold', C.res = 2, prop=.2, 
               py.nit = 20, en.tol=1e-5, mscale.rho.fun='bisquare')
   betapy2 <- a$initCoef[,1]
   sspy2 <- a$objF[1]
   S.init <- list(coef=betapy2, scale=sspy2)
   print('In MMPY')
   print(paste0('method: ', control$method))
   print('calling lmrob.fit')
   control$method <- 'M'
   outMM <- lmrob.fit(X, y, control, init=S.init, mf=mf)
   # if(intercept==TRUE)
   #    { outMM=lmrob(y~X, control=cont1,init=uu)}else
   #    { outMM=lmrob(y~X-1, control=cont1,init=uu)}
   return(outMM)
 }

old.MMPY <- function(X, y, intercept=FALSE) {
   # X will already contain a column of ones if needed
   #Compute an MM-estimator taking as initial Pe?a Yohai
   #INPUT
   #X nxp matrix, where n is the number of observations and p the number of  columns
   #y vector of dimension  n with the responses
   #
   #OUTPUT
   #outMM output of the MM estimator (lmrob) with 85% of efficiency and PY as initial
   #
   # 
  
   cont1 <- lmrob.control(tuning.chi = 1.5477, bb = 0.5, tuning.psi = 3.4434)
   n <- nrow(X)
   p <- ncol(X)
   if(intercept)
   { p=p+1}
   dee <- .5*(1-(p/n))
   print(dee)
   a <- pyinit(X=X, y=y, intercept=FALSE, deltaesc=dee, 
               cc.scale=cont1$tuning.chi, 
               prosac=.5, clean.method='threshold', C.res = 2, prop=.2, 
               py.nit = 20, en.tol=1e-5, mscale.rho.fun='bisquare')
   betapy2 <- a$initCoef[,1]
   sspy2 <- a$objF[1]
   S.init <- list(coef=betapy2, scale=sspy2)
   print('In old.MMPY')
   print(paste0('method: ', cont1$method))
   # print('calling lmrob.fit')
   # control$method <- 'M'
   # outMM <- lmrob.fit(X, y, control, init=S.init, mf=mf)
   if(intercept)
      { outMM=lmrob(y~X, control=cont1,init=S.init)}else
      { outMM=lmrob(y~X-1, control=cont1,init=S.init)}
   return(outMM)
 }
 
  

DCML_FINAL=function(X,y, outMM, intercept=TRUE)
#INPUT
#X nxp matrix, where n is the number of observations and p the number of  columns, the 1's of the intercept are not included
#y vector of dimension  n with the responses
#intercept FALSE the regression does not includes intercept, TRUE, the regression includes intercept
#outMM output of MMPY or SM_PY
#OUTPUT
#coef vector of coefficients, the first element is the intercept when there is one
#cov covariance matrix of the coefficients
#resid vector of residuals
#weight  vector with weights that the MMestimator assigns to every observation
#sigma standad error of errot term
 

{
XX=X
n=nrow(X)
p=ncol(X)
if(intercept==TRUE )
    {XX=cbind(rep(1,n),X)
    p=p+1}
cont1=lmrob.control(tuning.psi=3.44)
if(intercept==TRUE)
   {out3=lm(y~X)}else
   {out3=lm(y~X-1)}
betaLS=out3$coeff
resLS=out3$resid
dee=.5*(1-(p/n))
beta0=outMM$coeff
weight=outMM$rweights
residuos=outMM$resid
sigma=mscale(residuos,.00001,dee)
##Begin the computation of the DCML
deltas=.3*p/n 
C=t(XX)%*%diag(weight)%*%XX/sum(weight) 	
d=(beta0-betaLS)%*%C%*%(beta0-betaLS)
d=d/sigma^2
t0=min(1,sqrt(deltas/d))
beta1=t0*betaLS+(1-t0)*beta0
V=covdcml (resLS,residuos,C,sigma,t0,p,n)/n	
resid=y-XX%*%beta1
sigma=mscale(resid, .00001,dee) 
out=list(coef=beta1, cov=V, resid=resid,   sigma=sigma )
out
}

 SM_PY=function(y,X,Z, intercept=TRUE)
#old penayohai2 Compute an MM-estimator for mixed model using lmrob and taking as initial an SM estimator based on Pe?a-Yohai
#INPUT
#y response vector
#X matrix of continuous covariables
#Z matrix of  qualitative covariables
#OUTPUT
#out_lmrob output of lmrob take as initial a S-M estimator for mixed models computed with Pe?a Yohai
{
n=nrow(X)
q=ncol(Z)
p=ncol(X)
hh1=1+intercept
hh2=p+intercept
hh3=q+intercept
gamma=matrix(0, (q+intercept),p)
#Eliminate Z from X by L1 regression , obtaining a matrix X1
for( i in 1:p)
    {gamma[,i]=rq(X[,i]~Z)$coeff}
X1=X-Z%*%gamma[hh1:hh3,]
# We compute an MMestimator  ny lmrob using as covariables X1 as initial Pe?a Yohai
dee=.5*(1-((p+1)/n))
out= pyinit(intercept=intercept,X=X1, y=y, deltaesc=dee, cc.scale=1.547, prosac=.5,clean.method="threshold", C.res = 2, prop=.2, py.nit = 20, en.tol=1e-5)
betapy=out$initCoef[,1]
sspy=out$objF[1]
uu=list(coeff=betapy,scale=sspy)
out0=lmrob(y1~X1, control=cont1,init=uu) 
beta=out0$coeff
# after eliminating the influence of X1 we make an L1 regression using as covariables Z
y1=y-X1%*%beta[hh1:hh2]
fi=rq(y1~Z)$coeff
# retransform the coefficients to the original matrices X and Z
oo=NULL
if(intercept==TRUE)
oo=fi[1]
tt=gamma[hh1:hh3,]
if(p==1)
tt=matrix(tt,q,p)
beta00=c(oo,beta[hh1:hh2],fi[hh1:hh3]-  tt%*%beta[hh1:hh2])
res=y1-fi[1]-Z%*%fi[hh1:hh3]
dee=.5*(1-((p+q+intercept)/n))
ss=mscale(res,.0001,dee)
uu=list(coeff=beta00,scale=ss)
XX=cbind(X,Z)
#Compute the MMestimator using lmrob
out_lmrob=lmrob(y~XX,control=cont1,init=uu)$coeff
out_lmrob  
}






 
 