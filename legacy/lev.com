      integer, parameter :: nlev = 33
      real depth(nlev)
      data  depth/
     &  0,10,20,30,50,75,100,125,150,200,250,300,400,500,600,700,800
     &  ,900,1000,1100,1200,1300,1400,1500,1750,2000,2500,3000,3500
     &  ,4000,4500,5000,5500/

